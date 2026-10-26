"""Recover eta_S / eta_N from the repeated-team model.

Rugby-like: 16 teams, one home and one away meeting per pair (240 matches).
Football-like: 24 teams, two seasons of a single home-and-away (1104 matches).
Wald intervals from the observed information. Coverage below 0.85 at either
size means Phase 6 must not quote the split.
"""
import os
import sys
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from pef.repeated import (double_round_robin, simulate, fit_repeated,
                          signal_noise_ratio, check_likelihood)

TRUTH = dict(mu=(0.2, -0.1), tau2=1.0, lam=0.5, vA=1.0, vB=1.44, rho=0.4)
DESIGNS = {
    "rugby": dict(n_teams=16, meetings=1, reps=60),
    "football": dict(n_teams=24, meetings=2, reps=30),
}


def main():
    gap = check_likelihood()
    print(f"Woodbury likelihood matches dense covariance (gap {gap:.2e})", flush=True)
    truth_ratio = signal_noise_ratio(TRUTH["lam"], TRUTH["vA"], TRUTH["vB"], TRUTH["rho"])[0]
    rows = []
    for name, spec in DESIGNS.items():
        h, a = double_round_robin(spec["n_teams"], spec["meetings"])
        print(f"{name}: {len(h)} matches, {spec['reps']} reps", flush=True)
        for rep in range(spec["reps"]):
            rng = np.random.default_rng(10_000 * spec["n_teams"] + rep)
            d = simulate(spec["n_teams"], h, a, rng, **TRUTH)
            fit = fit_repeated(d["home"], d["away"], d["h_idx"], d["a_idx"], spec["n_teams"])
            if not fit["ok"]:
                rows.append(dict(design=name, rep=rep, ok=False, ratio=np.nan, se=np.nan,
                                 cover=False, truth=truth_ratio))
                continue
            se = fit["se_ratio"]
            cover = bool(np.isfinite(se) and abs(fit["ratio"] - truth_ratio) <= 1.96 * se)
            rows.append(dict(design=name, rep=rep, ok=True, ratio=fit["ratio"], se=se,
                             cover=cover, lam=fit["lam"], tau2=fit["tau2"],
                             truth=truth_ratio))
            if rep % 10 == 0:
                print(f"  rep {rep}: ratio {fit['ratio']:.3f} se {se}", flush=True)
    df = pd.DataFrame(rows)
    os.makedirs("results", exist_ok=True)
    df.to_csv("results/E5_repeated_measures.csv", index=False)
    summary = []
    for name, g in df.groupby("design"):
        ok = g[g.ok]
        summary.append(dict(design=name, n_ok=int(ok.shape[0]), n=int(g.shape[0]),
                            mean_ratio=float(ok.ratio.mean()) if len(ok) else np.nan,
                            bias=float(ok.ratio.mean() - truth_ratio) if len(ok) else np.nan,
                            coverage=float(ok.cover.mean()) if len(ok) else 0.0))
    sm = pd.DataFrame(summary)
    sm.to_csv("results/E5_repeated_measures_summary.csv", index=False)
    fig, ax = plt.subplots(figsize=(5.4, 3.4))
    ax.bar(sm["design"], sm["coverage"], color="#4C78A8")
    ax.axhline(0.95, color="black", ls="--", lw=0.8, label="Nominal 0.95")
    ax.axhline(0.85, color="#E45756", ls=":", lw=0.8, label="Quote threshold 0.85")
    ax.set_ylim(0, 1.05)
    ax.set_ylabel("Wald coverage of eta_S / eta_N")
    ax.set_xlabel("Design size")
    ax.legend(fontsize=8)
    fig.tight_layout()
    fig.savefig("results/E5_repeated_measures.png", dpi=140)
    plt.close(fig)
    print(sm.round(3).to_string(index=False))
    print("truth ratio", round(truth_ratio, 4))


if __name__ == "__main__":
    main()
