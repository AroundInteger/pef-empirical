"""Stored counterexample: total eta = 2 does not determine R^2_D.

Three explicit (Sigma_S, Sigma_N, b) with eta(Sigma_S + Sigma_N) = 2 and
R^2_D in {0.80, 0.33, 0}. Exact, not Monte Carlo. The zero case has no
signal in the difference (c' Sigma_S b = 0) while the summed covariance
still has eta = 2.
"""
import os
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

import sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from pef import Params, eta_component, r2

C = np.array([1.0, -1.0])


def pack(name, target, Sigma_S, Sigma_N, b, sigma_eps):
    p = Params(np.asarray(Sigma_S, float), np.asarray(Sigma_N, float),
               np.zeros(2), np.asarray(b, float), float(sigma_eps))
    eta_hat = eta_component(p.Sigma_K)
    r2_d = r2(p, "D")
    if abs(eta_hat - 2) > 1e-10 or abs(r2_d - target) > 1e-10:
        raise SystemExit(f"{name}: eta={eta_hat}, R2_D={r2_d}, target {target}")
    row = dict(case=name, target_r2=target, eta=eta_hat, r2_D=r2_d,
               sigma_eps=sigma_eps)
    for lab, M in (("S", p.Sigma_S), ("N", p.Sigma_N)):
        row[f"{lab}11"], row[f"{lab}12"], row[f"{lab}22"] = M[0, 0], M[0, 1], M[1, 1]
    row["b_A"], row["b_B"] = p.b[0], -p.b[1]
    row["signal_difference"] = float(C @ p.Sigma_S @ p.b)
    return row


def main():
    rows = [
        pack("high", 0.80,
             [[1.0, 0.2], [0.2, 1.0]],
             [[1.0, 0.8], [0.8, 1.0]],
             [1.0, -1.0], 0.0),
        pack("mid", 0.33,
             [[1.0, 0.67], [0.67, 1.0]],
             [[1.0, 0.33], [0.33, 1.0]],
             [1.0, -1.0], 0.0),
        pack("zero", 0.0,
             [[0.5, 0.5], [0.5, 0.5]],
             [[1.0, 0.25], [0.25, 1.0]],
             [1.0, 0.0], 1.0),
    ]
    os.makedirs("results", exist_ok=True)
    df = pd.DataFrame(rows)
    df.to_csv("results/E5_eta2_counterexample.csv", index=False)
    fig, ax = plt.subplots(figsize=(5.2, 3.4))
    ax.bar(df["case"], df["r2_D"], color="#4C78A8")
    ax.axhline(0, color="black", lw=0.6)
    ax.set_ylabel(r"Population $R^2_D$")
    ax.set_xlabel(r"Case (total $\eta = 2$ in every case)")
    ax.set_ylim(-0.02, 1.0)
    fig.tight_layout()
    fig.savefig("results/E5_eta2_counterexample.png", dpi=140)
    plt.close(fig)
    print(df[["case", "eta", "r2_D", "signal_difference"]].round(6).to_string(index=False))


if __name__ == "__main__":
    main()
