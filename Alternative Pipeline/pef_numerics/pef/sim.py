"""Samplers for the generative model, plus the population-true index."""
import numpy as np
from .model import FEATURES


def sample(p, n, rng):
    """Draw n observations. Returns dict with S, N, K (n x 2), M, Y."""
    S = rng.multivariate_normal(p.mu, p.Sigma_S, n, method="cholesky")
    N = rng.multivariate_normal(np.zeros(2), p.Sigma_N, n, method="cholesky")
    K = S + N
    M = S @ p.b + p.sigma_eps * rng.standard_normal(n)
    return dict(S=S, N=N, K=K, M=M, Y=(M > 0).astype(int))


def true_index(p, K, feature):
    """Standardised population-best linear index u for a feature set,
    and r = corr(index, M) >= 0. Uses true parameters (no fitting)."""
    T = FEATURES[feature]
    F = K @ T.T
    SKT = T @ p.Sigma_K @ T.T
    cov_FM = T @ p.Sigma_S @ p.b
    beta = np.linalg.solve(SKT, cov_FM)
    mu_F = T @ p.mu
    L = (F - mu_F) @ beta
    sd_L = np.sqrt(beta @ SKT @ beta)
    r = float(beta @ cov_FM / (sd_L * np.sqrt(p.var_M)))
    return L / sd_L, r
