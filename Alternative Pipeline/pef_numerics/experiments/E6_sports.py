"""Alignment, skill, and team-blocked log-loss on the exported matches.

Primary summaries, rugby and football separate:
  * likelihood-ratio statistics for H0: beta_A + beta_B = 0
  * leave-one-team-out log-loss for intercept, A, D, and (A, B)
  * skill = LL(intercept) - LL(best of A, D, full), with bootstrap interval
  * median gaps and 1/(2 n_train)

Leave-one-team-out: for held-out team t, test matches are those involving t;
training is the remaining matches (the opponent's other fixtures stay in).
Each match is scored once per participating team that produces a valid fold.
Uncertainty uses a team multinomial bootstrap with out-of-bag matches.
eta_S/eta_N is stored always and quoted only when E5 coverage clears the bar.
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
LAND = os.path.join(
    os.path.dirname(__file__), "..", "..", "..",
    "scripts", "paper_pipeline", "outputs", "pef_landscape_2season.csv",
)
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


def _fit_intercept(y, w=None):
    clf = _logit()
    X = np.ones((len(y), 1))
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
    """Mean test log-loss. Each match is scored once per participating team.

    Returns losses for intercept, A, D, full, plus mean n_train and skip counts.
    """
    Xs = _designs(d)
    names = ["intercept"] + list(Xs.keys())
    total = {k: 0.0 for k in names}
    count = {k: 0 for k in names}
    n_train_sum = 0
    n_folds_used = 0
    n_folds_skipped = 0
    for t in range(d["n_teams"]):
        test = (d["h"] == t) | (d["a"] == t)
        train = ~test
        if train.sum() < 20 or test.sum() < 5 or len(np.unique(d["y"][train])) < 2:
            n_folds_skipped += 1
            continue
        n_folds_used += 1
        n_train_sum += int(train.sum())
        yy = d["y"][test]
        # Intercept-only.
        clf0 = _fit_intercept(d["y"][train])
        p0 = np.clip(clf0.predict_proba(np.ones((test.sum(), 1)))[:, 1], 1e-6, 1 - 1e-6)
        total["intercept"] += float(-np.sum(yy * np.log(p0) + (1 - yy) * np.log(1 - p0)))
        count["intercept"] += int(test.sum())
        for name, X in Xs.items():
            clf = _fit_ll(X[train], d["y"][train])
            p = np.clip(clf.predict_proba(X[test])[:, 1], 1e-6, 1 - 1e-6)
            total[name] += float(-np.sum(yy * np.log(p) + (1 - yy) * np.log(1 - p)))
            count[name] += int(test.sum())
    if min(count.values()) == 0:
        out = {k: np.nan for k in names}
        out.update(mean_n_train=np.nan, n_folds_used=0, n_folds_skipped=n_folds_skipped,
                   n_score_rows=0)
        return out
    out = {k: total[k] / count[k] for k in names}
    out["mean_n_train"] = n_train_sum / n_folds_used
    out["n_folds_used"] = n_folds_used
    out["n_folds_skipped"] = n_folds_skipped
    out["n_score_rows"] = count["intercept"]
    return out


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
    """Out-of-bag log-loss gaps and skill under a team multinomial bootstrap."""
    gaps = []
    skills = []
    for _ in range(N_BOOT):
        mult = rng.multinomial(d["n_teams"], np.ones(d["n_teams"]) / d["n_teams"])
        w = mult[d["h"]] * mult[d["a"]]
        train, test = w > 0, w == 0
        if train.sum() < 20 or test.sum() < 8 or len(np.unique(d["y"][train])) < 2:
            continue
        lls = {}
        ok = True
        clf0 = _fit_intercept(d["y"][train], w[train])
        lls["intercept"], _ = _ll(clf0, np.ones((test.sum(), 1)), d["y"][test])
        for name, X in _designs(d).items():
            clf = _fit_ll(X[train], d["y"][train], w[train])
            if len(np.unique(d["y"][test])) < 1:
                ok = False
                break
            lls[name], _ = _ll(clf, X[test], d["y"][test])
        if ok:
            gaps.append((lls["D"] - lls["full"], lls["A"] - lls["D"], lls["A"] - lls["full"]))
            best = min(lls["A"], lls["D"], lls["full"])
            skills.append(lls["intercept"] - best)
    if not gaps:
        return (np.nan,) * 8
    arr = np.asarray(gaps, float)
    lo, hi = np.quantile(arr, [0.025, 0.975], axis=0)
    sk = np.asarray(skills, float)
    sk_lo, sk_hi = np.quantile(sk, [0.025, 0.975])
    return (float(lo[0]), float(hi[0]), float(lo[1]), float(hi[1]),
            float(lo[2]), float(hi[2]), float(sk_lo), float(sk_hi))


def quote_allowed():
    if not os.path.exists(SIM):
        return False, "simulation summary missing"
    sm = pd.read_csv(SIM)
    if sm.empty or (sm.coverage < 0.85).any():
        return False, "Wald coverage below 0.85 in the simulation"
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


def _corr(a, b):
    a = pd.Series(a)
    b = pd.Series(b)
    if len(a) < 3 or a.std(ddof=1) == 0 or b.std(ddof=1) == 0:
        return float("nan")
    return float(a.corr(b))


def main():
    df = pd.read_csv(DATA)
    land = pd.read_csv(LAND) if os.path.exists(LAND) else None
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
        q = bootstrap_gap(d, rng)
        split = fit_split(d, rng, do_boot=allow)
        best = min(loo["A"], loo["D"], loo["full"])
        skill = loo["intercept"] - best
        informative = bool(np.isfinite(q[6]) and np.isfinite(q[7]) and q[6] > 0)
        row = dict(
            sport=sport, kpi=kpi, n=d["n"], n_teams=d["n_teams"],
            exemplar=(sport, kpi) in EXEMPLARS,
            lr=lr, beta_sum=sum_beta,
            ll_intercept=loo["intercept"],
            ll_A=loo["A"], ll_D=loo["D"], ll_full=loo["full"],
            skill=skill,
            gap_D_minus_full=loo["D"] - loo["full"],
            gap_A_minus_D=loo["A"] - loo["D"],
            boot_gap_D_full_lo=q[0], boot_gap_D_full_hi=q[1],
            boot_gap_A_D_lo=q[2], boot_gap_A_D_hi=q[3],
            boot_gap_A_full_lo=q[4], boot_gap_A_full_hi=q[5],
            boot_skill_lo=q[6], boot_skill_hi=q[7],
            informative=informative,
            mean_n_train=loo["mean_n_train"],
            half_n_train_mn=(1000.0 / (2.0 * loo["mean_n_train"])
                             if np.isfinite(loo["mean_n_train"]) and loo["mean_n_train"] > 0
                             else np.nan),
            n_folds_used=loo["n_folds_used"],
            n_folds_skipped=loo["n_folds_skipped"],
            n_score_rows=loo["n_score_rows"],
            ratio=split.get("ratio", np.nan), ratio_lo=split.get("lo", np.nan),
            ratio_hi=split.get("hi", np.nan),
            quote_split=bool(allow and split.get("ok") and split.get("separated")),
            separated=bool(split.get("separated", False)),
            split_ok=bool(split.get("ok", False)))
        rows.append(row)
        print(f"{sport:9s} {kpi:28s} LR {lr:7.2f}  "
              f"skill {skill:+.4f}  info {informative}  "
              f"D-full {loo['D'] - loo['full']:+.4f}", flush=True)
    out = pd.DataFrame(rows)
    if land is not None:
        out = out.merge(
            land[["sport", "kpi", "kappa", "rho", "eta", "quadrant", "r_ax"]],
            on=["sport", "kpi"], how="left")
        out = out.rename(columns={"r_ax": "r_A"})
    os.makedirs("results", exist_ok=True)
    out.to_csv("results/E6_sports.csv", index=False)

    summary = []
    for sport, g in out.groupby("sport"):
        info = g[g.informative]
        summary.append(dict(
            sport=sport, n_kpi=len(g),
            n_informative=int(g.informative.sum()),
            median_lr=float(g.lr.median()),
            q25_lr=float(g.lr.quantile(.25)), q75_lr=float(g.lr.quantile(.75)),
            n_lr_above_two=int((g.lr > 2).sum()),
            n_lr_above_chi=int((g.lr > 3.84).sum()),
            median_skill=float(g.skill.median()),
            median_ll_intercept=float(g.ll_intercept.median()),
            median_gap_D_full=float(g.gap_D_minus_full.median()),
            median_gap_A_D=float(g.gap_A_minus_D.median()),
            median_ll_A=float(g.ll_A.median()), median_ll_D=float(g.ll_D.median()),
            median_ll_full=float(g.ll_full.median()),
            median_half_n_train_mn=float(g.half_n_train_mn.median()),
            median_mean_n_train=float(g.mean_n_train.median()),
            corr_eta_gap_Df=_corr(g.eta, g.gap_D_minus_full) if "eta" in g else np.nan,
            corr_eta_gap_AD=_corr(g.eta, g.gap_A_minus_D) if "eta" in g else np.nan,
            corr_rA_gap_AD=_corr(g.r_A, g.gap_A_minus_D) if "r_A" in g else np.nan,
            corr_eta_gap_Df_info=_corr(info.eta, info.gap_D_minus_full) if len(info) else np.nan,
            corr_eta_gap_AD_info=_corr(info.eta, info.gap_A_minus_D) if len(info) else np.nan,
            corr_rA_gap_AD_info=_corr(info.r_A, info.gap_A_minus_D) if len(info) else np.nan,
            median_gap_D_full_info=float(info.gap_D_minus_full.median()) if len(info) else np.nan,
            median_gap_A_D_info=float(info.gap_A_minus_D.median()) if len(info) else np.nan,
            n_quoted_splits=int(g.quote_split.sum()),
            quote_reason=reason))
    sm = pd.DataFrame(summary)
    sm.to_csv("results/E6_sports_summary.csv", index=False)
    print(sm.round(4).to_string(index=False))
    print("\nInformative KPIs by sport:")
    print(out.groupby("sport").informative.sum().to_string())


if __name__ == "__main__":
    main()
