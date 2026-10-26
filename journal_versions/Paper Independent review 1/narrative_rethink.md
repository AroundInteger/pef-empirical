# Narrative rethink — empirical PEF paper

Handoff note, 25 October 2026. Written so a fresh chat can continue without the previous transcript.

**Status.** Direction agreed in chat. The rewrite has **not** been started. Do not edit the manuscript until the user asks you to implement this note. Do not commit or push unless they ask.

**Canonical paper.** `/Users/rowanbrown/Documents/GitHub/pef-empirical`  
Edit `sections/` and `main.tex`. `journal_versions/JQAS/` is a packaging copy: sync it only after the canonical draft compiles. `arxiv/src/` is stale (old manufacturing prose and old figures) and was left out of the 25 October revision.

**Companion.** `/Users/rowanbrown/Documents/GitHub/pef-mathematics` owns geometry, \(\psi\), and the partition function. Do not edit its prose. Do not promote \(\psi\) into the empirical Results. Call \(\mathrm{Corr}(X_A, X)\) \(r_{AX}\). \(\psi\) is the companion Fisher–Rao coordinate.

---

## The problem

The title still asks a question the revised results do not answer:

> When Should Team KPIs Be Absolute or Relative for Match-Outcome Prediction?

The introduction (`sections/introduction.tex`, scope and contributions) still organises the paper around three questions:

1. Why does relativisation improve outcome prediction for some KPIs and harm it for others?
2. How can a relative feature with \(\eta<1\) still carry more information about the outcome?
3. Does the same \((\kappa,\rho)\) geometry appear outside invasion-game sport?

The conclusion (`sections/conclusion.tex`) contradicts itself. It opens by saying help and harm follow from \(\kappa\) and \(\rho\). It closes by saying the cell describes efficiency and which side is more variable, and does not by itself decide whether to relativise. Those two sentences cannot share a paper. The first is the sentence to delete.

The 25 October pre-submission review is `Review 1` in this folder. The revision that followed made the results honest and left the title’s promise in place. That is the remaining job.

---

## What the evidence can carry

The question the results support is: **does pairing efficiency tell you which feature to use?** The answer is no, for two separate reasons.

### Inside the probit model

The only generative model is the supplementary probit, assumptions (A1)–(A2):

- \(X \sim N(\delta, \mathrm{Var}(X))\) with component means \((\delta/2, -\delta/2)\), so \(\mathbb{E}[X]=\delta\).
- \(Y \mid X=x \sim \mathrm{Bernoulli}(\Phi(x/\sqrt{\mathrm{Var}(X)}))\).

Under that model the relative feature \(X = X_A - X_B\) is Bayes-sufficient for \(Y\). Predicted accuracy of the relative feature is therefore at least that of any rule based on \(X_A\) alone: \(\Delta\mathrm{ML} \ge 0\). The gain is a function of \((d_{\mathrm{rel}}, r_{AX})\), with a floor at zero. It is large when the absolute KPI does not already carry the difference (small \(r_{AX}\)).

\[
d_{\mathrm{rel}} = |\delta|/\sqrt{\mathrm{Var}(X)} = (|\delta|/\sigma_A)\sqrt{\eta/(1+\kappa)},
\quad
r_{AX} = (1 - \rho\sqrt{\kappa}) / \sqrt{1+\kappa - 2\sqrt{\kappa}\,\rho}.
\]

Exact \(I(X;Y)\) depends only on \(d_{\mathrm{rel}}\). It is largest near \(d_{\mathrm{rel}}=0\) (about \(0.279\) bits) and falls toward \(0\) as \(d_{\mathrm{rel}}\) grows, because \(Y\) becomes nearly certain. At fixed \(\delta/\sigma_A\), a larger \(\eta\) raises \(d_{\mathrm{rel}}\) and lowers exact \(I(X;Y)\). Efficiency is the wrong coordinate for the predictive decision.

The old expression \(1 - h(\Phi(d_{\mathrm{rel}}/2))\) is neither \(I(X;Y)\) nor the Jensen bound. Do not report it. The Jensen bound is \(I \ge h(\Phi(d_{\mathrm{rel}}/\sqrt{2})) - h(P_e)\), with \(P_e = 1 - \mathbb{E}[\Phi(|d_{\mathrm{rel}}+U|)]\), \(U\sim N(0,1)\). It is valid and loose (gap about \(0.09\) bits).

On the simulation grid, within a \(\delta/\sigma_A\) slice, \(\mathrm{corr}(\eta, I) \approx -0.87\). Pooled across slices it is about \(-0.22\). Pooling attenuates the correlation. It does not reverse it. The manuscript’s old \(r \approx -0.70\) was \(\mathrm{corr}(I_{\mathrm{old}}, \Delta\mathrm{ML}) = -0.7046\), mislabelled as a pooled \(\mathrm{corr}(\eta, I)\). Do not restore “strongly positively correlated, \(r \approx 0.87\)”.

Scenario values at \(\delta/\sigma_A = 1\) (exact \(I\)):

| Scenario | \(\kappa\) | \(\rho\) | \(\eta\) | \(I\) (bits) | ML gain |
|---|---:|---:|---:|---:|---:|
| High competitive | 2 | \(-0.3\) | 0.780 | 0.2644 | +9.4% |
| Moderate | 1.2 | \(-0.15\) | 0.870 | 0.2572 | +8.2% |
| Environmental | 1.1 | 0.4 | 1.665 | 0.2372 | +8.6% |
| Fisher | 1 | 0 | 1 | 0.2518 | +7.9% |

The Fisher baseline \(\eta=1\) still has about \(+7.9\%\) ML improvement inside the model. “All 16 Quadrant 4 cells with \(\eta<1\) gained” is a consistency check: every Quadrant 4 cell has \(\eta<1\).

### On the rugby and football KPIs

That model does not describe the sign of the empirical gain. Class separation is mostly about \(0.1\). Rugby accuracy sits on the home-win rate. Quadrant 3 point estimates fall on both sides of zero, and no fold interval lies entirely below zero.

Definitions that must stay distinct:

- Home–away gap \((\bar X_A - \bar X_B)/s_A\). This is **not** predictive signal. Do not plug it into \(I(X;Y)\).
- Class separation \(\hat d_Y = (\mathrm{mean}(X\mid Y=1) - \mathrm{mean}(X\mid Y=0))/\mathrm{SD}(X)\), with \(X = X_A - X_B\) and \(Y =\) home win versus not.
- \(r_{AX}\) is algebraic from \((\kappa, \rho)\).

Empirical associations (corrected finalize run):

| Association | Value |
|---|---:|
| \(\mathrm{corr}(\hat d_Y, \Delta\mathrm{ML})\) | 0.086 |
| \(\mathrm{corr}(\eta, \Delta\mathrm{ML})\) | 0.040 |
| \(\mathrm{corr}(\)home–away gap, \(\Delta\mathrm{ML})\) | \(-0.127\) |
| Median home–away \(\lvert\delta\rvert/\sigma_A\) | 0.292 |
| Median \(\lvert\hat d_Y\rvert\) | 0.129 |

`PEFcorrIpredML` is now \(0.086\) and means \(\mathrm{corr}(\hat d_Y, \Delta\mathrm{ML})\). It does not mean \(\mathrm{corr}(I_{\mathrm{pred}}, \Delta\mathrm{ML})\).

Outcome coding: home win versus not. Draws are coded 0. Home-win rates: rugby \(65.7\%\), football \(45.1\%\). In rugby the majority baseline equals the home-win rate, so accuracy-based \(\Delta\mathrm{ML}\) is nearly uninformative. Team-blocked CV partitions **home** teams only; away matches of a held-out club can remain in training. The fold \(t\) interval (\(k=5\), df \(=4\)) describes fold-to-fold variation. It is not a cluster-robust super-population interval.

Quadrant 3, full table (fold intervals, not the pooled accuracy column): \(n=55\), \(25\) negative point estimates, \(0\) intervals entirely below zero, \(2\) entirely above. Mean pooled accuracy improvement in Quadrant 3 is about \(+0.4\%\). Empirical harm is not established. The probit model cannot produce \(\Delta\mathrm{ML}<0\).

Pre-specified exemplars (do not hand-pick different KPIs). Rule: within each quadrant, \(\lvert\log\kappa\rvert > \log 1.05\), then the KPI whose \(\lvert\hat d_Y\rvert\) is closest to the eligible-set median. That median is about \(0.12\), so a null \(\Delta\mathrm{ML}\) is built into the design. The four checks are a check, not a confirmation.

| Cell | Sport | KPI | \(\kappa\) | \(\rho\) | \(\eta\) | \(\hat d_Y\) | Fold-mean \(\Delta\mathrm{ML}\) | Interval |
|---|---|---|---:|---:|---:|---:|---:|---|
| Q1 | rugby | lineout throws lost | 1.247 | +0.026 | 1.027 | \(-0.143\) | 0 | \([0, 0]\) (every fold matched the majority rate) |
| Q2 | rugby | rucks won | 0.820 | +0.818 | 5.382 | \(-0.148\) | \(-1.58\%\) | \([-4.31, +1.16]\) |
| Q3 | football | corners | 0.747 | \(-0.279\) | 0.784 | \(-0.121\) | \(+0.10\%\) | \([-5.55, +5.76]\) |
| Q4 | football | fouls | 1.157 | \(-0.047\) | 0.955 | \(-0.121\) | \(-1.75\%\) | \([-6.54, +3.04]\) |

None of the four intervals excludes zero. Rucks won is the Quadrant 2 exemplar. It is not a separate high-\(\eta\) foil.

Sports landscape: rugby and football occupy all four cells and concentrate in Quadrant 3. Do not write “sports = Quadrant 4”.

---

## The narrative to implement

Stop offering a feature-choice rule. The paper’s sentence is that the usual efficiency rule is not a prediction rule.

1. **Title.** Drop “when should”. A plain replacement: pairing efficiency does not decide whether a team KPI should be relativised. Wording can be tightened, but the promise has to match the result. Do not invent a threshold on \(\hat d_Y\) or \(r_{AX}\) from the sports cloud. Figure S5 does not support one.

2. **Three organising questions**, replacing the three in the introduction and the conclusion:
   - What does \(\eta\) measure? (distribution-free efficiency of the difference relative to unpaired measurement, and which side is more variable)
   - Why does that measure diverge from \(I(X;Y)\) and from \(\Delta\mathrm{ML}\) under the probit model? (exact integral in \(d_{\mathrm{rel}}\); gain surface in \((d_{\mathrm{rel}}, r_{AX})\) with a floor at zero)
   - Do the sports KPIs, or the three supporting domains, show \(\eta\) tracking predictive gain? (they do not, where an outcome exists at all)

3. **How to use the model result.** The gain surface stays as the model’s account of when a gain can occur. It is a result inside the probit model, with a floor at zero. It is not a recommendation for these leagues. A negative empirical point estimate is outside the model and, on these KPIs, consistent with fold noise.

4. **How to use the exemplars.** Keep the pre-specified table as a check that typical KPIs sit where any gain is undetectable. Do not describe them as confirming both signs, or as showing that absolute features are preferred in Quadrant 3.

5. **Supporting domains.** Healthcare, genomics, and finance stay only as evidence that the same second-moment geometry appears elsewhere. They have no match outcome, so they cannot answer the old title. Manufacturing was dropped (the file was Puma 560 / DELVE robot-arm dynamics, not Bosch CNC). Do not put it back. Do not substitute NASA C-MAPSS or another simulation.

6. **Practical guidance.** Estimate \(\kappa\), \(\rho\), and \(\eta\). Read the cell as efficiency and asymmetry. Compare absolute, difference, and the pair \((X_A, X_B)\) directly, and report an interval. The cell does not make that comparison for you.

### Claims that must not come back

- Quadrants labelled high / moderate / low information.
- “Help and harm follow from \(\kappa\) and \(\rho\).”
- “Confirm both signs of \(\Delta\mathrm{ML}\).”
- “Absolute features are preferred in Quadrant 3.”
- “Strongly positively correlated, \(r \approx 0.87\)” for \(\eta\) and \(I\).
- The old closed form reported as \(I(X;Y)\) or as the Jensen bound.
- A relative feature with \(\eta<1\) “still informs” as an empirical sports finding. Inside the model, state it only through \(I(d_{\mathrm{rel}})\) and the gain surface.
- Manufacturing, or a replacement simulated domain.
- \(\psi\), Figure 3b, or the residual slope of about \(-16.7\) as a result of this paper. That slope is one outlier near \(\psi \approx 3\).
- “Sports are mostly Quadrant 4.”
- Genomics “97% with \(\eta>1\)” as a random-gene rate. Genes were ranked by paired-differential signal, which preferentially selects high \(\rho\).

### Labelling conventions that must stay

- Sport: \(A =\) home, \(B =\) away, so \(\kappa = \mathrm{Var}(\mathrm{away})/\mathrm{Var}(\mathrm{home})\).
- Finance: \(A =\) S&P 500 index, \(B =\) constituent, so \(\kappa = \mathrm{Var}(\mathrm{stock})/\mathrm{Var}(\mathrm{market})\). Most names have \(\kappa>1\) and \(\rho>0\), so the typical cell is Quadrant 1. Swapping labels sends them to Quadrant 2 without changing \(\eta\). Do not move finance to Quadrant 2 by hand.
- \(\eta>1\) if and only if \(\rho>0\), for any admissible \(\kappa\). State this as a consequence of the formula, not as an empirical finding.
- Label swap \(\kappa \to 1/\kappa\) flips Q1\(\leftrightarrow\)Q2 and Q3\(\leftrightarrow\)Q4. \(\eta\) is invariant.

---

## Figures

Recommended in the same conversation. Not yet deleted. Cut them in the same pass as the narrative if the user asks you to implement this note.

**Keep**

- One empirical map: the full \((\rho, \kappa)\) cloud. That is `figures/Figure_S4_labelled_kpis.png`. Promote it if Figure 1 is only four KPIs standing in for the cloud. Do not keep both as main-text twins.
- One theory figure: the gain surface of \(d_{\mathrm{rel}}\) and \(r_{AX}\) (Figure S1, panel C; floor at zero). S2 panels B and C can stay if a cut of the surface is needed (\(\eta\) blows up as \(\rho\to 1\); \(I\) falls).
- One negative empirical figure: \(\hat d_Y\) against \(\Delta\mathrm{ML}\) (Figure S5). Retitle it. The filename still says `Ipred`. The association is \(r \approx 0.09\).
- The four exemplars as a table only.

**Drop**

- Figure 2. It is Figure 1 recoloured by the simulation surface at nominal \(\delta/\sigma_A = 1\). The markers are not each KPI’s empirical \(I\). Domain triangles have no outcome and do not belong on an information surface.
- Figure 3. Four points whose intervals include zero. It implies a slope the data do not have.
- Figure 3b. Companion \(\psi\) residual. One outlier. Not this paper.
- Figure S3. The same surface at three \(\delta\) values, with a colour scale running toward 1 bit while \(I\) never exceeds about \(0.28\), so the sensitivity is invisible.
- Figure S2, panel A. The same plane again, almost uniform at \(\lvert\hat d_Y\rvert \approx 0.13\).
- Figure S1, panel A, if it is only the design plot.

**Known labelling slip.** The PNG note inside Figure S2 still says \(\delta/\sigma_A = 0.13\). The slice that was passed is the median \(\lvert\hat d_Y\rvert\). The caption in `sections/supplementary.tex` is the correct wording. Fix the in-figure note if the figure is regenerated.

---

## Where the text lives

| Role | Path |
|---|---|
| Title | `main.tex` (line with `\title`) |
| Questions and contributions | `sections/introduction.tex` |
| Probit, integral, Jensen bound, \(r_{AX}\), \(d_Y\) | `sections/theoretical_framework.tex` |
| Exemplar rule, outcome coding, CV wording | `sections/methodology.tex` |
| Scenario table, correlations, exemplar table, domains | `sections/results.tex` |
| Practical guidance | `sections/discussion.tex` |
| The contradictory close | `sections/conclusion.tex` |
| Table 1 and figure captions | `sections/tables_and_figures.tex` |
| SI | `sections/supplementary.tex` |
| Generated macros | `scripts/paper_pipeline/outputs/numbers.tex` |
| Exemplar selection | `scripts/paper_pipeline/select_confirmatory_exemplars.m` and `outputs/confirmatory_exemplars.csv` |
| Per-KPI export | `outputs/referee_kpi_summary.csv` (86 rows) |
| JQAS copy | `journal_versions/JQAS/` — recopy after a clean canonical compile |
| Review that forced the revision | this folder, `Review 1` |

`numbers.tex` is generated. Macro names are letter-only. Do not hand-edit values. `PEFcorrIpredML` already means \(\mathrm{corr}(\hat d_Y, \Delta\mathrm{ML})\). Do not cite `\PEFmfgMeanEta` or any manufacturing macro.

Pipeline, only in this repo:

```bash
cd scripts/paper_pipeline
/Applications/MATLAB_R2025b.app/bin/matlab -batch "run('run_paper_pipeline.m')"
```

MATLAB is not on `PATH`. Executable: `/Applications/MATLAB_R2025b.app/bin/matlab` (R2025b). A narrative-only rewrite of the prose does not require a pipeline rerun. Regenerating a figure does.

Compile note from the revision: Homebrew biber 2.22 is incompatible with tectonic’s biblatex 3.17. The compile that worked prepended biber 2.17 at `/tmp/texbin/biber`:

```bash
PATH="/tmp/texbin:/opt/homebrew/bin:/usr/bin:/bin" tectonic -X compile --keep-logs main.tex
```

After any prose change, sync the touched `sections/*.tex` into `journal_versions/JQAS/sections/` and, if `numbers.tex` changed, copy `scripts/paper_pipeline/outputs/numbers.tex` to `journal_versions/JQAS/numbers.tex`. JQAS loads its local `numbers.tex`.

If pipeline outputs that feed companion §7 change (`kappa_symmetry_*.csv`, `psi_*.csv`, `pef_landscape_2season_geometry.csv`), refresh `pef-mathematics/validation_inputs/`. `domain_summary.csv` and `table_numbers.csv` in that folder were not refreshed on 25 October and are stale relative to the empirical outputs. Companion prose was not edited.

---

## Revision already in the draft (do not redo or undo)

Completed 25 October 2026 against `Review 1`. Canonical `sections/` and the MATLAB pipeline. Nothing committed.

- One generative model. Exact \(I(X;Y)\) by quadrature. Old closed form kept in code for comparison only.
- \(\mathrm{corr}(\eta, I)\) reported by \(\delta/\sigma_A\) slice (about \(-0.87\)) and pooled (about \(-0.22\)).
- Class separation \(\hat d_Y\) and \(r_{AX}\) added. Exemplars selected by the pre-specified rule above and wired through macros.
- Manufacturing removed from code, tables, figures, bibliography, and prose. Genomics ranking bias and the finance \(A/B\) convention are stated.
- Fold \(t\) intervals, AUC, Brier, majority baseline, and the \((X_A, X_B)\) comparator are in the ML export. Bootstrap \(B=1000\). Football bootstrap no longer filtered on the string `23/24` (that filter zeroed every football row). Fouls \(\eta\) interval \([0.897, 1.027]\) includes 1. Tackles \([0.773, 0.946]\) lies entirely below 1. Those two intervals are written in `sections/supplementary.tex` from `finalize_bootstrap_pef.csv` (seed `rng(20260521)`).
- Normality headline is the Shapiro–Wilk rejection rate on two-season paired differences: rugby \(11/22 = 50\%\), football \(40/64 = 62.5\%\). Mean \(W\) is secondary. The PEF formula does not require the rejection rate to be zero.
- Healthcare interval is pipelined: \(\hat\eta = 2.533\), CI \(2.448\)–\(2.622\), SE \(0.04\). Table 1’s SD for that row is this SE.
- SI sections use the `sisection` counter, defined in the preamble of `main.tex` (and both JQAS mains), because `\crefname` must exist before main-text `\cref` calls.
- Author-statement blanks in `sections/data_availability.tex` are for the authors to fill. Do not invent funding, ethics references, or co-author roles.

---

## Style

British English. LaTeX mathematics. No em-dash asides. Modest claims. State the intended sentence directly. Rugby and football are Quadrant-3-heavy. Do not oversell \(\eta \to \mathrm{ML}\).
