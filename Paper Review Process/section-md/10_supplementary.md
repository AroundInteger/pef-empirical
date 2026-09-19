# Supplementary Information

> **Review copy** from LaTeX. Source of truth: `sections/supplementary.tex`.
> Propose edits in chat (or annotate this file); agreed changes go into the `.tex`.
> Math rendering is approximate.

---

figure0
Sfigure
table0
Stable

# Supplementary Information

 This supplement follows the main paper: theoretical derivations, then the idealised probit check, then the sports KPI analysis. Figures are numbered in order of appearance (S1--S5). File names on disk retain their generator tags and need not match the printed S-number.

tabular@p0.22p0.34p0.38@

  **SI block** & **Main paper** & **Contents** \\

  1 Theory & Theory; Fig. 2; Intro. (Pitman) & Algebra; Pitman ARE; Fig. S1 \\
  2 Probit validation & Methods Tier 1; Results & Spec.; Figs S2--S3 \\
  3 Empirical analysis & Methods; Results; Discussion & Figs S4--S5; Table S1; QC \\

tabular

# SI Section 1: Theoretical Derivations

 Supports the theoretical framework ((sec:theory)). The main text states the closed form ((eq:mi_closed)) and the four-quadrant partition. This section records the omitted algebra and extends main-text Figure 2 ((fig:info_surface)).

 The algebraic derivation of the PEF formula ((eq:pef)) from the variance of correlated differences, together with its reduction to Fisher's classical case at $\kappa=1$, is given in full in (sec:theory) (2.1). This section records the omitted information-content algebra and the Pitman asymptotic relative efficiency proof.

## Information Content Derivation

Setup

Under Assumption (A1), $X=X_A-X_B\simN\bigl(\delta,\sigma^2_A(1+\kappa-2sqrt(\kappa) \rho)\bigr)$ with $\delta=\mu_A-\mu_B$.

The binary outcome $Y\in\0,1\$ is the match outcome; it is *not* a deterministic function of $X$. Under Assumption (A2) (Gaussian discriminant model, (sec:mi_setup)), the class-conditional distributions are
\[
  X Y=1(+/2, Var(X)), X Y=0(-/2, Var(X)),
\]
with equal priors. Mutual information:

$$

  I(X;Y) = H(Y) - H(Y\mid X).

$$

Unconditional Entropy

For equiprobable outcomes ($P(Y=1)=P(Y=0)=0.5$),

$$

  H(Y) = 1  bit.

$$

Conditional Entropy

Under (A2), the posterior is $P(Y=1\mid X=x)=\Phi(x/sqrt(\Var(X)))$, so the expected conditional entropy is

$$

  H(Y\mid X) &= E_X\bigl[H\bigl(P(Y=1\mid X)\bigr)\bigr].

$$

Evaluating this expectation under the marginal distribution of $X$ (which has mean $\delta/2$ under the equal-prior mixture) yields the closed-form approximation

$$

  H(Y\mid X) ≈ H\left(\Phi\left(2sqrt(\Var(X))\right)\right),

$$

where $H(p)=-p\log_2p-(1-p)\log_2(1-p)$ is the binary entropy function and the right-hand side equals the binary entropy of the Bayes error rate $\Phi(-\delta/(2sqrt(\Var(X))))$.

Substitution

From (eq:pef): $1+\kappa-2sqrt(\kappa) \rho=(1+\kappa)/\eta$. Therefore $\Var(X)=\sigma^2_A(1+\kappa)/\eta$, giving

$$

  I(X;Y) = 1 - H\left(\Phi\left(\delta2\sigma_Asqrt((1+\kappa)/\eta)\right)\right).

$$

## Connection to Pitman Asymptotic Relative Efficiency

This section establishes that, under bivariate normality and equal group sizes, the PEF equals the Pitman asymptotic relative efficiency (ARE) of the paired $t$-test relative to the independent two-sample $t$-test. We state this as a proposition, give a self-contained proof, verify the classical reduction, and record the qualifications that bound the result.

Proposition

**Proposition (PEF as Pitman ARE).** *Under Assumption (A1) and equal allocation ($n$ observations per group), the Pitman ARE of the paired $t$-test relative to the independent two-sample $t$-test equals*

$$

  ARE_paired/indep = 1+1+\kappa-2sqrt(\kappa) \rho = \eta.

$$

Proof

Let $N=2n$ be the total number of observations available. Fix $\mu_A-\mu_B=\delta>0$ and let $n\to\infty$. We compare the noncentrality parameters of the two tests at the same total sample size.

**Step 1: Paired test.** With $n$ matched pairs, differences $D_i=X_A,i-X_B,i\simN(\delta,\sigma^2_A(1+\kappa-2sqrt(\kappa) \rho))$ are i.i.d. under (A1). The noncentrality parameter of $T_p=D/\sqrts^2_D/n$ is

$$

  \lambda_p(n) = \deltasqrt(n)\sigma_A1+\kappa-2sqrt(\kappa) \rho.

$$

**Step 2: Independent two-sample test.** With $n$ independent observations per group (total $N=2n$, equal allocation), the noncentrality parameter of the Welch $t$-test $T_u=(X_A-X_B)/\sqrts^2_A/n+s^2_B/n$ is

$$

  \lambda_u(n) = \deltasqrt(n)\sigma_Asqrt(1+\kappa).

$$

**Step 3: ARE.** Both tests use the same total sample $N=2n$. The Pitman ARE is the limiting ratio of sample sizes required for equal power at fixed significance and effect size, which equals the ratio of squared noncentrality parameters per observation [lehmann1999]:

$$

  ARE_paired/indep
    = \lim_n\to\infty\fracn_u^*n_p^*
    = \frac\lambda_p^2(n)/n\lambda_u^2(n)/n
    = \frac\delta^2/\bigl(\sigma^2_A(1+\kappa-2sqrt(\kappa) \rho)\bigr)
           \delta^2/\bigl(\sigma^2_A(1+\kappa)\bigr)
    = 1+1+\kappa-2sqrt(\kappa) \rho
    = \eta 00 .

$$

Classical Verification

Setting $\kappa=1$:

$$

  ARE_paired/indep = (2)/(2-2\rho) = (1)/(1-\rho),

$$

recovering Fisher's classical paired-design efficiency [fisher1935]. The PEF is therefore the direct generalisation of Fisher's result to unequal variances, expressed in the language of Pitman efficiency.

Qualifications

Three conditions bound (eq:are_pef):

- **Normality.** Steps 1--2 use the normal noncentrality parameter. Under non-normality, the central limit theorem ensures the limiting noncentrality is still given by (eq:ncp_paired,eq:ncp_unpaired) under finite second moments, so the ARE result is asymptotically robust; however, the small-sample comparison may differ.

- **Equal group allocation.** Step 2 assumes $n_A=n_B=n$. Under Neyman-optimal allocation $n_A/n_B=\sigma_A/\sigma_B=1/sqrt(\kappa)$, the noncentrality of the independent test becomes $\deltasqrt(N)/(2\sigma_Asqrt(\kappa)/(1+sqrt(\kappa))·sqrt(1+\kappa))$, which modifies the ARE. Equal allocation is the natural comparison when paired and unpaired designs collect data in the same proportions.

- **Fixed alternative.** The result above uses a fixed $\delta$ and $n\to\infty$. Under local (Pitman) contiguous alternatives $\delta_n=c/sqrt(n)$, the noncentrality parameters remain $O(1)$ and the same ratio $\eta$ is obtained in the limit, so the result is unchanged [lehmann1999].

 The PEF formula is distribution-free ((eq:pef)); only the ARE *interpretation* in (eq:are_pef) requires normality. The distribution-free efficiency characterisation (the variance ratio) is the primary result; the Pitman ARE connection provides a classical testing-theory corroboration.

## Information surface

 (fig:si_info_sensitivity) examines sensitivity of the $I(X;Y)$ surface to $\delta/\sigma_A$ on a controlled grid; empirical KPI positions appear in (sec:si_landscape).

> **[Figure]** Sensitivity of the information-content surface $I(X;Y)$ to
    $\delta/\sigma_\mathrmA

\clearpage

# SI Section 2: Idealised Probit Validation

 Supports the first validation tier ((sec:methods)): an idealised probit simulation under (A1)--(A2) that confirms the closed-form PEF--information mapping ((eq:mi_closed)) and the efficiency--power tension ((sec:eff_power_theory)) before turning to empirical KPIs. Main-text scenario results appear in (sec:results,tab:scenarios); the specification below is the full model; (fig:si_idealised_stratified,fig:si_iso_eta_I) visualise grid-level and contour-level behaviour cited in (sec:results,sec:signal_strength).

## Idealised Probit Simulation: Model Specification and Validation

**Purpose.** The first validation tier ((sec:methods)) isolates the PEF--information content relationship ((eq:mi_closed)) from the finite-sample noise, mild non-normality, and team-level clustering present in the empirical KPIs. Data are generated to satisfy (A1)--(A2) exactly. The simulation then checks two claims. First, the closed-form mapping is recovered by five-fold logistic regression, the same classifier family as the empirical protocol. Pairs are independent by construction, so the simulation does not use team-blocked folds. Second, the efficiency--power tension ((sec:eff_power_theory)) arises as predicted. This is a check of internal consistency under the model's own assumptions, not an independent empirical test. The empirical tiers ((sec:results)) provide the latter.

**Data-generating process (A1).** For each grid cell $(,,/_A)$ we draw $n$ independent pairs from the bivariate normal

$$

  pmatrixX_A\\[2pt] X_Bpmatrix
  \sim N\left(
  pmatrix\delta/2\\[2pt] -\delta/2pmatrix,
  \sigma_A^2
  pmatrix1 & \rhosqrt(\kappa)\\[2pt] \rhosqrt(\kappa) & \kappapmatrix
  \right),

$$

with $_A=1$. This parameterisation fixes $Var(X_A)=_A^2$, $Var(X_B)=_A^2$, and $Corr(X_A,X_B)=$, so the variance ratio and correlation match their targets by construction. The relative feature $X=X_A-X_B$ then has mean $$ and variance $Var(X)=_A^2(1+-2sqrt() )$, exactly the denominator of (eq:pef).

**Outcome model (A2).** Binary outcomes are drawn from the probit link consistent with (eq:hygx):

$$

  Y_i \sim Bernoulli\left(\Phi\left(\fracX_isqrt(\Var(X))\right)\right),

$$

which makes $X$ the Bayes-sufficient statistic for $Y$ and yields analytic information content $I(X;Y)$ as in (eq:mi_closed) and Bayes error $(-/(2sqrt(Var(X))))$.

**Grid and Monte Carlo design.** The factorial grid is $\0.8,1.0,1.2,2.0\$, $\-0.3,-0.15,0,0.4\$, and $/_A\0.3,0.5,1.0,2.0\$ (64 admissible cells; the admissibility constraint $1+-2sqrt() >0$ holds throughout). Each cell uses $n=5,000$ pairs and is repeated over $50$ Monte Carlo trials with deterministic per-cell seeds (base seed $20,260,520$). The four named scenarios of (tab:scenarios) are simulated identically.

**Estimands.** For each cell we record (a) the analytic quantities $$, $Var(X)$, $I(X;Y)$, and the Bayes accuracy bound, computed directly from $(,,,_A)$; and (b) Monte Carlo estimates from the machine-learning protocol used throughout the paper, namely five-fold cross-validated logistic-regression accuracy for absolute features ($X_A$ only), relative features ($X=X_A-X_B$), and the full pair $(X_A,X_B)$. The headline machine-learning improvement is the relative-minus-absolute accuracy difference, matching (sec:methods).

**Validation 2 (PEF--information mapping).** At fixed signal strength, analytic $$ and $I(X;Y)$ are strongly positively correlated ($r≈0.87$ within the $/_A$ slice nearest the empirical median; (sec:results)). Pooled across $/_A$ the correlation reverses sign ($r≈-0.70$), because signal strength shifts $I(X;Y)$ independently of the $(,)$ position: the iso-$$ versus iso-$I$ divergence shown in (fig:si_idealised_stratified,fig:si_iso_eta_I). This confirms the manuscript's central caveat that $$ alone does not determine predictive gain.

**Validation 3 (efficiency--power tension).** All 16 Quadrant 4 grid cells with $<1$ produced positive mean machine-learning improvement ((fig:si_idealised_stratified)), reproducing the predicted tension ((sec:eff_power_theory)) in a setting free of empirical confounds.

**Validation 4 (a master surface and its envelope).** Under (A1)--(A2) the relativisation gain is a function of two coordinates, with closed-form bounds. The outcome depends on the pair only through $X$ ((eq:si_outcome)). The relative feature is therefore Bayes-sufficient, and its optimal rule is the sign of $X$. Write the standardised relative signal

$$

  d_rel  =  |\delta|sqrt(\Var(X))  =  |\delta|\sigma_Asqrt((\eta)/(1+\kappa)),
  \qquad u \equiv Xsqrt(\Var(X)) \sim N(d_rel,1).

$$

The Bayes accuracy of the relative feature depends on $d_rel$ alone,

$$

  acc_R(d_rel)  =  E\bigl[\Phi(|u|)\bigr]  =  g(d_rel),
  \qquad g(d) \equiv E_u\simN(0,1)\Phi(|d+u|).

$$

The absolute feature $A=X_A$ is jointly Gaussian with $X$. Their correlation is

$$

  r  \equiv  \Corr(A,X)  =  1-\rhosqrt(\kappa) 1+\kappa-2sqrt(\kappa) \rho   =  (1-\rhosqrt(\kappa))sqrt((\eta)/(1+\kappa)) .

$$

Set $w=(A-/2)/_A(0,1)$. The posterior is $E[Y A]=((d_rel+rw)/2-r^2)$, which is monotone in $A$. The Bayes rule therefore thresholds $A$, and

$$

  acc_A(d_rel,r)  =  E_w\left[\Phi\left(\frac|d_rel+rw|\sqrt2-r^2\right)\right].

$$

The relativisation gain is the two-parameter surface

$$

  \DeltaML(d_rel,r)  =  100 \fracacc_R(d_rel)-acc_A(d_rel,r)acc_A(d_rel,r) .

$$

Across the 64 grid cells this analytic surface reproduces the simulated $$ almost exactly ($r=0.9998$; (eq:si_surface) versus five-fold logistic CV). The machine-learning pipeline therefore attains the Bayes-optimal gain. No third coordinate is needed. The accuracy $acc_A$ increases with $r$ from the majority-class baseline to $acc_R$. At each $d_rel$ the surface is bracketed by two closed-form envelopes:

$$

  0_floor (r\to1)  \le  \DeltaML  \le  \underbrace100\left(\fracg(d_rel)\Phi(d_rel/sqrt(2))-1\right)_ceiling (r\to0) .

$$

The floor is exact. With $X$ Bayes-sufficient, relativisation cannot reduce accuracy in this idealised setting, so $0$. The gain vanishes as $r1$, where $A$ coincides with $X$, and under signal saturation, where both accuracies approach one. The ceiling is attained as $r0$, where $A$ carries no outcome information and collapses to the marginal rate $(d_rel/sqrt(2))=(Y=1)$. From (eq:si_drel), large $$ raises $d_rel$ rather than lowering it. The percentage gain is largest when $d_rel$ is modest, so accuracies have not saturated, and $r$ is small, so $A$ is poorly aligned with $X$. (fig:si_idealised_stratified)C shows the design points between these curves, coloured by $r$. The grid samples $r[0.32,0.83]$, so the visible upper edge is the $r=0.32$ contour, not the $r0$ ceiling.

\clearpage

> **[Figure]** Idealised probit simulation (SI \S2) under (A1)--(A2).
    Grid: $\0.8,1.0,1.2,2.0\

> **[Figure]** Idealised probit companion (SI 2): iso-$\eta$ vs. iso-$I(X;Y)$.
    (A) Surface at median empirical $\delta/\sigma_\mathrmA

\clearpage

# SI Section 3: Empirical Analysis

 Supports landscape characterisation ((sec:outcome_defs,sec:results)): the full $86$-KPI inventory on the $(,)$ plane and quadrant aggregates. Main-text Figures 1--2 map exemplars on the PEF and information surfaces; Figure 3 is the confirmatory $$--$$ check. This section gives per-KPI detail ((fig:si_kpi_labelled,fig:si_ipred_vs_dml)), quadrant-level aggregates (Table S1), and quality-control checks. Throughout, $I_pred(X;Y)$ denotes the plug-in of (eq:mi_closed) at the estimated $(hat,hat,hat,hat_A)$. It is not a fitted mutual-information estimator, and it is not a global predictor of $$.

> **[Figure]** Season-specific KPI positions and quadrant occupancy (rugby URC; football Championship;
    seasons 23/24--24/25). (A, B) rugby; (C, D) football. Markers are coloured by quadrant
    (Q1 green, Q2 blue, Q3 orange, Q4 red). (E) share of KPIs in each quadrant, by season.
    Year-on-year identity is not traced: arrows overstate small moves across $=1$ or $=0$.
    A minority of rugby KPIs cross a quadrant boundary between seasons. Football remains Q3-heavy.
    Main-text (fig:pef_landscape,fig:info_surface

\clearpage

> **[Figure]** Plug-in $I_mathrmpred

| table)[h]

  lccccc@

    **Q** | **$n$** | **Mean $\hat\eta$** | **95\% CI** | **\% $\hat\eta>1$** | Mean $\DeltaML$ |
| --- | --- | --- | --- | --- | --- |
| Q1 | 12 | 1.346 | $[0.986,1.706]$ | 100 | 0.4\% |
| Q2 | 12 | 1.547 | $[0.857,2.237]$ | 100 | 0.5\% |
| Q3 | 55 | 0.788 | $[0.759,0.818]$ | 0 | 0.4\% |
| Q4 | 7 | 0.913 | $[0.867,0.959]$ | 0 | -0.2\% |
|
  minipage0.95
    Mean $\DeltaML$: team-blocked five-fold cross-validated accuracy improvement (relative minus absolute features), pooled across KPIs in the quadrant ((sec:ml_cv)). 95\% CIs are $±1.96$ standard errors of the within-quadrant mean $\hat\eta$. Landscape characterisation only; mechanistic confirmation uses (tab:exemplars). It is not a recommendation to relativise generic Q3 KPIs.
  minipage |

*Descriptive quadrant-level statistics across the sports KPI inventory (seasons 23/24--24/25 pooled).*

## Quality control

 Supports normality and transformation checks in Methods ((sec:qc)) and distributional limitations in Discussion.

### Paired-difference normality

The information-content mapping ((eq:mi_closed)) uses assumption (A1) on the pair $(X_A,X_B)$. The relevant check for that approximation is the per-match paired difference $X=X_A-X_B$, not the separate home or away series. On the two-season primary window, mean Shapiro--Wilk $W$ for the difference series is $0.977$ in rugby and $0.986$ in football, with mean skewness $0.028$ and $0.069$ respectively (`normality\_commentary.csv`). Those figures are the source of the $0.98$ and $≈ 0.03$--$0.07$ ranges quoted in the Introduction and in the Theory remark. Home and away series are more right-skewed, as expected for count KPIs. The PEF formula itself does not require normality.

### Log-transform and Quadrant 4 bootstrap

A log-transform $Z=\log(X+1)$ on the 22 rugby action KPIs preserves rank order by $\rho$ (Spearman $r_s=0.967$; mean $|\rho_\log-\rho|=0.032$). The mean PEF ratio is $\eta_\log/\eta=1.085$ (median $1.002$; paired $t$, $p=0.357$). That mean is pulled by rucks won. The transform is a sensitivity check for right-skewed counts, not a default step.

Team-stratified bootstrap 95\% intervals ($B=300$; home-team resampling) for tackles (rugby, Q4) are $[0.773,0.960]$ on $\hat\eta$, entirely below one. The confirmatory Q4 point estimate remains $\hat\eta=0.81$ for goalkeeper long balls ((tab:exemplars)).

The open SI2 and SI3 tools for the six-step procedure in (sec:practical_guidance) are documented at (sec:data_availability).
