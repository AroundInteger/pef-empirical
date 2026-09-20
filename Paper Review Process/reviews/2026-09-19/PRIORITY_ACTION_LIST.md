PRIORITY ACTION LIST — Empirical PEF — V1 first-pass 2026-09-19

Venue tags: JQAS · EJSS · JSAMS · IJPAS · CSF · C (Series C) · AoAS  
“Blocks” means the item will stop a clean submission to that venue as the manuscript now stands.

🔴 CRITICAL (must resolve before submission)

  C1. Choose a venue and stop treating EJSS and JSAMS as interchangeable. JSAMS 2026 scope is clinical / medicine / exercise science. Submitting the current file there is a predicted desk reject. — why it is critical: wasted review cycle and a paper sitting under consideration. — resolution: submit-first JQAS; EJSS only after a 5k-word rewrite; IJPAS as specialist fallback; CSF only as a new opening; do not send to JSAMS without written editor clearance. — blocks: JSAMS (now); EJSS/IJPAS/CSF if you upload this file unchanged

  ✅ C2. Healthcare Results printed N = 1 participant (`\PEFhealthN`). — resolved 2026-09-19: Results now uses N = 10,352; Table 1 footnote states `\PEFhealthN` is one study, not a participant count.

  C3. JSAMS / EJSS / IJPAS word and packaging caps. Body ~8,025 words; abstract 337; 9 display items; 47 cites. — why it is critical: hard desk filters. — resolution: do not upload this file to those journals. Cut and restructure first (see venue reports). — blocks: EJSS, JSAMS, IJPAS (CSF abstract/Highlights only)

🟠 SIGNIFICANT (strongly recommended before submission)

  S1. Abstract 337 words; no keywords. — why it matters: JQAS ~200 + 3–6 keywords; others ≤250. — resolution: cut using the five-part skeleton; add venue-legal keywords. — blocks: JQAS, EJSS, JSAMS, CSF, C; IJPAS pending official abstract rule

  S2. JQAS (and EJSS/JSAMS) blind package is not built. Named author on `main.tex`; numeric Vancouver; figures embedded. — why it matters: technical check and review policy. — resolution: anonymised PDF + LaTeX; separate title page; author-date for JQAS; separate figure files. — blocks: JQAS, EJSS, JSAMS

  🔄 S3. Author names: Brown, Kilduff, Scott (Bennett removed 2026-09-19). D4 sign-off on order and affiliations still open. — blocks: none for listing names; still blocks a signed submission

  ✅ S4. Methods Statistical Rigour / QC promised unreported tests. — resolved 2026-09-19: section now reports team-cluster bootstrap, ΔML, δ/σ_A, and Shapiro–Wilk only.

  ✅ S5. Football Methods listed cards. — resolved 2026-09-19: illustrative list is now duels, pressures, interceptions, fouls, and shot volume.

  S6. Finance Methods vs Results disagree (asset classes vs S&P 100 / S&P 500 2020–2023, n = 18). — why it matters: cannot replicate the supporting tier. — resolution: put the Results specification in Methods. — blocks: all venues

  S7. Q4 practitioner recipe outruns the confirmatory row (ΔML = −0.3%). — why it matters: JQAS-style scepticism; CSF overclaim. — resolution: Q4 = estimate δ/σ_A and check with CV; tension lives on the grid and landscape. — blocks: JQAS, CSF; weakens EJSS/IJPAS

  S8. Companion ψ / sphere / partition function named in Methods, Results, and Fig. 3 caption. — why it matters: split-publication creep. — resolution: one “in prep.” sentence; strip from Results and Fig. 3. — blocks: JQAS, IJPAS (CSF can keep a short surface paragraph)

  S9. Pipeline, MATLAB R2025b, seed, and `run_paper_pipeline.m` are not in the manuscript. — why it matters: PEF reproducibility checklist. — resolution: one paragraph in Data/code availability. — blocks: C, AoAS (policy); significant for JQAS

  S10. Sports data cannot be redistributed. — why it matters: Series C / AoAS require share-or-explain. — resolution: name the agreement; list what is public (`pef-tools`, supporting-domain files, estimators); state the request route. — blocks: C, AoAS

  S11. Cross-domain “same pairing structure” overclaims manufacturing / genomics estimands. — why it matters: generalisability. — resolution: geometry checks, not ML replications. — blocks: CSF if oversold; significant everywhere

  S12. Missing venue-native citations. JQAS: recent win-probability / feature-construction papers. CSF: Buldú 2021 issue, Petersen & Penner, Li or Medina. — why it matters: novelty and scope signal. — blocks: JQAS (moderate), CSF (desk-reject risk)

  S13. CSF Highlights file and information-first title/abstract do not exist. — why it matters: required packaging + scope gate. — resolution: only if CSF is chosen; this is a new paper opening. — blocks: CSF

  S14. Supporting-domain η is not ML; abstract says the pairing “recurs” in four domains. — why it matters: overclaim in the most-read paragraph. — resolution: “the same (κ, ρ) geometry”. — blocks: all venues (soft)

🟡 POLISH (improves quality, does not block submission)

  P1. Move Shapiro–Wilk W = 0.98 and κ/ρ ranges out of the Introduction. — resolution: Methods/SI. — venues: all

  P2. Rename Table 1 “Efficiency” to “% with η > 1”. — venues: all

  P3. Figure 2: say markers are (κ, ρ) positions on a δ/σ_A = 1 surface. — venues: all

  P4. State why the absolute baseline is X_A only, not (X_A, X_B). — venues: JQAS, C, AoAS

  P5. Double space after “Thus, η” in `introduction.tex`. — venues: all

  P6. Confirm `pef-tools` URL and README before the data statement is frozen. — venues: all

  P7. Re-fetch Wiley EJSS guidelines and T&F IJPAS instructions (Cloudflare / timeout this pass). — venues: EJSS, IJPAS

  P8. Refresh `TARGET_JOURNAL_MATRIX.md` exemplar ΔMLs and the 86-KPI count so planning docs match `numbers.tex`. — venues: planning only

  P9. Colour-blind check on Q1 green / Q4 red tags; marker shape already helps. — venues: all

✅ STRENGTHS (do not change these)

  + The research question is specific and new relative to Scott/Bennett: a regime in which relativisation is predictively harmful, not only unhelpful.
  + Landscape vs mechanistic confirmation is consistently signposted; the inventory is correctly Q3-heavy (55/86).
  + Global η–ML mapping is retired (r = 0.040); `eq:dml_poly` is absent from the main text.
  + Q4 exemplar is honestly near-zero; rucks won (η = 5.38, ΔML = −1.6%) is the right high-η / no-signal foil.
  + Team-blocked CV and cluster bootstrap match league dependence; the paper does not pretend matches are i.i.d.
  + Distribution-free η and Gaussian (A1)–(A2) I(X;Y) are kept distinct.
  + Title is already application-led (helps JQAS, IJPAS, and a Series C backup).
