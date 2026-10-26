"""Generative model (STRATEGY.md, Section 3.1).

S ~ N(mu, Sigma_S), N ~ N(0, Sigma_N) independent, K = S + N,
M = b^T S + eps with b = (b_A, -b_B), eps ~ N(0, sigma_eps^2), Y = 1(M > 0).
"""
from dataclasses import dataclass
import numpy as np

# Feature sets as linear maps T applied to K = (A, B): features = T @ K.
FEATURES = {
    "full": np.array([[1.0, 0.0], [0.0, 1.0]]),
    "D": np.array([[1.0, -1.0]]),
    "A": np.array([[1.0, 0.0]]),
}


@dataclass(frozen=True)
class Params:
    Sigma_S: np.ndarray
    Sigma_N: np.ndarray
    mu: np.ndarray            # (mu_A, mu_B)
    b: np.ndarray             # (b_A, -b_B)
    sigma_eps: float

    @property
    def Sigma_K(self):
        return self.Sigma_S + self.Sigma_N

    @property
    def var_M(self):
        return float(self.b @ self.Sigma_S @ self.b + self.sigma_eps ** 2)

    @property
    def mu_M(self):
        return float(self.b @ self.mu)

    @property
    def z(self):
        return self.mu_M / np.sqrt(self.var_M)

    @property
    def delta(self):
        return float(self.mu[0] - self.mu[1])


def _cov(vA, vB, rho):
    c = rho * np.sqrt(vA * vB)
    return np.array([[vA, c], [c, vB]])


def from_dimensionless(z=0.0, rho_S=0.0, rho_N=0.0, w=0.5, q=0.8,
                       kappa_S=1.0, kappa_N=1.0, b_ratio=1.0):
    """Build Params from the dimensionless grid of STRATEGY.md Section 4.

    Entity A has total feature variance 1: Var(S_A) = w, Var(N_A) = 1 - w.
    Entity B: Var(S_B) = kappa_S * w, Var(N_B) = kappa_N * (1 - w).
    b = (1, -b_ratio). q = Var(b^T S) / Var(M). z = E[M] / sd(M) (signed).
    """
    Sigma_S = _cov(w, kappa_S * w, rho_S)
    Sigma_N = _cov(1 - w, kappa_N * (1 - w), rho_N)
    b = np.array([1.0, -b_ratio])
    vbs = float(b @ Sigma_S @ b)
    if vbs <= 0:
        raise ValueError("degenerate signal: Var(b^T S) = 0")
    var_M = vbs / q
    sigma_eps = np.sqrt(var_M - vbs)
    mu_M = z * np.sqrt(var_M)
    mu = np.array([mu_M, 0.0])  # b_A = 1, so b^T mu = mu_A
    return Params(Sigma_S, Sigma_N, mu, b, sigma_eps)
