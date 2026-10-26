"""Closed forms (STRATEGY.md Sections 2 and 3.2).

All population metrics use Theorem A: under joint Gaussianity, for a feature
set with best linear index L and r = corr(L, M) >= 0,
    P(Y=1 | F) = Phi((z + r u) / sqrt(1 - r^2)),   u = standardised L ~ N(0,1).
Metrics are 1-D integrals over u, evaluated on a fine grid.
Log-loss and mutual information are in nats.
"""
import numpy as np
from scipy.special import ndtr, log_ndtr
from scipy.integrate import trapezoid, cumulative_trapezoid
from .model import FEATURES

# ---------------------------------------------------------------- inferential PEF


def eta(kappa, rho):
    kappa = np.asarray(kappa, float)
    return (1 + kappa) / (1 + kappa - 2 * np.sqrt(kappa) * rho)


def rho_eff(kappa, rho):
    return rho * 2 * np.sqrt(kappa) / (1 + kappa)


def eta_component(Sigma):
    """PEF of a 2x2 covariance: (var_A + var_B) / Var(A - B)."""
    c = np.array([1.0, -1.0])
    return float(np.trace(Sigma) / (c @ Sigma @ c))

# ---------------------------------------------------------------- predictive R^2


def r2(p, feature):
    """Population R^2 of the best linear predictor of M from feature set."""
    T = FEATURES[feature]
    SKT = T @ p.Sigma_K @ T.T
    cov_FM = T @ p.Sigma_S @ p.b
    beta = np.linalg.solve(SKT, cov_FM)
    return float(beta @ cov_FM / p.var_M)


def beta_full(p):
    return np.linalg.solve(p.Sigma_K, p.Sigma_S @ p.b)


def alignment_cos2(p):
    """Theorem B: cos^2 of angle between beta and c in the Sigma_K metric."""
    c = np.array([1.0, -1.0])
    bta = beta_full(p)
    SK = p.Sigma_K
    return float((c @ SK @ bta) ** 2 / ((c @ SK @ c) * (bta @ SK @ bta)))


def reliability_D(p):
    """Theorem C: Var(S_D)/Var(D), directly and via the eta law."""
    c = np.array([1.0, -1.0])
    direct = float((c @ p.Sigma_S @ c) / (c @ p.Sigma_K @ c))
    Lam = np.trace(p.Sigma_N) / np.trace(p.Sigma_S)
    eS, eN = eta_component(p.Sigma_S), eta_component(p.Sigma_N)
    via_law = 1.0 / (1.0 + Lam * eS / eN)
    return direct, via_law

# ---------------------------------------------------------------- metrics


_U = np.linspace(-12.0, 12.0, 48001)
_PHI = np.exp(-0.5 * _U ** 2) / np.sqrt(2 * np.pi)


def _hb(logp, log1mp):
    p = np.exp(logp)
    return -(p * logp + (1 - p) * log1mp)


def population_metrics(z, r2_val):
    """Bayes-optimal population metrics given (z, r^2). Returns dict."""
    r = np.sqrt(min(max(r2_val, 0.0), 1.0 - 1e-12))
    s = np.sqrt(1 - r ** 2)
    a = (z + r * _U) / s
    logp, log1mp = log_ndtr(a), log_ndtr(-a)
    p = np.exp(logp)
    pi1 = float(ndtr(z))
    logloss = trapezoid(_hb(logp, log1mp) * _PHI, _U)
    brier = trapezoid(p * (1 - p) * _PHI, _U)
    acc = trapezoid(np.maximum(p, 1 - p) * _PHI, _U)
    H0 = float(_hb(np.log(pi1), np.log1p(-pi1))) if 0 < pi1 < 1 else 0.0
    mi = H0 - logloss
    # AUC = P(L1 > L0) = int p(u) phi(u) P(U<u, Y=0) du / (pi1 pi0)
    G = cumulative_trapezoid((1 - p) * _PHI, _U, initial=0.0)
    auc = trapezoid(p * _PHI * G, _U) / (pi1 * (1 - pi1))
    return dict(r2=float(r ** 2), logloss=float(logloss), brier=float(brier),
                accuracy=float(acc), mi=float(mi), auc=float(auc))


def all_population(p, features=("full", "D", "A")):
    return {f: population_metrics(p.z, r2(p, f)) for f in features}
