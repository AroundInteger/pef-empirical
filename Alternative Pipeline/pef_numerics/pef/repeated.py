"""Repeated-team signal–noise model.

X_A = mu_A + u_home - lambda u_away + eps_A
X_B = mu_B + u_away - lambda u_home + eps_B

Team effects u_i are i.i.d. N(0, tau^2). Residuals are bivariate normal and
independent of u. Sigma_S is the covariance of (u_h - lambda u_a, u_a - lambda u_h)
and Sigma_N is the residual covariance.
"""
import numpy as np
from scipy.optimize import minimize

from .theory import eta


def signal_noise_ratio(lam, vA, vB, rho):
    """eta_S / eta_N. Variances of the residuals are vA and vB."""
    eta_s = (1.0 + lam ** 2) / (1.0 + lam) ** 2
    kappa = vB / vA
    eta_n = eta(kappa, rho)
    return float(eta_s / eta_n), float(eta_s), float(eta_n)


def _nll_parts(muA, muB, tau2, lam, vA, vB, rho, home, away, h_idx, a_idx, n_teams, w):
    c = rho * np.sqrt(vA * vB)
    det = vA * vB - c * c
    if det <= 1e-14 or tau2 <= 0 or vA <= 0 or vB <= 0 or abs(rho) >= 0.999:
        return None
    r0 = home - muA
    r1 = away - muB
    i00, i11, i01 = vB / det, vA / det, -c / det
    d0 = i00 * r0 + i01 * r1
    d1 = i01 * r0 + i11 * r1
    wh = w * (d0 - lam * d1)
    wa = w * (-lam * d0 + d1)
    q = np.zeros(n_teams)
    np.add.at(q, h_idx, wh)
    np.add.at(q, a_idx, wa)
    hh = i00 + i11 * lam ** 2 + 2.0 * i01 * (-lam)
    aa = i00 * lam ** 2 + i11 + 2.0 * i01 * (-lam)
    ha = i00 * (-lam) + i11 * (-lam) + i01 * (1.0 + lam ** 2)
    G = np.zeros((n_teams, n_teams))
    np.add.at(G, (h_idx, h_idx), w * hh)
    np.add.at(G, (a_idx, a_idx), w * aa)
    np.add.at(G, (h_idx, a_idx), w * ha)
    np.add.at(G, (a_idx, h_idx), w * ha)
    Mdl = np.eye(n_teams) + tau2 * G
    try:
        chol = np.linalg.cholesky(Mdl)
    except np.linalg.LinAlgError:
        return None
    logdet = float(np.sum(w) * np.log(det) + 2.0 * np.sum(np.log(np.diag(chol))))
    solved = np.linalg.solve(Mdl, q)
    quad = float(np.dot(w * r0, d0) + np.dot(w * r1, d1) - tau2 * np.dot(q, solved))
    nll = 0.5 * (2.0 * float(np.sum(w)) * np.log(2.0 * np.pi) + logdet + quad)
    return float(nll)


def negloglik(theta, home, away, h_idx, a_idx, n_teams, w):
    muA, muB, log_tau2, lam, log_vA, log_vB, art = theta
    val = _nll_parts(muA, muB, np.exp(log_tau2), lam, np.exp(log_vA), np.exp(log_vB),
                     np.tanh(art), home, away, h_idx, a_idx, n_teams, w)
    return 1e12 if val is None or not np.isfinite(val) else val


def _start(home, away, h_idx, a_idx, n_teams):
    muA, muB = float(np.mean(home)), float(np.mean(away))
    # Team means of the home margin, shrunk toward zero, as a scale for tau.
    acc = np.zeros(n_teams)
    cnt = np.zeros(n_teams)
    np.add.at(acc, h_idx, home - muA)
    np.add.at(cnt, h_idx, 1.0)
    ok = cnt > 0
    tm = np.zeros(n_teams)
    tm[ok] = acc[ok] / cnt[ok]
    tau2 = float(np.var(tm[ok])) if ok.sum() > 2 else float(np.var(home))
    tau2 = max(tau2, 1e-3)
    vA = max(float(np.var(home)), 1e-3)
    vB = max(float(np.var(away)), 1e-3)
    rho = float(np.corrcoef(home, away)[0, 1]) if len(home) > 2 else 0.0
    rho = float(np.clip(rho, -0.8, 0.8))
    return np.array([muA, muB, np.log(tau2), 0.0, np.log(vA), np.log(vB), np.arctanh(rho)])


def fit_repeated(home, away, h_idx, a_idx, n_teams, weights=None):
    """Maximum likelihood. Returns a dict, or ok=False.

    weights are match multiplicity from a team-cluster bootstrap. A match
    with multiplicity zero is dropped.
    """
    home = np.asarray(home, float)
    away = np.asarray(away, float)
    h_idx = np.asarray(h_idx, int)
    a_idx = np.asarray(a_idx, int)
    w = np.ones(len(home)) if weights is None else np.asarray(weights, float)
    keep = w > 0
    home, away, h_idx, a_idx, w = home[keep], away[keep], h_idx[keep], a_idx[keep], w[keep]
    if len(home) < n_teams:
        return dict(ok=False)
    theta0 = _start(home, away, h_idx, a_idx, n_teams)
    starts = [theta0, theta0 + np.array([0, 0, 0, 0.5, 0, 0, 0]),
              theta0 + np.array([0, 0, -1.0, -0.5, 0, 0, 0])]
    best = None
    for st in starts:
        res = minimize(negloglik, st, args=(home, away, h_idx, a_idx, n_teams, w),
                       method="L-BFGS-B")
        if best is None or res.fun < best.fun:
            best = res
    if best is None or not np.isfinite(best.fun) or best.fun >= 1e11:
        return dict(ok=False)
    muA, muB, log_tau2, lam, log_vA, log_vB, art = best.x
    vA, vB, rho = float(np.exp(log_vA)), float(np.exp(log_vB)), float(np.tanh(art))
    ratio, eta_s, eta_n = signal_noise_ratio(lam, vA, vB, rho)
    # Numerical Hessian in the unconstrained coordinates, then delta method.
    eps = 1e-4
    H = np.zeros((7, 7))
    f0 = best.fun
    x = best.x.copy()
    for i in range(7):
        for j in range(i, 7):
            xp, xm = x.copy(), x.copy()
            xp[i] += eps
            xp[j] += eps
            xm[i] -= eps
            xm[j] -= eps
            xpi, xmi = x.copy(), x.copy()
            xpi[i] += eps
            xpi[j] -= eps
            xmi[i] -= eps
            xmi[j] += eps
            H[i, j] = (negloglik(xp, home, away, h_idx, a_idx, n_teams, w)
                       - negloglik(xpi, home, away, h_idx, a_idx, n_teams, w)
                       - negloglik(xmi, home, away, h_idx, a_idx, n_teams, w)
                       + negloglik(xm, home, away, h_idx, a_idx, n_teams, w)) / (4 * eps * eps)
            H[j, i] = H[i, j]
    se_ratio = np.nan
    try:
        cov = np.linalg.inv(H)
        # Gradient of the ratio w.r.t. unconstrained theta.
        g = np.zeros(7)
        for i in range(7):
            xp, xm = x.copy(), x.copy()
            xp[i] += eps
            xm[i] -= eps
            rp = _ratio_of_theta(xp)
            rm = _ratio_of_theta(xm)
            g[i] = (rp - rm) / (2 * eps)
        var = float(g @ cov @ g)
        if var > 0:
            se_ratio = float(np.sqrt(var))
    except np.linalg.LinAlgError:
        se_ratio = np.nan
    return dict(ok=True, mu_A=float(muA), mu_B=float(muB), tau2=float(np.exp(log_tau2)),
                lam=float(lam), vA=vA, vB=vB, rho=rho, eta_S=eta_s, eta_N=eta_n,
                ratio=ratio, se_ratio=se_ratio, nll=float(f0))


def _ratio_of_theta(theta):
    lam = theta[3]
    vA, vB = np.exp(theta[4]), np.exp(theta[5])
    rho = np.tanh(theta[6])
    return signal_noise_ratio(lam, vA, vB, rho)[0]


def simulate(n_teams, home_idx, away_idx, rng, mu=(0.0, 0.0), tau2=1.0, lam=0.5,
             vA=1.0, vB=1.44, rho=0.4):
    """Draw one season. home_idx, away_idx index teams."""
    u = rng.normal(0.0, np.sqrt(tau2), n_teams)
    h = np.asarray(home_idx, int)
    a = np.asarray(away_idx, int)
    cov = np.array([[vA, rho * np.sqrt(vA * vB)], [rho * np.sqrt(vA * vB), vB]])
    eps = rng.multivariate_normal(np.zeros(2), cov, len(h), method="cholesky")
    home = mu[0] + u[h] - lam * u[a] + eps[:, 0]
    away = mu[1] + u[a] - lam * u[h] + eps[:, 1]
    signal = np.column_stack([u[h] - lam * u[a], u[a] - lam * u[h]])
    return dict(home=home, away=away, h_idx=h, a_idx=a, signal=signal, noise=eps, u=u)


def double_round_robin(n_teams, meetings_each_way, rng=None):
    """Every ordered pair (home, away), repeated meetings_each_way times."""
    rows = [(i, j) for i in range(n_teams) for j in range(n_teams) if i != j
            for _ in range(meetings_each_way)]
    arr = np.array(rows, int)
    if rng is not None:
        arr = arr[rng.permutation(len(arr))]
    return arr[:, 0], arr[:, 1]


def check_likelihood(tol=1e-6):
    """Woodbury negative log-likelihood against a dense covariance on 4 teams."""
    rng = np.random.default_rng(0)
    h, a = double_round_robin(4, 1)
    muA, muB, tau2, lam, vA, vB, rho = 0.3, -0.2, 0.7, 0.4, 1.1, 0.8, 0.25
    d = simulate(4, h, a, rng, mu=(muA, muB), tau2=tau2, lam=lam, vA=vA, vB=vB, rho=rho)
    w = np.ones(len(h))
    wood = _nll_parts(muA, muB, tau2, lam, vA, vB, rho, d["home"], d["away"],
                      d["h_idx"], d["a_idx"], 4, w)
    m = len(h)
    L = np.zeros((2 * m, 4))
    for i in range(m):
        L[2 * i, h[i]] += 1.0
        L[2 * i, a[i]] += -lam
        L[2 * i + 1, h[i]] += -lam
        L[2 * i + 1, a[i]] += 1.0
    c = rho * np.sqrt(vA * vB)
    V = np.zeros((2 * m, 2 * m))
    block = np.array([[vA, c], [c, vB]])
    for i in range(m):
        V[2 * i:2 * i + 2, 2 * i:2 * i + 2] = block
    Sigma = tau2 * L @ L.T + V
    r = np.empty(2 * m)
    r[0::2] = d["home"] - muA
    r[1::2] = d["away"] - muB
    sign, logdet = np.linalg.slogdet(Sigma)
    dense = 0.5 * (2 * m * np.log(2 * np.pi) + logdet + r @ np.linalg.solve(Sigma, r))
    if sign <= 0 or abs(wood - dense) > tol:
        raise RuntimeError(f"Woodbury nll {wood} != dense {dense}")
    return abs(wood - dense)
