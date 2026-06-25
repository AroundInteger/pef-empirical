# PEF empirical paper — reproducibility repository

Companion to the Paired Efficiency Factor (PEF) empirical manuscript. The mathematical companion lives in [`pef-mathematics`](../pef-mathematics) (local) or on GitHub when published.

**Project memory:** [`PEF_PROJECT_MEMORY.md`](PEF_PROJECT_MEMORY.md) (both repos).  
**Submission checklist, companion drafting order, and 2-day timeline:** [`PAPER_ROADMAP.md`](PAPER_ROADMAP.md).

## Layout

```
pef-empirical/
├── main.tex, sections/, references.bib
├── figures/                         Generated PNGs (see table below)
├── Data/                            Sports raw inputs (~2.5 MB; no multi-GB event files)
├── paper_data_and_analysis/         Supporting-domain summary CSVs
├── scripts/
│   ├── paper_pipeline/              Canonical pipeline (three MATLAB entry points)
│   │   ├── run_paper_pipeline.m
│   │   ├── run_pef_idealised_probit_sim.m
│   │   ├── run_pef_finalize_diagnostics.m
│   │   ├── sync_to_companion.sh
│   │   ├── lib/pef_theory_helpers.m
│   │   └── outputs/                 numbers.tex, CSVs, SI diagnostics
│   ├── PEF_Normality_4seasons/      KPI loaders, compute_pef, normality
│   └── matlab_figures/              Supplementary figures S1–S2 (standalone)
└── .cursor/rules/                   MATLAB path, companion scope, Git workflow
```

## Figures

| File | Role | Generator |
|------|------|-----------|
| `Figure_1.png` | PEF landscape (main) | `run_paper_pipeline.m` |
| `Figure_2.png` | Information surface (main) | `run_paper_pipeline.m` |
| `Figure_3.png` | PEF-to-ML mapping (main) | `run_paper_pipeline.m` |
| `Figure_3b.png` | ψ-stratified ML residual (companion bridge) | `run_paper_pipeline.m` |
| `Figure_1_SI.png` | Info sensitivity (S1) | `matlab_figures/generate_figure_S1_info_sensitivity.m` |
| `Figure_2_SI.png` | Labelled KPI maps (S2) | `matlab_figures/generate_figure_S2_labelled_kpis.m` |
| `Figure_S3_Ipred_vs_dML.png` | *I*\_pred vs ΔML (S3) | `run_pef_finalize_diagnostics.m` |
| `Figure_S4_idealised_I_vs_dML_stratified.png` | Idealised probit (S4) | `run_pef_idealised_probit_sim.m` + finalize |
| `Figure_S5_iso_eta_I_tension.png` | Iso-η / iso-*I* (S5) | `run_pef_finalize_diagnostics.m` |
| `Figure_finalize_bootstrap_exemplars.png` | Bootstrap exemplars (S6) | `run_pef_finalize_diagnostics.m` |
| `Figure_S6_q4_bayes_gap.png` | Q4 Bayes gap (S7) | `run_pef_finalize_diagnostics.m` |
| `Figure_S7_season_drift_alignment.png` | Season drift (S8) | `run_pef_finalize_diagnostics.m` |

Captions for S1–S8 are in `sections/supplementary.tex`.

## Requirements

- MATLAB R2019b+ with **Statistics and Machine Learning Toolbox** (`fitglm`, `cvpartition`, etc.)
- On this machine: `/Applications/MATLAB_R2025b.app/bin/matlab` (not on default shell `PATH`)
- Optional: Python 3.10+ for `run_paper_pipeline.py` (subset of outputs only; **MATLAB is canonical**)

## Reproduce numbers and figures (three-script workflow)

Run from `scripts/paper_pipeline` in order:

```bash
cd scripts/paper_pipeline

# 1. Main pipeline (~3–8 min): landscape, ML, numbers.tex, companion §7 CSVs
/Applications/MATLAB_R2025b.app/bin/matlab -batch "run('run_paper_pipeline.m')"

# 2. Idealised probit simulation (A1)–(A2); PRODUCTION_CONFIG locked in script
/Applications/MATLAB_R2025b.app/bin/matlab -batch "run('run_pef_idealised_probit_sim.m')"

# 3. Pre-submission diagnostics: S3–S8 figures + finalize_*.csv
/Applications/MATLAB_R2025b.app/bin/matlab -batch "run('run_pef_finalize_diagnostics.m')"
```

### LaTeX numeric inputs

| File | Included in `main.tex` | Contents |
|------|------------------------|----------|
| `outputs/numbers.tex` | `\input` after fallbacks | Domain means, quadrant stats, η→ML metrics |
| `outputs/finalize_correlations.tex` | `\input` after `numbers.tex` | `\PEFcorrIpredML`, `\PEFcorrEtaML`, `\PEFcorrEtaIpred`, `\PEFmedianDeltaRatio` |

Do **not** hand-edit these files; re-run the scripts above.

### Standalone SI figures (S1–S2)

If S1–S2 need regenerating without a full pipeline run:

```bash
cd scripts/matlab_figures
/Applications/MATLAB_R2025b.app/bin/matlab -batch "generate_figure_S1_info_sensitivity"
/Applications/MATLAB_R2025b.app/bin/matlab -batch "generate_figure_S2_labelled_kpis"
```

## Companion sync (§7 validation inputs)

After a pipeline run that changes geometry or ψ outputs, from the **empirical repo root**:

```bash
bash scripts/paper_pipeline/sync_to_companion.sh
```

This copies eight validation CSVs plus mirrors `lib/pef_theory_helpers.m` to `pef-mathematics/validation_inputs/` and `pef-mathematics/scripts/lib/`, and writes `validation_inputs/_manifest.csv` (sha256, commit SHA, timestamp). The script warns if the empirical tree is dirty — commit before claiming provenance.

Override sibling path: `PEF_MATHEMATICS_DIR=/path/to/pef-mathematics bash scripts/paper_pipeline/sync_to_companion.sh`

## Data provenance

| Domain | Source |
|--------|--------|
| Rugby | URC match KPIs, seasons 23/24–24/25 pooled (`Data/Rugby/`) |
| Football | English Championship team summaries, same two seasons (`Data/Football/Raw/team_summaries_4seasons/`) |
| Healthcare, finance, genomics, manufacturing | `paper_data_and_analysis/outputs/` |

Large event-level football files from the legacy repo are **not** required for this pipeline.

## Compile PDF

From repo root:

```bash
latexmk -pdf -bibtex- -e '$bibtex = q/biber %O %B;' main.tex
```

Overleaf: pdfLaTeX + Biber, main document `main.tex`.

## Cursor rules (symmetric with companion repo)

| Rule | Purpose |
|------|---------|
| `project-context.mdc` | Repo map, workspace, pipeline, scope |
| `companion-paper.mdc` | What belongs in `pef-mathematics` vs here |
| `github-workflow.mdc` | Post-edit reminders: pipeline, commit, push, sync §7 CSVs |
| `matlab.mdc` | Full path to MATLAB R2025b on this machine |
| `latex-paper.mdc` | British English and LaTeX maths (`.tex` files) |

Open **both** repos in `pef-papers.code-workspace` when editing cross-citations or refreshing validation inputs.

## Git (learning notes)

- Commit when you have a coherent unit of work; ask the agent to commit only when you want that recorded.
- Meaningful messages: what changed and **why**, not a file list.
- First push to GitHub: `git remote add origin git@github.com:YOUR_USER/pef-empirical.git` then `git push -u origin main`.
- See `.cursor/rules/github-workflow.mdc` for the agent checklist after each agreed edit.

## Changelog

Entries in reverse-chronological order. Add a new entry here in the same commit as the work it describes.

---

### `draft/strand2-reframe` branch — in progress

**Planned changes (Phases 1–4):**  
Retire `eq:dml_poly` (polynomial η→ML mapping) from main text; replace §2.5 and Results §4.2 with a δ/σ_A framing and a four-exemplar table (one per quadrant: rugby `kick_metres` Q1, football `long_balls` Q2, football `passes` Q3, football `goalkeeper_long_balls` Q4). Drop legacy significance apparatus (Methods §4.5, Results §4.3, `tab:mc`). Compress `appendix_b_log_transform` into a brief SI note. Annotate four exemplar points on Figure 3. Target journal: **JQAS** (primary), JRSS Series C (backup).

---

### 2026-06-24 · `863bd7c` — Pitman-Morgan citations and roadmap status update

Added formal citations for Pitman (1939) and Morgan (1939) in `theoretical_framework.tex`, establishing provenance of the variance-ratio test that underlies Section 2. Added a closing sentence cross-referencing the companion mathematics paper (`brownPEFmath`). Updated `PAPER_ROADMAP.md` to reflect June 2026 drafting sprint completion for the companion (`pef-mathematics`).

---

### 2026-06-22 · `5aa9cfc` — Idealised probit diagnostic figures

Added outputs from `run_pef_idealised_probit_sim.m` and `run_pef_finalize_diagnostics.m` to the repository: `idealised_probit_grid.csv`, `idealised_probit_scenarios.csv`, SI figures S3–S8. These figures underpin Strand 1 of the empirical validation (theory-aligned probit simulation under assumptions A1–A2).

---

### 2026-06-22 · `85bdbc6` — Submission-prep consistency pass

Major consistency pass across manuscript and pipeline:

- **Game counts:** Methods and appendix updated to use two-season pooled figures (rugby 283, football 1114) throughout.
- **Study count:** Corrected to 113 KPI studies.
- **ML methods:** Aligned to MATLAB logistic `fitglm`, 5-fold CV.
- **η–I narrative:** Updated correlation figures (fixed-δ r ≈ 0.87; heterogeneous KPI r ≈ −0.21); replaced stale r = 0.900.
- **Scenario table:** Updated to idealised probit figures (≈9.4, 8.2, 8.6, 7.9 %).
- **SI integration:** New §Efficiency–Power Alignment subsection in `results.tex`; S3–S8 figures wired into captions in `supplementary.tex`.
- **Scripts:** Added `run_pef_finalize_diagnostics.m`, `run_pef_idealised_probit_sim.m`, `lib/pef_theory_helpers.m`, `sync_to_companion.sh`.
- **`numbers.tex`:** Regenerated with pipeline run at 2026-06-22 10:59.

---

### 2026-05-20 · `371faba` — Project memory, Cursor context rules, README links

Added `PEF_PROJECT_MEMORY.md` (master reference document for humans and Cursor agents). Added `.cursor/rules/` files symmetric with the companion repo: `project-context.mdc`, `companion-paper.mdc`, `github-workflow.mdc`, `matlab.mdc`, `latex-paper.mdc`. Updated README with layout tree, figures table, and three-script workflow.

---

### 2026-05-20 · `8875f35` — Symmetric Cursor rules and README layout fix

Minor fix to README formatting after initial import; ensured Cursor rule filenames and content are symmetric across both PEF repos.

---

### 2026-05-19 · `19baf6f` — Initial import from UP1_PEF migration

First commit in standalone `pef-empirical` repository, migrated from the development monorepo `UP1_PEF`. Includes: manuscript `.tex` files, `Data/`, `figures/`, `scripts/paper_pipeline/` with outputs, `paper_data_and_analysis/outputs/`. Multi-GB football event files deliberately excluded (gitignored). See `UP1_PEF/paper/REPO_MIGRATION_INVENTORY.md` for full dependency audit.
