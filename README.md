# PEF empirical paper — reproducibility repository

Companion to the Paired Efficiency Factor (PEF) empirical manuscript. The mathematical companion lives in [`pef-mathematics`](../pef-mathematics) (local) or on GitHub when published.

## Layout

```
pef-empirical/
├── main.tex, sections/, references.bib
├── figures/                    Generated PNGs (Figures 1–3, 3b, S1, S2)
├── Data/                       Sports raw inputs (~2.5 MB; no multi-GB event files)
├── paper_data_and_analysis/    Supporting-domain summary CSVs
├── scripts/
│   ├── paper_pipeline/         Canonical entry: run_paper_pipeline.m
│   ├── PEF_Normality_4seasons/ KPI loaders, compute_pef, normality
│   └── matlab_figures/          Supplementary figures S1–S2
└── .cursor/rules/              MATLAB path, companion scope, Git workflow
```

## Cursor rules (symmetric with companion repo)

| Rule | Purpose |
|------|---------|
| `companion-paper.mdc` | What belongs in `pef-mathematics` vs here |
| `github-workflow.mdc` | Post-edit reminders: pipeline, commit, push, sync §7 CSVs |
| `matlab.mdc` | Full path to MATLAB R2025b on this machine |

Open **both** repos in one Cursor window (multi-root workspace) when editing cross-citations or refreshing validation inputs.

## Requirements

- MATLAB R2019b+ with **Statistics and Machine Learning Toolbox**
- Optional: Python 3.10+ for `run_paper_pipeline.py` (subset of outputs)

## Reproduce numbers and figures

```bash
cd scripts/paper_pipeline
/Applications/MATLAB_R2025b.app/bin/matlab -batch "run('run_paper_pipeline.m')"
```

Outputs: `scripts/paper_pipeline/outputs/numbers.tex` (included in `main.tex` via `\input`).

Supplementary figures:

```bash
cd scripts/matlab_figures
/Applications/MATLAB_R2025b.app/bin/matlab -batch "generate_figure_S1_info_sensitivity; generate_figure_S2_labelled_kpis"
```

After pipeline changes that affect companion §7, refresh mathematics inputs:

```bash
cp scripts/paper_pipeline/outputs/{kappa_symmetry_*,psi_*,pef_landscape_2season_geometry.csv} \
   ../pef-mathematics/validation_inputs/
```

## Data provenance

| Domain | Source |
|--------|--------|
| Rugby | URC match KPIs, seasons 23/24–24/25 (`Data/Rugby/`) |
| Football | English Championship team summaries (`Data/Football/Raw/team_summaries_4seasons/`) |
| Healthcare, finance, genomics, manufacturing | `paper_data_and_analysis/outputs/` |

Large event-level football files from the legacy repo are **not** required for this pipeline.

## Compile PDF

From repo root:

```bash
latexmk -pdf -bibtex- -e '$bibtex = q/biber %O %B;' main.tex
```

## Git (learning notes)

- Commit when you have a coherent unit of work; ask the agent to commit only when you want that recorded.
- Meaningful messages: what changed and **why**, not a file list.
- First push to GitHub: `git remote add origin git@github.com:YOUR_USER/pef-empirical.git` then `git push -u origin main`.
- See `.cursor/rules/github-workflow.mdc` for the agent checklist after each agreed edit.

## History

Migrated from the development monorepo `UP1_PEF` (2026-05-19). See `paper/REPO_MIGRATION_INVENTORY.md` in the archive for the full dependency audit.
