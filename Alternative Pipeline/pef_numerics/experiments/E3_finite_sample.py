"""Phase 3: finite-sample theory (STRATEGY.md Theorems E and F).

Each replicate: draw a training sample of size n, fit probit (and logistic)
on the full pair (A, B) and on D, compute the EXACT expected test log-loss of
each fitted model (pef.fit.expected_logloss), and record
    gain = LL_full - LL_D   (> 0 means relativisation helps).

3A aligned (beta ∝ c): theory n * E[gain] -> 1/2.
3B misaligned via b_ratio: Delta_inf = LL_D,inf - LL_full,inf (exact);
   theory gain(n) ~ 1/(2n) - Delta_inf, crossover n* ~ 1/(2 Delta_inf).
3C misaligned via asymmetric noise (kappa_N != 1, b = c): same theory.
"""
import os
import sys
import numpy as np
import pandas as pd
from scipy.optimize import brentq
from sklearn.linear_model import LogisticRegression

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from pef import from_dimensionless, sample, r2, population_metrics  # noqa
from pef.fit import probit_fit, expected_logloss  # noqa
from pef.runtime import pool, scale  # noqa

R = int(os.environ.get("PEF_R", scale(3000, 100)))
BASE = dict(z=0.0, rho_S=0.2, rho_N=0.6, w=0.5, q=0.8)


def delta_inf(p):
    return (population_metrics(p.z, r2(p, "D"))["logloss"]
            - population_metrics(p.z, r2(p, "full"))["logloss"])


def one_cell(args):
    label, kw, n, seed, do_logit = args
    p = from_dimensionless(**kw)
    rng = np.random.default_rng(seed)
    g_pr, g_lo, nonconv = [], [], 0
    for _ in range(R):
        d = sample(p, n, rng)
        K, Y = d["K"], d["Y"]
        if Y.min() == Y.max():
            nonconv += 1
            continue
        D = (K[:, 0] - K[:, 1])[:, None]
        tf, okf = probit_fit(K, Y)
        td, okd = probit_fit(D, Y)
        if not (okf and okd):
            nonconv += 1
            continue
        g_pr.append(expected_logloss(p, "full", tf[0], tf[1:])
                    - expected_logloss(p, "D", td[0], td[1:]))
        if do_logit:
            mf = LogisticRegression(C=np.inf, max_iter=1000).fit(K, Y)
            md = LogisticRegression(C=np.inf, max_iter=1000).fit(D, Y)
            g_lo.append(expected_logloss(p, "full", mf.intercept_[0], mf.coef_[0], "logit")
                        - expected_logloss(p, "D", md.intercept_[0], md.coef_[0], "logit"))
    g_pr = np.array(g_pr)
    out = dict(label=label, n=n, reps=len(g_pr), nonconverged=nonconv,
               delta_inf=delta_inf(p), gain_probit=g_pr.mean(),
               se_probit=g_pr.std(ddof=1) / np.sqrt(len(g_pr)), **kw)
    if do_logit:
        g_lo = np.array(g_lo)
        out.update(gain_logit=g_lo.mean(), se_logit=g_lo.std(ddof=1) / np.sqrt(len(g_lo)))
    return out


def b_ratio_for(target):
    f = lambda br: delta_inf(from_dimensionless(**BASE, b_ratio=br)) - target  # noqa
    return brentq(f, 1.0 + 1e-9, 3.0)


def kappaN_for(target):
    f = lambda kN: delta_inf(from_dimensionless(**BASE, kappa_N=kN)) - target  # noqa
    return brentq(f, 1.0 + 1e-9, 50.0)


if __name__ == "__main__":
    cells = []
    seed = 1
    aligned = {
        "A1": BASE,
        "A2": dict(z=0.5, rho_S=-0.3, rho_N=0.3, w=0.3, q=0.9),
        "A3": dict(z=0.0, rho_S=0.5, rho_N=0.8, w=0.8, q=0.6),
    }
    for lab, kw in aligned.items():
        for n in (50, 100, 200, 500, 1000, 2000, 5000):
            cells.append((lab, kw, n, seed, lab == "A1")); seed += 1
    for nstar in (100, 300, 1000):
        br = b_ratio_for(1 / (2 * nstar))
        kw = dict(BASE, b_ratio=br)
        for n in np.unique(np.round(nstar * np.geomspace(0.25, 4, 9)).astype(int)):
            cells.append((f"B_n*{nstar}", kw, int(n), seed, False)); seed += 1
    kN = kappaN_for(1 / (2 * 300))
    kw = dict(BASE, kappa_N=kN)
    for n in np.unique(np.round(300 * np.geomspace(0.25, 4, 9)).astype(int)):
        cells.append(("C_kN_n*300", kw, int(n), seed, False)); seed += 1

    with pool() as pl:
        rows = pl.map(one_cell, cells)
    df = pd.DataFrame(rows)
    os.makedirs("results", exist_ok=True)
    df.to_csv("results/E3_finite_sample.csv", index=False)
    print(df[["label", "n", "reps", "nonconverged", "delta_inf", "gain_probit", "se_probit"]].to_string(index=False))
