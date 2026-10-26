# White paper — empirical PEF

Test for the rewrite. A paragraph that fails a habit below does not go in the manuscript.

**Standing sentence.** Pairing efficiency does not decide whether a team KPI should be relativised for match-outcome prediction.

That sentence is false if, on these rugby and football KPIs, \(\hat\eta\) sorts \(\Delta\mathrm{ML}\) once fold intervals are included. The deciding table is the full cloud of \(\hat\eta\) against \(\Delta\mathrm{ML}\), and of \(\hat d_Y\) against \(\Delta\mathrm{ML}\), with intervals. Present numbers: \(\mathrm{corr}(\hat\eta,\Delta\mathrm{ML})=\PEFcorrEtaML\) (0.040) and \(\mathrm{corr}(\hat d_Y,\Delta\mathrm{ML})=\PEFcorrIpredML\) (0.086). The four pre-specified exemplar intervals cover zero.

**Working title.** Pairing Efficiency Does Not Decide Whether a Team KPI Should Be Relativised.

## Three questions

1. What does \(\eta\) measure? The variance of the paired difference relative to unpaired measurement, and which side is more variable. \(\eta>1\) if and only if \(\rho>0\). The \(\kappa=1\) split flips if A and B are swapped.
2. Why does that diverge from \(I(X;Y)\) and from \(\Delta\mathrm{ML}\) under the probit model? \(I(X;Y)\) is the integral in \(d_{\mathrm{rel}}\). At fixed \(\delta/\sigma_A\), larger \(\eta\) raises \(d_{\mathrm{rel}}\) and lowers \(I\). Inside the model \(\Delta\mathrm{ML}\ge 0\), and the gain is \((d_{\mathrm{rel}}, r_{AX})\), including a gain at \(\eta=1\).
3. Do these KPIs show \(\eta\) tracking predictive gain? They do not. Healthcare, genomics, and finance show the same \((\kappa,\rho)\) geometry and have no match outcome.

## Figures that earn a sentence

- Full \((\rho,\kappa)\) cloud in the main text (the file `figures/Figure_S4_labelled_kpis.png`). Rugby and football occupy all four cells and concentrate in Quadrant 3.
- Gain surface in the supplement (Figure S1, the panel of \(\Delta\mathrm{ML}\) against \(d_{\mathrm{rel}}\) and \(r_{AX}\), floor at zero). The \((\rho,\tau)\) design locator is omitted.
- Class separation against \(\Delta\mathrm{ML}\) (Figure S5 file, caption retitled). On these KPIs, class separation does not line up with the accuracy change.
- Cuts of \(\eta\) and \(I\) at \(\kappa=1\) and \(\rho=0\) (Figure S2, panels of the two cuts only). The slice is the median \(|\hat d_Y|\), not \(\delta/\sigma_A\).

Dropped from the manuscript, generators left on disk: Figure 2, Figure 3, Figure S3, Figure S2 panel A, Figure S1 panel A. Figure 3b stays out of the TeX. Exemplars stay as a table.

## Ten habits

1. **Falsifiable sentence before the title.** The title is the standing sentence. The results point at the two correlations and the fold intervals.
2. **One comparison, one symbol, one paragraph.** \(\eta\), \(I(X;Y)\), and \(\Delta\mathrm{ML}\) do not share a verb. The home–away gap and \(\hat d_Y\) do not share the name signal. \(r_{AX}\) is not \(\psi\).
3. **Two-point check.** No sentence of the form “larger \(\eta\) means more information” or “\(\eta<1\) still helps prediction” unless it has been evaluated at two \((\kappa,\rho)\) points. At fixed \(\delta/\sigma_A\), larger \(\eta\) lowers exact \(I\). The Fisher row may show a gain at \(\eta=1\).
4. **A model may evidence only what it can produce.** The probit grid is cited for \(\Delta\mathrm{ML}\ge 0\) and for the gain surface. It is not cited as confirmation of empirical help or harm. The 16 Quadrant 4 cells are one consistency check.
5. **The file’s shape is the citation.** Manufacturing is absent. Genomics states that ranking by paired-differential signal prefers high \(\rho\). Finance states A = index, B = constituent. Do not invite engineering telemetry back.
6. **The interval is in the same sentence as the sign.** No helps, harms, near zero, or preference unless the fold interval is in that sentence, or the sentence says the interval covers both actions. Quadrant 3: 25 of 55 negative point estimates, 0 intervals entirely below zero, 2 entirely above.
7. **Illustration versus estimation.** The four names stay lineout throws lost, rucks won, corners, and fouls. They illustrate the median \(|\hat d_Y|\). The estimate is the cloud.
8. **Trace a correlation before narrating it.** Within-slice \(\mathrm{corr}(\eta,I)\approx -0.87\), pooled \(\approx -0.22\). Pooling attenuates and does not reverse. The old \(r\approx -0.70\) appears only as the discarded mislabelling. A positive \(r\approx 0.87\) for \(\eta\) and \(I\) does not appear.
9. **The empirical paper reports the association.** No \(\psi\), no Figure 3b, no residual slope. Where \(\eta\) and \(\Delta\mathrm{ML}\) disagree, report \(r=0.040\).
10. **The PDF is the paper.** After compile, the log has no undefined references, and the PDF does not contain: “when should”, “helps and harms”, “prefer absolute”, “directional agreement”, “conservative”, “equal priors”, manufacturing, Bosch. SI cross-references resolve as SI sections. `numbers.tex` is pipeline output.

## Frozen on purpose

No new data, no new simulation, no new exemplar rule, no hand-edit of `numbers.tex`, no companion prose, no `arxiv/src/` sync, no commit unless asked.
