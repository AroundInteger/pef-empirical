# SKILL: PEF Split-Publication Review
**File:** `review-pef-papers.md`  
**Role:** Project-specific calibration, scope boundaries, pipeline provenance, and joint-paper consistency for `pef-empirical` and `pef-mathematics`  
**Read after:** `review-calibration.md` and **before** `review-science.md` when reviewing either PEF manuscript

---

## 1. Purpose

The PEF project uses a **split publication strategy**: two maintained repositories, two manuscripts, one shared formula. Generic review skills apply, but without this annex a reviewer will miscalibrate venue norms, miss scope creep between papers, or flag “missing theory” / “missing data” that deliberately lives in the sibling repo.

**Always read this file when:**
- The document path or content references `pef-empirical`, `pef-mathematics`, PEF, paired efficiency, or \(\eta(\kappa,\rho)\)
- The user asks for a review of either manuscript or a joint pre-submission check

**Reference documents (read-only context; do not duplicate in review output):**
- `PEF_PROJECT_MEMORY.md` — scope boundaries and reproducibility entry points
- `TARGET_JOURNAL_MATRIX.md` — venue priorities and known reviewer attack surfaces

---

## 2. Document routing

At calibration, classify:

| Field | Empirical (`pef-empirical`) | Companion (`pef-mathematics`) |
|---|---|---|
| **Paper role** | Cross-domain validation, quadrants, KPI ML, Gaussian MI link | Geometry, symmetries, sphere, partition function, Fisher–Rao \(\psi\), §7 numeric tests |
| **Submit order** | **First** | Around same time / after empirical reproducibility is stable |
| **Primary venue** | JQAS (primary); EJSS/JSAMS backup | AoAS (primary); JRSS Series C backup |
| **Primary field** | Sports analytics + applied statistics | Applied mathematics / information geometry |
| **Application domain** | Rugby URC + English Championship KPIs; supporting domains in SI | None new — cites empirical for datasets |
| **Canonical pipeline** | `scripts/paper_pipeline/run_paper_pipeline.m` | Imports `validation_inputs/` only |

Default venue inference: use `TARGET_JOURNAL_MATRIX.md` unless the user overrides.

---

## 3. Scope boundary checklist

Apply in every PEF review. Violations are typically **🔴 CRITICAL** for the manuscript where the violation occurs.

### 3.1 Empirical paper must not (as primary Results)

- Promote Fisher–Rao \(\psi\), partition-function proofs, Möbius/Chebyshev series, or sphere geometry as headline contributions (cite companion briefly instead)
- Oversell a global \(\eta \rightarrow\) ML mapping (pooled correlation weak; `eq:dml_poly` retired from main text)
- Claim rugby landscape is “mostly Q4” — inventory is **Q3-heavy**
- Present `pef_landscape_ml_validation_matlab_script.m` outputs as KPI pipeline reruns (that script is synthetic Monte Carlo)
- Treat distribution-free \(\eta\) and Gaussian (A1)–(A2) MI link as interchangeable without labelling assumptions

### 3.2 Companion paper must not

- Re-derive or headline six-domain KPI ML results (cross-cite empirical)
- Invent §7 statistics not present in `validation_inputs/*.csv`
- Treat Level 1 symmetry checks (dense grid / implementation) as empirical discoveries — label as consistency checks on `pef_theory_helpers.m`
- Block empirical submission on unfinished companion theory

### 3.3 Cross-citation discipline

- Empirical → companion: minimal forward cite (“in prep.” or published); no long reproduced proofs
- Companion → empirical: data provenance and KPI counts; no duplicate tables
- Numeric claims in companion §7 must match stamped CSVs and `_manifest.csv` (sha256, empirical commit)

---

## 4. PEF science checklist

Add to `review-science.md` Part A/B when reviewing either paper.

### 4.1 Three-tier validation (empirical)

| Tier | Content | Review focus |
|---|---|---|
| 1 | Idealised probit simulation under (A1)–(A2) | Confirms `eq:mi_closed`; scope must stay “controlled reference”, not proof for all KPIs |
| 2 | Sports KPI landscape + **four quadrant exemplars** | Landscape = descriptive; mechanistic claims rest on exemplars + \(\delta/\sigma_{\mathrm{A}}\) moderator |
| 3 | Four supporting domains | Generalisability hedged; role in main text vs SI appropriate for venue |

**Flag [CRITICAL]** if main text inferential claims rest on pooled landscape statistics alone (especially pooled \(\eta\)–ML correlation).

**Flag [SIGNIFICANT]** if exemplar selection criteria or \(\delta/\sigma_{\mathrm{A}}\) matching is unclear.

**Known counter-exemplar:** rugby `rucks_won` — high \(\eta\), negligible \(\Delta\mathrm{ML}\); confirms signal-strength moderation. Absence of this tension in Discussion is a gap.

**Q4 feature, not bug:** \(\eta<1\) with positive \(\Delta\mathrm{ML}\) — efficiency–power tension must be explained, not hidden.

### 4.2 Statistical treatment (empirical)

- Multiple KPI comparisons: per-KPI bootstrap intervals and stated FDR/Bonferroni/Holm where hypothesis tests run — do **not** demand single-study power calculations at clinical-trial standard for observational sports KPI inventory
- Sports ML: five-fold CV on pooled seasons — probe team-level clustering (paper cites cluster-robust checks); random CV alone may be [SIGNIFICANT], not automatically [CRITICAL] if robustness is reported
- Effect sizes alongside significance for exemplars and key contrasts

### 4.3 Theory companion

- Theorem/proposition proofs complete or explicitly deferred
- Canonical \(\eta = \cosh\tau/(\cosh\tau-\rho)\) consistent with empirical formula
- §7 claims traceable to CSV columns named in prose
- Regime change at \(\rho=0\) and \(\psi\)-scale pooling interpreted at appropriate depth for target venue (AoAS: deeper; Series C: emphasise cross-domain CSV tests)

---

## 5. PEF pipeline and reproducibility checklist

Add to `review-science.md` Part B.

| Check | Empirical | Companion |
|---|---|---|
| Entry point named | `run_paper_pipeline.m` | `validation_inputs/` + cite empirical pipeline |
| Generated numbers | `\input{scripts/paper_pipeline/outputs/numbers.tex}` current (no `???`) | N/A — no `numbers.tex` |
| Macro naming | Letter-only `\PEF...` macros | N/A |
| Figures | `figures/Figure_*.png` from pipeline outputs | `Figure_4_sphere.png` etc. |
| Shared library | `scripts/paper_pipeline/lib/pef_theory_helpers.m` | Mirrored under `scripts/lib/` via sync |
| Companion sync | After pipeline change: `sync_to_companion.sh` → `_manifest.csv` | Manifest commit matches cited empirical commit |
| MATLAB path | `/Applications/MATLAB_R2025b.app/bin/matlab` documented in README | Points to empirical for full rerun |

**Flag [CRITICAL]** if manuscript numbers contradict CSV/`numbers.tex` or companion §7 cites stale manifest.

**Flag [SIGNIFICANT]** if methods omit seeds, software version, or pipeline path needed for replication.

---

## 6. Known narrative traps (auto-flag)

When any of these appear mischaracterised, escalate severity:

| Trap | Correct framing |
|---|---|
| “Sports KPIs populate Q4” | Rugby/football landscape is Q3-heavy |
| Strong global \(\eta\)–ML correlation | Retired from headline; exemplars + honest limitation |
| `eq:dml_poly` in main text | Should be absent; optional SI footnote only |
| Synthetic landscape ML script | Not empirical KPI validation |
| ψ / partition function in empirical Results | Belongs in companion |
| Six-domain ML novelty in companion | Belongs in empirical |
| Level 1 symmetry “validation” | Implementation consistency, not new empirical science |

---

## 7. Venue-specific emphasis

### 7.1 JQAS (empirical primary)

- Lead with rugby + football KPI question and practitioner quadrant guidance
- Cite Scott/Bennett URC lineage and recent JQAS scepticism on win-probability / observational ML
- Absolute vs relative feature engineering as core narrative
- Cross-domain detail acceptable in SI; main text stays sports-spined
- Honest limitation on weak pooled \(\eta\)–ML mapping strengthens credibility

### 7.2 Annals of Applied Statistics (companion primary)

- Proof completeness and explicit assumptions
- §7 as falsifiability of geometric claims, not tautological restatement of definitions
- Fisher–Rao \(\psi\) and meta-analytic scale — primary depth here
- Cross-cite empirical for data; do not re-run sports ML

### 7.3 JRSS Series C (companion backup / empirical backup)

- Applied statistics + clear application hook if empirical
- Cross-domain numerical tests weighted over Fisher–Rao depth
- Rugby/football in title if empirical targets Series C

---

## 8. Mode D — Joint consistency review

**Trigger:** User requests pre-submission cross-paper check, or both repos/manuscripts are in scope.

**Sequence:**
1. Brief calibration for **both** paper roles and venues
2. Run §3 scope boundary checklist across both manuscripts
3. Run §5 pipeline checklist (`_manifest.csv`, shared `pef_theory_helpers.m`, cross-cites)
4. Run §6 narrative trap scan on both
5. **Do not** repeat full Mode A science/communication audits unless user asks

**Output format:**

```
JOINT CONSISTENCY REVIEW — PEF empirical + companion — [date/version]

CALIBRATION
  Empirical venue: [JQAS / …]
  Companion venue: [AoAS / …]
  Manifest empirical commit: [sha from _manifest.csv]

SCOPE BOUNDARY
  [CRITICAL / SIGNIFICANT] [issue] — [which paper] — [resolution]

NUMERIC / PROVENANCE
  [severity] [issue] — [resolution]

CROSS-CITATION
  [severity] [issue] — [resolution]

NARRATIVE TRAPS
  [severity] [issue] — [resolution]

RECOMMENDED ORDER OF WORK
  1. …
  2. …

PRIORITY ACTION LIST (cross-paper items only)
  [C/S/P items affecting submission readiness]
```

End with recommendation: proceed empirical Mode A / refresh validation_inputs / companion blocked until manifest sync, etc.

---

## 9. Language and LaTeX conventions (both papers)

- British English in prose
- Greek and operators in math mode (`$\eta$`, `$\kappa$`, `$\rho$`, `$\psi$`) — not Unicode in `.tex`
- Empirical: generated macros from pipeline — never hand-edit values in `numbers.tex`
- Companion: `\cref` and `\textcite` to empirical for data; no invented CSV values

---

## 10. Integration with other skill files

| Skill file | PEF addition |
|---|---|
| `review-calibration.md` | §5.5 profiles; extended venue table; calibration profile fields |
| `review-science.md` | §4 split-paper tensions; §2.4 KPI note |
| `review-communication.md` | §2.9 non-IMRaD; landscape figure checks |
| `review-orchestrator.md` | Mode D workflow; conditional read of this file |
| `review-outputs.md` | Joint review uses §8 format above, not Format A/B |

When **not** reviewing PEF papers, skip this file entirely.
