# Shared scientific rigour audit — empirical PEF

**Date:** 2026-09-19  
**Source:** `sections/*.tex` + `scripts/paper_pipeline/outputs/numbers.tex` (2026-09-16)  
**Skills:** `review-science.md` Parts A/B; `review-pef-papers.md` §§3–6  
**Severity here is journal-agnostic.** Venue reports re-weight these findings.

---

```
SCIENTIFIC RIGOUR AUDIT

Research question / hypothesis: clear — why does relativisation of some KPIs help match-outcome prediction while for others it is predictively harmful?

Novelty claim: genuine, with one overstated edge — the algebra of Var(X_A−X_B) is standard; the contribution is the (κ,ρ) efficiency ratio plus the (A1)–(A2) information link, the signed-harm (Q3) result, and the four-exemplar confirmation. The paper already says this in the provenance subsection. The overstated edge is cross-domain “generalisability” from PEF estimates without per-domain ML (healthcare N-macro bug aside).
```

---

## Research question and hypothesis

The question is stated in the Introduction and answered in the Discussion. The work is confirmatory on three tiers (idealised probit → sports landscape + exemplars → supporting domains) rather than a single global hypothesis test. That design is appropriate for an observational KPI inventory.

**No circular hypothesis.** The paper does not claim that η predicts ΔML globally (`\PEFmlCorr` = 0.040 is correctly retired).

---

## Novelty

Genuine relative to the Bennett/Scott rugby KPI line and to Fisher’s equal-variance pairing result:

- A regime in which relativisation should be *avoided* (Q3 signed harm) is new relative to Scott et al. (help vs no help).
- The efficiency–power tension (η < 1 can still carry information) is the theoretical payoff; it is demonstrated on the probit grid and in parts of the landscape, **not** by the current Q4 exemplar (ΔML = −0.3%).
- The paper is honest that PEF is a reframing of second-moment algebra, not a new variance identity.

**Literature gaps (not fatal):** recent JQAS work on win-probability estimation difficulty and feature construction is not cited in the draft. For a JQAS submission that is [SIGNIFICANT]. For sport-science venues the missing JQAS cluster is [MINOR]. CSF would need Buldú et al. 2021 and Petersen & Penner (metric renormalisation).

---

## Methodology

[SIGNIFICANT] **Results prose uses `\PEFhealthN` as a participant count.** `numbers.tex` sets `\PEFhealthN` = 1 (one healthcare *study*). Methods correctly say 10,352 NHANES records retained. Results (`sections/results.tex`, supporting-validation bullet) prints “across *N* = 1 NHANES participants”. `tab:validation` uses the same macro in an “*n* studies” column, which is consistent with 1, but the Results sentence is false. **Resolution:** introduce a participant-count macro (e.g. `\PEFhealthNpart`) or write 10,352 in prose; never reuse the study-count macro as *N* participants.

[SIGNIFICANT] **Methods list football KPIs that the outcome-definition rule excludes.** Primary-data bullet includes “cards”; `sec:outcome_defs` omits cards, scoring events, xG/OBV, and shots on target as circular with the binary outcome. **Resolution:** delete cards (and any other circular items) from the illustrative list.

[SIGNIFICANT] **Statistical-rigour subsection describes analyses that Results do not report.** Methods promise Bonferroni / BH / Holm, Cohen’s *d*, partial η², a priori power for *d* = 0.2/0.5/0.8, Little’s MCAR, Durbin–Watson, and Levene. The primary sports story actually uses per-KPI bootstrap intervals and team-blocked CV ΔML. Unreported batteries look like template residue and invite a “where are these tests?” review. **Resolution:** keep only procedures that produce numbers in Results or SI; move the rest out or report them.

[SIGNIFICANT] **Supporting-domain pairing is not the same estimand as sports pairing.** Healthcare is systolic vs diastolic on one visit (clinically established pulse pressure). Genomics is patient-matched tissue. Finance is stock vs market. Manufacturing pairs angular position with angular velocity, and torque with a displacement metric — not home vs away on one occasion. The PEF algebra still applies, but “the same pairing structure recurs” overclaims mechanistic equivalence. **Resolution:** label supporting domains as second-moment geometry checks, not as outcome-prediction replications. Restrict “generalisability” to (κ, ρ, η) recurrence.

[SIGNIFICANT] **Finance Methods vs Results disagree on the sample.** Methods: “Yahoo Finance across multiple asset classes and periods.” Results: S&P 100 vs S&P 500, 2020–2023 pinned snapshot, *n* = 18. **Resolution:** put the Results specification in Methods.

[MINOR] **Introduction reports Shapiro–Wilk *W* = 0.98 and κ ranges before Methods.** Those are results. **Resolution:** keep a qualitative “differences are approximately normal” clause; move numbers to Methods/Results/SI.

[MINOR] **Power-analysis language is the wrong community standard** for an 86-KPI observational inventory (PEF checklist §4.2). If retained, it should be framed as estimation precision for (κ, ρ), not as a clinical-trial sample-size justification.

---

## Statistical treatment

[SIGNIFICANT] **Q4 confirmatory row does not illustrate the efficiency–power tension.** Goalkeeper long balls: κ = 1.00, ρ = −0.24, η = 0.81, ΔML = −0.3%. The paper now says this correctly (near-zero; tension lives in the grid and the landscape). `TARGET_JOURNAL_MATRIX.md` still lists Q4 ΔML = +2.2% and rucks ΔML = 0%. Those matrix numbers are stale and must not be reused in a cover letter. **Resolution:** treat the current `numbers.tex` exemplars as canonical; refresh the matrix if it remains a planning document.

[SIGNIFICANT] **Exemplar selection criteria are only partly specified.** Signal is “broadly comparable” (0.16–0.32). Q4 sits on the κ = 1 boundary (κ = 1.00), so it is a weak Q4. **Resolution:** state the pre-specified rule (one KPI per quadrant, closest to target δ/σ_A, action KPI, non-circular). Acknowledge the Q4 boundary case.

[SIGNIFICANT] **Team-blocked CV still leaks away opponents.** The paper says so. That is acceptable for JQAS if season-blocked / chronological CV stays a limitation (already in Discussion). Elevate only if a venue demands temporal validation as primary. Not [CRITICAL] under PEF §4.2.

[MINOR] **Accuracy as the sole ML metric.** ΔML is a relative change in accuracy. Class balance in league results is not discussed. For a sign test this is tolerable; AUROC or log-loss would be stronger. Preference, not a community veto.

[MINOR] **Multiple-testing story is incomplete** once the unused correction paragraph is removed: landscape η intervals are descriptive; exemplar ΔML is four planned tests. Say that explicitly.

**What is sound**

- Landscape vs mechanistic roles are signposted (Q3-heavy inventory is not the confirmatory test).
- Global η–ML *r* = 0.040 is not headlined.
- `eq:dml_poly` is absent from the main text.
- Rucks won foil (η = 5.38, δ/σ_A = 0.07, ΔML = −1.6%) is present and correctly used.
- Idealised probit is labelled a controlled reference under (A1)–(A2), not a proof for all KPIs.
- Distribution-free η vs Gaussian *I*(*X*;*Y*) is labelled.

---

## Reproducibility

[SIGNIFICANT] **Sports data cannot be redistributed.** Data-availability statement is honest. JQAS/IJPAS can live with a restricted-data + code/tools path. Series C and AoAS treat data/code availability as policy, not a courtesy. **Resolution:** name the agreement, state what *can* be shared (KPI list, estimators, fold rule, seeds, supporting-domain public files, `pef-tools`), and what a replicator would need to request.

[SIGNIFICANT] **Pipeline path, MATLAB version, and seed are thin in the manuscript.** Methods mention MATLAB `glmfit`, toolbox, and “fixed random seeds” without the seed value, R2025b, or `run_paper_pipeline.m`. README has this; the paper does not. **Resolution:** one reproducibility paragraph: entry script, MATLAB version, toolbox, seed, `numbers.tex` generation date.

[MINOR] **Interactive tools** at `github.com/AroundInteger/pef-tools` are cited; SI is said to carry schemas. Confirm the URL and README exist before submission (not re-checked as a live clone in this audit).

**Pipeline checklist (`review-pef-papers.md` §5)**

| Check | Status |
|-------|--------|
| Entry point named in paper | Missing (README only) — [SIGNIFICANT] |
| `numbers.tex` current, no `???` | Pass (2026-09-16) |
| Letter-only macros | Pass |
| Figures from pipeline | Assumed; not re-rendered this pass |
| Companion ψ numbers in empirical Results | Not headlined; macros exist in `numbers.tex` but are unused in prose — good |
| Healthcare *N* macro | Fail — see above |

---

## Literature coverage

[SIGNIFICANT for JQAS] Missing recent JQAS cluster named in `TARGET_JOURNAL_MATRIX.md` (win-probability estimation difficulty; feature-engineering / soccer-value papers). Direct citation line Scott 2023 / Bennett is present.

[SIGNIFICANT for CSF] No Buldú 2021 special-issue editorial; no Petersen & Penner renormalisation; no network-sports complexity vocabulary.

[MINOR] Dixon & Coles and Berrar are present; Gramacy / Franks meta-analytics / Bornn sports-stats line is thin beyond `bornn2021`.

---

## Conclusions vs evidence

[SIGNIFICANT] **Practical-guidance step list is stronger than the Q4 evidence.** Step 6 tells practitioners to compute *I*(*X*;*Y*) and relativise in Q4 when information “justifies” it. The confirmatory Q4 row is near zero. The tension is real on the grid and in the landscape, but the practitioner recipe should say: Q4 is unresolved at matched low-to-moderate signal; check δ/σ_A and validate with CV; do not treat *I*(*X*;*Y*) under (A1)–(A2) as a substitute for the classifier.

[MINOR] Conclusion restates η and the four domains cleanly. It does not invent a global mapping.

[MINOR] “Steps 1–6” in the practical-guidance paragraph match the six enumerated items.

---

## PEF scope / split-paper

[SIGNIFICANT] **Companion geometry is named in empirical Methods, Results, and Figure 3 caption.**  
- Methods `sec:outcome_defs`: “canonical form, sphere geometry, and Fisher–Rao ψ scale in the companion”.  
- Results exemplars: “canonical η(τ,ρ), partition-function structure, ψ-scale stabilisation”.  
- Figure 3 caption: “Fisher–Rao ψ-scale diagnostics are developed in the companion”.  

This is a forward cite, not a results claim, so not [CRITICAL]. It is more than the “minimal in prep.” rule. **Resolution:** one sentence in Methods or Discussion (“geometric identities in the companion”) and drop ψ / partition function / sphere from Results and the Figure 3 caption.

**Trap scan (`review-pef-papers.md` §6)**

| Trap | Verdict |
|------|---------|
| “Sports KPIs populate Q4” | Avoided. Q3-heavy (64%) is stated. |
| Strong global η–ML | Avoided. *r* = 0.040 not headlined. |
| `eq:dml_poly` in main | Absent. |
| Synthetic landscape ML as empirical | Not used as KPI rerun. |
| ψ / partition function in empirical Results | Borderline — named, not quantified. |
| Six-domain ML novelty | Not claimed. Supporting domains are η summaries. |
| Level 1 symmetry as discovery | Not claimed. |

**Rugby landscape:** Q3-heavy. Do not let a cover letter revive “mostly Q4”.

---

## Numerical pipeline audit

### Mathematics

[MINOR] PEF formula in `introduction.tex` `eq:pef` is correct: η = (1+κ)/(1+κ−2√κ ρ). (Markdown review copies are not.)

[MINOR] (A2) Gaussian discriminant + equal priors is a strong idealisation; the paper says real outcomes are not generated by one KPI. Good.

No proof gap that blocks the distribution-free η claim. *I*(*X*;*Y*) closed form is deferred to SI with the right assumptions labelled.

### Data pipeline

[SIGNIFICANT] Healthcare *N* macro collision — see Methodology.

[MINOR] Genomics “3,500 genes ranked by paired-differential signal” is a selected subset; selection rule should be one sentence in Methods (already partly there).

### Evaluation

[SIGNIFICANT] Absolute baseline is *X*_A only, not (*X*_A, *X*_B). That is a stated design (univariate). Reviewers may ask why the two-absolute model is not the comparator. **Resolution:** one sentence — two-absolute is a multivariate model; the paper’s object is one feature’s absolute vs relative form.

Probit grid: 16/16 Q4 cells with η < 1 show positive mean ML improvement *under the simulation’s own outcome model*. Correctly labelled internal consistency.

---

## Strengths (do not undo)

- Clear signed-harm result for Q3 (passes, ΔML = −0.8%) that the motivating rugby papers did not classify.
- Honest Q4 exemplar (near-zero, not a forced tension demo).
- Rucks won foil: high η, no signal, negative ΔML.
- Team-blocked CV and cluster bootstrap are the right dependence story for league data.
- Three-tier design (grid / exemplars / landscape) is internally consistent and matches Strand 2 v2.
- Distribution-free η vs (A1)–(A2) information link is kept distinct.
