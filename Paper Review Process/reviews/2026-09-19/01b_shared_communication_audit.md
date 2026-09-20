# Shared communication audit — empirical PEF

**Date:** 2026-09-19  
**Skills:** `review-communication.md`; `abstract-structure-guide.md`  
**Authoritative prose:** `sections/*.tex`

---

```
COMMUNICATION AUDIT
```

## Abstract

The five-part skeleton is present (background → problem → methods → results → one-sentence conclusion). Register is sports-analyst, not theorem-first. No displayed equations; no (A1)–(A2); no sentence-initial *Because*; PEF is given one *which* clause then a second sentence.

[SIGNIFICANT] **337 words vs venue caps.** JQAS asks ~200; EJSS / JSAMS / CSF ask ≤250. The house guide targets ~230–270. The extra length is the methods paragraph (Fisher + univariate scope) plus a four-sentence results paragraph. **Resolution:** cut to ≤200 for JQAS (drop “covering different count, rate, and event measures”; collapse the simulation + exemplar sentence; keep 86 KPIs, Q3-ish anti-correlation, and the signed both-ways result). Cut to ≤250 for the other venues.

[SIGNIFICANT for JSAMS] **Unstructured.** JSAMS requires Objectives / Design / Method / Results / Conclusions.

[MINOR] “The same pairing structure recurs in healthcare, genomics, finance, and manufacturing” is broader than the supporting-tier evidence (η geometry, not ML). Hedge: “the same (κ, ρ) geometry”.

[MINOR] Abstract omits league names (good per house guide) but also omits that mechanistic confirmation is four exemplars, not the pooled inventory. One clause would help.

House-guide checklist: five parts yes; no equations yes; no *Because* yes; no chained *which* yes; Fisher after motivation yes; univariate scope yes; conclusion one sentence yes; word count fail; macros compile yes.

---

## Introduction

Funnel works: cross-domain relativisation → sport KPI contradiction (Scott URC vs women’s) → Fisher → unequal-variance PEF → efficiency vs information → contributions.

[SIGNIFICANT] **Introduction is doing Methods/Results work.** Shapiro–Wilk *W* = 0.98, skewness 0.03–0.07, typical κ 1.0–2.5, ρ −0.3 to +0.4 already appear before the theory section. For JQAS this is a density problem; for 5k-word venues it is unaffordable.

[SIGNIFICANT for EJSS/JSAMS/IJPAS] **Theory is introduced at full strength before the empirical question is allowed to breathe.** Sport-science reviewers want the rugby/football puzzle in paragraph 1, not finance/NHANES/control charts. The current first subsection leads with other domains.

[MINOR] Contributions list is enumerable and matches the paper. Item 5 (cross-domain) should stay hedged.

[MINOR] Organisation paragraph is standard and useful.

---

## Methods

Three-tier design is clear. Landscape vs mechanistic confirmation is the most important signpost in the paper and it is done well (`sec:outcome_defs`).

[SIGNIFICANT] **Replication sufficiency is uneven.** Sports leagues, seasons, *n*, circular-KPI rule, team-blocked fold rule, and ΔML formula are enough to re-implement the sports ML comparison *if* one has the data. Finance sample, genomics ranking rule, MATLAB version, pipeline entry point, and seed are not.

[SIGNIFICANT] **Statistical-rigour and QC blocks read as a methods template.** They do not match what Results reports (see science audit). They also break voice: the rest of Methods is PEF-specific; these paragraphs are generic.

[MINOR] Forward references to Results figures for season-drift are acceptable (design statement).

[MINOR] Cards in the football KPI list vs omission rule — science issue that also reads as sloppy.

---

## Results

Landscape vs exemplars vs grid is consistently separated. Q3-heavy warning is repeated in the right places. Q4 is not oversold.

[SIGNIFICANT] **Healthcare *N* = 1 in prose** is a communication failure as well as a numeric one (reader will not reconcile it with Methods).

[MINOR] Results open with the idealised simulation, not with the sports landscape. JQAS/IJPAS readers will accept this; EJSS/JSAMS readers will want sports first.

[MINOR] Some paragraphs are long (~80–100 words) and carry two jobs (what the table shows + what it does not claim). Split.

---

## Discussion / Conclusions

Discussion opens by answering the four objectives. Limitations are specific (normality, stationarity, binary outcomes, strategic interaction, shallower supporting tier). Future directions are grounded.

[SIGNIFICANT] **Practical-guidance list is more imperative than the Q4 evidence.** Soften Q4 to “estimate δ/σ_A and validate; do not relativise on η < 1 alone.”

[MINOR] Companion geometry is invoked again as the reason quadrants are nonlinear. One cite is enough.

[MINOR] Conclusion is concise and does not introduce new claims. It repeats η in symbols; JQAS abstract rules do not bind the conclusion, but a sport-science conclusion could stay in words.

---

## Language and clarity

British English throughout. Hedging on pooled mapping is well calibrated. η, κ, ρ are consistent.

[SIGNIFICANT if systematic] **Sentence length.** Several Introduction and Discussion sentences exceed ~35 words and stack subordinate clauses (writing-clarity house rule). Not unreadable; will cost space in a 5k-word cut.

[MINOR] Em-dash asides were not spotted as `---` in the `.tex` sections read for this audit.

[MINOR] “Thus, η  depends” has a double space in `introduction.tex`.

[MINOR] Author block still has a placeholder affiliation line. That is a submission-package issue, not a prose issue.

---

## Structure and flow

Non-IMRaD with an explicit Theoretical Framework section is right for JQAS/CSF/Series C and wrong for EJSS/JSAMS (they want Introduction → Methods → Results → Discussion → Conclusion). Theory can move to SI for those venues.

Section balance: Theory (~2,050 words) > Discussion (~1,800) > Methods (~1,500) > Introduction (~1,380) > Results (~1,030). Results is short relative to Theory. For JQAS that is acceptable if SI carries the landscape. For sport-science venues Theory must shrink first.

---

```
VISUAL COMMUNICATION AUDIT
```

## Figure 1 — PEF landscape (η)

Caption is self-contained: log10 colour mapping, admissibility boundary, exemplar season-drift, supporting-domain triangles, pointer to the full cloud in SI. Q3-heavy inventory is *not* mischaracterised as Q4.

[MINOR] Caption is long. JQAS can keep it; JSAMS/EJSS will want a shorter caption and the drift explanation in SI.

[MINOR] Colour: Q1 green / Q2 blue / Q3 orange / Q4 red plus a diverging log η scale. Colour-blind risk on green–red quadrant tags was not Ishihara-tested this pass. **Preference:** also encode quadrant by marker shape (already partly done: rugby circles, football squares).

## Figure 2 — *I*(*X*;*Y*) surface

Layout matches Figure 1; sequential vs diverging scale is explained. Good.

[MINOR] Surface is at δ/σ_A = 1; exemplars sit at 0.16–0.32. The caption points to SI sensitivity. The main-text reader can still misread exemplar height on a δ = 1 surface. One clause: “markers show (κ, ρ) position only; colour is the nominal-δ surface, not the KPI’s own *I*.”

## Figure 3 — η vs ΔML exemplars

Four exemplars + rucks foil; broken *x*-axis explained; zero line as the decision; colours match Figures 1–2. Does not plot the pooled *r* = 0.040 as a fitted surface.

[SIGNIFICANT] **Figure 3 caption ends on Fisher–Rao ψ.** That is companion material. Drop it.

[MINOR] No uncertainty intervals on the four ΔML points. Team-blocked CV variability is in SI; a short “SE in SI” would help.

## SI figures S1–S5

Printed order is theory surface → probit → empirical maps. Captions include generator script names (useful for reproducibility; slightly industrial for a journal SI). Self-contained enough for submission.

## Tables

| Table | Role | Note |
|-------|------|------|
| `tab:cross_domain` | Familiar methods → PEF regime | Fine in Theory; first to cut for 5k-word venues |
| `tab:scenarios` | Probit cells | Needed; SEs in footnote |
| `tab:exemplars` | Confirmatory four | The key table |
| `tab:validation` | Six-domain summary | Healthcare *n* = 1 study is easy to misread as *N* = 1 people |
| `tab:quadrants` | Practitioner map | Keep for all sports venues |
| `tab:boundary` | Illustrative limits | Cut first for JSAMS 6-item cap |

[SIGNIFICANT for JSAMS] 6 tables + 3 figures = 9 display items (cap 6). Move `tab:boundary`, `tab:cross_domain`, and one figure (probably Fig. 2, if Fig. 1 + Fig. 3 stay) to SI.

[MINOR] `tab:validation` “Efficiency” column is the landscape rate (η > 1), not ML success. The footnote says so; the header still invites misreading. Rename “% with η > 1”.

---

## Title

Current title is JQAS/IJPAS-native. It is wrong for CSF (no information / complex-systems hook) and slightly stats-light for Series C (application is in the title, which Series C wants). JSAMS titles in this area usually name a clinical or performance outcome more narrowly.

Matrix title variant 1 remains the better JQAS option if “relativised” is preferred to “absolute or relative.”
