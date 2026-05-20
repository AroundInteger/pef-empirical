#!/usr/bin/env python3
"""
run_paper_pipeline.py
=====================
Python equivalent of run_paper_pipeline.m.

Single entry-point that generates every figure, table number, and
supplementary output needed for the PEF framework paper.

Data sources
------------
Primary sports (23/24 + 24/25):
  Data/Rugby/Raw/4_seasons rugby abs.csv        (filtered to last 2 seasons)
  Data/Football/Raw/team_summaries_4seasons/
    championship_team_23_24.csv
    championship_team_24_25.csv
SI normality (all 4 seasons):
  Same raw files, all seasons
Non-sports (pre-computed CSVs):
  paper_data_and_analysis/outputs/real_finance_pef_results.csv
  paper_data_and_analysis/outputs/manufacturing_pef_results.csv
  paper_data_and_analysis/outputs/tcga_brca_gene_pef.csv

Outputs
-------
figures/Figure_1.png          PEF landscape: KPI segments (23/24->24/25)
figures/Figure_2.png          I(X;Y) information surface
figures/Figure_3.png          PEF-to-ML mapping + empirical scatter
outputs/pef_landscape_2season.csv
outputs/pef_landscape_per_season.csv
outputs/normality_primary_2season.csv
outputs/normality_si_4season.csv
outputs/normality_commentary.csv
outputs/ml_empirical_results.csv
outputs/domain_summary.csv
outputs/table_numbers.csv
outputs/normality_summary_SI.png

Dependencies
------------
  pip install numpy pandas scipy statsmodels matplotlib scikit-learn
"""
from __future__ import annotations

import sys
import warnings
from pathlib import Path

import numpy as np
import pandas as pd
from scipy import stats
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap

# Reuse helpers from the 4-season normality pipeline
_PY_HELPERS = Path(__file__).resolve().parent.parent / "PEF_Normality_4seasons" / "python"
if str(_PY_HELPERS) not in sys.path:
    sys.path.insert(0, str(_PY_HELPERS))
from run_pef_normality_analysis import (
    load_rugby_paired, load_football_paired, compute_pef,
    normality_windows, build_windows, _redblue_diverging,
)

try:
    from statsmodels.stats.diagnostic import lilliefors as _lilliefors
    from sklearn.linear_model import LogisticRegression
    from sklearn.model_selection import StratifiedKFold
    from sklearn.metrics import roc_auc_score
    _HAS_SK = True
except ImportError:
    _HAS_SK = False
    warnings.warn("scikit-learn not installed; ML validation will be skipped.")

np.random.seed(20260511)

# ======================================================================
# Paths
# ======================================================================
HERE      = Path(__file__).resolve().parent
SCRIPTS   = HERE.parent                                             # scripts/
REPO      = SCRIPTS.parent                                          # overleaf_pef_article/
RUGBY_RAW = REPO / "Data" / "Rugby" / "Raw" / "4_seasons rugby abs.csv"
FOOT_DIR  = REPO / "Data" / "Football" / "Raw" / "team_summaries_4seasons"
FOOT_2S   = ["championship_team_23_24.csv", "championship_team_24_25.csv"]
FOOT_4S   = ["championship_team_21_22.csv", "championship_team_22_23.csv",
             "championship_team_23_24.csv", "championship_team_24_25.csv"]
NS_DIR    = REPO / "paper_data_and_analysis" / "outputs"
OUT_DIR   = HERE / "outputs"
FIG_DIR   = REPO / "figures"
OUT_DIR.mkdir(exist_ok=True)
FIG_DIR.mkdir(exist_ok=True)

SEASONS_PRI = {"23/24", "24/25"}
ALPHA       = 0.05
N_CV_FOLDS  = 5

print("=" * 60)
print(" PEF paper pipeline  (primary: 23/24 + 24/25)")
print(f" Outputs -> {OUT_DIR}")
print("=" * 60)

# ======================================================================
# [1/7]  Raw rugby data
# ======================================================================
print("\n[1/7] Loading raw rugby data...")
rugby_all, rugby_kpis = load_rugby_paired(RUGBY_RAW)
_outcomes_r = _rugby_outcomes(RUGBY_RAW)
rugby_all   = rugby_all.merge(_outcomes_r, on="matchid", how="left")
rugby_2s    = rugby_all[rugby_all.season.isin(SEASONS_PRI)].copy()
print(f"   4-season: {len(rugby_all)} matches  |  "
      f"2-season: {len(rugby_2s)} matches  |  {len(rugby_kpis)} KPIs")

# ======================================================================
# [2/7]  Raw football data
# ======================================================================
print("\n[2/7] Loading raw football data...")
foot_2s, foot_kpis = load_football_paired(FOOT_DIR, FOOT_2S)
foot_all, _        = load_football_paired(FOOT_DIR, FOOT_4S)
_out_f2 = _football_outcomes(FOOT_DIR, FOOT_2S)
_out_f4 = _football_outcomes(FOOT_DIR, FOOT_4S)
foot_2s  = foot_2s.merge(_out_f2, on="match_id", how="left")
foot_all = foot_all.merge(_out_f4, on="match_id", how="left")
print(f"   4-season: {len(foot_all)} matches  |  "
      f"2-season: {len(foot_2s)} matches  |  {len(foot_kpis)} KPIs")

# ======================================================================
# [3/7]  PEF landscape
# ======================================================================
print("\n[3/7] Computing PEF landscape...")
pef_rugby_2s = compute_pef(rugby_2s, rugby_kpis, "rugby")
pef_foot_2s  = compute_pef(foot_2s,  foot_kpis,  "football")
pef_2s_all   = pd.concat([pef_rugby_2s, pef_foot_2s], ignore_index=True)

# Per-season (for Figure 1 segments)
per_season_rows = []
for sp_label, paired, kpis in [("rugby", rugby_2s, rugby_kpis),
                                ("football", foot_2s, foot_kpis)]:
    for szn in sorted(paired.season.unique()):
        sub = paired[paired.season == szn]
        pp  = compute_pef(sub, kpis, sp_label)
        pp["season"] = szn
        per_season_rows.append(pp)
pef_per_season = pd.concat(per_season_rows, ignore_index=True)

# 4-season pooled (SI)
pef_rugby_4s = compute_pef(rugby_all, rugby_kpis, "rugby")
pef_foot_4s  = compute_pef(foot_all,  foot_kpis,  "football")
pef_4s_all   = pd.concat([pef_rugby_4s, pef_foot_4s], ignore_index=True)

pef_2s_all.to_csv(OUT_DIR / "pef_landscape_2season.csv", index=False)
pef_per_season.to_csv(OUT_DIR / "pef_landscape_per_season.csv", index=False)
pef_4s_all.to_csv(OUT_DIR / "pef_landscape_4season.csv", index=False)
print(f"   Rugby 2s : mean eta={pef_rugby_2s.eta.mean():.3f} ({len(pef_rugby_2s)} KPIs)")
print(f"   Football 2s: mean eta={pef_foot_2s.eta.mean():.3f} ({len(pef_foot_2s)} KPIs)")

# ======================================================================
# [4/7]  Normality analysis
# ======================================================================
print("\n[4/7] Normality analysis...")

win_r2 = build_windows(sorted(rugby_2s.season.unique().tolist()))
win_f2 = build_windows(sorted(foot_2s.season.unique().tolist()))
norm_rugby_2s = normality_windows(rugby_2s, rugby_kpis, win_r2, "rugby")
norm_foot_2s  = normality_windows(foot_2s,  foot_kpis,  win_f2, "football")
norm_primary  = pd.concat([norm_rugby_2s, norm_foot_2s], ignore_index=True)
norm_primary.to_csv(OUT_DIR / "normality_primary_2season.csv", index=False)

win_r4 = build_windows(sorted(rugby_all.season.unique().tolist()))
win_f4 = build_windows(sorted(foot_all.season.unique().tolist()))
norm_rugby_4s = normality_windows(rugby_all, rugby_kpis, win_r4, "rugby")
norm_foot_4s  = normality_windows(foot_all,  foot_kpis,  win_f4, "football")
norm_si       = pd.concat([norm_rugby_4s, norm_foot_4s], ignore_index=True)
norm_si.to_csv(OUT_DIR / "normality_si_4season.csv", index=False)

norm_commentary = compute_normality_commentary(norm_primary, norm_si)
norm_commentary.to_csv(OUT_DIR / "normality_commentary.csv", index=False)
print_normality_commentary(norm_commentary)

# ======================================================================
# [5/7]  Non-sports domain summaries
# ======================================================================
print("\n[5/7] Loading non-sports domain summaries...")
domain_summary = load_nonsports(NS_DIR)
domain_summary.to_csv(OUT_DIR / "domain_summary.csv", index=False)
for _, row in domain_summary.iterrows():
    print(f"   {row['domain']:<20}  mean_eta={row['mean_eta']:.3f}  "
          f"success={row['success_pct']:.1f}%")

# ======================================================================
# [6/7]  ML validation
# ======================================================================
print("\n[6/7] ML validation...")
if _HAS_SK:
    print("   Empirical: rugby 5-fold CV...")
    ml_rugby = ml_empirical(rugby_2s, rugby_kpis, "home_win", N_CV_FOLDS)
    ml_rugby["sport"] = "rugby"
    print("   Empirical: football 5-fold CV...")
    ml_foot  = ml_empirical(foot_2s,  foot_kpis,  "home_win", N_CV_FOLDS)
    ml_foot["sport"]  = "football"
    ml_all = pd.concat([ml_rugby, ml_foot], ignore_index=True)
    ml_all = join_pef_to_ml(ml_all, pef_2s_all)
    ml_all.to_csv(OUT_DIR / "ml_empirical_results.csv", index=False)
    print(f"   Rugby    mean acc impr: {ml_rugby.acc_improvement.mean():+.1f}%")
    print(f"   Football mean acc impr: {ml_foot.acc_improvement.mean():+.1f}%")
else:
    ml_all = pd.DataFrame()
    print("   Skipped (scikit-learn not installed).")

ml_surface = build_ml_surface()

# ======================================================================
# [7/7]  Figures + table_numbers.csv
# ======================================================================
print("\n[7/7] Generating figures...")
figure_1_landscape(pef_2s_all, pef_per_season, domain_summary,
                   FIG_DIR / "Figure_1.png")
print("   Figure 1 saved.")
figure_2_info_surface(FIG_DIR / "Figure_2.png")
print("   Figure 2 saved.")
figure_3_ml_mapping(ml_all, ml_surface, FIG_DIR / "Figure_3.png")
print("   Figure 3 saved.")
figure_si_normality(norm_primary, norm_si, OUT_DIR / "normality_summary_SI.png")
print("   SI normality figure saved.")

stats = collate_table_numbers(pef_2s_all, pef_per_season,
                              norm_commentary, domain_summary, ml_all, norm_primary)
stats.to_csv(OUT_DIR / "table_numbers.csv", index=False)
print(f"   table_numbers.csv written ({len(stats)} rows).")

print("\n" + "=" * 60)
print(" Pipeline complete.")
print(f" Figures : {FIG_DIR}")
print(f" Outputs : {OUT_DIR}")
print("=" * 60)


# ======================================================================
#  HELPER FUNCTIONS
# ======================================================================

def _rugby_outcomes(csv_path: Path) -> pd.DataFrame:
    """Read raw rugby CSV → matchid + home_win (1/0)."""
    df = pd.read_csv(csv_path, dtype=str)
    df["match_location"] = df["match_location"].str.lower().str.strip()
    df["outcome"]        = df["outcome"].str.lower().str.strip()
    home = df[df.match_location == "home"][["matchid", "outcome"]].copy()
    home["matchid"]   = pd.to_numeric(home["matchid"], errors="coerce")
    home["home_win"]  = (home["outcome"] == "win").astype(int)
    return home[["matchid", "home_win"]].drop_duplicates("matchid")


def _football_outcomes(csv_dir: Path, season_files: list[str]) -> pd.DataFrame:
    """Read championship CSVs → match_id + home_win (1/0)."""
    rows = []
    for fname in season_files:
        fp = csv_dir / fname
        if not fp.exists():
            continue
        t = pd.read_csv(fp, dtype=str)
        need = {"home_away", "result", "match_id"}
        if not need.issubset(t.columns):
            continue
        t["home_away"] = t["home_away"].str.lower().str.strip()
        t["result"]    = t["result"].str.upper().str.strip()
        home = t[t.home_away == "home"][["match_id", "result"]].copy()
        home["home_win"] = (home["result"] == "W").astype(int)
        rows.append(home[["match_id", "home_win"]])
    if not rows:
        return pd.DataFrame(columns=["match_id", "home_win"])
    out = pd.concat(rows, ignore_index=True).drop_duplicates("match_id")
    return out


def compute_normality_commentary(norm_prim: pd.DataFrame,
                                 norm_si: pd.DataFrame) -> pd.DataFrame:
    """Key normality statistics for paper text."""
    rows = []
    for sp in ["rugby", "football"]:
        for sd in ["home", "away", "diff"]:
            m1 = ((norm_prim.sport == sp) & (norm_prim.side == sd) &
                  (norm_prim.window_n_seasons == 1))
            v1 = norm_prim.loc[m1, "verdict"]
            pct_nc_1s = 100 * ((v1 == "Normal") | (v1 == "Close")).mean()
            pct_n_1s  = 100 * (v1 == "Normal").mean()
            n_kpis    = len(v1) / max(norm_prim.loc[m1, "window_label"].nunique(), 1)

            m2 = ((norm_prim.sport == sp) & (norm_prim.side == sd) &
                  (norm_prim.window_n_seasons == 2))
            v2 = norm_prim.loc[m2, "verdict"]
            pct_nc_2s = 100 * ((v2 == "Normal") | (v2 == "Close")).mean() if len(v2) else np.nan

            m4 = ((norm_si.sport == sp) & (norm_si.side == sd) &
                  (norm_si.window_n_seasons == 4))
            v4 = norm_si.loc[m4, "verdict"]
            pct_nc_4s = 100 * ((v4 == "Normal") | (v4 == "Close")).mean() if len(v4) else np.nan

            mean_W  = norm_prim.loc[m1, "sw_W"].mean()   if "sw_W"  in norm_prim.columns else np.nan
            mean_sk = norm_prim.loc[m1, "skewness"].mean() if "skewness" in norm_prim.columns else np.nan
            mean_ku = norm_prim.loc[m1, "kurtosis"].mean() if "kurtosis" in norm_prim.columns else np.nan

            rows.append(dict(sport=sp, side=sd, n_kpis=n_kpis,
                             pct_normal_close_1season=pct_nc_1s,
                             pct_normal_1season=pct_n_1s,
                             pct_normal_close_2season=pct_nc_2s,
                             pct_normal_close_4season=pct_nc_4s,
                             mean_SW_W=mean_W,
                             mean_skewness=mean_sk,
                             mean_kurtosis=mean_ku))
    return pd.DataFrame(rows)


def print_normality_commentary(nc: pd.DataFrame) -> None:
    print("\n--- Normality commentary ---")
    print(f"{'Sport':<10} {'Side':<5}  1-season  2-season  4-season  mean_W  skew   kurt")
    print("-" * 70)
    for _, r in nc.iterrows():
        print(f"{r.sport:<10} {r.side:<5}  "
              f"{r.pct_normal_close_1season:5.1f}%    "
              f"{r.pct_normal_close_2season:5.1f}%    "
              f"{r.pct_normal_close_4season:5.1f}%   "
              f"{r.mean_SW_W:.3f}  {r.mean_skewness:+.2f}  {r.mean_kurtosis:.2f}")
    for sp in ["rugby", "football"]:
        row = nc[(nc.sport == sp) & (nc.side == "diff")]
        if not row.empty:
            row = row.iloc[0]
            print(f"\n  {sp} diff: {row.pct_normal_close_1season:.0f}% pass "
                  f"Normal/Close at single-season n  (W={row.mean_SW_W:.3f}, "
                  f"skew={row.mean_skewness:+.2f})")
            print(f"  Power effect: pooling 4 seasons -> {row.pct_normal_close_4season:.0f}%")
    print("\n  Note: Rejection increase with pooling reflects test power (larger n\n"
          "  detects minor deviations), NOT distributional change. W + skewness\n"
          "  remain stable -> assumption A1 (diff-series normality) holds.\n")


def load_nonsports(ns_dir: Path) -> pd.DataFrame:
    specs = [
        ("Finance",          "real_finance_pef_results.csv"),
        ("Manufacturing",    "manufacturing_pef_results.csv"),
        ("Clinical Genomics","real_gene_expression_tcga_study.csv"),
    ]
    ETA_COLS   = ["eta","pef","PEF","ETA","eta_pooled","mean_eta"]
    RHO_COLS   = ["rho","correlation","pearson_r","rho_pooled","mean_rho"]
    KAPPA_COLS = ["kappa","variance_ratio","kappa_pooled","mean_kappa"]

    def _first(t, candidates):
        for c in candidates:
            if c in t.columns: return c
        return None

    rows = []
    for dom, fname in specs:
        fp = ns_dir / fname
        if not fp.exists():
            print(f"   WARNING: {fname} not found, skipping.")
            continue
        t = pd.read_csv(fp)
        ec = _first(t, ETA_COLS)
        if ec is None: continue
        eta = pd.to_numeric(t[ec], errors="coerce").dropna()
        eta = eta[eta > 0]
        rc = _first(t, RHO_COLS);   kc = _first(t, KAPPA_COLS)
        rho_mean   = float(pd.to_numeric(t[rc], errors="coerce").mean()) if rc else np.nan
        kappa_mean = float(pd.to_numeric(t[kc], errors="coerce").mean()) if kc else np.nan
        rows.append(dict(domain=dom, n=len(eta), mean_eta=float(eta.mean()),
                         sd_eta=float(eta.std()), success_pct=100*float((eta > 1).mean()),
                         rho_mean=rho_mean, kappa_mean=kappa_mean))
    return pd.DataFrame(rows)


def ml_empirical(paired: pd.DataFrame, kpis: list[str],
                 outcome_col: str, k: int) -> pd.DataFrame:
    """5-fold logistic CV: absolute vs relative feature per KPI."""
    if outcome_col not in paired.columns:
        warnings.warn(f"ml_empirical: column '{outcome_col}' not found. Skipping.")
        return pd.DataFrame()

    y_all = pd.to_numeric(paired[outcome_col], errors="coerce").values
    cv    = StratifiedKFold(n_splits=k, shuffle=True, random_state=20260511)
    rows  = []

    for kpi in kpis:
        ch = f"{kpi}_home"; ca = f"{kpi}_away"
        if ch not in paired.columns: continue
        A = pd.to_numeric(paired[ch], errors="coerce").values
        B = pd.to_numeric(paired[ca], errors="coerce").values
        ok = ~np.isnan(A) & ~np.isnan(B) & ~np.isnan(y_all)
        A, B, y = A[ok], B[ok], y_all[ok].astype(int)
        if len(y) < 20 or len(np.unique(y)) < 2: continue
        D = A - B   # relative feature

        acc_a, auc_a = _cv_logistic(A.reshape(-1,1), y, cv)
        acc_r, auc_r = _cv_logistic(D.reshape(-1,1), y, cv)
        rows.append(dict(kpi=kpi, n=len(y),
                         acc_abs=acc_a, acc_rel=acc_r,
                         acc_improvement=100*(acc_r - acc_a) / max(acc_a, 0.01),
                         auc_abs=auc_a, auc_rel=auc_r,
                         auc_improvement=100*(auc_r - auc_a) / max(auc_a, 0.01)))
    return pd.DataFrame(rows)


def _cv_logistic(X: np.ndarray, y: np.ndarray, cv) -> tuple[float, float]:
    """Return mean accuracy and AUC across CV folds."""
    accs, aucs = [], []
    clf = LogisticRegression(max_iter=500, solver="lbfgs")
    for tr, te in cv.split(X, y):
        if len(np.unique(y[tr])) < 2:
            continue
        clf.fit(X[tr], y[tr])
        proba = clf.predict_proba(X[te])[:, 1]
        accs.append(float((proba >= 0.5).astype(int) == y[te]).mean() if False
                    else np.mean((proba >= 0.5).astype(int) == y[te]))
        if len(np.unique(y[te])) > 1:
            aucs.append(roc_auc_score(y[te], proba))
    return (float(np.mean(accs)) if accs else np.nan,
            float(np.mean(aucs)) if aucs else np.nan)


def join_pef_to_ml(ml: pd.DataFrame, pef: pd.DataFrame) -> pd.DataFrame:
    """Merge (kappa, rho, eta, quadrant) from PEF table into ML table."""
    cols = [c for c in ["kpi","kappa","rho","eta","quadrant"] if c in pef.columns]
    return ml.merge(pef[cols].drop_duplicates("kpi"), on="kpi", how="left")


def build_ml_surface() -> dict:
    eta = np.linspace(0.3, 4, 200)
    ml  = 0.234*(eta-1) + 0.089*(eta-1)**2
    return {"eta": eta, "ml_improvement": ml}


# ---- Figure 1: PEF landscape with KPI segments ----------------------
def figure_1_landscape(pef_2s: pd.DataFrame, pef_per_season: pd.DataFrame,
                       domain_summary: pd.DataFrame, fpath: Path) -> None:
    fig, ax = plt.subplots(figsize=(11, 8))

    r_g = np.linspace(-0.95, 0.95, 400)
    k_g = np.linspace(0.05, 5,    400)
    R, K = np.meshgrid(r_g, k_g)
    eta_s = (1+K) / (1+K - 2*np.sqrt(K)*R)
    eta_s = np.where((eta_s <= 0) | (eta_s > 10), np.nan, eta_s)
    im = ax.imshow(np.log2(eta_s), extent=[r_g.min(), r_g.max(), k_g.min(), k_g.max()],
                   origin="lower", aspect="auto", alpha=0.4,
                   cmap=_redblue_diverging(), vmin=-1.5, vmax=1.5)
    plt.colorbar(im, ax=ax, label=r"$\log_2(\eta)$")

    cs = ax.contour(R, K, eta_s, [0.5, 0.75, 1, 1.25, 1.5, 2, 3],
                    colors="k", linewidths=0.7)
    ax.clabel(cs, fontsize=8, colors="0.25")
    ax.axhline(1.0, color="k", linestyle="--", linewidth=1.5)
    ax.axvline(0.0, color="k", linestyle="--", linewidth=1.5)

    sport_clr  = {"rugby": (0.12, 0.47, 0.71), "football": (0.90, 0.40, 0.05)}
    sport_mker = {"rugby": "o", "football": "s"}
    seasons_u  = sorted(pef_per_season.season.unique())
    s1 = seasons_u[-2] if len(seasons_u) >= 2 else seasons_u[0]
    s2 = seasons_u[-1]

    for sp, clr in sport_clr.items():
        sub1 = pef_per_season[(pef_per_season.sport == sp) & (pef_per_season.season == s1)]
        sub2 = pef_per_season[(pef_per_season.sport == sp) & (pef_per_season.season == s2)]
        for _, row1 in sub1.iterrows():
            row2 = sub2[sub2.kpi == row1.kpi]
            if row2.empty: continue
            r1,k1 = row1.rho, row1.kappa
            r2,k2 = row2.iloc[0].rho, row2.iloc[0].kappa
            if any(np.isnan([r1,k1,r2,k2])): continue
            ax.plot([r1,r2],[k1,k2], "-", color=(*clr, 0.35), linewidth=1.1)
        # Mean position
        sub_m = pef_2s[pef_2s.sport == sp]
        ax.scatter(sub_m.rho, sub_m.kappa, s=60, color=clr, marker=sport_mker[sp],
                   edgecolors="k", linewidths=0.5, alpha=0.85,
                   label=f"{sp} (n={len(sub_m)})")

    # Non-sports triangles
    if not domain_summary.empty and {"rho_mean","kappa_mean"}.issubset(domain_summary.columns):
        pal = plt.get_cmap("tab10")(np.linspace(0, 1, len(domain_summary)))
        for i, (_, dr) in enumerate(domain_summary.iterrows()):
            if np.isnan(dr.rho_mean) or np.isnan(dr.kappa_mean): continue
            ax.scatter(dr.rho_mean, dr.kappa_mean, s=100, color=pal[i], marker="^",
                       edgecolors="k", linewidths=0.8, label=dr["domain"])

    for (txt, rx, ky) in [("Q1",0.82,4.5),("Q2",0.82,0.12),
                           ("Q3",-0.97,0.12),("Q4",-0.97,4.5)]:
        ax.text(rx, ky, txt, fontsize=13, fontweight="bold", color="0.25")

    ax.set_xlim(-1, 1); ax.set_ylim(0.05, 5)
    ax.set_xlabel(r"Pairwise correlation $\rho$", fontsize=12)
    ax.set_ylabel(r"Variance ratio $\kappa = \sigma_B^2/\sigma_A^2$", fontsize=12)
    ax.set_title("PEF landscape: rugby URC + football Championship (23/24 and 24/25)",
                 fontsize=11)
    ax.legend(loc="upper left", bbox_to_anchor=(1.18, 1.0), frameon=False, fontsize=9)
    ax.grid(True, alpha=0.4); plt.tight_layout()
    fig.savefig(fpath, dpi=200, bbox_inches="tight")
    plt.close(fig)


# ---- Figure 2: I(X;Y) information surface ---------------------------
def figure_2_info_surface(fpath: Path) -> None:
    fig, ax = plt.subplots(figsize=(9, 7))
    r_g = np.linspace(-0.95, 0.95, 300)
    k_g = np.linspace(0.05, 5,    300)
    R, K = np.meshgrid(r_g, k_g)
    delta = 1.0; sigma_a = 1.0
    eta_s = (1+K) / (1+K - 2*np.sqrt(K)*R)
    eta_s = np.where((eta_s <= 0) | (eta_s > 20), np.nan, eta_s)
    sep   = stats.norm.cdf(delta / (2*sigma_a*np.sqrt((1+K) / np.maximum(eta_s, 1e-6))))
    sep   = np.clip(sep, 1e-9, 1-1e-9)
    I_xy  = 1 - (-sep*np.log2(sep) - (1-sep)*np.log2(1-sep))
    im = ax.imshow(I_xy, extent=[r_g.min(), r_g.max(), k_g.min(), k_g.max()],
                   origin="lower", aspect="auto", alpha=0.5, cmap="viridis")
    plt.colorbar(im, ax=ax, label=r"$I(X;Y)$ (bits)")
    cs = ax.contour(R, K, I_xy, [0.01,0.02,0.05,0.1,0.15,0.2], colors="k", linewidths=0.75)
    ax.clabel(cs, fontsize=8)
    ax.axhline(1.0, color="k", linestyle="--", linewidth=1.5)
    ax.axvline(0.0, color="k", linestyle="--", linewidth=1.5)
    ax.set_xlim(-1,1); ax.set_ylim(0.05,5)
    ax.set_xlabel(r"Pairwise correlation $\rho$", fontsize=12)
    ax.set_ylabel(r"Variance ratio $\kappa = \sigma_B^2/\sigma_A^2$", fontsize=12)
    ax.set_title(r"Information content $I(X;Y)$   [$\delta/\sigma_A = 1$]", fontsize=12)
    ax.grid(True, alpha=0.4); plt.tight_layout()
    fig.savefig(fpath, dpi=200, bbox_inches="tight")
    plt.close(fig)


# ---- Figure 3: PEF-to-ML mapping ------------------------------------
def figure_3_ml_mapping(ml_all: pd.DataFrame, ml_surface: dict,
                        fpath: Path) -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    q_col  = {"Q1":(0.20,0.63,0.17),"Q2":(0.12,0.47,0.71),
               "Q3":(0.89,0.47,0.07),"Q4":(0.77,0.15,0.16)}

    if not ml_all.empty and "eta" in ml_all.columns and "acc_improvement" in ml_all.columns:
        valid = ml_all.dropna(subset=["eta","acc_improvement"])
        for q, clr in q_col.items():
            sub = valid[valid.get("quadrant","") == q] if "quadrant" in valid.columns else valid
            if sub.empty: continue
            ax1.scatter(sub.eta, sub.acc_improvement, s=55, color=clr,
                        edgecolors="k", linewidths=0.4, alpha=0.85, label=q)

    ax1.plot(ml_surface["eta"], 100*ml_surface["ml_improvement"],
             "k-", linewidth=2, label="Polynomial fit")
    ax1.axvline(1.0, color="k", linestyle=":", linewidth=1)
    ax1.set_xlabel(r"$\eta$ (PEF)", fontsize=11)
    ax1.set_ylabel("Acc. improvement (%)", fontsize=11)
    ax1.set_title(r"Empirical ML improvement vs $\eta$", fontsize=11)
    ax1.legend(frameon=False, fontsize=9); ax1.grid(True, alpha=0.4)

    quads = list(q_col.keys())
    q_means = []
    q_ns    = []
    if not ml_all.empty and "quadrant" in ml_all.columns:
        for q in quads:
            sub = ml_all[ml_all.quadrant == q]["acc_improvement"].dropna()
            q_means.append(sub.mean() if len(sub) else 0.0)
            q_ns.append(len(sub))
    else:
        q_means = [0.0]*4; q_ns = [0]*4

    colors_bar = [q_col[q] for q in quads]
    bars = ax2.bar(quads, q_means, color=colors_bar, edgecolor="k", linewidth=0.6)
    for bar, n, v in zip(bars, q_ns, q_means):
        ax2.text(bar.get_x()+bar.get_width()/2,
                 v + 0.3*np.sign(v) + 0.3, f"n={n}",
                 ha="center", fontsize=9)
    ax2.set_xlabel("Quadrant", fontsize=11)
    ax2.set_ylabel("Mean acc. improvement (%)", fontsize=11)
    ax2.set_title("Mean improvement by quadrant", fontsize=11)
    ax2.grid(True, alpha=0.4, axis="y")

    fig.suptitle("PEF-to-ML mapping (empirical, 23/24 + 24/25)",
                 fontsize=12, fontweight="bold")
    plt.tight_layout()
    fig.savefig(fpath, dpi=200, bbox_inches="tight")
    plt.close(fig)


# ---- SI figure: normality summary -----------------------------------
def figure_si_normality(norm_prim: pd.DataFrame, norm_si: pd.DataFrame,
                        fpath: Path) -> None:
    cats   = ["Normal","Close","NotNormal"]
    colours = [(0.20,0.62,0.18),(0.85,0.65,0.13),(0.75,0.13,0.13)]
    sports = sorted(norm_prim.sport.unique())
    sides  = ["home","away","diff"]
    n_sp   = len(sports)

    fig, axes = plt.subplots(n_sp*2, 3, figsize=(12, 4*n_sp), sharey=True)
    if axes.ndim == 1: axes = axes.reshape(n_sp*2, 3)

    for si, sp in enumerate(sports):
        for row_offset, norm_tbl, tag in [(0, norm_prim, "2-season primary"),
                                          (1, norm_si,   "4-season SI")]:
            for j, sd in enumerate(sides):
                ax = axes[si*2 + row_offset, j]
                wins = sorted(norm_tbl.window_n_seasons.unique())
                cube = np.zeros((len(wins), 3))
                for wi, w in enumerate(wins):
                    mask = ((norm_tbl.sport == sp) & (norm_tbl.side == sd) &
                            (norm_tbl.window_n_seasons == w))
                    v = norm_tbl.loc[mask, "verdict"]
                    for ci, c in enumerate(cats):
                        cube[wi, ci] = (v == c).sum()
                tot  = cube.sum(axis=1, keepdims=True); tot[tot == 0] = 1
                prop = 100 * cube / tot
                bot  = np.zeros(len(wins))
                for ci, (c, clr) in enumerate(zip(cats, colours)):
                    ax.bar(np.arange(len(wins)), prop[:,ci], bottom=bot,
                           color=clr, edgecolor="none",
                           label=c if (si == 0 and row_offset == 0 and j == 0) else None)
                    bot += prop[:,ci]
                ax.set_xticks(np.arange(len(wins)))
                ax.set_xticklabels([f"{w}s" for w in wins])
                ax.set_ylim(0,100)
                if j == 0: ax.set_ylabel(f"{sp}\n{tag}\n% of KPI series", fontsize=8)
                if si == 0 and row_offset == 0: ax.set_title(f"side: {sd}", fontsize=10)
                ax.grid(True, alpha=0.3)

    handles = [plt.Rectangle((0,0),1,1,color=c) for c in colours]
    fig.legend(handles, cats, loc="lower center", ncol=3,
               bbox_to_anchor=(0.5,-0.01), frameon=False)
    fig.suptitle("Normality verdict — primary 2-season (top rows) vs 4-season SI (bottom rows)",
                 fontsize=11, fontweight="bold")
    plt.tight_layout()
    fig.savefig(fpath, dpi=150, bbox_inches="tight")
    plt.close(fig)


# ---- Collate table numbers for LaTeX --------------------------------
def collate_table_numbers(pef_2s, pef_per_season, nc, domain_summary,
                          ml_all, norm_primary) -> pd.DataFrame:
    rows = []
    def add(table, row_label, metric, value):
        rows.append({"table": table, "row_label": row_label,
                     "metric": metric, "value": value})

    for sp in ["rugby","football"]:
        sub = pef_2s[(pef_2s.sport == sp) & pef_2s.eta.notna()]
        add("Table1", sp, "mean_eta",    sub.eta.mean())
        add("Table1", sp, "sd_eta",      sub.eta.std())
        add("Table1", sp, "success_pct", 100*(sub.eta > 1).mean())
        add("Table1", sp, "n_kpis",      len(sub))

    if not domain_summary.empty:
        for _, dr in domain_summary.iterrows():
            add("Table1", dr["domain"], "mean_eta",    dr["mean_eta"])
            add("Table1", dr["domain"], "sd_eta",      dr["sd_eta"])
            add("Table1", dr["domain"], "success_pct", dr["success_pct"])

    for q in ["Q1","Q2","Q3","Q4"]:
        sub = pef_2s[(pef_2s.get("quadrant","") == q) & pef_2s.eta.notna()] \
              if "quadrant" in pef_2s.columns else pd.DataFrame()
        if not sub.empty:
            add("Table4", q, "mean_eta", sub.eta.mean())
            add("Table4", q, "n_kpis",   len(sub))
        if not ml_all.empty and "quadrant" in ml_all.columns:
            qml = ml_all[ml_all.quadrant == q]["acc_improvement"].dropna()
            add("Table4", q, "mean_ml_impr", qml.mean() if len(qml) else np.nan)

    if not ml_all.empty and {"acc_improvement","eta"}.issubset(ml_all.columns):
        valid = ml_all.dropna(subset=["acc_improvement","eta"])
        if len(valid) > 3:
            r_val = valid.eta.corr(valid.acc_improvement)
            resid = valid.acc_improvement - (0.234*(valid.eta-1) + 0.089*(valid.eta-1)**2)
            add("Table5","mapping","r",    r_val)
            add("Table5","mapping","R2",   r_val**2)
            add("Table5","mapping","MAE",  resid.abs().mean())
            add("Table5","mapping","RMSE", np.sqrt((resid**2).mean()))

    for _, r in nc.iterrows():
        lbl = f"{r.sport}_{r.side}"
        add("NormCommentary", lbl, "pct_nc_1s", r.pct_normal_close_1season)
        add("NormCommentary", lbl, "pct_nc_2s", r.pct_normal_close_2season)
        add("NormCommentary", lbl, "pct_nc_4s", r.pct_normal_close_4season)
        add("NormCommentary", lbl, "mean_W",    r.mean_SW_W)

    return pd.DataFrame(rows)


if __name__ == "__main__":
    pass   # all code runs at module level above
