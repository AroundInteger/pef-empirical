"""Run-time settings shared by all experiments.

Environment variables
---------------------
PEF_WORKERS  number of worker processes (default: all cores).
PEF_QUICK    if set to 1, every experiment shrinks its replicate counts
             (smoke test: checks the pipeline runs, NOT a valid result).

Each worker is pinned to one BLAS/OpenMP thread. Without this, scikit-learn's
gradient boosting starts one thread per core inside every worker process,
and the oversubscription can slow a run down by an order of magnitude.
This is what stopped the first E4b run.
"""
import os
from multiprocessing import Pool, get_context

_THREAD_VARS = ("OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS",
                "VECLIB_MAXIMUM_THREADS", "NUMEXPR_NUM_THREADS")


def quick():
    return os.environ.get("PEF_QUICK", "0") == "1"


def scale(full, quick_value):
    """Replicate count: `full` normally, `quick_value` in smoke-test mode."""
    return quick_value if quick() else full


def workers():
    return int(os.environ.get("PEF_WORKERS", os.cpu_count() or 1))


def _pin_threads():
    for v in _THREAD_VARS:
        os.environ[v] = "1"
    try:
        from threadpoolctl import threadpool_limits
        threadpool_limits(1)
    except ImportError:
        pass


def pool():
    """Process pool whose workers each use a single thread.
    PEF_MP_START=spawn|fork|forkserver overrides the platform default
    (macOS and Windows default to spawn, Linux to fork)."""
    method = os.environ.get("PEF_MP_START")
    if method:
        return get_context(method).Pool(workers(), initializer=_pin_threads)
    return Pool(workers(), initializer=_pin_threads)
