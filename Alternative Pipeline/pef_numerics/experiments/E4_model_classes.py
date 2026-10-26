"""Phase 4: does the advantage of relativisation depend on the learner?
(STRATEGY.md Conjecture G: learners that cannot represent A - B cheaply,
e.g. axis-aligned trees, benefit more and for longer.)

Regimes:
  aligned      A1 base point (D lossless in population)
  misaligned   b_ratio giving n* = 300 for probit
  shared_noise strong shared measurement noise: w = 0.3, rho_S = 0, rho_N = 0.9
Feature sets: full (A, B), D, and full+D (trees only; collinear for linear models).
Metric: held-out log-loss on a fixed 100k test set per regime (common random
numbers across reps and models); also AUC. Bayes log-loss reported as floor.
"""
import os
import sys
import warnings
import numpy as np
import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import HistGradientBoostingClassifier, RandomForestClassifier
from sklearn.metrics import log_loss, roc_auc_score
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import make_pipeline

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from pef import from_dimensionless, sample, r2, population_metrics  # noqa
from pef.runtime import pool, scale  # noqa

warnings.filterwarnings("ignore")
REPS = int(os.environ.get("PEF_R4", scale(40, 3)))
NS = (100, 300, 1000, 3000, 10000)
REGIMES = {
    "aligned": dict(z=0.0, rho_S=0.2, rho_N=0.6, w=0.5, q=0.8),
    "misaligned": dict(z=0.0, rho_S=0.2, rho_N=0.6, w=0.5, q=0.8, b_ratio=1.1765592111044554),
    "shared_noise": dict(z=0.0, rho_S=0.0, rho_N=0.9, w=0.3, q=0.8),
}


def models():
    return {
        "logistic": lambda: LogisticRegression(C=np.inf, max_iter=2000),
        "ridge_logistic": lambda: make_pipeline(StandardScaler(), LogisticRegression(C=1.0, max_iter=2000)),
        "gbm": lambda: HistGradientBoostingClassifier(max_iter=200, learning_rate=0.05,
                                                      early_stopping=True, validation_fraction=0.2,
                                                      n_iter_no_change=20, random_state=0),
        "rf": lambda: RandomForestClassifier(n_estimators=150, min_samples_leaf=10, n_jobs=1, random_state=0),
    }


def feats(K, which):
    D = (K[:, 0] - K[:, 1])[:, None]
    return {"full": K, "D": D, "full+D": np.column_stack([K, D])}[which]


def cell(args):
    regime, n, seed = args
    p = from_dimensionless(**REGIMES[regime])
    test = sample(p, 100_000, np.random.default_rng(999))
    rng = np.random.default_rng(seed)
    rows = []
    for rep in range(REPS):
        tr = sample(p, n, rng)
        if tr["Y"].min() == tr["Y"].max():
            continue
        for mname, mk in models().items():
            sets = ("full", "D", "full+D") if mname in ("gbm", "rf") else ("full", "D")
            for fs in sets:
                m = mk().fit(feats(tr["K"], fs), tr["Y"])
                pr = np.clip(m.predict_proba(feats(test["K"], fs))[:, 1], 1e-6, 1 - 1e-6)
                rows.append(dict(regime=regime, n=n, rep=rep, model=mname, features=fs,
                                 logloss=log_loss(test["Y"], pr), auc=roc_auc_score(test["Y"], pr)))
    return rows


if __name__ == "__main__":
    cells = [(r, n, 100 + i) for i, (r, n) in enumerate((r, n) for r in REGIMES for n in NS)]
    with pool() as pl:
        out = [row for rows in pl.imap_unordered(cell, cells) for row in rows]
    df = pd.DataFrame(out)
    bayes = {r: {f: population_metrics(from_dimensionless(**kw).z, r2(from_dimensionless(**kw), f))["logloss"]
                 for f in ("full", "D")} for r, kw in REGIMES.items()}
    df["bayes_full"] = df.regime.map(lambda r: bayes[r]["full"])
    df["bayes_D"] = df.regime.map(lambda r: bayes[r]["D"])
    os.makedirs("results", exist_ok=True)
    df.to_csv("results/E4_model_classes.csv", index=False)
    print("rows", len(df))
