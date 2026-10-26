# PEF numerical programme

This package contains the code and results that verify the Paired Efficiency Factor (PEF) theory. It covers symbolic proofs, closed-form versus Monte Carlo checks, inference, finite-sample prediction theory and model-class experiments.

- `STRATEGY.md` defines every quantity and holds the claims register.
- `results/SUMMARY.md` regenerates every number reported, straight from the CSVs.

## Quick start (macOS with Anaconda)

```bash
cd pef_numerics
conda create -n pef python=3.12 -y      # or use an existing environment
conda activate pef
pip install -r requirements.txt

python run_all.py --quick               # about 5 minutes; checks the pipeline only
python run_all.py                       # full run (timings below)
```

Results go to `results/` (one CSV per experiment), plus `results/SUMMARY.md` and `results/logs/`.

Quick mode writes to `results_quick/` instead, so it never touches a full run. **Do not cite quick-mode numbers.**

## Useful options

| Command | What it does |
|---|---|
| `python run_all.py --only E3 summary` | Run selected phases only |
| `python run_all.py --force` | Rerun phases already marked done |
| `PEF_WORKERS=8 python run_all.py` | Set the number of worker processes (default: all cores) |
| `python -m pytest -q tests` | Closed-form test suite only (about 3 s) |
| `python analysis/summarise.py` | Rebuild SUMMARY.md from existing CSVs |
| `python experiments/E4b_tuned_trees.py aligned` | Run one regime of an experiment |

The runner is **resumable**. Finished phases are recorded in `results/logs/status.json` and skipped next time. E4b also checkpoints after every replicate, so an interrupted run can simply be restarted.

## Phases

| Phase | Script | What it verifies | Time (2 cores) |
|---|---|---|---|
| tests | `tests/test_theory.py` | 18 deterministic checks of all closed forms | < 1 min |
| E0 | `E0_symbolic.py` | sympy proofs of P1–P5, the sech form, Theorems B and C, Proposition D, plus 4 negative controls | < 1 min |
| E1 | `E1_population_mc.py` | Theorem A metrics and Theorem C versus Monte Carlo (200 draws × 10⁶) | 5 min |
| E1rep | same, fresh seeds | Independent replication at 4 × 10⁶ | ~20 min |
| E2 | `E2_inference.py` | P6 variance ratio; paired-t power versus noncentral t (and a replication); CI coverage for η; Lin (1989) cross-check | ~30 min |
| E2e | `E2e_smallsample.py` | Small-sample corrections to the Fisher-z interval | ~3 min |
| E3 | `E3_finite_sample.py` | 1/(2n) gain law; crossover sample size | ~15 min |
| E4 | `E4_model_classes.py` | Logistic, ridge, GBM and RF on full / D / full+D (untuned) | ~35 min |
| E4b | `E4b_tuned_trees.py` | Trees tuned per feature set; the admissible test of Conjecture G | ~12 min |

On an Apple-silicon Mac with 8–12 cores, expect roughly a third to a quarter of these times.

## Layout

```
pef/            library
  model.py      generative model and dimensionless parameterisation
  theory.py     closed forms: η, R², Theorem A metrics, Theorems B and C
  sim.py        samplers
  fit.py        probit MLE; exact expected test log-loss
  runtime.py    workers, single-thread pinning, quick mode
experiments/    one script per phase; each writes results/<phase>*.csv
analysis/       summarise.py builds results/SUMMARY.md
tests/          pytest suite
```

## Reproducibility notes

- **Fixed seeds.** All seeds are fixed. Every phase except E4/E4b reproduces bit-for-bit on the same library versions.
- **Tree models (E4, E4b).** These can differ in the last digits across scikit-learn versions or CPU architectures. The conclusions should not change.
- **Thread pinning.** Each worker process is pinned to one BLAS/OpenMP thread. Without this, scikit-learn's gradient boosting oversubscribes the CPU, which made the first E4b attempt time out.
- **Multiprocessing start method.** The code was tested under both `fork` (Linux default) and `spawn` (macOS default). To force one, set `PEF_MP_START=spawn`.
