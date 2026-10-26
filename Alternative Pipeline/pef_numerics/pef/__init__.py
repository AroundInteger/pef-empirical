"""PEF numerics: closed forms, samplers and fitting helpers for the
Paired Efficiency Factor research programme. See STRATEGY.md."""

from .model import Params, from_dimensionless, FEATURES
from .theory import (eta, rho_eff, r2, alignment_cos2, reliability_D,
                     eta_component, population_metrics, all_population)
from .sim import sample, true_index
