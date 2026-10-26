"""Phase 5 stress grid.

Two design points: the E3 aligned base point, and the coefficient asymmetry
whose probit crossover is n* = 300. For each law the second-moment targets of
Theorems B and C are the covariances of that law, and Theorem A is the
Gaussian (z, r^2) formula at those same second moments. A survives only when
the pair (features, outcome) is jointly Gaussian.
"""
import os
import sys
import numpy as np
import pandas as pd
from scipy.special import ndtr
from scipy.stats import multivariate_t, gamma
from scipy import stats
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pef import (Params, from_dimensionless, sample, r2, alignment_cos2,
                 reliability_D, population_metrics, rho_eff)
from E2_inference import suff, reff_hat, delta_var_reff

N_REP = 40
N_PER = 2_500
COV_REPS = 400
COV_N = 50
SEED = 20261026
MIS_B = 1.1765592111044554

DESIGNS = {
    "aligned": dict(z=0.0, rho_S=0.2, rho_N=0.6, w=0.5, q=0.8),
    "misaligned": dict(z=0.0, rho_S=0.2, rho_N=0.6, w=0.5, q=0.8, b_ratio=MIS_B),
}


def _params(SS, SN, b, sigma_eps, mu=None):
    mu = np.zeros(2) if mu is None else np.asarray(mu, float)
    return Params(np.asarray(SS, float), np.asarray(SN, float), mu,
                  np.asarray(b, float), float(sigma_eps))


def draw_gaussian(p, n, rng):
    return sample(p, n, rng), p


def draw_t(p, n, rng, nu):
    scale_s = p.Sigma_S * (nu - 2) / nu
    scale_n = p.Sigma_N * (nu - 2) / nu
    S = np.atleast_2d(multivariate_t.rvs(loc=p.mu, shape=scale_s, df=nu, size=n, random_state=rng))
    N = np.atleast_2d(multivariate_t.rvs(loc=np.zeros(2), shape=scale_n, df=nu, size=n, random_state=rng))
    K = S + N
    M = S @ p.b + p.sigma_eps * rng.standard_normal(n)
    return dict(S=S, N=N, K=K, M=M, Y=(M > 0).astype(int)), p


def _gamma_K(p, K):
    sd = np.sqrt(np.diag(p.Sigma_K))
    Z = (K - p.mu) / sd
    U = np.clip(ndtr(Z), 1e-8, 1 - 1e-8)
    return np.column_stack([gamma.ppf(U[:, j], a=2.0, scale=sd[j] / np.sqrt(2.0)) for j in range(2)])


def _spec_from_draw(d):
    """Second-moment summary when the law is not the linear-Gaussian Params."""
    K, M, S = d["K"], d["M"], d["S"]
    SK = np.cov(K.T)
    cross = np.cov(K.T, M)[:2, 2]
    var_M = float(np.var(M, ddof=1))
    beta = np.linalg.solve(SK, cross)
    r2_full = float(beta @ cross / var_M)
    c = np.array([1.0, -1.0])
    cos2 = float((c @ SK @ beta) ** 2 / ((c @ SK @ c) * (beta @ SK @ beta)))
    rel = float(np.var(S @ c, ddof=1) / np.var(K @ c, ddof=1))
    return dict(beta=beta, r=float(np.sqrt(max(r2_full, 0.0))),
                z=float(M.mean() / np.sqrt(var_M)), cos2=cos2, rel=rel)


_GAMMA_PILOT = {}


def draw_gamma(p, n, rng):
    """Gaussian copula, gamma margins, same marginal variances as K. Y stays probit."""
    d = sample(p, n, rng)
    d = dict(d)
    d["K"] = _gamma_K(p, d["K"])
    key = (p.Sigma_K.tobytes(), p.b.tobytes())
    if key not in _GAMMA_PILOT:
        pilot = sample(p, 80_000, np.random.default_rng(SEED + 17))
        pilot = dict(pilot)
        pilot["K"] = _gamma_K(p, pilot["K"])
        _GAMMA_PILOT[key] = _spec_from_draw(pilot)
    return d, _GAMMA_PILOT[key]


def draw_poisson(p, n, rng):
    lam0, lam_a, lam_b = 1.5, 2.0, 2.0
    z0 = rng.poisson(lam0, n)
    zA = rng.poisson(lam_a, n)
    zB = rng.poisson(lam_b, n)
    S = np.column_stack([zA, zB]).astype(float)
    N = np.column_stack([z0, z0]).astype(float)
    M = (zA - zB) + rng.normal(0.0, 1.0, n)
    d = dict(S=S, N=N, K=S + N, M=M, Y=(M > 0).astype(int))
    target = _params([[lam_a, 0], [0, lam_b]], [[lam0, lam0], [lam0, lam0]],
                     [1.0, -1.0], 1.0)
    return d, target


def draw_ordinal(p, n, rng):
    d = sample(p, n, rng)
    y = np.digitize(d["M"], [-0.5, 0.5])
    d = dict(d)
    d["Y"] = (y == 2).astype(int)
    return d, p


def draw_contam(p, n, rng):
    d = sample(p, n, rng)
    K = d["K"].copy()
    m = rng.random(n) < 0.05
    scale = 5.0 * np.sqrt(np.diag(p.Sigma_K))
    K[m] = K[m] + rng.normal(0.0, 1.0, size=(int(m.sum()), 2)) * scale
    d = dict(d)
    d["K"] = K
    d["N"] = K - d["S"]
    extra = np.diag(0.05 * scale ** 2)
    SK = p.Sigma_K + extra
    target = _params(p.Sigma_S, SK - p.Sigma_S, p.b, p.sigma_eps, p.mu)
    return d, target


def draw_repeated(p, n, rng):
    n_teams = 60
    h = rng.integers(0, n_teams, n)
    a = rng.integers(0, n_teams, n)
    a[h == a] = (a[h == a] + 1) % n_teams
    tau2, lam, vA, vB, rho = 1.0, 0.5, 1.0, 1.44, 0.4
    u = rng.normal(0.0, np.sqrt(tau2), n_teams)
    eps = rng.multivariate_normal([0, 0], [[vA, rho * np.sqrt(vA * vB)],
                                           [rho * np.sqrt(vA * vB), vB]], n)
    S = np.column_stack([u[h] - lam * u[a], u[a] - lam * u[h]])
    M = S @ np.array([1.0, -1.0]) + rng.normal(0.0, 0.5, n)
    d = dict(S=S, N=eps, K=S + eps, M=M, Y=(M > 0).astype(int))
    vS = tau2 * (1 + lam ** 2)
    cS = -2 * lam * tau2
    target = _params([[vS, cS], [cS, vS]],
                     [[vA, rho * np.sqrt(vA * vB)], [rho * np.sqrt(vA * vB), vB]],
                     [1.0, -1.0], 0.5)
    return d, target


LAWS = [
    ("gaussian", draw_gaussian),
    ("t3", lambda p, n, rng: draw_t(p, n, rng, 3)),
    ("t5", lambda p, n, rng: draw_t(p, n, rng, 5)),
    ("gamma_copula", draw_gamma),
    ("bivariate_poisson", draw_poisson),
    ("ordinal", draw_ordinal),
    ("contamination", draw_contam),
    ("repeated_team", draw_repeated),
]


def batches(n):
    return np.array_split(np.arange(n), N_BATCH)


def mc_metric(y, u, z, r):
    s = np.sqrt(max(1.0 - r * r, 1e-12))
    out = {k: [] for k in ("logloss", "brier", "auc", "mi")}
    for ix in batches(len(y)):
        uu, yy = u[ix], y[ix]
        prob = np.clip(ndtr((z + r * uu) / s), 1e-6, 1 - 1e-6)
        ll = -np.mean(yy * np.log(prob) + (1 - yy) * np.log(1 - prob))
        out["logloss"].append(ll)
        out["brier"].append(np.mean((yy - prob) ** 2))
        pos, neg = uu[yy == 1], uu[yy == 0]
        out["auc"].append(np.nan if len(pos) == 0 or len(neg) == 0 else
                          stats.mannwhitneyu(pos, neg, alternative="greater").statistic
                          / (len(pos) * len(neg)))
        pi = float(yy.mean())
        h = 0.0 if pi in (0.0, 1.0) else -(pi * np.log(pi) + (1 - pi) * np.log(1 - pi))
        out["mi"].append(h - ll)
    rows = []
    theory = population_metrics(z, r * r)
    for key, vals in out.items():
        vals = np.asarray(vals, float)
        est = float(np.nanmean(vals))
        se = float(np.nanstd(vals, ddof=1) / np.sqrt(np.isfinite(vals).sum()))
        zed = (est - theory[key]) / se if se > 0 else np.nan
        rows.append((key, est, theory[key], se, zed))
    return rows


def as_spec(target):
    if isinstance(target, dict):
        return target
    beta = np.linalg.solve(target.Sigma_K, target.Sigma_S @ target.b)
    return dict(beta=beta, r=float(np.sqrt(max(r2(target, "full"), 0.0))),
                z=float(target.z), cos2=float(alignment_cos2(target)),
                rel=float(reliability_D(target)[1]))


def score_bc(d, spec):
    """Batch estimates of the alignment ratio and of reliability, versus population."""
    c = np.array([1.0, -1.0])
    theory_cos = spec["cos2"]
    theory_rel = spec["rel"]
    ratios, rels = [], []
    for ix in batches(len(d["M"])):
        K, M, S = d["K"][ix], d["M"][ix], d["S"][ix]
        SK = np.cov(K.T)
        cross = np.cov(K.T, M)[:2, 2]
        var_M = float(np.var(M, ddof=1))
        beta = np.linalg.solve(SK, cross)
        r2f = float(beta @ cross / var_M)
        # R^2 of D from the same linear projection restricted to c.
        var_D = float(c @ SK @ c)
        cov_D = float(c @ cross)
        r2d = (cov_D ** 2) / (var_D * var_M) if var_D > 0 else np.nan
        ratios.append(r2d / r2f if r2f > 1e-8 else np.nan)
        rels.append(np.var(S @ c, ddof=1) / np.var(K @ c, ddof=1))
    out = []
    for check, vals, theory in (("B_alignment", ratios, theory_cos),
                                ("C_reliability", rels, theory_rel)):
        vals = np.asarray(vals, float)
        est = float(np.nanmean(vals))
        se = float(np.nanstd(vals, ddof=1) / np.sqrt(np.isfinite(vals).sum()))
        zed = (est - theory) / se if se > 0 else np.nan
        out.append((check, est, theory, se, zed))
    return out


def fisher_coverage(draw, design_p, truth, rng):
    q = stats.t.ppf(0.975, COV_N - 2)
    hits = []
    for _ in range(COV_REPS):
        d, _ = draw(design_p, COV_N, np.random.default_rng(int(rng.integers(1, 1_000_000_000))))
        s11, s22, s12 = (float(v) for v in suff(d["K"]))
        r = float(np.clip(reff_hat(s11, s22, s12), -0.999999, 0.999999))
        vn = float(delta_var_reff(np.array(s11), np.array(s22), np.array(s12), 1.0))
        vn = vn / (1 - r ** 2) ** 2
        se = np.sqrt(max(vn, 0.0) / (COV_N - 2))
        z = np.arctanh(r)
        lo, hi = np.tanh(z - q * se), np.tanh(z + q * se)
        hits.append(lo <= truth <= hi)
    est = float(np.mean(hits))
    se = float(np.sqrt(est * (1 - est) / max(len(hits), 1)))
    return est, se, (est - 0.95) / se if se > 0 else np.nan


def _passes(est, theory, se, zed, absolute):
    if np.isfinite(est) and abs(est - theory) <= 1e-6:
        return True
    if absolute is not None and np.isfinite(est) and abs(est - theory) <= absolute:
        return True
    return bool(np.isfinite(zed) and abs(zed) < 3)


def one(design, law_name, draw, p, rng):
    """Independent replicates, so shared team effects are not treated as iid noise."""
    bag = {k: [] for k in ("logloss", "brier", "auc", "mi", "B_alignment", "C_reliability")}
    spec = None
    c = np.array([1.0, -1.0])
    for _ in range(N_REP):
        d, target = draw(p, N_PER, rng)
        spec = as_spec(target)
        L = (d["K"] - d["K"].mean(0)) @ spec["beta"]
        sd = np.std(L, ddof=1)
        u = L / sd
        y = d["Y"]
        s = np.sqrt(max(1.0 - spec["r"] ** 2, 1e-12))
        prob = np.clip(ndtr((spec["z"] + spec["r"] * u) / s), 1e-6, 1 - 1e-6)
        ll = float(-np.mean(y * np.log(prob) + (1 - y) * np.log(1 - prob)))
        bag["logloss"].append(ll)
        bag["brier"].append(float(np.mean((y - prob) ** 2)))
        pos, neg = u[y == 1], u[y == 0]
        bag["auc"].append(np.nan if len(pos) == 0 or len(neg) == 0 else
                          float(stats.mannwhitneyu(pos, neg, alternative="greater").statistic)
                          / (len(pos) * len(neg)))
        pi = float(y.mean())
        h = 0.0 if pi in (0.0, 1.0) else float(-(pi * np.log(pi) + (1 - pi) * np.log(1 - pi)))
        bag["mi"].append(h - ll)
        K, M, S = d["K"], d["M"], d["S"]
        SK = np.cov(K.T)
        cross = np.cov(K.T, M)[:2, 2]
        var_M = float(np.var(M, ddof=1))
        beta = np.linalg.solve(SK, cross)
        r2f = float(beta @ cross / var_M)
        var_D = float(c @ SK @ c)
        r2d = (float(c @ cross) ** 2) / (var_D * var_M)
        bag["B_alignment"].append(r2d / r2f if r2f > 1e-8 else np.nan)
        bag["C_reliability"].append(float(np.var(S @ c, ddof=1) / np.var(K @ c, ddof=1)))
    theory_A = population_metrics(spec["z"], spec["r"] ** 2)
    targets = {"logloss": theory_A["logloss"], "brier": theory_A["brier"],
               "auc": theory_A["auc"], "mi": theory_A["mi"],
               "B_alignment": spec["cos2"], "C_reliability": spec["rel"]}
    rows = []
    for key, vals in bag.items():
        vals = np.asarray(vals, float)
        est = float(np.nanmean(vals))
        se = float(np.nanstd(vals, ddof=1) / np.sqrt(np.isfinite(vals).sum()))
        zed = (est - targets[key]) / se if se > 0 else np.nan
        absolute = 0.01 if key in ("B_alignment", "C_reliability") else None
        rows.append(dict(design=design, law=law_name, check=("A_" + key) if key in theory_A else key,
                         estimate=est, theory=targets[key], se=se, z=zed,
                         survives=_passes(est, targets[key], se, zed, absolute)))
    return rows


def main():
    rng = np.random.default_rng(SEED)
    rows = []
    for design, kw in DESIGNS.items():
        p = from_dimensionless(**kw)
        for law_name, draw in LAWS:
            print(design, law_name, flush=True)
            rows.extend(one(design, law_name, draw, p, rng))
            if law_name in ("gaussian", "t3", "t5", "contamination"):
                if law_name == "contamination":
                    extra = np.diag(0.05 * (5.0 * np.sqrt(np.diag(p.Sigma_K))) ** 2)
                    SK = p.Sigma_K + extra
                else:
                    SK = p.Sigma_K
                kappa = SK[1, 1] / SK[0, 0]
                rho = SK[0, 1] / np.sqrt(SK[0, 0] * SK[1, 1])
                truth = float(np.clip(rho_eff(kappa, rho), -0.999, 0.999))
                est, se, zed = fisher_coverage(draw, p, truth, rng)
                rows.append(dict(design=design, law=law_name, check="P6d_fisher_z",
                                 estimate=est, theory=0.95, se=se, z=zed,
                                 survives=bool(abs(est - 0.95) <= 0.04)))
    df = pd.DataFrame(rows)
    os.makedirs("results", exist_ok=True)
    df.to_csv("results/E5_stress.csv", index=False)
    sub = df[df.check.isin(["A_logloss", "B_alignment", "C_reliability", "P6d_fisher_z"])]
    pivot = sub.groupby(["law", "check"]).survives.mean().unstack()
    fig, ax = plt.subplots(figsize=(7.4, 3.8))
    pivot.plot(kind="bar", ax=ax)
    ax.set_ylabel("Share of design points inside the pass rule")
    ax.set_xlabel("Observation or outcome law")
    ax.set_ylim(0, 1.05)
    ax.legend(title="Check", fontsize=8)
    fig.tight_layout()
    fig.savefig("results/E5_stress.png", dpi=140)
    plt.close(fig)
    print(pivot.round(2).to_string())


if __name__ == "__main__":
    main()
