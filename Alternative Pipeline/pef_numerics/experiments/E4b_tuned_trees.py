"""Phase 4b: tree models with hyperparameters tuned PER feature set, model and
replicate. Each candidate is scored on a 25% validation split by log-loss,
and the winner is refitted on all the training data. Motivated by E4: the
random-forest verdict on D flipped sign with leaf size, so untuned
comparisons are not admissible evidence.

Checkpointed and resumable: every finished replicate is appended to
results/E4b_tuned_trees.csv straight away. A rerun skips (regime, n, rep)
triples already present, so an interrupted run loses at most one replicate
per worker.

Usage:
    python experiments/E4b_tuned_trees.py                  # all regimes
    python experiments/E4b_tuned_trees.py aligned          # one regime
    PEF_R4B=12 python experiments/E4b_tuned_trees.py ...   # replicate count
"""
import os
import sys
import warnings
import numpy as np
import pandas as pd
from sklearn.ensemble import HistGradientBoostingClassifier, RandomForestClassifier
from sklearn.metrics import log_loss

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pef import from_dimensionless, sample  # noqa
from pef.runtime import pool, scale  # noqa
from E4_model_classes import REGIMES, feats  # noqa

warnings.filterwarnings("ignore")
REPS = int(os.environ.get("PEF_R4B", scale(12, 2)))
NS = (1000, 3000, 10000)
OUT = "results/E4b_tuned_trees.csv"
COLS = ["regime", "n", "rep", "model", "features", "hp", "logloss", "val_logloss"]


def rf_grid(n):
    return [dict(min_samples_leaf=l) for l in (5, 20, 50, 100, 200, 500) if l <= n // 10]


def gbm_grid(n):
    return [dict(max_leaf_nodes=m, min_samples_leaf=l) for m in (3, 8, 31) for l in (10, 50) if l <= n // 10]


def make(model, hp):
    if model == "rf":
        return RandomForestClassifier(n_estimators=100, n_jobs=1, random_state=0, **hp)
    return HistGradientBoostingClassifier(max_iter=300, learning_rate=0.05, early_stopping=True,
                                          validation_fraction=0.2, n_iter_no_change=20,
                                          random_state=0, **hp)


def ll(m, X, y):
    return log_loss(y, np.clip(m.predict_proba(X)[:, 1], 1e-6, 1 - 1e-6))


_TEST = {}


def test_set(regime):
    if regime not in _TEST:   # fixed test set per regime: common random numbers
        _TEST[regime] = sample(from_dimensionless(**REGIMES[regime]), 100_000, np.random.default_rng(999))
    return _TEST[regime]


def one_rep(args):
    """One replicate. Its seed depends only on (regime, n, rep), so results
    are identical however the work is split or resumed."""
    regime, n, rep = args
    p = from_dimensionless(**REGIMES[regime])
    test = test_set(regime)
    rng = np.random.default_rng([700, list(REGIMES).index(regime), n, rep])
    tr = sample(p, n, rng)
    idx = rng.permutation(n)
    va, fi = idx[: n // 4], idx[n // 4:]
    rows = []
    for model, grid in (("rf", rf_grid(n)), ("gbm", gbm_grid(n))):
        for fs in ("full", "D", "full+D"):
            X, Xt = feats(tr["K"], fs), feats(test["K"], fs)
            scores = [ll(make(model, hp).fit(X[fi], tr["Y"][fi]), X[va], tr["Y"][va]) for hp in grid]
            k = int(np.argmin(scores))
            m = make(model, grid[k]).fit(X, tr["Y"])
            rows.append(dict(regime=regime, n=n, rep=rep, model=model + "_tuned", features=fs,
                             hp=str(grid[k]), logloss=ll(m, Xt, test["Y"]), val_logloss=scores[k]))
    return rows


def done_keys():
    if not os.path.exists(OUT):
        return set()
    d = pd.read_csv(OUT)
    # a replicate is complete only if all 6 (model, feature set) rows are present
    c = d.groupby(["regime", "n", "rep"]).size()
    return set(c[c == 6].index)


if __name__ == "__main__":
    regimes = sys.argv[1:] or list(REGIMES)
    os.makedirs("results", exist_ok=True)
    done = done_keys()
    todo = [(r, n, k) for r in regimes for n in NS for k in range(REPS) if (r, n, k) not in done]
    todo.sort(key=lambda t: -t[1])   # largest n first, for load balance
    print(f"{len(done)} replicates already done, {len(todo)} to run", flush=True)
    if not os.path.exists(OUT):
        pd.DataFrame(columns=COLS).to_csv(OUT, index=False)
    with pool() as pl:
        for i, rows in enumerate(pl.imap_unordered(one_rep, todo), 1):
            pd.DataFrame(rows, columns=COLS).to_csv(OUT, mode="a", header=False, index=False)
            print(f"[{i}/{len(todo)}] {rows[0]['regime']} n={rows[0]['n']} rep={rows[0]['rep']}", flush=True)
