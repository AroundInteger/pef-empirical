"""Phase 2: the inferential PEF (STRATEGY.md Section 2).

2a  P6: Var(delta_hat unpaired) / Var(delta_hat paired) = eta.
2b  Power: paired t vs Welch, empirical vs noncentral-t theory.
2c  Estimator eta_hat = (s_A^2 + s_B^2) / s_D^2: confidence-interval coverage for
    percentile bootstrap, BCa, delta method on log(eta), delta method on
    atanh(rho_eff).
2d  Cross-check of our delta-method variance against Lin (1989) for the
    concordance correlation with zero location shift.
Outputs: results/E2a_variance_ratio.csv, E2b_power.csv, E2c_coverage.csv, E2d_lin.csv
"""
import os
import sys
import itertools
import numpy as np
import pandas as pd
from scipy import stats
from scipy.special import ndtri, ndtr

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from pef import eta, rho_eff  # noqa
from pef.runtime import pool, scale  # noqa

Z975 = stats.norm.ppf(0.975)


def cov2(kappa, rho):
    sB = np.sqrt(kappa)
    return np.array([[1.0, rho * sB], [rho * sB, kappa]])


# ------------------------------------------------------------- 2a variance ratio
def e2a(reps=None, n=30, seed=1):
    reps = reps or scale(200_000, 5_000)
    rng = np.random.default_rng(seed)
    rows = []
    for kappa, rho in itertools.product([1, 4, 0.25], [-0.8, -0.3, 0, 0.4, 0.8, 0.95]):
        C = cov2(kappa, rho)
        L = np.linalg.cholesky(C)
        X = rng.standard_normal((reps, n, 2)) @ L.T          # paired samples
        d_paired = X[..., 0].mean(1) - X[..., 1].mean(1)
        Y = rng.standard_normal((reps, n, 2)) * np.sqrt([1, kappa])   # independent
        d_unp = Y[..., 0].mean(1) - Y[..., 1].mean(1)
        ratio = d_unp.var() / d_paired.var()
        # SE of variance ratio (both chi-square-like): rel SE ~ sqrt(2/reps) each
        se = ratio * np.sqrt(4 / reps)
        rows.append(dict(kappa=kappa, rho=rho, eta_theory=eta(kappa, rho),
                         ratio_mc=ratio, se=se, z=(ratio - eta(kappa, rho)) / se))
    return pd.DataFrame(rows)


# ------------------------------------------------------------- 2b power
def e2b(reps=None, seed=2):
    reps = reps or scale(40_000, 2_000)
    rng = np.random.default_rng(seed)
    rows = []
    for n, kappa, rho, d in itertools.product([10, 20, 50], [1, 4], [-0.5, 0, 0.5, 0.8], [0.3, 0.6]):
        C = cov2(kappa, rho)
        L = np.linalg.cholesky(C)
        X = rng.standard_normal((reps, n, 2)) @ L.T
        X[..., 0] += d                                        # delta = d * sigma_A
        D = X[..., 0] - X[..., 1]
        t_p = D.mean(1) / (D.std(1, ddof=1) / np.sqrt(n))
        crit_p = stats.t.ppf(0.975, n - 1)
        pow_p = np.mean(np.abs(t_p) > crit_p)
        sD = np.sqrt(1 + kappa - 2 * np.sqrt(kappa) * rho)
        ncp_p = d * np.sqrt(n) / sD
        th_p = stats.nct.sf(crit_p, n - 1, ncp_p) + stats.nct.cdf(-crit_p, n - 1, ncp_p)
        # Welch on independent samples of size n each
        Y = rng.standard_normal((reps, n, 2)) * np.sqrt([1, kappa])
        Y[..., 0] += d
        res = stats.ttest_ind(Y[..., 0], Y[..., 1], axis=1, equal_var=False)
        pow_w = np.mean(res.pvalue < 0.05)
        df_w = (1 + kappa) ** 2 * (n - 1) / (1 + kappa ** 2)     # population Satterthwaite
        ncp_w = d * np.sqrt(n) / np.sqrt(1 + kappa)
        cw = stats.t.ppf(0.975, df_w)
        th_w = stats.nct.sf(cw, df_w, ncp_w) + stats.nct.cdf(-cw, df_w, ncp_w)
        se = lambda p: np.sqrt(p * (1 - p) / reps)  # noqa
        rows.append(dict(n=n, kappa=kappa, rho=rho, d=d, eta=eta(kappa, rho),
                         power_paired_mc=pow_p, power_paired_theory=th_p,
                         z_paired=(pow_p - th_p) / max(se(th_p), 1e-12),
                         power_welch_mc=pow_w, power_welch_theory_approx=th_w,
                         z_welch=(pow_w - th_w) / max(se(th_w), 1e-12)))
    return pd.DataFrame(rows)


# ------------------------------------------------------------- 2c CI coverage
def suff(X):
    """Sample covariance pieces along axis -2 (observations)."""
    Xc = X - X.mean(-2, keepdims=True)
    m = X.shape[-2]
    s11 = (Xc[..., 0] ** 2).sum(-1) / (m - 1)
    s22 = (Xc[..., 1] ** 2).sum(-1) / (m - 1)
    s12 = (Xc[..., 0] * Xc[..., 1]).sum(-1) / (m - 1)
    return s11, s22, s12


def reff_hat(s11, s22, s12):
    return 2 * s12 / (s11 + s22)


def delta_var_reff(s11, s22, s12, n):
    """Asymptotic Var(rho_eff_hat) under bivariate normality, plug-in."""
    T = s11 + s22
    g = np.stack([-2 * s12 / T ** 2, -2 * s12 / T ** 2, 2 / T], -1)
    V = np.empty(s11.shape + (3, 3))
    V[..., 0, 0] = 2 * s11 ** 2
    V[..., 1, 1] = 2 * s22 ** 2
    V[..., 2, 2] = s11 * s22 + s12 ** 2
    V[..., 0, 1] = V[..., 1, 0] = 2 * s12 ** 2
    V[..., 0, 2] = V[..., 2, 0] = 2 * s11 * s12
    V[..., 1, 2] = V[..., 2, 1] = 2 * s22 * s12
    return np.einsum("...i,...ij,...j->...", g, V, g) / n


def coverage_cell(args):
    n, kappa, rho, R, B, seed = args
    rng = np.random.default_rng(seed)
    C = cov2(kappa, rho)
    L = np.linalg.cholesky(C)
    true_eta = eta(kappa, rho)
    true_r = rho_eff(kappa, rho)
    hits = dict(percentile=0, bca=0, delta_log=0, delta_atanh=0)
    widths = {k: [] for k in hits}
    for _ in range(R):
        X = rng.standard_normal((n, 2)) @ L.T
        s = suff(X)
        r_hat = reff_hat(*s)
        e_hat = 1 / (1 - r_hat)
        # bootstrap (operate on rho_eff, monotone map to eta)
        idx = rng.integers(0, n, (B, n))
        rb = reff_hat(*suff(X[idx]))
        lo, hi = np.quantile(rb, [0.025, 0.975])
        ci = {"percentile": (lo, hi)}
        # BCa via jackknife acceleration
        z0 = ndtri(np.clip(np.mean(rb < r_hat), 1 / B, 1 - 1 / B))
        jk = np.array([reff_hat(*suff(np.delete(X, i, 0))) for i in range(n)])
        dm = jk.mean() - jk
        a = (dm ** 3).sum() / (6 * ((dm ** 2).sum()) ** 1.5 + 1e-300)
        adj = lambda zq: ndtr(z0 + (z0 + zq) / (1 - a * (z0 + zq)))  # noqa
        ci["bca"] = tuple(np.quantile(rb, [adj(-Z975), adj(Z975)]))
        v = delta_var_reff(*s, n)
        # delta on log(eta) = -log(1 - r)
        se_log = np.sqrt(v) / (1 - r_hat)
        le = np.log(e_hat)
        ci["delta_log"] = (1 - np.exp(-(le - Z975 * se_log)), 1 - np.exp(-(le + Z975 * se_log)))
        # delta on atanh(rho_eff)
        se_z = np.sqrt(v) / (1 - r_hat ** 2)
        zz = np.arctanh(np.clip(r_hat, -0.999999, 0.999999))
        ci["delta_atanh"] = (np.tanh(zz - Z975 * se_z), np.tanh(zz + Z975 * se_z))
        for k, (a_, b_) in ci.items():   # intervals on rho_eff scale; same coverage for eta
            hits[k] += a_ <= true_r <= b_
            widths[k].append(1 / (1 - min(b_, 0.999999)) - 1 / (1 - a_))
    out = []
    for k in hits:
        cov = hits[k] / R
        out.append(dict(n=n, kappa=kappa, rho=rho, eta=true_eta, method=k, coverage=cov,
                        mc_se=np.sqrt(0.95 * 0.05 / R),
                        median_width_eta=float(np.median(widths[k]))))
    return out


def e2c(R=None, B=None):
    R, B = R or scale(1000, 40), B or scale(999, 199)
    cells = [(n, k, r, R, B, 5000 + i) for i, (n, k, r) in enumerate(
        itertools.product([20, 50, 100, 400], [1, 4], [-0.5, 0.0, 0.3, 0.6, 0.9]))]
    with pool() as pl:
        res = pl.map(coverage_cell, cells)
    return pd.DataFrame([row for cell in res for row in cell])


# ------------------------------------------------------------- 2d Lin cross-check
def e2d():
    rows = []
    for kappa, rho in itertools.product([1, 2, 4, 9], [-0.6, 0.2, 0.5, 0.8, 0.95]):
        sB = np.sqrt(kappa)
        s11, s22, s12 = 1.0, kappa, rho * sB
        rc = rho_eff(kappa, rho)
        ours = delta_var_reff(np.array(s11), np.array(s22), np.array(s12), 1.0) / (1 - rc ** 2) ** 2
        # Lin (1989), variance of atanh(rho_c_hat) times n, with zero location shift (u = 0)
        lin = (1 - rho ** 2) * rc ** 2 / ((1 - rc ** 2) * rho ** 2)
        rows.append(dict(kappa=kappa, rho=rho, rho_eff=rc, n_var_atanh_ours=float(ours),
                         n_var_atanh_lin=lin, rel_diff=float(ours / lin - 1)))
    return pd.DataFrame(rows)


if __name__ == "__main__":
    os.makedirs("results", exist_ok=True)
    which = sys.argv[1:] or ["a", "b", "brep", "c", "d"]
    if "d" in which:
        d = e2d(); d.to_csv("results/E2d_lin.csv", index=False); print(d.round(6).to_string(index=False))
    if "a" in which:
        a = e2a(); a.to_csv("results/E2a_variance_ratio.csv", index=False); print(a.round(4).to_string(index=False))
    if "b" in which:
        b = e2b(); b.to_csv("results/E2b_power.csv", index=False)
        print(b[["n", "kappa", "rho", "d", "eta", "power_paired_mc", "power_paired_theory", "z_paired",
                 "power_welch_mc", "power_welch_theory_approx", "z_welch"]].round(3).to_string(index=False))
    if "brep" in which:   # independent replication of 2b, fresh seed, 2.5x reps
        b = e2b(reps=scale(100_000, 2_000), seed=99); b.to_csv("results/E2b_power_rep.csv", index=False)
        print("2b replication written")
    if "c" in which:
        c = e2c(); c.to_csv("results/E2c_coverage.csv", index=False); print("coverage cells:", len(c))
