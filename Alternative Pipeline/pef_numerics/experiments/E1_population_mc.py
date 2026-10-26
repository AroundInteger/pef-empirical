"""Phase 1: closed forms (Theorem A metrics, Theorem C reliability) versus
Monte Carlo. 200 random parameter draws (half exchangeable, half
asymmetric), n = 10^6 per draw, standard errors by batch means (20 batches).
Output: results/E1_population_mc.csv (one row per draw x feature x metric).
"""
import os
import sys
import numpy as np
import pandas as pd
from scipy.special import ndtr, log_ndtr
from sklearn.metrics import roc_auc_score

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from pef import from_dimensionless, all_population, sample, true_index, reliability_D  # noqa
from pef.runtime import pool, scale  # noqa

N_DRAWS, N_BATCH = scale(200, 20), 20
N_MC = int(os.environ.get("PEF_NMC", scale(1_000_000, 50_000)))
SEED_OFFSET = os.environ.get("PEF_SEED")   # None: original run; else fresh sampling seeds
OUT = os.environ.get("PEF_OUT", "results/E1_population_mc.csv")
FEATS = ("full", "D", "A")
METRICS = ("r2", "logloss", "brier", "accuracy", "auc", "mi")


def draw_params(i, rng):
    exch = i % 2 == 0
    kw = dict(z=rng.uniform(-1, 1), rho_S=rng.uniform(-0.9, 0.9),
              rho_N=rng.uniform(-0.9, 0.9), w=rng.uniform(0.15, 0.9),
              q=rng.uniform(0.4, 0.97))
    if not exch:
        kw.update(kappa_S=np.exp(rng.uniform(np.log(.25), np.log(4))),
                  kappa_N=np.exp(rng.uniform(np.log(.25), np.log(4))),
                  b_ratio=rng.uniform(0.5, 1.5))
    return exch, kw


def hb(y):
    return 0.0 if y in (0, 1) else -(y * np.log(y) + (1 - y) * np.log(1 - y))


def batch_metrics(u, r, z, Y, M):
    s = np.sqrt(1 - r * r)
    a = (z + r * u) / s
    p = ndtr(a)
    ll = -np.mean(Y * log_ndtr(a) + (1 - Y) * log_ndtr(-a))
    n = len(u)
    rr = np.corrcoef(u, M)[0, 1] ** 2
    rr = rr - (1 - rr) * (1 - 2 * rr) / n      # first-order bias correction
    return dict(r2=rr, logloss=ll,
                brier=np.mean((Y - p) ** 2), accuracy=np.mean((p > .5) == Y),
                auc=roc_auc_score(Y, u), mi=hb(Y.mean()) - ll)


def run_draw(i):
    rng = np.random.default_rng(10_000 + i)
    exch, kw = draw_params(i, rng)
    p = from_dimensionless(**kw)
    theory = all_population(p, FEATS)
    rel_direct, rel_law = reliability_D(p)
    if SEED_OFFSET is not None:              # same parameters, independent sample
        rng = np.random.default_rng(int(SEED_OFFSET) + i)
    d = sample(p, N_MC, rng)
    rows = []
    batches = np.array_split(np.arange(N_MC), N_BATCH)
    for f in FEATS:
        u, r = true_index(p, d["K"], f)
        per = [batch_metrics(u[ix], r, p.z, d["Y"][ix], d["M"][ix]) for ix in batches]
        for m in METRICS:
            vals = np.array([b[m] for b in per])
            rows.append(dict(draw=i, exch=exch, feature=f, metric=m,
                             theory=theory[f][m], mc=vals.mean(),
                             se=vals.std(ddof=1) / np.sqrt(N_BATCH), **kw))
    SD = d["S"] @ np.array([1., -1.])
    Dv = d["K"] @ np.array([1., -1.])
    rel = np.array([np.var(SD[ix]) / np.var(Dv[ix]) for ix in batches])
    rows.append(dict(draw=i, exch=exch, feature="D", metric="reliability",
                     theory=rel_law, mc=rel.mean(), se=rel.std(ddof=1) / np.sqrt(N_BATCH),
                     law_vs_direct=abs(rel_law - rel_direct), **kw))
    return rows


if __name__ == "__main__":
    with pool() as pl:
        out = [row for rows in pl.imap_unordered(run_draw, range(N_DRAWS)) for row in rows]
    df = pd.DataFrame(out)
    df["zscore"] = (df.mc - df.theory) / df.se
    os.makedirs("results", exist_ok=True)
    df.to_csv(OUT, index=False)
    print(f"rows: {len(df)}")
