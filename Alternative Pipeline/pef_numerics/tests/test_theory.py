"""Deterministic checks of the closed forms (STRATEGY.md Sections 2-3).
Run: python3 -m pytest -q tests/"""
import os
import sys
import numpy as np
import pytest

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from pef import (eta, rho_eff, r2, alignment_cos2, reliability_D, eta_component,
                 population_metrics, from_dimensionless)

rng = np.random.default_rng(0)
KAPPAS = np.exp(rng.uniform(np.log(0.05), np.log(20), 400))
RHOS = rng.uniform(-0.999, 0.999, 400)


def random_params(n=300, seed=1):
    g = np.random.default_rng(seed)
    out = []
    for _ in range(n):
        out.append(from_dimensionless(
            z=g.uniform(-1.5, 1.5), rho_S=g.uniform(-.95, .95), rho_N=g.uniform(-.95, .95),
            w=g.uniform(.05, .95), q=g.uniform(.3, .99),
            kappa_S=np.exp(g.uniform(-2, 2)), kappa_N=np.exp(g.uniform(-2, 2)),
            b_ratio=g.uniform(.3, 2)))
    return out


PARAMS = random_params()

# ---- inferential PEF


def test_sech_form():
    assert np.allclose(eta(KAPPAS, RHOS), 1 / (1 - rho_eff(KAPPAS, RHOS)), rtol=1e-12)


def test_P1_sign():
    e = eta(KAPPAS, RHOS)
    assert np.all((e > 1) == (RHOS > 0))


def test_P2_symmetry():
    assert np.allclose(eta(KAPPAS, RHOS), eta(1 / KAPPAS, RHOS), rtol=1e-12)


def test_P3_bounds():
    assert np.all(eta(KAPPAS, RHOS) >= 0.5)
    assert np.isclose(eta(1.0, -1.0), 0.5)


def test_P4_max_at_balance():
    for rho in (0.2, 0.6, 0.95):
        k = np.exp(np.linspace(-3, 3, 2001))
        assert np.isclose(k[np.argmax(eta(k, rho))], 1.0, atol=5e-3)

# ---- predictive theory


def test_B_inequality_and_ratio():
    for p in PARAMS:
        full, D = r2(p, "full"), r2(p, "D")
        assert D <= full + 1e-12
        assert np.isclose(D / full, alignment_cos2(p), rtol=1e-10)


def test_C_reliability_law():
    for p in PARAMS:
        direct, law = reliability_D(p)
        assert np.isclose(direct, law, rtol=1e-12)


def test_D_general_reduction():
    """Exchangeable b = c gives 2η. A non-exchangeable draw does not."""
    g = np.random.default_rng(7)
    for _ in range(50):
        rS, rN, w = g.uniform(-.9, .9), g.uniform(-.9, .9), g.uniform(.1, .9)
        p = from_dimensionless(z=0.0, rho_S=rS, rho_N=rN, w=w, q=0.8)
        rho_tot = w * rS + (1 - w) * rN
        assert np.isclose(r2(p, "D") / r2(p, "A"), 2 * eta(1.0, rho_tot), rtol=1e-10)
    p = from_dimensionless(z=0.0, rho_S=0.3, rho_N=-0.2, w=0.4, q=0.7,
                           kappa_S=2.5, kappa_N=0.4, b_ratio=1.5)
    SK = p.Sigma_K
    rho_tot = SK[0, 1] / np.sqrt(SK[0, 0] * SK[1, 1])
    kappa = SK[1, 1] / SK[0, 0]
    assert abs(r2(p, "D") / r2(p, "A") - 2 * eta(kappa, rho_tot)) > 0.05


def test_D_exchangeable_gain():
    g = np.random.default_rng(2)
    for _ in range(200):
        rS, rN, w = g.uniform(-.95, .95), g.uniform(-.95, .95), g.uniform(.05, .95)
        p = from_dimensionless(z=g.uniform(-1, 1), rho_S=rS, rho_N=rN, w=w,
                               q=g.uniform(.3, .99))
        rho_tot = w * rS + (1 - w) * rN
        assert np.isclose(r2(p, "D") / r2(p, "A"), 2 * eta(1.0, rho_tot), rtol=1e-10)
        assert np.isclose(r2(p, "D"), r2(p, "full"), rtol=1e-10)   # D lossless


def test_eta_component_matches_eta():
    for p in PARAMS[:50]:
        S = p.Sigma_S
        k, rho = S[1, 1] / S[0, 0], S[0, 1] / np.sqrt(S[0, 0] * S[1, 1])
        assert np.isclose(eta_component(S), eta(k, rho), rtol=1e-12)

# ---- Theorem A metric mapping


def test_sheppard():
    for r in np.linspace(0, 0.99, 34):
        m = population_metrics(0.0, r ** 2)
        assert abs(m["accuracy"] - (0.5 + np.arcsin(r) / np.pi)) < 1e-6


def test_null_predictor():
    for z in (-1.0, 0.0, 0.7):
        m = population_metrics(z, 0.0)
        assert abs(m["mi"]) < 1e-9 and abs(m["auc"] - 0.5) < 1e-9


@pytest.mark.parametrize("z", [-1.0, 0.0, 0.5, 1.2])
def test_monotone_in_r2(z):
    grid = np.linspace(0, 0.98, 50)
    m = [population_metrics(z, v) for v in grid]
    for key, sign in (("logloss", -1), ("brier", -1), ("mi", 1), ("auc", 1)):
        vals = np.array([x[key] for x in m])
        assert np.all(sign * np.diff(vals) > 0), key
    acc = np.array([x["accuracy"] for x in m])
    assert np.all(np.diff(acc) >= -1e-12)   # weakly monotone (flat when |z| large, r small)

# ---- exact expected log-loss machinery (Phase 3)
from pef.fit import true_probit, expected_logloss, probit_fit  # noqa: E402


def test_exact_logloss_at_truth_equals_bayes():
    for p in PARAMS[:60]:
        for f in ("full", "D", "A"):
            t0, t = true_probit(p, f)
            bayes = population_metrics(p.z, r2(p, f))["logloss"]
            assert abs(expected_logloss(p, f, t0, t) - bayes) < 1e-8


def test_truth_minimises_exact_logloss():
    p = PARAMS[3]
    t0, t = true_probit(p, "full")
    best = expected_logloss(p, "full", t0, t)
    g = np.random.default_rng(5)
    for _ in range(50):
        d0, d = g.normal(0, .05), g.normal(0, .05, 2)
        assert expected_logloss(p, "full", t0 + d0, t + d) >= best - 1e-12


def test_probit_fit_consistent():
    from pef import sample
    p = from_dimensionless(z=0.3, rho_S=0.2, rho_N=0.6)
    d = sample(p, 300_000, np.random.default_rng(0))
    th, ok = probit_fit(d["K"], d["Y"])
    t0, t = true_probit(p, "full")
    assert ok and np.allclose(th, np.r_[t0, t], atol=0.02)
