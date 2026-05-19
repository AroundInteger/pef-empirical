#!/usr/bin/env python3
"""
run_pef_normality_analysis.py

Python equivalent of the MATLAB driver at
    scripts/PEF_Normality_4seasons/run_pef_normality_analysis.m

End-to-end PEF + normality analysis for the rugby union (URC) and football
(English Championship) datasets across 4 seasons each.

Pipeline
--------
1. Load paired (home, away) match-level KPI data.
2. Compute kappa, rho, eta (PEF) and four-quadrant label per KPI, pooled
   across all 4 seasons and per season.
3. Run Shapiro-Wilk + Lilliefors normality tests on each KPI for the
   home, away, and home-away difference series, across:
        - each season alone (4 windows)
        - two 2-season pools (first half, second half)
        - the full 4-season pool
4. Curate exemplar KPIs in each PEF quadrant and split by
   attacking / defensive / discipline role.
5. Write all results to CSV and produce two summary figures.

Outputs land in `outputs/` next to this script.

Dependencies
------------
    pip install numpy pandas scipy statsmodels matplotlib

References
----------
    Shapiro, S.S. & Wilk, M.B. (1965). An analysis of variance test for
        normality (complete samples). Biometrika 52, 591-611.
    Lilliefors, H.W. (1967). On the Kolmogorov-Smirnov test for normality
        with mean and variance unknown. JASA 62, 399-402.

This is the Python mirror; the MATLAB version implements the Royston (1992)
extension of Shapiro-Wilk in-house via `swtest.m`, which is valid up to
n = 5000. scipy.stats.shapiro covers the same range, so results agree.
"""
from __future__ import annotations

import os
import glob
import sys
import warnings
from dataclasses import dataclass
from pathlib import Path

import numpy as np
import pandas as pd
from scipy import stats
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap

try:
    from statsmodels.stats.diagnostic import lilliefors as _lilliefors
    _HAS_LILLIEFORS = True
except ImportError:
    _HAS_LILLIEFORS = False
    warnings.warn(
        "statsmodels not installed; Lilliefors test will be unavailable. "
        "Install with `pip install statsmodels` for full parity with MATLAB."
    )


# =====================================================================
# Paths
# =====================================================================
HERE = Path(__file__).resolve().parent                  # scripts/PEF_Normality_4seasons/python
REPO_ROOT = HERE.parent.parent.parent                   # overleaf_pef_article/
RUGBY_CSV = REPO_ROOT / "Data" / "Rugby" / "Raw" / "4_seasons rugby abs.csv"
FOOT_DIR  = REPO_ROOT / "Data" / "Football" / "Raw" / "team_summaries_4seasons"
FOOT_FILES = [
    "championship_team_21_22.csv",
    "championship_team_22_23.csv",
    "championship_team_23_24.csv",
    "championship_team_24_25.csv",
]
OUT_DIR = HERE / "outputs"


# =====================================================================
# 1. Loaders
# =====================================================================
def load_rugby_paired(csv_path: Path) -> tuple[pd.DataFrame, list[str]]:
    """Long->wide pivot of the rugby URC dataset.

    Returns
    -------
    paired : DataFrame with columns season, matchid, home_team, away_team,
             plus {kpi}_home, {kpi}_away for every numeric KPI.
    kpi_names : list of KPI base names (suffix '_a' stripped).
    """
    df = pd.read_csv(csv_path)
    df["match_location"] = df["match_location"].str.lower().str.strip()

    kpi_cols = [c for c in df.columns if c.endswith("_a")]
    kpi_names = [c[:-2] for c in kpi_cols]

    # Coerce KPI columns to numeric.
    for c in kpi_cols:
        df[c] = pd.to_numeric(df[c], errors="coerce")

    home = df[df.match_location == "home"].set_index("matchid")
    away = df[df.match_location == "away"].set_index("matchid")
    common = home.index.intersection(away.index)

    dropped = (home.index.symmetric_difference(away.index)).size
    if dropped:
        warnings.warn(f"load_rugby_paired: dropped {dropped} matches without exactly one home+one away row")

    # Build dict of columns first (avoid pandas fragmentation warnings).
    out = {
        "season":    home.loc[common, "season"].values,
        "matchid":   common.values,
        "home_team": home.loc[common, "team"].values,
        "away_team": away.loc[common, "team"].values,
    }
    for c, base in zip(kpi_cols, kpi_names):
        out[f"{base}_home"] = home.loc[common, c].values
        out[f"{base}_away"] = away.loc[common, c].values
    paired = pd.DataFrame(out)
    return paired, kpi_names


def load_football_paired(csv_dir: Path, season_files: list[str]) -> tuple[pd.DataFrame, list[str]]:
    """Long->wide pivot across the 4 football Championship CSVs.

    Uses the intersection of numeric columns across all season files as the
    KPI set, after stripping obvious match-level metadata columns.
    """
    METADATA = {
        "match_id", "competition_country_name", "competition_name", "season_name",
        "home_team_id", "away_team_id", "match_date", "team_id", "team_name",
        "opposition_team_id", "opposition_team_name", "home_away", "result",
        "wins", "draws", "losses", "matches_played", "points",
    }

    frames = [pd.read_csv(csv_dir / f) for f in season_files]
    numeric_sets = []
    for d in frames:
        nums = {c for c in d.columns
                if pd.api.types.is_numeric_dtype(d[c]) and c not in METADATA}
        numeric_sets.append(nums)
    kpi_names = sorted(set.intersection(*numeric_sets))

    full = pd.concat(frames, ignore_index=True)
    full["home_away"] = full["home_away"].str.lower().str.strip()

    home = full[full.home_away == "home"].set_index("match_id")
    away = full[full.home_away == "away"].set_index("match_id")
    common = home.index.intersection(away.index)

    dropped = (home.index.symmetric_difference(away.index)).size
    if dropped:
        warnings.warn(f"load_football_paired: dropped {dropped} matches without exactly one home+one away row")

    out = {
        "season":    home.loc[common, "season_name"].values,
        "match_id":  common.values,
        "home_team": home.loc[common, "team_name"].values,
        "away_team": away.loc[common, "team_name"].values,
    }
    for c in kpi_names:
        out[f"{c}_home"] = home.loc[common, c].values
        out[f"{c}_away"] = away.loc[common, c].values
    paired = pd.DataFrame(out)
    return paired, kpi_names


# =====================================================================
# 2. PEF computation
# =====================================================================
def _classify_quadrant(kappa: float, rho: float) -> str:
    if np.isnan(kappa) or np.isnan(rho):
        return "NA"
    if kappa > 1 and rho > 0: return "Q1"
    if kappa < 1 and rho > 0: return "Q2"
    if kappa < 1 and rho < 0: return "Q3"
    if kappa > 1 and rho < 0: return "Q4"
    return "boundary"


def compute_pef(paired: pd.DataFrame, kpi_names: list[str], sport_label: str) -> pd.DataFrame:
    """Compute kappa, rho, eta and the quadrant per KPI.

    Home = entity A throughout, so kappa = var(away)/var(home). The output
    also reports `kappa_abs = max(var)/min(var)` as a side-symmetric
    asymmetry summary.
    """
    rows = []
    for k in kpi_names:
        ch, ca = f"{k}_home", f"{k}_away"
        if ch not in paired.columns or ca not in paired.columns:
            continue
        a = pd.to_numeric(paired[ch], errors="coerce").to_numpy()
        b = pd.to_numeric(paired[ca], errors="coerce").to_numpy()
        ok = np.isfinite(a) & np.isfinite(b)
        a, b = a[ok], b[ok]
        n = a.size
        if n < 4:
            continue
        vA, vB = float(np.var(a, ddof=1)), float(np.var(b, ddof=1))
        if vA <= 0 or vB <= 0:
            rows.append(dict(sport=sport_label, kpi=k, n=n,
                             var_home=vA, var_away=vB,
                             mean_home=float(np.mean(a)), mean_away=float(np.mean(b)),
                             cohens_d_paired=np.nan,
                             kappa=np.nan, rho=np.nan, eta=np.nan,
                             kappa_abs=np.nan, quadrant="degenerate",
                             p_rho=np.nan, sig_rho=False))
            continue
        kappa = vB / vA
        kappa_abs = max(vA, vB) / min(vA, vB)
        rho, p_rho = stats.pearsonr(a, b)
        denom = 1 + kappa - 2*np.sqrt(kappa)*rho
        eta = (1 + kappa) / denom if denom != 0 else np.nan
        d = a - b
        sd_d = float(np.std(d, ddof=1))
        cohens_d = float(np.mean(d) / sd_d) if sd_d > 0 else np.nan
        rows.append(dict(
            sport=sport_label, kpi=k, n=n,
            var_home=vA, var_away=vB,
            mean_home=float(np.mean(a)), mean_away=float(np.mean(b)),
            cohens_d_paired=cohens_d,
            kappa=kappa, rho=rho, eta=eta,
            kappa_abs=kappa_abs,
            quadrant=_classify_quadrant(kappa, rho),
            p_rho=p_rho, sig_rho=bool(p_rho < 0.05),
        ))
    return pd.DataFrame(rows)


# =====================================================================
# 3. Normality testing across season windows
# =====================================================================
def _safe_shapiro(x: np.ndarray, alpha: float = 0.05) -> tuple[float, float, bool]:
    x = x[np.isfinite(x)]
    if x.size < 4 or x.size > 5000 or np.std(x) == 0:
        return (np.nan, np.nan, False)
    try:
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")
            W, p = stats.shapiro(x)
        return (float(W), float(p), bool(p < alpha))
    except Exception:
        return (np.nan, np.nan, False)


def _safe_lilliefors(x: np.ndarray, alpha: float = 0.05) -> tuple[float, float, bool]:
    x = x[np.isfinite(x)]
    if x.size < 4 or np.std(x) == 0 or not _HAS_LILLIEFORS:
        return (np.nan, np.nan, False)
    try:
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")
            stat, p = _lilliefors(x, dist="norm", pvalmethod="approx")
        return (float(stat), float(p), bool(p < alpha))
    except Exception:
        return (np.nan, np.nan, False)


def _verdict_from_pvalues(p_sw: float, p_lill: float, alpha: float = 0.05) -> str:
    ps = [p for p in (p_sw, p_lill) if not np.isnan(p)]
    if not ps:
        return "NA"
    if all(p >= alpha for p in ps):
        return "Normal"
    if all(p >= 0.01  for p in ps):
        return "Close"
    return "NotNormal"


def normality_windows(paired: pd.DataFrame, kpi_names: list[str],
                      windows: list[list[str]], sport_label: str,
                      alpha: float = 0.05) -> pd.DataFrame:
    """Test KPI normality across user-specified season windows.

    For each KPI and window runs Shapiro-Wilk + Lilliefors on the home,
    away, and home-away difference series. Returns one row per
    (KPI, side, window) triple.
    """
    rows = []
    for win in windows:
        win_label = "+".join(str(s) for s in win)
        sub = paired[paired.season.isin(win)]
        for k in kpi_names:
            ch, ca = f"{k}_home", f"{k}_away"
            if ch not in sub.columns or ca not in sub.columns:
                continue
            a = pd.to_numeric(sub[ch], errors="coerce").to_numpy()
            b = pd.to_numeric(sub[ca], errors="coerce").to_numpy()
            ok = np.isfinite(a) & np.isfinite(b)
            a, b = a[ok], b[ok]
            d = a - b
            for side, x in (("home", a), ("away", b), ("diff", d)):
                if x.size < 4 or np.std(x) == 0:
                    continue
                sw_W, sw_p, sw_h = _safe_shapiro(x, alpha)
                lill_KS, lill_p, lill_h = _safe_lilliefors(x, alpha)
                sk = float(stats.skew(x, bias=False))
                ku = float(stats.kurtosis(x, fisher=False, bias=False))
                v = _verdict_from_pvalues(sw_p, lill_p, alpha)
                rows.append(dict(
                    sport=sport_label, kpi=k, side=side,
                    window_label=win_label, window_n_seasons=len(win),
                    n=int(x.size),
                    skewness=sk, kurtosis=ku,
                    sw_W=sw_W, sw_p=sw_p, sw_reject=sw_h,
                    lill_KS=lill_KS, lill_p=lill_p, lill_reject=lill_h,
                    verdict=v,
                ))
    return pd.DataFrame(rows)


def build_windows(season_list: list[str]) -> list[list[str]]:
    """Per-season + 2-season pooled (first half / second half) + 4-season pool."""
    seasons = sorted(set(season_list))
    windows = [[s] for s in seasons]
    if len(seasons) >= 4:
        windows.append([seasons[0], seasons[1]])
        windows.append([seasons[2], seasons[3]])
        windows.append(list(seasons))
    return windows


# =====================================================================
# 4. Exemplar curation
# =====================================================================
RUGBY_ROLES = {
    "attacking":  ["carries", "metres_made", "defenders_beaten", "clean_breaks",
                   "offloads", "passes", "kicks_from_hand", "kick_metres",
                   "rucks_won", "scrums_won", "lineout_throws_won", "final_points"],
    "defensive":  ["tackles", "missed_tackles", "turnovers_won",
                   "turnovers_conceded", "lineout_throws_lost"],
    "discipline": ["penalties_conceded", "scrum_pens_conceded",
                   "lineout_pens_conceded", "general_play_pens_conceded",
                   "free_kicks_conceded", "ruck_maul_tackle_pen_con", "red_cards"],
}

FOOTBALL_ROLES = {
    "attacking":  ["goals", "np_goals", "xg", "np_xg", "penalty_xg", "shots",
                   "shots_inside_box", "shots_outside_box", "big_chances",
                   "corners", "sp_goals", "sp_xg", "sp_shots", "shots_on_target",
                   "np_shots_on_target", "op_goals", "op_xg", "op_shots",
                   "goals_from_counters", "xg_from_counters", "passes",
                   "successful_passes", "op_passes", "successful_op_passes",
                   "passes_inside_box", "passes_into_box", "op_passes_into_box",
                   "passes_into_final_third", "op_passes_into_final_third",
                   "passes_in_final_third", "deep_completions", "long_balls",
                   "crosses", "dribbles", "carries", "carries_into_final_third",
                   "carries_into_box", "progressive_carries",
                   "deep_progressions", "box_entries", "obv", "on_ball_obv",
                   "obv_from_passes", "obv_from_carries",
                   "obv_from_dribbles", "obv_from_dribble_carry"],
    "defensive":  ["tackles", "successful_tackles", "ball_recoveries",
                   "regains", "regains_opposition_half",
                   "tackle_interceptions_opposition_half", "blocks",
                   "pressures", "pressures_opposition_half", "counterpressures",
                   "counterpressures_opposition_half", "defensive_obv"],
    "discipline": ["yellow_cards", "second_yellow_cards", "red_cards", "fouls"],
}

ROLE_MAP = {"rugby": RUGBY_ROLES, "football": FOOTBALL_ROLES}


def curate_exemplars(pef_tbl: pd.DataFrame, top_n: int = 3) -> pd.DataFrame:
    """Pick top-n exemplars per (sport, quadrant) and per (sport, role).

    Ranking criterion is |eta - 1| (largest pairing effect first), which
    surfaces the most illustrative KPIs in each cell.
    """
    t = pef_tbl.copy()
    # Attach role labels.
    role = pd.Series("unclassified", index=t.index, dtype="object")
    for sport, roles in ROLE_MAP.items():
        for role_name, kpis in roles.items():
            mask = (t.sport == sport) & (t.kpi.isin(kpis))
            role.loc[mask] = role_name
    t["role"] = role
    t["abs_dev_eta_1"] = (t.eta - 1).abs()

    rows = []
    quads = ["Q1", "Q2", "Q3", "Q4"]
    for sport in t.sport.unique():
        for q in quads:
            sub = t[(t.sport == sport) & (t.quadrant == q) & t.eta.notna()]
            if sub.empty:
                continue
            sub = sub.sort_values("abs_dev_eta_1", ascending=False).head(top_n).copy()
            sub["rank_in_group"] = np.arange(1, len(sub) + 1)
            sub["criterion"] = f"quadrant:{q}"
            rows.append(sub)
    for sport in t.sport.unique():
        for role_name in ROLE_MAP.get(sport, {}).keys():
            sub = t[(t.sport == sport) & (t.role == role_name) & t.eta.notna()]
            if sub.empty:
                continue
            sub = sub.sort_values("abs_dev_eta_1", ascending=False).head(top_n).copy()
            sub["rank_in_group"] = np.arange(1, len(sub) + 1)
            sub["criterion"] = f"role:{role_name}"
            rows.append(sub)
    exemplars = pd.concat(rows, ignore_index=True) if rows else pd.DataFrame()
    keep = ["sport", "kpi", "role", "quadrant", "kappa", "rho", "eta", "n",
            "abs_dev_eta_1", "rank_in_group", "criterion"]
    return exemplars[[c for c in keep if c in exemplars.columns]]


# =====================================================================
# 5. Plots
# =====================================================================
def _redblue_diverging(n: int = 256):
    return LinearSegmentedColormap.from_list(
        "redblue_diverging",
        [(0.05, 0.30, 0.55), (1.00, 1.00, 1.00), (0.65, 0.10, 0.10)],
        N=n,
    )


def plot_pef_landscape(pef_tbl: pd.DataFrame, save_path: Path) -> None:
    """(rho, kappa) scatter coloured by sport with iso-eta contours.

    Horizontal axis is correlation rho (typically more intuitive); vertical axis
    is variance ratio kappa.
    """
    t = pef_tbl[pef_tbl.eta.notna()].copy()

    fig, ax = plt.subplots(figsize=(11, 8))

    k_grid = np.linspace(0.05, 5, 400)
    r_grid = np.linspace(-0.95, 0.95, 400)
    # indexing='xy': row index -> kappa, col index -> rho (x = rho, y = kappa)
    R, K = np.meshgrid(r_grid, k_grid)
    eta_surf = (1 + K) / (1 + K - 2*np.sqrt(K)*R)
    eta_surf = np.where((eta_surf <= 0) | (eta_surf > 10), np.nan, eta_surf)
    log2_eta = np.log2(eta_surf)

    im = ax.imshow(log2_eta, extent=[r_grid.min(), r_grid.max(),
                                     k_grid.min(), k_grid.max()],
                   origin="lower", aspect="auto", alpha=0.45,
                   cmap=_redblue_diverging(), vmin=-1.5, vmax=1.5)
    cb = plt.colorbar(im, ax=ax)
    cb.set_label(r"$\log_2(\eta)$")

    cs = ax.contour(R, K, eta_surf, levels=[0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0],
                    colors="k", linewidths=0.75)
    ax.clabel(cs, fontsize=9, colors="0.25")
    ax.axhline(1.0, color="k", linestyle="--", linewidth=1.5)
    ax.axvline(0.0, color="k", linestyle="--", linewidth=1.5)

    sports = sorted(t.sport.unique())
    palette = plt.get_cmap("tab10")(np.arange(len(sports)))
    for i, sp in enumerate(sports):
        sub = t[t.sport == sp]
        ax.scatter(sub.rho, sub.kappa, s=90, color=palette[i],
                   edgecolor="k", alpha=0.85, label=sp)

    # Quadrant annotations: (x, y) = (rho, kappa)
    ax.text(0.85, 3.2, "Q1 (high $\\kappa$, +$\\rho$)", fontsize=11, fontweight="bold")
    ax.text(0.85, 0.22, "Q2 (low $\\kappa$, +$\\rho$)",  fontsize=11, fontweight="bold")
    ax.text(-0.92, 0.22, "Q3 (low $\\kappa$, -$\\rho$)", fontsize=11, fontweight="bold")
    ax.text(-0.92, 3.2, "Q4 (high $\\kappa$, -$\\rho$)", fontsize=11, fontweight="bold")

    ax.set_xlim(-1, 1); ax.set_ylim(0.05, 5)
    ax.set_xlabel(r"Pairwise correlation $\rho$")
    ax.set_ylabel(r"Variance ratio $\kappa = \sigma_B^2 / \sigma_A^2$")
    ax.set_title("PEF landscape: KPIs from 4 seasons rugby (URC) + football (English Championship)")
    ax.legend(loc="upper right", bbox_to_anchor=(1.3, 1.0), frameon=False)
    ax.grid(True, alpha=0.4)

    plt.tight_layout()
    fig.savefig(save_path, dpi=200, bbox_inches="tight")
    plt.close(fig)


def plot_normality_summary(norm_tbl: pd.DataFrame, save_path: Path) -> None:
    """Stacked-bar verdict proportions across (sport, side, window size)."""
    sports = sorted(norm_tbl.sport.unique())
    sides  = ["home", "away", "diff"]
    wins   = sorted(norm_tbl.window_n_seasons.unique())
    cats   = ["Normal", "Close", "NotNormal"]
    colours = {"Normal": "#349441",
               "Close":  "#d9a521",
               "NotNormal": "#bf3434"}

    fig, axes = plt.subplots(len(sports), len(sides),
                             figsize=(12, 7), sharey=True)
    if len(sports) == 1:
        axes = np.array([axes])

    for i, sp in enumerate(sports):
        for j, side in enumerate(sides):
            ax = axes[i, j]
            cube = np.zeros((len(wins), len(cats)))
            for wi, w in enumerate(wins):
                mask = ((norm_tbl.sport == sp) &
                        (norm_tbl.side == side) &
                        (norm_tbl.window_n_seasons == w))
                v = norm_tbl.loc[mask, "verdict"]
                for ci, c in enumerate(cats):
                    cube[wi, ci] = (v == c).sum()
            totals = cube.sum(axis=1, keepdims=True)
            totals[totals == 0] = 1
            props = 100 * cube / totals
            bottom = np.zeros(len(wins))
            for ci, c in enumerate(cats):
                ax.bar(np.arange(len(wins)), props[:, ci], bottom=bottom,
                       color=colours[c], edgecolor="none", label=c if (i == 0 and j == 0) else None)
                bottom = bottom + props[:, ci]
            ax.set_xticks(np.arange(len(wins)))
            ax.set_xticklabels([f"{w} seas." for w in wins])
            ax.set_ylim(0, 100)
            if j == 0:
                ax.set_ylabel(f"{sp}\n% of KPI series")
            if i == 0:
                ax.set_title(f"side: {side}")
            ax.grid(True, alpha=0.4)

    handles = [plt.Rectangle((0, 0), 1, 1, color=colours[c]) for c in cats]
    fig.legend(handles, cats, loc="lower center", ncol=3,
               bbox_to_anchor=(0.5, -0.02), frameon=False)
    fig.suptitle("Shapiro-Wilk + Lilliefors normality verdicts vs. season-window size",
                 fontsize=13, fontweight="bold")
    plt.tight_layout(rect=[0, 0.04, 1, 0.97])
    fig.savefig(save_path, dpi=200, bbox_inches="tight")
    plt.close(fig)


# =====================================================================
# 6. Rollups + reporting
# =====================================================================
def rollup_normality(norm_tbl: pd.DataFrame) -> pd.DataFrame:
    g = norm_tbl.groupby(["sport", "side", "window_n_seasons"])
    counts = g["verdict"].value_counts().unstack(fill_value=0)
    counts["n_tests"]      = counts.sum(axis=1)
    for col in ["Normal", "Close", "NotNormal"]:
        if col not in counts.columns:
            counts[col] = 0
    counts["pct_normal"]    = 100 * counts["Normal"]    / counts["n_tests"]
    counts["pct_close"]     = 100 * counts["Close"]     / counts["n_tests"]
    counts["pct_notnormal"] = 100 * counts["NotNormal"] / counts["n_tests"]
    out = counts.reset_index().rename(columns={
        "Normal": "n_normal", "Close": "n_close", "NotNormal": "n_notnormal"
    })
    return out.sort_values(["sport", "side", "window_n_seasons"]).reset_index(drop=True)


def tabulate_quadrants(pef_tbl: pd.DataFrame) -> pd.DataFrame:
    quads = ["Q1", "Q2", "Q3", "Q4", "boundary", "degenerate"]
    rows = []
    for q in quads:
        sub = pef_tbl[pef_tbl.quadrant == q]
        rows.append(dict(Quadrant=q,
                         N_KPIs=len(sub),
                         Mean_eta=float(sub.eta.mean()) if len(sub) else np.nan))
    return pd.DataFrame(rows)


def print_summary(pef_tbl: pd.DataFrame, norm_tbl: pd.DataFrame, exemplars: pd.DataFrame) -> None:
    sports = sorted(pef_tbl.sport.unique())
    print("\nPEF landscape (4-season pooled):")
    for sp in sports:
        sub = pef_tbl[(pef_tbl.sport == sp) & pef_tbl.eta.notna()]
        print(f"  {sp}: N_KPIs={len(sub)} | mean(eta)={sub.eta.mean():.3f} | % with eta>1 = {100*(sub.eta>1).mean():.1f}%")
        for q in ["Q1", "Q2", "Q3", "Q4"]:
            qsub = sub[sub.quadrant == q]
            if not qsub.empty:
                print(f"     {q}: n={len(qsub):2d}, mean(eta)={qsub.eta.mean():.3f}")

    print("\nNormality verdict by sport / side / window size (% Normal or Close):")
    sides = ["home", "away", "diff"]
    wins  = sorted(norm_tbl.window_n_seasons.unique())
    for sp in sports:
        for side in sides:
            parts = [f"  {sp:<8} {side:<4}"]
            for w in wins:
                mask = ((norm_tbl.sport == sp) &
                        (norm_tbl.side == side) &
                        (norm_tbl.window_n_seasons == w))
                v = norm_tbl.loc[mask, "verdict"]
                if v.empty:
                    parts.append(f" w={w}: n=0    ")
                else:
                    pct = 100 * ((v == "Normal") | (v == "Close")).mean()
                    parts.append(f" w={w}:{pct:5.1f}%")
            print(" ".join(parts))

    print("\nTop quadrant exemplars (rank 1 per sport, quadrant):")
    top = exemplars[(exemplars.criterion.str.startswith("quadrant:")) &
                    (exemplars.rank_in_group == 1)]
    for _, r in top.iterrows():
        print(f"  {r.sport:<8} {r.quadrant}: {r.kpi:<32} "
              f"kappa={r.kappa:6.2f}  rho={r.rho:+.3f}  eta={r.eta:5.3f}  n={int(r.n)}")


# =====================================================================
# Main driver
# =====================================================================
def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    np.random.seed(20260511)   # paper-stable seed

    print("=========================================================")
    print(" PEF + Normality analysis (rugby URC, football Championship)")
    print(f" Outputs -> {OUT_DIR}")
    print("=========================================================")

    # 1. Load
    print("\n[1/5] Loading paired data...")
    rugby_p, rugby_kpis = load_rugby_paired(RUGBY_CSV)
    foot_p,  foot_kpis  = load_football_paired(FOOT_DIR, FOOT_FILES)
    print(f"   rugby: {len(rugby_p)} matches across seasons "
          f"{sorted(rugby_p.season.unique())}, {len(rugby_kpis)} KPIs")
    print(f"   football: {len(foot_p)} matches across seasons "
          f"{sorted(foot_p.season.unique())}, {len(foot_kpis)} KPIs")

    # 2. PEF
    print("\n[2/5] Computing PEF landscape (4-season pooled)...")
    pef_r = compute_pef(rugby_p, rugby_kpis, "rugby")
    pef_f = compute_pef(foot_p,  foot_kpis,  "football")
    print("   Rugby quadrant distribution:")
    print(tabulate_quadrants(pef_r).to_string(index=False))
    print("   Football quadrant distribution:")
    print(tabulate_quadrants(pef_f).to_string(index=False))

    pef_landscape = pd.concat([pef_r, pef_f], ignore_index=True)
    pef_landscape.to_csv(OUT_DIR / "pef_landscape_pooled4.csv", index=False)

    # Per-season PEF (for the year-on-year stability segments in Figure 1)
    print("\n   Computing per-season PEF...")
    per_season = []
    for sp_label, paired, kpis in [("rugby", rugby_p, rugby_kpis),
                                   ("football", foot_p, foot_kpis)]:
        for season in sorted(paired.season.unique()):
            sub = paired[paired.season == season]
            pp = compute_pef(sub, kpis, sp_label)
            pp["season"] = season
            per_season.append(pp)
    pd.concat(per_season, ignore_index=True).to_csv(
        OUT_DIR / "pef_landscape_per_season.csv", index=False)

    # 3. Normality
    print("\n[3/5] Normality testing across season windows...")
    rugby_windows = build_windows(rugby_p.season.unique().tolist())
    foot_windows  = build_windows(foot_p.season.unique().tolist())
    norm_r = normality_windows(rugby_p, rugby_kpis, rugby_windows, "rugby")
    norm_f = normality_windows(foot_p,  foot_kpis,  foot_windows,  "football")
    normality_all = pd.concat([norm_r, norm_f], ignore_index=True)
    normality_all.to_csv(OUT_DIR / "normality_results.csv", index=False)

    roll = rollup_normality(normality_all)
    roll.to_csv(OUT_DIR / "normality_rollup.csv", index=False)

    # 4. Exemplars
    print("\n[4/5] Curating exemplar KPIs...")
    exemplars = curate_exemplars(pef_landscape, top_n=3)
    exemplars.to_csv(OUT_DIR / "pef_exemplars.csv", index=False)

    # 5. Figures
    print("\n[5/5] Generating figures...")
    plot_pef_landscape(pef_landscape, OUT_DIR / "pef_landscape.png")
    plot_normality_summary(normality_all, OUT_DIR / "normality_summary.png")

    print("\n--- Summary ---------------------------------------------")
    print_summary(pef_landscape, normality_all, exemplars)
    print("---------------------------------------------------------")
    print(f"Done. CSVs and figures saved in:\n   {OUT_DIR}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
