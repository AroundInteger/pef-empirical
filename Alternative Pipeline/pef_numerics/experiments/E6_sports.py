"""Phase 6: alignment and the repeated-team split on the exported matches.

Primary summaries, rugby and football separate:
  * the distribution of likelihood-ratio statistics for H0: beta_A + beta_B = 0
  * the median team-blocked out-of-sample log-loss gap
Predictive log-loss is leave-one-team-out: a match is scored for a team when
that team is held out and the other team is not in the training set.
Uncertainty for the median gap is a team-cluster bootstrap (out-of-bag matches).
eta_S/eta_N is stored always and quoted only when the simulation coverage in
E5_repeated_measures_summary.csv cleared the pre-set bar.
"""
import os
import sys
import numpy as np
import pandas as pd
from sklearn.linear_model import LogisticRegression
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from pef.repeated import fit_repeated

DATA = os.path.join(os.path.dirname(__file__), "..", "data", "matches_long.csv")
SIM = os.path.join("results", "E5_repeated_measures_summary.csv")
EXEMPLARS = {("rugby", "lineout_throws_lost"), ("rugby", "rucks_won"),
             ("football", "corners"), ("football", "fouls")}
N_BOOT = 80
N_RATIO = 30
SEED = 20261026


def _logit():
    return LogisticRegression(C=1e12, solver="lbfgs", max_iter=200)


def _fit_ll(X, y, w=None):
    clf = _logit()
    if w is None:
        clf.fit(X, y)
    else:
        clf.fit(X, y, sample_weight=w)
    return clf


def _ll(clf, X, y):
    p = np.clip(clf.predict_proba(X)[:, 1], 1e-6, 1 - 1e-6)
    return float(-np.mean(y * np.log(p) + (1 - y) * np.log(1 - p))), len(y)


def _prepare(g):
    g = g.dropna(subset=["home_value", "away_value", "home_win"])
    if len(g) < 40 or g.home_win.nunique() < 2:
        return None
    A = g.home_value.to_numpy(float)
    B = g.away_value.to_numpy(float)
    scale = np.std(np.concatenate([A, B]), ddof=1)
    if not np.isfinite(scale) or scale < 1e-8:
        return None
    A = (A - A.mean()) / scale
    B = (B - B.mean()) / scale
    # A common scale keeps the null beta_A + beta_B = 0 unchanged.
    y = g.home_win.to_numpy(float)
    teams = pd.unique(np.concatenate([g.home_team.to_numpy(), g.away_team.to_numpy()]))
    index = {t: i for i, t in enumerate(teams)}
    h = np.array([index[t] for t in g.home_team])
    a = np.array([index[t] for t in g.away_team])
    return dict(A=A, B=B, D=A - B, y=y, h=h, a=a, n_teams=len(teams), n=len(y))


def _designs(d):
    return {"A": d["A"][:, None], "D": d["D"][:, None],
            "full": np.column_stack([d["A"], d["B"]])}


def loo_logloss(d):
    """Mean test log-loss. Each match is scored once per participating team."""
    Xs = _designs(d)
    total = {k: 0.0 for k in Xs}
    count = {k: 0 for k in Xs}
    for t in range(d["n_teams"]):
        test = (d["h"] == t) | (d["a"] == t)
        train = ~test
        if train.sum() < 20 or test.sum() < 5 or len(np.unique(d["y"][train])) < 2:
            continue
        for name, X in Xs.items():
            clf = _fit_ll(X[train], d["y"][train])
            p = np.clip(clf.predict_proba(X[test])[:, 1], 1e-6, 1 - 1e-6)
            yy = d["y"][test]
            total[name] += float(-np.sum(yy * np.log(p) + (1 - yy) * np.log(1 - p)))
            count[name] += int(test.sum())
    if min(count.values()) == 0:
        return {k: np.nan for k in Xs}
    return {k: total[k] / count[k] for k in Xs}


def lr_stat(d):
    """2 (ll_full - ll_D) on the whole sample. Dependence-robust p is not claimed."""
    Xs = _designs(d)
    ll = {}
    coef = None
    for name, X in Xs.items():
        clf = _fit_ll(X, d["y"])
        p = np.clip(clf.predict_proba(X)[:, 1], 1e-12, 1 - 1e-12)
        ll[name] = float(np.sum(d["y"] * np.log(p) + (1 - d["y"]) * np.log(1 - p)))
        if name == "full":
            coef = clf.coef_.ravel()
    return 2.0 * (ll["full"] - ll["D"]), float(coef[0] + coef[1]), ll


def bootstrap_gap(d, rng):
    """Out-of-bag log-loss gaps under a team multinomial bootstrap."""
    gaps = []
    for _ in range(N_BOOT):
        mult = rng.multinomial(d["n_teams"], np.ones(d["n_teams"]) / d["n_teams"])
        w = mult[d["h"]] * mult[d["a"]]
        train, test = w > 0, w == 0
        if train.sum() < 20 or test.sum() < 8 or len(np.unique(d["y"][train])) < 2:
            continue
        lls = {}
        ok = True
        for name, X in _designs(d).items():
            clf = _fit_ll(X[train], d["y"][train], w[train])
            if len(np.unique(d["y"][test])) < 1:
                ok = False
                break
            lls[name], _ = _ll(clf, X[test], d["y"][test])
        if ok:
            gaps.append((lls["D"] - lls["full"], lls["A"] - lls["D"], lls["A"] - lls["full"]))
    if not gaps:
        return (np.nan,) * 6
    arr = np.asarray(gaps, float)
    lo, hi = np.quantile(arr, [0.025, 0.975], axis=0)
    return float(lo[0]), float(hi[0]), float(lo[1]), float(hi[1]), float(lo[2]), float(hi[2])


def quote_allowed():
    if not os.path.exists(SIM):
        return False, "simulation summary missing"
    sm = pd.read_csv(SIM)
    if sm.empty or (sm.coverage < 0.85).any():
        return False, "Wald coverage below 0.85 in the simulation"
    truth = None
    # Relative bias uses the truth stored on the draw file if present.
    draws = os.path.join("results", "E5_repeated_measures.csv")
    if os.path.exists(draws):
        raw = pd.read_csv(draws)
        truth = float(raw.truth.iloc[0])
        rel = (sm.mean_ratio - truth).abs() / abs(truth)
        if (rel > 0.15).any():
            return False, "relative bias above 15% in the simulation"
    return True, "simulation coverage and bias within the pre-set bar"


def fit_split(d, rng, do_boot):
    fit = fit_repeated(d["A"], d["B"], d["h"], d["a"], d["n_teams"])
    if not fit.get("ok"):
        return dict(ok=False, ratio=np.nan, lo=np.nan, hi=np.nan, separated=False)
    ratios = []
    if do_boot:
        for _ in range(N_RATIO):
            mult = rng.multinomial(d["n_teams"], np.ones(d["n_teams"]) / d["n_teams"])
            w = (mult[d["h"]] * mult[d["a"]]).astype(float)
            if np.count_nonzero(w) < d["n_teams"]:
                continue
            b = fit_repeated(d["A"], d["B"], d["h"], d["a"], d["n_teams"], weights=w)
            if b.get("ok") and np.isfinite(b["ratio"]) and b["ratio"] > 0:
                ratios.append(b["ratio"])
    if len(ratios) >= 10:
        lo, hi = np.quantile(ratios, [0.025, 0.975])
    else:
        se = fit["se_ratio"]
        lo = fit["ratio"] - 1.96 * se if np.isfinite(se) else np.nan
        hi = fit["ratio"] + 1.96 * se if np.isfinite(se) else np.nan
    span = (np.isfinite(lo) and np.isfinite(hi) and lo > 0 and hi / lo >= 10)
    return dict(ok=True, ratio=fit["ratio"], lo=float(lo), hi=float(hi),
                separated=bool(np.isfinite(lo) and np.isfinite(hi) and not span),
                lam=fit["lam"], eta_S=fit["eta_S"], eta_N=fit["eta_N"])


def main():
    df = pd.read_csv(DATA)
    allow, reason = quote_allowed()
    print("quote eta_S/eta_N:", allow, reason, flush=True)
    rng = np.random.default_rng(SEED)
    rows = []
    for (sport, kpi), g in df.groupby(["sport", "kpi"], sort=True):
        d = _prepare(g)
        if d is None:
            continue
        lr, sum_beta, _ = lr_stat(d)
        loo = loo_logloss(d)
        # Bootstrap the three gaps. Stored as six quantiles.
        q = bootstrap_gap(d, rng)
        split = fit_split(d, rng, do_boot=allow)
        rows.append(dict(
            sport=sport, kpi=kpi, n=d["n"], n_teams=d["n_teams"], exemplar=(sport, kpi) in EXEMPLARS,
            lr=lr, beta_sum=sum_beta,
            ll_A=loo["A"], ll_D=loo["D"], ll_full=loo["full"],
            gap_D_minus_full=loo["D"] - loo["full"],
            gap_A_minus_D=loo["A"] - loo["D"],
            boot_gap_D_full_lo=q[0], boot_gap_D_full_hi=q[1],
            boot_gap_A_D_lo=q[2], boot_gap_A_D_hi=q[3],
            boot_gap_A_full_lo=q[4], boot_gap_A_full_hi=q[5],
            ratio=split.get("ratio", np.nan), ratio_lo=split.get("lo", np.nan),
            ratio_hi=split.get("hi", np.nan),
            quote_split=bool(allow and split.get("ok") and split.get("separated")),
            separated=bool(split.get("separated", False)),
            split_ok=bool(split.get("ok", False))))
        print(f"{sport:9s} {kpi:28s} LR {lr:7.2f}  "
              f"LOO D-full {loo['D'] - loo['full']:+.4f}", flush=True)
    out = pd.DataFrame(rows)
    os.makedirs("results", exist_ok=True)
    out.to_csv("results/E6_sports.csv", index=False)
    # Sport-level primary summary.
    summary = []
    for sport, g in out.groupby("sport"):
        summary.append(dict(
            sport=sport, n_kpi=len(g),
            median_lr=float(g.lr.median()),
            q25_lr=float(g.lr.quantile(.25)), q75_lr=float(g.lr.quantile(.75)),
            median_gap_D_full=float(g.gap_D_minus_full.median()),
            median_gap_A_D=float(g.gap_A_minus_D.median()),
            median_ll_A=float(g.ll_A.median()), median_ll_D=float(g.ll_D.median()),
            median_ll_full=float(g.ll_full.median()),
            n_quoted_splits=int(g.quote_split.sum()),
            quote_reason=reason))
    sm = pd.DataFrame(summary)
    sm.to_csv("results/E6_sports_summary.csv", index=False)
    fig, axes = plt.subplots(1, 2, figsize=(8.2, 3.6))
    for sport, g in out.groupby("sport"):
        axes[0].hist(g.lr, bins=15, alpha=0.55, label=sport)
    axes[0].set_xlabel(r"Likelihood-ratio statistic for $\beta_A+\beta_B=0$")
    axes[0].set_ylabel("KPIs")
    axes[0].legend(fontsize=8)
    x = np.arange(len(sm))
    axes[1].bar(x - 0.15, sm.median_ll_A, width=0.3, label="A")
    axes[1].bar(x + 0.15, sm.median_ll_D, width=0.3, label="D")
    axes[1].scatter(x, sm.median_ll_full, color="black", zorder=3, label="(A, B)")
    axes[1].set_xticks(x, sm.sport)
    axes[1].set_ylabel("Median team-blocked log-loss (nats)")
    axes[1].legend(fontsize=8)
    fig.tight_layout()
    fig.savefig("results/E6_sports.png", dpi=140)
    plt.close(fig)
    print(sm.round(4).to_string(index=False))


if __name__ == "__main__":
    main()
