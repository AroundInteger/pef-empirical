# PEF empirical paper — reproducibility repository

Companion to the Paired Efficiency Factor (PEF) empirical manuscript. The mathematical companion lives in [`pef-mathematics`](https://github.com/AroundInteger/pef-mathematics) (when published).

## Layout

```
pef-empirical/
├── paper/              LaTeX source (main.tex, sections/, references.bib)
├── figures/            Generated PNGs (Figures 1–3, 3b, S1, S2)
├── scripts/
│   ├── paper_pipeline/     Canonical entry: run_paper_pipeline.m
│   ├── PEF_Normality_4seasons/  KPI loaders, compute_pef, normality
│   └── matlab_figures/     Supplementary figures S1–S2
├── data/
│   ├── sports/         Raw match KPI inputs (~2.5 MB)
│   └── non_sports/     Pre-computed PEF summaries for supporting domains
└── .cursor/rules/      MATLAB path for agents
```

## Requirements

- MATLAB R2019b+ with **Statistics and Machine Learning Toolbox**
- Optional: Python 3.10+ with `numpy`, `pandas`, `scipy`, `matplotlib`, `scikit-learn`, `statsmodels` for `run_paper_pipeline.py` (subset of outputs)

## Reproduce numbers and figures

```bash
cd scripts/paper_pipeline
/Applications/MATLAB_R2025b.app/bin/matlab -batch "run('run_paper_pipeline.m')"
```

Outputs: `scripts/paper_pipeline/outputs/numbers.tex` (included in `paper/main.tex` via `\input`).

Supplementary figures:

```bash
cd scripts/matlab_figures
/Applications/MATLAB_R2025b.app/bin/matlab -batch "generate_figure_S1_info_sensitivity; generate_figure_S2_labelled_kpis"
```

## Data provenance

| Domain | Source |
|--------|--------|
| Rugby | URC match KPIs, seasons 23/24–24/25 (`data/sports/rugby/`) |
| Football | English Championship team summaries (`data/sports/football/team_summaries_4seasons/`) |
| Healthcare, finance, genomics, manufacturing | Summary CSVs in `data/non_sports/` (see paper Methods) |

Large event-level football files from the legacy repo are **not** required for this pipeline.

## Compile PDF

From `paper/`:

```bash
latexmk -pdf -bibtex- -e '$bibtex = q/biber %O %B;' main.tex
```

## History

Migrated from the development monorepo `UP1_PEF` (2026-05-19). See `paper/REPO_MIGRATION_INVENTORY.md` in the archive for the full dependency audit.
