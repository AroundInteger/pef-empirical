"""Probit fitting and EXACT expected test log-loss for a fitted linear-index
predictor (no test-set Monte Carlo): the fitted index v = th0 + th^T F and
the margin M are jointly Gaussian, so E[log-loss] is a 1-D integral."""
import numpy as np
from scipy.special import log_ndtr, ndtr
from scipy.integrate import trapezoid
from .model import FEATURES

_U = np.linspace(-12.0, 12.0, 24001)
_PHI = np.exp(-0.5 * _U ** 2) / np.sqrt(2 * np.pi)


def true_probit(p, feature):
    """Population probit coefficients (th0, th) for P(Y=1 | F)."""
    T = FEATURES[feature]
    SKT = T @ p.Sigma_K @ T.T
    cFM = T @ p.Sigma_S @ p.b
    g = np.linalg.solve(SKT, cFM)
    s = np.sqrt(p.var_M - g @ cFM)
    return (p.mu_M - g @ (T @ p.mu)) / s, g / s


def _logF(v, link):
    if link == "probit":
        return log_ndtr(v), log_ndtr(-v)
    return -np.logaddexp(0, -v), -np.logaddexp(0, v)     # logit


def expected_logloss(p, feature, th0, th, link="probit"):
    """Exact expected test log-loss of predictor F(th0 + th^T features),
    F = Phi (probit) or logistic (logit), over a fresh draw."""
    if link != "probit":
        return _expected_logloss_link(p, feature, th0, th, link)
    return _expected_logloss_link(p, feature, th0, th, "probit")


def _expected_logloss_link(p, feature, th0, th, link):
    """Exact E[-Y log F(v) - (1-Y) log F(-v)] over a fresh draw."""
    T = FEATURES[feature]
    th = np.atleast_1d(th)
    mu_v = th0 + th @ (T @ p.mu)
    var_v = th @ (T @ p.Sigma_K @ T.T) @ th
    c_vM = th @ (T @ p.Sigma_S @ p.b)
    if var_v < 1e-300:
        pi1 = ndtr(p.mu_M / np.sqrt(p.var_M))
        lp, lq = _logF(np.array(mu_v), link)
        return float(-(pi1 * lp + (1 - pi1) * lq))
    sd_v = np.sqrt(var_v)
    v = mu_v + sd_v * _U
    m = p.mu_M + c_vM / var_v * (v - mu_v)
    s = np.sqrt(max(p.var_M - c_vM ** 2 / var_v, 1e-300))
    p1 = ndtr(m / s)
    lp, lq = _logF(v, link)
    return float(trapezoid((-(p1 * lp + (1 - p1) * lq)) * _PHI, _U))


def probit_fit(X, y, max_iter=100, tol=1e-10):
    """Probit MLE by Fisher scoring. X includes no intercept (added here).
    Returns (theta, converged). Non-convergence flags (quasi-)separation."""
    Xd = np.column_stack([np.ones(len(y)), X])
    th = np.zeros(Xd.shape[1])
    for _ in range(max_iter):
        a = Xd @ th
        lP, lQ = log_ndtr(a), log_ndtr(-a)
        lphi = -0.5 * a * a - 0.5 * np.log(2 * np.pi)
        # score weights: phi*(y-Phi)/(Phi*Q) = y*phi/Phi - (1-y)*phi/Q
        sw = y * np.exp(lphi - lP) - (1 - y) * np.exp(lphi - lQ)
        w = np.exp(2 * lphi - lP - lQ)                     # Fisher information weights
        grad = Xd.T @ sw
        H = (Xd * w[:, None]).T @ Xd
        try:
            step = np.linalg.solve(H, grad)
        except np.linalg.LinAlgError:
            return th, False
        th = th + step
        if np.max(np.abs(th)) > 50:
            return th, False
        if np.max(np.abs(step)) < tol:
            return th, True
    return th, False
