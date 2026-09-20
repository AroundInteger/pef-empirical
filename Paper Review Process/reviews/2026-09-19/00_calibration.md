# Calibration profile — empirical PEF manuscript

**Date:** 2026-09-19  
**Review type:** Mode A first-pass (venue-calibrated)  
**Authoritative text:** `sections/*.tex`, `main.tex`, `scripts/paper_pipeline/outputs/numbers.tex` (generated 2026-09-16 12:29:35)  
**Not authoritative:** `Paper Review Process/section-md/` mathematics (exporter garbles displayed formulae)

Frozen after confirmation of the review plan. Companion (`pef-mathematics`) is out of scope except for the split-publication checklist.

---

```
CALIBRATION PROFILE
Document type:    Original research journal article
Primary field:    Sports analytics → applied statistics (method) + invasion-game KPI analysis (application)
Target venue:     Five empirical venues (see below); default submit-first remains JQAS
Applicable norms: PEF split-publication checklist; observational sports-analytics / JQAS ML norms (not CONSORT)
Special context:  Split publication with pef-mathematics; restricted URC / club sports data; pipeline-owned numbers.tex
Review mode:      Mode A per venue (shared science + communication audits; Format A per journal)

PEF fields:
Paper role:       empirical
Sibling paper:    companion in prep (brownPEFmath)
Pipeline status:  numbers.tex current (2026-09-16); no ??? placeholders in generated macros
Reference docs:   PEF_PROJECT_MEMORY.md, TARGET_JOURNAL_MATRIX.md
```

---

## Shared manuscript facts (all reviews)

| Item | Current draft |
|------|----------------|
| Title | When Should Team KPIs Be Absolute or Relative for Match-Outcome Prediction? |
| Author block | Rowan Brown + placeholder “Sports Analytics Group”; Bennett / Kilduff / Scott not yet named (roadmap D4) |
| Inventory | 86 KPIs (22 rugby URC, 64 football Championship); Q3-heavy (55/86 = 64.0%) |
| Matches | Rugby *n* = 283; football *n* = 1,114; seasons 23/24–24/25 pooled |
| Exemplars | Q1 kick metres η = 2.84, ΔML = +4.3%; Q2 long balls η = 1.30, ΔML = +5.5%; Q3 passes η = 0.61, ΔML = −0.8%; Q4 GK long balls η = 0.81, ΔML = −0.3%; foil rucks won η = 5.38, ΔML = −1.6% |
| Pooled η–ML | *r* = 0.040 (retired from headline; correct) |
| Abstract | ~337 prose words; five-part skeleton present; no equations |
| Body prose | ~8,025 words (tables and displayed equations stripped) |
| Main display items | 6 tables + 3 figures = 9 |
| SI | 5 figures (S1–S5) + ≥1 table |
| Unique cites in main | 47 keys (55 entries in `references.bib`) |
| Citation style | `biblatex` numeric / Vancouver order-of-appearance |
| Data | Sports not redistributed; tools at github.com/AroundInteger/pef-tools |

**Must not headline (empirical):** Fisher–Rao ψ, partition-function proofs, sphere geometry.  
**Must not oversell:** global η → ML mapping; rugby landscape as “mostly Q4”.

---

## Venue-specific calibration

| Venue | Tier | Reviewer community | Immediate packaging risk |
|-------|------|--------------------|--------------------------|
| **JQAS** (primary) | Strong field (ASA sports stats) | Sports KPI + honest observational ML | Blind review; ~200-word abstract; Harvard/Chicago author-date; typical 20–30 double-spaced pages |
| **EJSS** (backup) | Solid mid-tier sport science; gold OA (Wiley from 2024) | Practitioners / sport scientists | ≤5,000 words body; unstructured abstract ≤250; IMRaD; theory section will not fit as written |
| **JSAMS** (backup) | Sport medicine / clinically meaningful sport science | Clinicians + applied sport scientists | Scope mismatch. ≤5,000 words; structured abstract; ≤6 tables+figures; ≤40 refs |
| **IJPAS** (fallback) | Performance-analysis specialist | Notational / KPI analysts | Typical original paper ≤7,500 words *inclusive* of tables, refs, captions |
| **CSF** (explore) | Q1 nonlinear science | Complexity / information / econophysics | No strict page cap; Highlights 3–5 × 85 chars; desk-reject if it reads as generic sports analytics |

**Series C** and **AoAS** receive a requirements + fit note only (not a sixth/seventh Format A).

---

## Counts used for packaging checks

| Metric | Estimate | Method |
|--------|----------|--------|
| Abstract words | 337 | Macro-expanded prose in `abstract.tex` |
| Body words excl. abstract | ~8,025 | LaTeX stripped of tables, figures, displayed equations |
| Captions (main + SI, rough) | ~261 | `\caption{}` text |
| Main tables | 6 | `tab:cross_domain`, `tab:scenarios`, `tab:exemplars`, `tab:validation`, `tab:quadrants`, `tab:boundary` |
| Main figures | 3 | Figures 1–3 |
| SI figures / tables | 5 / 1 | `supplementary.tex` |
| Unique main-text cites | 47 | `\cite` / `\parencite` keys in main sections |

These are review estimates, not `texcount` journal-page proofs. Double-spaced JQAS conversion of ~8k body words plus display items is roughly the upper end of the 20–30 page band.
