─────────────────────────────────────────────────────────
PEER REVIEW REPORT
Paper: When Should Team KPIs Be Absolute or Relative for Match-Outcome Prediction?
Field: Sports analytics → applied statistics
Target venue: Journal of Quantitative Analysis in Sports (De Gruyter / ASA), Tier: strong field
Review type: First-pass
─────────────────────────────────────────────────────────

OVERALL ASSESSMENT

This is a sports-KPI paper with a genuine question: relativisation sometimes helps match-outcome models and sometimes harms them, and the motivating rugby studies only classified help versus no help. The Paired Efficiency Factor organises that choice by (κ, ρ, δ/σ_A), the inventory is honestly Q3-heavy (55 of 86 KPIs), and the four exemplars plus the rucks-won foil are the right confirmatory design. The draft already avoids the main self-inflicted attack (a global η → ML surface; pooled r = 0.040). It is not submission-ready: the abstract is ~337 words against JQAS’s ~200, the author block is incomplete, the healthcare N macro prints “1 participant”, Methods promise tests Results never show, and the package is still Vancouver numeric rather than JQAS author-date and is not de-identified.

RECOMMENDATION: Major revision

Rationale: The core contribution is sound for JQAS and does not need a new study. The issues below are packaging, one numeric collision, methods residue, and a slightly over-imperative Q4 recipe. Those are addressable without changing the pipeline design.

─────────────────────────────────────────────────────────
MAJOR CONCERNS (must be addressed)

1. Abstract length and JQAS house form (§Abstract)
   JQAS asks an abstract of about 200 words and 3–6 keywords that do not appear in the title. The current abstract is ~337 words and there are no keywords.
   Why it matters: this is a first-filter item at ScholarOne.
   Suggested resolution: cut to ~200 words using the existing five-part skeleton. Keep rugby + football, 86 KPIs, the both-ways result, and the univariate scope. Drop the “count, rate, and event” clause and collapse simulation + exemplars into one sentence. Add keywords such as paired comparisons; key performance indicators; rugby union; association football; feature engineering (none of these repeat the title’s “absolute or relative”).

2. Healthcare participant count is wrong in Results (§Results, supporting validation)
   `\PEFhealthN` = 1 is a study count. Results uses it as “N NHANES participants”. Methods correctly give 10,352 records.
   Why it matters: a JQAS reviewer will treat this as carelessness about data scale.
   Suggested resolution: new macro for participants, or write 10,352; keep 1 only in the “n studies” column of Table 1, with the existing dagger footnote.

3. Methods describe a statistical battery that Results do not report (§Methodology, Statistical Rigour / QC)
   Bonferroni/BH/Holm, Cohen’s d, partial η², a priori power, Little’s MCAR, Durbin–Watson, and Levene are promised. The sports story is bootstrap intervals and team-blocked ΔML.
   Why it matters: reviewers will ask where the tests are, or will infer leftover template text.
   Suggested resolution: delete unused procedures or report them in SI. Keep bootstrap, team-blocked CV, and the circular-KPI rule.

4. Blind-review and reference-style package (whole manuscript)
   JQAS reviews are blind. Manuscripts must be de-identified; typical length 20–30 double-spaced pages; Harvard/Chicago author-date; figures as separate EPS/TIF/JPG. The draft names the corresponding author on the title page, uses numeric Vancouver `biblatex`, and embeds figures.
   Why it matters: formatting non-compliance delays or blocks technical check.
   Suggested resolution: anonymised PDF + LaTeX source; separate title page; `biblatex` authoryear / Chicago author-date; keywords; double-spaced 11–12 pt single column; figures as separate files. Complete the real author block (Bennett/Kilduff/Scott) only on the title page, not in the blinded file.

5. Practical Q4 guidance outruns the confirmatory row (§Discussion, practical guidance; Table `tab:exemplars`)
   Goalkeeper long balls: η = 0.81, ΔML = −0.3%. The text is already honest that this is not a large relative-feature gain. The six-step recipe still tells practitioners to compute I(X;Y) and relativise in Q4 when information “justifies” it.
   Why it matters: JQAS has recently published sceptical win-probability work; over-precise practitioner rules will be attacked.
   Suggested resolution: Q1–Q2 relative; Q3 absolute; Q4 “estimate δ/σ_A, then check with CV; the (A1)–(A2) I formula is a prior, not a substitute.” Keep the tension on the probit grid and the landscape, not on this exemplar.

─────────────────────────────────────────────────────────
MINOR CONCERNS (should be addressed, will not block acceptance if sound explanation given)

1. Football Methods list includes “cards”; outcome definitions omit cards as circular with the result. Align the list.

2. Finance Methods (“multiple asset classes and periods”) disagree with Results (S&P 100 vs S&P 500, 2020–2023, n = 18).

3. Companion ψ / sphere / partition function is named in Methods, Results, and the Figure 3 caption. One “in prep.” sentence is enough for JQAS.

4. Recent JQAS papers on the difficulty of estimating win probability and on soccer feature construction are not cited. Add two or three; they strengthen, not dilute, the honest-limits story.

5. Pipeline entry point, MATLAB R2025b, toolbox, and seed are in the README, not the paper. Add one reproducibility paragraph.

6. Introduction already quotes Shapiro–Wilk W = 0.98 and κ/ρ ranges. Move numbers to Methods/SI.

7. Absolute baseline is X_A only. State why (X_A, X_B) is out of scope (multivariate).

8. Supporting domains show (κ, ρ, η), not ML. Hedge “generalisability” accordingly.

─────────────────────────────────────────────────────────
OPTIONAL SUGGESTIONS (POLISH — author's discretion)

- Prefer the matrix title variant “When should team KPIs be relativised? …” if you want the verb the rugby group already uses.
- Rename Table 1 column “Efficiency” to “% with η > 1”.
- Add a clause on Figure 2 that exemplar markers are (κ, ρ) positions on a δ/σ_A = 1 surface.
- Cover letter: Scott et al. 2023 URC + a JQAS win-probability-scepticism paper + practitioner quadrant guide. Do not quote the July 2026 matrix exemplar ΔMLs (they are stale; Q4 is no longer +2.2%).

─────────────────────────────────────────────────────────
SPECIFIC COMMENTS BY SECTION

Abstract: Structure good; 337 words; no keywords.
Introduction: Question is clear; too much numeric preview; lead is already sports-capable.
Methods: Three-tier design and team-blocked CV are JQAS-strengths; residual template stats are not.
Results: Landscape vs exemplars is the right story. Fix healthcare N. Keep the honest Q4 row.
Discussion: Limitations are real. Soften Q4 recipe. One companion cite only.
Conclusions: No new claims.
Figures: Fig. 1–3 are the right set. Drop ψ from Fig. 3 caption. SI S1–S5 can stay.
References: Switch to author-date; add recent JQAS cluster.
─────────────────────────────────────────────────────────
