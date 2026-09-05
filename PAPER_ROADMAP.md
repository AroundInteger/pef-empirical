# PEF papers — dual roadmap

**Last updated:** 2026-09-05  
**Current branch (`pef-empirical`):** `main` (pre-review polish through `5888d22`; intro pass through `9c713e7`)  
**Target:** submission-ready empirical draft; companion complete draft follows

This file tracks the two parallel paths to submission. Tick items in Git commits or by editing status columns as work completes.

---

## Status at a glance (2026-09-05)

| Paper | Stage | Next action |
|-------|--------|-------------|
| **Empirical** | Submission draft — body + SI largely complete; pre-review polish done (`5888d22`) | `latexmk` on Overleaf/MacTeX (`D1`); co-author sign-off (`D4`); companion sync (`A6`) after pipeline commit |
| **Companion** | First full draft (June 2026) | Refresh `validation_inputs/` from empirical (`A6`) — inputs stale vs `1d75f33` pipeline run |

**Recent empirical work:** see **Session log** below (2026-07-03 pre-review chat; 2026-07-09 intro pass).

**Compile check (2026-07-28):** `latexmk` / `pdflatex` not available on this machine's shell `PATH`. Static check: section labels and new cites resolve in repo; `numbers.tex` regenerated 2026-07-03 (`1d75f33`). Run full compile on **Overleaf** or after installing MacTeX.

---

## Session log

### 2026-07-03 — Pre-review manuscript polish (Cursor chat)

**Scope:** JQAS-facing abstract/title, terminology, CV methodology, exemplar interpretation, future-work framing. All changes on `main`; head **`5888d22`**.

| Area | Outcome |
|------|---------|
| **Title** | `When Should Team KPIs Be Absolute or Relative for Match-Outcome Prediction?` |
| **Abstract** | Five-part lay structure; pooled `\PEFtotalStudies` scope (no league/match totals); data-informed diagnostic; indicate vs predict; information content terminology |
| **Authors** | Placeholder block: Rowan Brown + Sports Analytics Group only (`ee6d332`; restore Bennett/Kilduff/Scott after D4) |
| **Terminology** | data-informed (not data-driven); structured guidance (not actionable); abstract structure guide synced |
| **Pipeline** | Team-blocked five-fold CV for ML; team-cluster bootstrap for PEF CIs; full rerun + finalize diagnostics (`1d75f33`) |
| **Methods** | `\cref{sec:ml_cv}` documents team-blocked folds; robustness text matches code (removed unimplemented cluster-robust SE / mixed-effects claims) |
| **Results / Discussion** | Univariate $\Delta\mathrm{ML}$ scope; team-fold rationale; Q4 exemplar text aligned to $\Delta\mathrm{ML}\approx -0.3\%$; exemplars as **local** $(\kappa,\rho)$ anchors (nonlinear geometry; `\parencite{brownPEFmath}`) |
| **Future directions** | Within-quadrant high/low $\kappa$ and $|\rho|$ stratification; season-blocked CV noted |

**Commits (newest first):** `5888d22` … `6c9189c` (see `git log 6c9189c..5888d22`).

**Follow-ups for next review:** `D1` Overleaf compile; `D4` co-authors; `A6` sync companion `validation_inputs/` from `1d75f33`; optional season-blocked CV (future study, not in current pipeline).

### 2026-07-09 — Introduction prose pass

Fisher limits, Scott URC vs women's rugby null, rationale-before-examples, sport pivot, Montgomery SPC cite; `scott2023womens` DOI fix. Head **`9c713e7`** (after merge `31f5d72`).

---

## Road A — Empirical paper (`pef-empirical`)

**Goal:** Submission-ready manuscript with a clean, reproducible MATLAB pipeline.

**Canonical run:**

```bash
cd scripts/paper_pipeline
/Applications/MATLAB_R2025b.app/bin/matlab -batch "run('run_paper_pipeline.m')"
/Applications/MATLAB_R2025b.app/bin/matlab -batch "run('run_pef_idealised_probit_sim.m')"
/Applications/MATLAB_R2025b.app/bin/matlab -batch "run('run_pef_finalize_diagnostics.m')"
```

### A. Reproducibility and repo

| ID | Task | Status |
|----|------|--------|
| A1 | Full pipeline + finalize + idealised sim run on clean tree | **Done** (2026-07-03, `1d75f33` — team-blocked CV + team bootstrap) |
| A2 | All `figures/Figure_*.png` paths resolve | Done |
| A3 | `numbers.tex` + `finalize_correlations.tex` match manuscript | Done |
| A4 | Commit June pipeline/SI work | **Done** — Strand 2 merged to `main` (Overleaf merge `31f5d72`, July 2026); intro polish commits through `9c713e7` |
| A5 | README documents S1–S8 and three-script workflow | Done |
| A6 | `sync_to_companion.sh` after clean commit (optional pre-submit) | **Stale** — companion last synced at empirical `4792602` (2026-06-22); pipeline outputs changed at `1d75f33` (2026-07-03); prose through `5888d22` |

### B. Manuscript ↔ pipeline consistency (blocking)

| ID | Issue | Status |
|----|-------|--------|
| B1 | Game counts: Methods/appendix use 283 / 1114 (two-season pooled), not 240 / 552 | Done |
| B2 | Study count: 113 KPI studies, not “47-study” | Done |
| B3 | ML methods: logistic `glmfit`, team-blocked five-fold CV (MATLAB), not scikit-learn trio | Done (2026-07-03, `1d75f33`) |
| B4 | η–*I* narrative: fixed-δ idealised *r* ≈ 0.87; heterogeneous KPI *r* ≈ −0.21; replace stale *r* = 0.900 | Done |
| B5 | Scenario table: idealised probit ML % (≈ 9.4, 8.2, 8.6, 7.9), not legacy 15.2 / 25.3 | Done |
| B6 | Multiple-comparison table (`tab:mc`): not pipeline-generated — soften, replace, or move to SI | **Done** — removed entirely (Phase 1, 2026-06-25) |
| B7 | `eq:dml_poly` retired from main text; §2.5 replaced with signal-strength narrative (`eq:delta_ratio`) | **Done** (Phase 1, 2026-06-25) |
| B8 | Abstract `\PEFmlCorr` headline removed; replaced with quadrant exemplar statement | **Done** (Phase 1, 2026-06-25) |
| B9 | Discussion quadrant narrative; remove obsolete TODO | Done |

### C. SI and narrative integration

| ID | Task | Status |
|----|------|--------|
| C1 | Main text cites S1–S2 | Done |
| C2 | Main text cites S3–S8 (minimal Results paragraph vs SI-only) | Done — new §Efficiency–Power Alignment subsection in results.tex |
| C3 | `Figure_3b` (ψ residual): cite, defer to companion, or omit | Done — one sentence in Fig 3 caption; `brownPEFmath` stub added to references.bib |
| C4 | Supporting-domain SI figures vs prose claim | Done — prose now cites tab:validation and fig:pef_landscape only |
| C5 | Efficiency–power story wired to S4–S7 | **Done** — §2.5 rewritten as signal-strength narrative; exemplar table in Results (Phase 1, 2026-06-25) |

### D. Pre-submission polish

| ID | Task | Status |
|----|------|--------|
| D1 | `latexmk -pdf` — zero undefined refs | **Pending** — not run locally (no TeX on shell PATH, 2026-07-28); use Overleaf or MacTeX |
| D2 | Author block, affiliations, data/code statement | Partial — placeholder author block (`ee6d332`); final names/affiliations pending D4 |
| D6 | Pre-review polish: title/abstract, CV grouping, exemplar local geometry, $\Delta\mathrm{ML}$ framing | **Done** (2026-07-03 chat, `5888d22`) |
| D3 | Target journal + SI format | Partial — see [`TARGET_JOURNAL_MATRIX.md`](TARGET_JOURNAL_MATRIX.md) (JQAS primary; CSF explore tier) |
| D4 | Co-author sign-off on weak η→ML framing | Pending |
| D5 | Introduction prose pass (Fisher, Scott citations, opening structure) | **Done** — July 2026 commits `8b7c57f`–`9c713e7` on `main` |

### Empirical sequence (recommended)

1. ~~**B1–B5** (consistency pass)~~ ✓ 2026-06-15
2. ~~**C2–C3** (SI integration decisions)~~ ✓ 2026-06-22
3. ~~**Phase 1** (Strand 2 reframe: retire `eq:dml_poly`; §2.5 → signal-strength; exemplar table; drop `tab:mc` + `appendix_b`; log-transform → SI Note S1)~~ ✓ 2026-06-25 → merged to `main` July 2026
4. ~~**Phase 2** (Figure 3 exemplar annotations; regenerated `figures/Figure_3.png`)~~ ✓ 2026-06-25
5. ~~**Phase 3** (Introduction prose: Fisher limits, mixed-gain citations, opening structure, sport pivot, SPC cite)~~ ✓ 2026-07-09 (`9c713e7`)
6. **D1** — `latexmk` compile on Overleaf/MacTeX; fix any undefined refs
7. ~~**A1** — full three-script pipeline rerun~~ ✓ 2026-07-03 (`1d75f33`)
8. **D2** — final author block, affiliations, data/code statement
9. **D4** — co-author sign-off on weak η→ML framing and exemplar table values
10. **A6** — `sync_to_companion.sh` after pipeline commit (if §7 CSVs change)

---

## Road B — Mathematics companion (`pef-mathematics`)

**Goal:** Theory-first companion citing empirical CSVs in §7; empirical submits first.

**Validation inputs:** refresh from empirical via `bash scripts/paper_pipeline/sync_to_companion.sh` (run from `pef-empirical` root on a **clean** tree).

### Drafting order

| Phase | Section | File | Depends on | Status |
|-------|---------|------|------------|--------|
| 0 | Refresh inputs + companion Fig 1 plan | `validation_inputs/` | Empirical pipeline | **Done** (2026-06-22); **re-sync needed** before companion submit (empirical at `9c713e7`, inputs from `4792602`) |
| 1 | §2 Canonical form + κ ↔ 1/κ | `sections/canonical_form.tex` | — | **Drafted** 2026-06-22 |
| 1b | §1 Introduction | `sections/introduction.tex` | §2 | **Drafted** 2026-06-22 |
| 2 | §7.1–7.2 Symmetry tests | `sections/numerical_validation.tex` | CSVs | **Drafted** 2026-06-22 (§7.3–7.7 pending theory) |
| 3 | §5 Partition function | `sections/partition_function.tex` | §2 | **Drafted** 2026-06-22 |
| 4 | §4 Sphere realisation + Fig 4 | `sections/sphere_realisation.tex` | §2 | **Drafted** 2026-06-22 |
| 5 | §6 Fisher–Rao ψ | `sections/fisher_rao.tex` | §5, §7.5 CSVs | **Drafted** 2026-06-22 |
| 6 | §3 Möbius / Chebyshev | `sections/mobius_chebyshev.tex` | §2 (+ literature scan) | **Drafted** 2026-06-22 |
| 7 | §7.3–7.7 Remaining validation + falsifiability table | `numerical_validation.tex` | §3–§6 | **Drafted** 2026-06-22 |
| 9 | §8 Discussion | `sections/discussion.tex` | §7.7 | **Drafted** 2026-06-22 |
| 10 | Abstract | `sections/abstract.tex` | All above | **Drafted** 2026-06-22 |

```mermaid
flowchart TD
  P0[Refresh validation_inputs] --> S2[§2 Canonical form]
  S2 --> S7a[§7.1–7.2 Symmetry]
  S2 --> S5[§5 Partition function]
  S5 --> S4[§4 Sphere + Fig 4]
  S5 --> S6[§6 Fisher-Rao psi]
  S6 --> S7b[§7.3–7.6]
  S2 --> S3[§3 Mobius/Chebyshev]
  S7b --> S7c[§7.7 Falsifiability]
  S3 --> S1[§1 Introduction]
  S7c --> S8[§8 Discussion]
  S8 --> ABS[Abstract last]
```

### Companion scope guardrails

- Do **not** re-derive six-domain KPI ML tables from empirical.
- §7 numbers must match `validation_inputs/` — no hand-typing.
- ψ headline interpretation lives here, not in empirical Results.

---

## Cross-links

| Empirical submits with… | Companion later cites… |
|-------------------------|------------------------|
| Distribution-free η, quadrants, weak η→ML | Canonical form, κ symmetry |
| (A1)–(A2) MI + idealised probit SI | Partition function, ρ = 0 regime |
| Sports + six-domain validation | §7 CSV tests |
| No ψ headline | ψ scale, meta-analytic pooling |

**Project memory:** [`PEF_PROJECT_MEMORY.md`](PEF_PROJECT_MEMORY.md) (both repos).

---

## Two-day plan (complete drafts by 2026-06-17)

**Definition of “complete draft”**

| Paper | Complete draft means | Realistic scope |
|-------|----------------------|-----------------|
| **Empirical** | Compiles cleanly; pipeline reproducible; main + SI internally consistent; author/metadata blocks filled; ready for your read-through before journal formatting | **Achievable** — manuscript body largely written |
| **Mathematics** | All sections have prose (not TODO scaffolds); §7 reports CSV numbers; one companion figure; abstract last | **Achievable as first full draft** — §3 Möbius may stay shorter; deep literature scan deferred |

### Day 1 — Tue 2026-06-16

| Block | Empirical (`pef-empirical`) | Mathematics (`pef-mathematics`) |
|-------|----------------------------|-----------------------------------|
| **Morning** | **C2:** Add one Results subsection (efficiency–power) cross-ref S3–S7. **C3:** One sentence on Fig 3b → companion. **C4:** Soften supporting-domain SI claim or note as table-only. | **P0:** Commit empirical work → `sync_to_companion.sh`. **§2** canonical form (full draft from outline). |
| **Afternoon** | **D1:** `latexmk` — fix undefined refs/cites. **B6:** Drop or move `tab:mc` if still uncomfortable. | **§7.1–7.2** symmetry tests (prose from `kappa_symmetry_*.csv`). **§5** partition function + cumulant identity. |
| **Evening** | **A1:** Full three-script pipeline rerun. **A4:** Git commit (pipeline + tex + figures + README). | **§7.5–7.6** ψ stabilisation + regime LRT from `psi_*.csv`. Start **§4** sphere theorem + figure sketch. |

### Day 2 — Wed 2026-06-17 (target: complete drafts)

| Block | Empirical | Mathematics |
|-------|-----------|-------------|
| **Morning** | **D2:** Author, affiliation, data/code availability statement. Read-through: abstract ↔ Results alignment (weak η→ML). | Finish **§4** sphere + **§6** ψ (meta-analytic recipe). **§7.3–7.4** cumulant + sphere numerical checks. |
| **Afternoon** | **D3:** Pick target journal; adjust SI placement if needed. Final compile + PDF review. | **§3** Möbius linearisation (core identity + iso-η contours; Chebyshev/Poisson abbreviated). **§7.7** falsifiability table. |
| **Evening** | Mark empirical **submission draft** in roadmap. Optional: send PDF to co-authors. | **§1** intro + **§8** discussion + **abstract**. Compile companion PDF. Mark both drafts complete. |

### Parallel workstreams (if solo)

```mermaid
gantt
    title PEF papers — 2-day draft sprint
    dateFormat YYYY-MM-DD
    section Empirical
    SI integration C2-C4     :a1, 2026-06-16, 1d
    Compile and metadata D1-D2 :a2, 2026-06-16, 2d
    Pipeline commit A1-A4    :a3, 2026-06-16, 1d
    section Mathematics
    Sync plus Section 2 7.1  :b1, 2026-06-16, 1d
    Sections 4 5 6 7 core  :b2, 2026-06-17, 1d
    Intro discussion abstract :b3, 2026-06-17, 1d
```

### Risk buffer

| Risk | Mitigation |
|------|------------|
| Companion §3 literature scan slows Day 2 | Ship §3 as “identity + contours”; defer Chebyshev/Poisson to appendix remark |
| `tab:mc` / Cohen’s *d* numbers untrusted | Move table to SI or delete; keep bootstrap narrative |
| Pipeline rerun changes macros | Rerun **after** tex edits; commit outputs + tex together |
| Two full papers in 48 h is tight | **Priority order:** empirical submission draft first; companion “complete draft” = all sections prose, polish later |

### Checklist at end of Day 2

- [x] Empirical manuscript body + SI drafted (Strand 2; July intro pass)
- [ ] Empirical PDF compiles; no `???` macros; S1–S8 present (`D1` — run on Overleaf)
- [x] `pef-empirical` committed on `main`
- [ ] `sync_to_companion.sh` run on latest pipeline commit (`A6`)
- [x] Companion first full draft (June 2026)
- [ ] Companion PDF compiles; `validation_inputs/_manifest.csv` matches empirical commit SHA
- [x] This roadmap updated (2026-09-05; session log for 2026-07-03 chat)

**Repos:** [`pef-empirical`](.) (submit first) · [`pef-mathematics`](../pef-mathematics) (companion)
