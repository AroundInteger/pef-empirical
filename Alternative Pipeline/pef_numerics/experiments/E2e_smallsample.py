"""Phase 2e: small-sample corrections for the Fisher-z interval on rho_eff.
Variants: variance divisor n (asymptotic), n-2 (Lin 1989), n-3 (Fisher r);
normal vs t_{n-2} quantile. 20,000 reps per cell, vectorised (no bootstrap)."""
import os, sys, itertools
import numpy as np, pandas as pd
from scipy import stats
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pef import rho_eff
from pef.runtime import scale
from E2_inference import cov2, suff, reff_hat, delta_var_reff

R = scale(20_000, 1_000)
rows = []
rng = np.random.default_rng(42)
for n, kappa, rho in itertools.product([10, 15, 20, 30, 50, 100], [1, 4, 0.25], [-0.5, 0, 0.3, 0.6, 0.8, 0.9, 0.95]):
    L = np.linalg.cholesky(cov2(kappa, rho))
    X = rng.standard_normal((R, n, 2)) @ L.T
    s = suff(X)
    r = reff_hat(*s)
    true_r = rho_eff(kappa, rho)
    z = np.arctanh(np.clip(r, -0.999999, 0.999999))
    vn = delta_var_reff(*s, 1.0) / (1 - r ** 2) ** 2          # n * Var(atanh)
    for div_name, div in (("n", n), ("n-2", n - 2), ("n-3", n - 3)):
        for qname, q in (("z", stats.norm.ppf(.975)), ("t", stats.t.ppf(.975, n - 2))):
            se = np.sqrt(vn / div)
            cov = np.mean((np.tanh(z - q * se) <= true_r) & (true_r <= np.tanh(z + q * se)))
            rows.append(dict(n=n, kappa=kappa, rho=rho, variant=f"{div_name}/{qname}", coverage=cov))
df = pd.DataFrame(rows)
df.to_csv("results/E2e_smallsample.csv", index=False)
mcse = np.sqrt(.95 * .05 / R)
print(f"MC SE per cell: {mcse:.4f}")
g = df.groupby(["variant", "n"]).coverage
print(g.mean().unstack().round(3))
print("\nworst cell:"); print(g.min().unstack().round(3))
print("\nmax |coverage-0.95|:"); print(df.assign(e=(df.coverage-.95).abs()).groupby(["variant","n"]).e.max().unstack().round(3))
