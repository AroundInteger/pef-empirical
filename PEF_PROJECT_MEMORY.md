# PEF project memory (master reference)

**Last updated:** 2026-05-21  
**Purpose:** Single source of truth for humans and Cursor agents across `pef-empirical`, `pef-mathematics`, and the archived monorepo.

---

## 1. What we are building

Two maintained Git repositories for a **split publication strategy**:

| Paper | Repo | Audience / role |
|-------|------|-----------------|
| Empirical PEF | `pef-empirical` | Cross-domain validation, quadrants, KPI ML, Gaussian information link — **submit first** |
| Mathematics companion | `pef-mathematics` | Geometry, symmetries, sphere, partition function, Fisher–Rao ψ, §7 numeric tests |

The old monorepo **`UP1_PEF`** (~29 GB history) is **archive / reference only**. Live sources are the two new repos.

---

## 2. Local paths and workspace

| Item | Path |
|------|------|
| Empirical repo | `/Users/rowanbrown/Documents/GitHub/pef-empirical` |
| Mathematics repo | `/Users/rowanbrown/Documents/GitHub/pef-mathematics` |
| Multi-root workspace | `/Users/rowanbrown/Documents/GitHub/pef-papers.code-workspace` |
| This document | `PEF_PROJECT_MEMORY.md` at the root of **each** repo (keep copies in sync) |
| Archive | `/Users/rowanbrown/Documents/GitHub/UP1_PEF` |
| Rule templates (regenerate scripts) | `UP1_PEF/paper/cursor-rules-templates/` |
| Migration audit | `UP1_PEF/paper/REPO_MIGRATION_INVENTORY.md` |

**Open `pef-papers.code-workspace` for daily work.** Keep `UP1_PEF` in a separate window when you need history or old scripts.

---

## 3. GitHub and Git habits

- **Account:** `AroundInteger` (`gh` authenticated via HTTPS).
- **Remotes:** one repo = one remote = one history. Do not mix empirical and mathematics commits.
- **Agent default:** suggest commits after agreed work; **commit/push only when Rowan asks**.
- **Messages:** imperative summary + why (not a file list).
- **Recreate repos:** `UP1_PEF/paper/create_pef_empirical_repo.sh`, `create_pef_mathematics_repo.sh` (destructive `rm -rf` on destination).

---

## 4. Reproducibility (empirical only)

**Entry point:** `pef-empirical/scripts/paper_pipeline/run_paper_pipeline.m`

```bash
cd /Users/rowanbrown/Documents/GitHub/pef-empirical/scripts/paper_pipeline
/Applications/MATLAB_R2025b.app/bin/matlab -batch "run('run_paper_pipeline.m')"
```

**MATLAB:** R2025b at `/Applications/MATLAB_R2025b.app/bin/matlab` (not on default `PATH`). Needs Statistics and Machine Learning Toolbox.

**Key outputs:**

- `outputs/numbers.tex` — included in `main.tex`
- `figures/Figure_1.png` … `Figure_3b.png`
- §7 CSVs: `kappa_symmetry_*.csv`, `psi_*.csv`, `pef_landscape_2season_geometry.csv`

**SI figures:** `scripts/matlab_figures/generate_figure_S1_info_sensitivity.m`, `generate_figure_S2_labelled_kpis.m`

**Idealised probit sim:** `scripts/paper_pipeline/run_pef_idealised_probit_sim.m` (theory-aligned A1–A2; outputs `idealised_probit_*.csv/png` in `outputs/`). **Paper-locked `PRODUCTION_CONFIG`:** `n=5000`, 50 trials, 5-fold CV, `kappa∈{0.8,1,1.2,2}`, `rho∈{-0.3,-0.15,0,0.4}`, `delta/sigma_A∈{0.3,0.5,1,2}` (64 cells; no δ=0 slice).

**Pre-submission finalize diagnostics:** `scripts/paper_pipeline/run_pef_finalize_diagnostics.m` (after pipeline + idealised sim; per-KPI `I_pred`, stratified idealised corr, iso-η/iso-I, bootstrap, Q4 Bayes gap, season drift → `outputs/finalize_*.csv`, `figures/Figure_S3`–`S8` + `Figure_finalize_bootstrap_exemplars.png`; captions in `sections/supplementary.tex`)

**Data in repo (~14 MB empirical):**

- Rugby: `Data/Rugby/Raw/4_seasons rugby abs.csv`
- Football: `Data/Football/Raw/team_summaries_4seasons/*.csv` (four seasons)
- Non-sports: `paper_data_and_analysis/outputs/*.csv`
- **Not migrated:** ~6.2 GB event-level `20*_Data.csv`

**Genomics:** MATLAB pipeline uses `real_gene_expression_tcga_study.csv`; Python `run_paper_pipeline.py` may reference `tcga_brca_gene_pef.csv` — treat MATLAB as canonical.

---

## 5. Companion sync (mathematics)

After an empirical pipeline run that changes geometry/ψ outputs, run the
provenance-stamped sync script from the empirical repo root:

```bash
cd /Users/rowanbrown/Documents/GitHub/pef-empirical
bash scripts/paper_pipeline/sync_to_companion.sh
```

It copies the eight §7 CSVs (`kappa_symmetry_*`, `psi_*`,
`pef_landscape_2season_geometry.csv`, `domain_summary.csv`,
`table_numbers.csv`) into `pef-mathematics/validation_inputs/`, mirrors the
shared math library `scripts/paper_pipeline/lib/` to
`pef-mathematics/scripts/lib/` (read-only audit copy for §7 reviewers), and
writes `validation_inputs/_manifest.csv` with sha256, empirical commit SHA,
clean/dirty flag, and UTC timestamp per file. Override the sibling location
with `PEF_MATHEMATICS_DIR` if needed. The script warns if the empirical tree
is dirty — commit before claiming provenance.

§7 in the companion must match these files — do not hand-type statistics.

### Shared math primitives (single source of truth)

`pef-empirical/scripts/paper_pipeline/lib/pef_theory_helpers.m` is the
canonical implementation of `eta_pef`, `eta_pef_vec`, `classify_quadrant`,
`mi_closed`, `bayes_acc_x`, etc. Callers (`compute_pef.m`,
`kappa_involution_audit.m`, `generate_figure_S2_labelled_kpis.m`, the
pipeline entry-points) all route through this struct of function handles
rather than re-inlining the formula. The mirror under
`pef-mathematics/scripts/lib/` is auto-regenerated by the sync script.

---

## 6. Research scope boundaries

### Empirical owns

- \(\eta = (1+\kappa)/(1+\kappa-2\sqrt{\kappa}\rho)\) and four-quadrant taxonomy
- Primary sports: rugby + football KPIs, seasons 23/24–24/25 pooled
- Six supporting domains (healthcare, finance, genomics, manufacturing, etc.)
- Gaussian (A1)–(A2): \(\eta \leftrightarrow I(X;Y)\) as **empirical** story
- ML: `home_win`, absolute vs relative KPI; weak global η→ML mapping
- Honest reporting: do not oversell polynomial DML fit

### Mathematics owns

- \(\tau=\tfrac{1}{2}\log\kappa\), canonical \(\eta\), \(\kappa\leftrightarrow 1/\kappa\), Möbius/Chebyshev
- Sphere and partition-function readings
- Fisher–Rao \(\psi\), regime change at \(\rho=0\)
- §7 numerical validation from `validation_inputs/`

### Narrative traps (both agents)

- Rugby PEF landscape is **Q3-heavy**, not “mostly Q4”
- `pef_landscape_ml_validation_matlab_script.m` is **synthetic simulation** (tanh outcomes), not KPI pipeline rerun
- ψ and partition-function **proofs** belong in companion, not empirical Results as headline

---

## 7. Cursor rules (per repo)

Each repo has `.cursor/rules/`:

| File | Empirical | Mathematics |
|------|-----------|-------------|
| `project-context.mdc` | ✓ | ✓ |
| `companion-paper.mdc` / `empirical-paper.mdc` | companion | empirical |
| `github-workflow.mdc` | ✓ | ✓ |
| `matlab.mdc` | ✓ | ✓ (points to empirical) |
| `latex-paper.mdc` | ✓ (`**/*.tex`) | ✓ |

---

## 8. LaTeX and language

- **British English** throughout manuscripts
- Greek and operators in LaTeX math mode, not Unicode
- Full style guide (archive): `UP1_PEF/paper/draft_v13_comprehensive_theoretical/documentation/OVERLEAF_BEST_PRACTICES.md`
- **Do not** edit `.tex` unless the user explicitly requests a manuscript change

---

## 9. Outstanding / optional future work

- Push both repos to GitHub if not already public
- Archive or mark read-only the old `SEF-Framework-Cross-Sport-Validation` remote
- ~~Align Python pipeline genomics filename with MATLAB~~ (done: `real_gene_expression_tcga_study.csv`)
- Module C: idealised simulation — `run_pef_idealised_probit_sim.m` (done; `PRODUCTION_CONFIG` locked)
- Finalize surface diagnostics — `run_pef_finalize_diagnostics.m` (done; SI captions S3–S8 in `supplementary.tex`)
- Sports quadrant narrative fix in `discussion.tex` (when user asks for LaTeX edit)

---

## 10. Cursor “Memories” (UI)

If you use **Cursor → Settings → Memories**, consider saving these one-liners:

1. PEF work uses workspace `pef-papers.code-workspace` with `pef-empirical` + `pef-mathematics`; UP1_PEF is archive only.
2. Run `run_paper_pipeline.m` only in `pef-empirical`; refresh `pef-mathematics/validation_inputs/` after §7-related outputs change.
3. GitHub user AroundInteger; commit/push only when I ask; British English for LaTeX.
4. Rugby landscape is Q3-heavy; synthetic landscape script ≠ KPI pipeline.
5. MATLAB: `/Applications/MATLAB_R2025b.app/bin/matlab` — not on shell PATH.

Rules in `.cursor/rules/` duplicate and extend this for agents automatically.
