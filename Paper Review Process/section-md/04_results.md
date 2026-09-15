# Results

> **Review copy** from LaTeX. Source of truth: `sections/results.tex`.
> Propose edits in chat (or annotate this file); agreed changes go into the `.tex`.
> Math rendering is approximate.

---

# Results

## Theoretical Foundation: PEF--Information Content

The theoretical relationship between $\eta$ and information content ((eq:mi_closed)) was examined in four named scenarios from the theory-aligned idealised probit simulation ((fig:si_idealised_stratified); Supplementary (sec:si_note_s2)) under assumptions (A1)--(A2), with $n=5,000$ per cell, 50 Monte Carlo trials, and five-fold logistic cross-validation matching the empirical protocol. The simulation's data-generating process, estimands, and parameter-recovery checks are specified in full in Supplementary (sec:si_note_s2).

| table[t]

  lccccc@

    **Scenario** | $\kappa$ | $\rho$ | $\eta$ | $I(X;Y)$ (bits) | ML impr.$^\dagger$ |
| --- | --- | --- | --- | --- | --- |
| High competitive dynamics | 2.0 | $-0.3$ | 0.780 | 0.029 | 9.4\% |
| Moderate competitive dynamics | 1.2 | $-0.15$ | 0.870 | 0.044 | 8.2\% |
| Environmental dynamics | 1.1 | 0.4 | 1.665 | 0.087 | 8.6\% |
| Balanced (Fisher baseline) | 1.0 | 0.0 | 1.000 | 0.056 | 7.9\% |
|
  minipage0.95
    $^\dagger$Mean five-fold cross-validated accuracy improvement (relative minus absolute features) across 50 Monte Carlo trials per scenario cell ($\delta/\sigma_A=1$). Standard errors are $≈$0.8--1.0 percentage points (Supplementary (sec:si_note_s2)).
  minipage |

*Scenario-level confirmation from the idealised probit simulation (A1)--(A2).*

On the admissible $(\kappa,\rho)$ grid at fixed $\delta/\sigma_A=1$, analytic $\eta$ and $I(X;Y)$ from (eq:mi_closed) are strongly correlated ($r≈ 0.87$ across 16 grid cells in the idealised simulation). The four scenarios in (tab:scenarios) span the quadrant space under controlled (A1)--(A2) conditions; the first two illustrate the efficiency--power tension ($\eta<1$ with positive mean ML improvement), consistent with (sec:eff_power_theory).

## Sports KPI Landscape

The full sports inventory spans all four quadrants ((fig:pef_landscape); $113$ KPI studies, (sec:outcome_defs)). Rugby union (URC) contributes $24$ KPIs and football (English Championship) $89$; per-KPI $(\hat\kappa,\hat\rho,\hat\eta)$ estimates and season-to-season drift appear in Supplementary (fig:si_kpi_labelled,fig:si_ipred_vs_dml). Domain-level landscape summaries are collected in (tab:validation): rugby mean $\hat\eta=1.313$ (95\% CI: $[0.915,1.712]$; $54.2\%$ of KPIs with $\hat\eta>1$), football mean $\hat\eta=0.884$ (95\% CI: $[0.846,0.922]$; $16.9\%$ with $\hat\eta>1$). These figures characterise the empirical $(\kappa,\rho)$ distribution, notably the Q3-heavy structure of invasion-game KPIs ($77$ of $113$ studies; $68.1\%$). They do not serve as the primary confirmatory test.

KPIs with positive correlation (e.g., kicks from hand, carries) concentrate in Quadrants 1--2 and typically yield $\hat\eta>1$; KPIs with negative or near-zero correlation (e.g., turnovers won, penalties conceded) fall predominantly in Quadrants 3--4 with $\hat\eta\le 1$, yet several still show positive ML improvement in the full scatter ((fig:pef_ml)), consistent with the efficiency--power tension ((sec:eff_power_theory)). Mechanistic confirmation of the taxonomy's directional predictions is assessed through the four quadrant exemplars below ((sec:exemplars)), not through pooled success rates over the Q3-dominated inventory.

## Efficiency--Power Alignment Across Quadrants

The four quadrants differ not only in mean $\eta$ but in the relationship between efficiency and predictive gain. Three supplementary analyses characterise this structure.

**Idealised simulation under (A1)--(A2).** On the theory-aligned probit grid (Supplementary (fig:si_idealised_stratified); $n=5,000$, 50 trials, five-fold CV), all 16 out of 16 Quadrant 4 cells with $\eta<1$ produced positive mean ML improvement. At fixed $\delta/\sigma_A$, $\eta$ and $I(X;Y)$ are strongly correlated (within-slice $r≈0.87$ at the empirical median $\delta/\sigma_A=0.2837$). However, the pooled-across-$\delta/\sigma_A$ correlation is negative ($r=-0.70$), because signal strength shifts the $I(X;Y)$ level independently of the $(\kappa,\rho)$ position. The practical consequence is that iso-$\eta$ and iso-$I(X;Y)$ contours diverge once $\delta/\sigma_A$ varies across KPIs (Supplementary (fig:si_iso_eta_I)).

**Quadrant distribution.** Of the 113 sports KPI studies, $77$ ($68.1\%$) lie in Q3: the negative-correlation regime where competitive dynamics dominate and absolute features are typically preferred. This reflects a structural feature of professional invasion-game sport: high-volume counts (passes, pressures, duels) are anti-correlated across opponents. Because the dataset is Q3-heavy, any aggregate statistic pooled across all KPIs primarily characterises this dominant regime rather than the mechanism across the full quadrant space (Supplementary (tab:si_quad_landscape)). The exemplar approach ((tab:exemplars)) directly addresses this by selecting one KPI per quadrant, allowing the taxonomy's directional predictions to be assessed without the distributional confound.

**Quadrant 4 and the Bayes bound.** Team-stratified bootstrap intervals on the confirmatory exemplars show that $\eta<1$ is estimated with low uncertainty for the Quadrant 4 KPI (Supplementary (fig:si_bootstrap_exemplars)). Under (A1)--(A2) with equal priors, the Gaussian Bayes accuracy of the absolute feature is the theoretical comparator. For the Q4 confirmatory KPI, team-blocked CV accuracies for absolute and relative features are close to each other and sit below that bound (Supplementary (fig:si_q4_bayes_gap)). The gap is expected: real match outcomes are not generated from a single KPI by the probit link (A2). Relativisation does not lift accuracy here, matching the Q4 row of (tab:exemplars). This is the limited-signal Quadrant 4 case, not the efficiency--power tension. Relative gain despite $\eta<1$ appears in the simulation grid and in parts of the landscape ((fig:si_idealised_stratified,fig:pef_ml)). Statistical efficiency and information content remain related but distinct: the value of relativisation cannot be read from $\eta$ alone ((sec:eff_power_theory)).

## Quadrant Exemplars and Signal-Strength Context

(fig:pef_ml) places the full KPI inventory ($N=113$) in landscape context: an $\hat\eta$--$\DeltaML$ scatter with four annotated exemplars, one per quadrant, selected to test directional predictions when signal strength is held approximately constant ((tab:exemplars)).

Each $\DeltaML$ in (tab:exemplars) comes from *univariate* logistic regression (one KPI feature per model: $X_A$ or $X_A-X_B$). Percentage gains are therefore modest in absolute terms yet substantively informative. The confirmatory question is *directional*: does relativisation help or hurt for this KPI at comparable $\delta/\sigma_A$? It is not construction of an optimal multi-feature match predictor. Prior rugby and football work that motivates this study combined many KPIs in a single classifier, where per-feature gains can compound, cancel, or interact ((sec:discussion)); the present single-KPI design is conservative by construction. Team-blocked cross-validation ((sec:ml_cv)) further avoids the optimistic bias of random match folds when the same side recurs across fixtures, and reduces leakage of a team's early and late home matches across train and test partitions; season-blocked validation is noted as a further tightening step in (sec:discussion).

The four confirmatory KPIs occupy distinct regions of the $(\kappa,\rho)$ plane ((fig:pef_landscape,tab:exemplars)) at comparable signal strength; they are not interchangeable summaries of their quadrants. Because $\eta$ and $I(X;Y)$ respond nonlinearly to $(\kappa,\rho)$ and to $\delta/\sigma_A$ ((eq:mi_closed)), each exemplar illustrates *local* regime behaviour. The companion mathematics paper develops the underlying geometry (canonical $\eta(\tau,\rho)$, partition-function structure, $\psi$-scale stabilisation) [brownPEFmath]. Interpreting a quadrant label as a uniform prescription would therefore overstate what the taxonomy claims.

| table[t]

  llccccc@

    **Q** | **KPI (sport)** | $\kappa$ | $\rho$ | $\eta$ | $\delta/\sigma_A$ | $\DeltaML$ (\%) |
| --- | --- | --- | --- | --- | --- | --- |
| Q1 | Kick metres (rugby) | 1.06 | $+0.65$ | 2.84 | 0.19 | $+4.3$ |
| Q2 | Long balls (football) | 0.91 | $+0.23$ | 1.30 | 0.16 | $+5.5$ |
| Q3 | Passes (football) | 0.84 | $-0.65$ | 0.61 | 0.32 | $-0.8$ |
| Q4 | Goalkeeper long balls (football) | 1.00 | $-0.24$ | 0.81 | 0.26 | $-0.3$ |
|
  minipage0.95
    Two-season pooled estimates ($\kappa$, $\rho$, $\eta$, $\delta/\sigma_A$) and team-blocked five-fold cross-validated logistic improvement ($\DeltaML$, relative minus absolute features; (sec:ml_cv)). Signal strengths ($\delta/\sigma_A≈0.16$--$0.32$) are broadly comparable across exemplars. The table tests direction at matched signal: Q1 and Q2, positive gain with $\eta>1$; Q3, negative gain with $\eta<1$; Q4, $\eta<1$ with near-zero $\DeltaML$. Relative gain despite $\eta<1$ is shown in the idealised grid and the full landscape ((sec:eff_power,fig:pef_ml)), not by a large Q4 exemplar gain.
  minipage |

*Quadrant exemplars: four KPIs spanning the $(\kappa,\rho)$ parameter space.*

The Q4 exemplar (goalkeeper long balls, $\eta=0.81$) has $\DeltaML=-0.3\%$ at team-blocked cross-validation. The gain is near zero at this $\delta/\sigma_A$, as expected when pairing inflates variance and signal is limited. This row is not a demonstration of relative benefit despite $\eta<1$. Cases with $\eta<1$ and $\DeltaML>0$ appear in the full inventory ((fig:pef_ml,sec:eff_power)). Here $\kappa≈1.00$, so $\eta<1$ is driven by negative correlation ($\rho=-0.24$) rather than variance asymmetry. The KPI therefore sits on the boundary between Quadrants 3 and 4. The Q3 exemplar (passes, football; $\rho=-0.65$, $\eta=0.61$) shows the complementary case. Strong negative correlation places this KPI deep in the low-efficiency regime, and $\DeltaML=-0.8\%$ confirms that absolute features are preferred. Rucks won (rugby; Q2: $\kappa=0.82$, $\rho=+0.82$, $\eta=5.38$, $\delta/\sigma_A=0.07$) is a useful boundary illustration. Despite the highest $\eta$ in the dataset, $\DeltaML=-1.6\%$ because the two teams are almost equally matched on average (negligible $\delta/\sigma_A$). Even very high pairing efficiency confers no ML gain without sufficient signal strength.

## Supporting Validation: Cross-Domain Results

Having established the mechanism through the idealised simulation and single-KPI exemplars, we assess whether the same $(\kappa,\rho)$ structure recurs beyond sport. (tab:validation) summarises results across all six domains. The supporting domains illustrate how empirical $(\kappa,\rho)$ structures propagate into $\hat\eta$ and landscape efficiency rates (proportion with $\hat\eta>1$; (sec:outcome_defs)):

- **Healthcare** [nhanes2017pbxo]: pooled $\eta=2.533$ (bootstrap 95\% CI: $[2.448,2.622]$) across $N=1$ NHANES participants pairing systolic and diastolic blood pressure from the same oscillometric measurement (Quadrant 2). Pulse pressure ($SBP-DBP$) is the clinically established relative feature.

- **Clinical genomics** [brunner2014earlybreast,geoGSE47462]: mean $\eta=2.696$ (SD $=1.601$) across $3500$ genes ranked by paired-differential signal in GSE47462; $97.0\%$ of genes yielded $\eta>1$.

- **Finance**: mean $\eta=3.129$ (SD $=1.108$) across $18$ S\&P 100 stocks relativised to daily S\&P 500 returns (2020--2023 pinned snapshot); $100.0\%$ with $\hat\eta>1$.

- **Manufacturing** [openml752bosch]: mean $\eta=1.382$ (SD $=1.401$) on Bosch OpenML 752 CNC cycles ($N=16384$ axis-wise pairings). Approximately $50.5\%$ of pairings yielded $\eta>1$.

Summary statistics for all six domains are collected in (tab:validation); the sports landscape with supporting-domain overlay markers appears in (fig:pef_landscape). Detailed per-study breakdowns for the non-sports domains are not separately visualised given the cross-sectional nature of those datasets.
