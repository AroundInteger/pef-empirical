"""Build the main-text alignment and gap figure from E6_sports.csv.

Panel A: LR histograms with landmarks at 2 and 3.84.
Panel B: per-KPI D vs (A,B) gaps in milli-nats, coloured by informative flag,
with a sport-level -1/(2 n_train) reference.

Run from the package root:
  python analysis/plot_sports_alignment.py
"""
from __future__ import annotations

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

HERE = Path(__file__).resolve().parent
PKG = HERE.parent
REPO = PKG.parent.parent
CSV = PKG / "results" / "E6_sports.csv"
OUT = REPO / "figures" / "Figure_E6_alignment_logloss.png"


def main() -> None:
    df = pd.read_csv(CSV)
    df["gap_Df_mn"] = 1000.0 * df["gap_D_minus_full"]

    fig, axes = plt.subplots(1, 2, figsize=(8.6, 3.8))

    ax = axes[0]
    for sport, colour in (("rugby", "#1f77b4"), ("football", "#ff7f0e")):
        g = df.loc[df.sport == sport, "lr"]
        ax.hist(g, bins=15, alpha=0.55, label=sport, color=colour)
    ax.axvline(2.0, color="black", linestyle="-", linewidth=1.2, label=r"$\Lambda=2$")
    ax.axvline(3.84, color="black", linestyle="--", linewidth=1.2, label=r"$\chi^2_1$ 5%")
    ax.set_xlabel(r"Likelihood-ratio statistic for $\beta_A+\beta_B=0$")
    ax.set_ylabel("KPIs")
    ax.legend(frameon=False, fontsize=8)
    ax.text(0.02, 0.98, "(A)", transform=ax.transAxes, va="top", ha="left",
            fontsize=14, fontweight="bold")

    ax = axes[1]
    sports = ["rugby", "football"]
    rng = np.random.default_rng(0)
    for i, sport in enumerate(sports):
        g = df.loc[df.sport == sport]
        x = i + rng.uniform(-0.12, 0.12, size=len(g))
        info = g.informative.to_numpy(bool)
        ax.scatter(x[~info], g.loc[~info, "gap_Df_mn"], s=22, alpha=0.55,
                   c="#7f7f7f", label="not informative" if i == 0 else None, zorder=2)
        ax.scatter(x[info], g.loc[info, "gap_Df_mn"], s=36, alpha=0.9,
                   c="#d62728", label="informative" if i == 0 else None, zorder=3)
        ref = -float(g.half_n_train_mn.median())
        ax.hlines(ref, i - 0.35, i + 0.35, colors="black", linestyles="--", linewidth=1.2)
    ax.axhline(0.0, color="0.5", linewidth=0.8)
    ax.set_xticks([0, 1], sports)
    ax.set_ylabel(r"Gap $\mathrm{LL}(D)-\mathrm{LL}(A,B)$ (milli-nats)")
    ax.legend(frameon=False, fontsize=8, loc="upper right")
    ax.text(0.02, 0.98, "(B)", transform=ax.transAxes, va="top", ha="left",
            fontsize=14, fontweight="bold")
    # Caption note: dashed segments are -1/(2 n_train) at the sport median.

    fig.tight_layout()
    OUT.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(OUT, dpi=300, bbox_inches="tight", facecolor="white")
    plt.close(fig)
    print(f"Wrote {OUT}")


if __name__ == "__main__":
    main()
