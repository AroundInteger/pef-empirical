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

 This supplement supports the main paper in seven thematic blocks, ordered to follow the manuscript narrative (simulation validation, mathematical derivations, theory, sports landscape, efficiency--power diagnostics, quality control, practitioner tools). Figure, table, and note numbers (S1--S8; Notes S1--S4) are fixed for cross-referencing; block order differs from numeric figure order where material is grouped by topic.

tabular@p0.22p0.34p0.38@

  **SI block** & **Main paper** & **Contents** \\

  1 Probit validation & Intro.; Methods Tier 1; Results & Note S2; Figs S4--S5 \\
  2 Maths. derivations & Theory; Intro. (Pitman) & Note S3 \\
  3 Info. surface & Theory; Fig. 2 & Fig. S1 \\
  4 KPI landscape & Methods; Results; Discussion & Figs S2--S3; Tables S1--S2; Fig. S8 \\
  5 Eff.--power & Results ((sec:eff_power)) & Figs S6--S7 \\
  6 QC & Methods ((sec:qc)); Discussion & Normality note; Note S1 \\
  7 Practitioner tool & Discussion ((sec:practical_guidance)) & Note S4 \\

tabular

# SI Section 1: Idealised Probit Validation

 Supports the first validation tier ((sec:methods)): an idealised probit simulation under (A1)--(A2) that confirms the closed-form PEF--information mapping ((eq:mi_closed)) and the efficiency--power tension ((sec:eff_power_theory)) before turning to empirical KPIs. Main-text scenario results appear in (sec:results,tab:scenarios); Supplementary Note S2 gives the full specification; Figures S4--S5 visualise grid-level and contour-level behaviour cited in (sec:results,sec:signal_strength).

## Supplementary Note S2: Idealised Probit Simulation: Model Specification and Validation

**Purpose.** The first validation tier ((sec:methods)) isolates the PEF--information content relationship ((eq:mi_closed)) from the finite-sample noise, mild non-normality, and team-level clustering present in the empirical KPIs. Data are generated to satisfy (A1)--(A2) exactly. The simulation then checks two claims. First, the closed-form mapping is recovered by five-fold logistic regression, the same classifier family as the empirical protocol. Pairs are independent by construction, so the simulation does not use team-blocked folds. Second, the efficiency--power tension ((sec:eff_power_theory)) arises as predicted. This is a check of internal consistency under the model's own assumptions, not an independent empirical test. The empirical tiers ((sec:results)) provide the latter.

**Data-generating process (A1).** For each grid cell $(\kappa,\rho,\delta/\sigma_A)$ we draw $n$ independent pairs from the bivariate normal

$$

  pmatrixX_A\\[2pt] X_Bpmatrix
  \sim N\left(
  pmatrix\delta/2\\[2pt] -\delta/2pmatrix,
  \sigma_A^2
  pmatrix1 & \rhosqrt(\kappa)\\[2pt] \rhosqrt(\kappa) & \kappapmatrix
  \right),

$$

with $\sigma_A=1$. This parameterisation fixes $\Var(X_A)=\sigma_A^2$, $\Var(X_B)=\kappa\sigma_A^2$, and $\Corr(X_A,X_B)=\rho$, so the variance ratio and correlation match their targets by construction. The relative feature $X=X_A-X_B$ then has mean $\delta$ and variance $\Var(X)=\sigma_A^2(1+\kappa-2sqrt(\kappa) \rho)$, exactly the denominator of (eq:pef).

**Outcome model (A2).** Binary outcomes are drawn from the probit link consistent with (eq:hygx):

$$

  Y_i \sim Bernoulli\left(\Phi\left(\fracX_isqrt(\Var(X))\right)\right),

$$

which makes $X$ the Bayes-sufficient statistic for $Y$ and yields analytic information content $I(X;Y)$ as in (eq:mi_closed) and Bayes error $\Phi\bigl(-\delta/(2sqrt(\Var(X)))\bigr)$.

**Grid and Monte Carlo design.** The factorial grid is $\kappa\in\0.8,1.0,1.2,2.0\$, $\rho\in\-0.3,-0.15,0,0.4\$, and $\delta/\sigma_A\in\0.3,0.5,1.0,2.0\$ (64 admissible cells; the admissibility constraint $1+\kappa-2sqrt(\kappa) \rho>0$ holds throughout). Each cell uses $n=5,000$ pairs and is repeated over $50$ Monte Carlo trials with deterministic per-cell seeds (base seed $20,260,520$). The four named scenarios of (tab:scenarios) are simulated identically.

**Estimands.** For each cell we record (a) the analytic quantities $\eta$, $\Var(X)$, $I(X;Y)$, and the Bayes accuracy bound, computed directly from $(\kappa,\rho,\delta,\sigma_A)$; and (b) Monte Carlo estimates from the machine-learning protocol used throughout the paper, namely five-fold cross-validated logistic-regression accuracy for absolute features ($X_A$ only), relative features ($X=X_A-X_B$), and the full pair $(X_A,X_B)$. The headline machine-learning improvement is the relative-minus-absolute accuracy difference, matching (sec:methods).

**Validation 1 (parameter recovery).** From each simulated sample we re-estimate $\kappa=s_B^2/s_A^2$, $\rho$, and $\eta$ using the same sample estimators as the empirical analysis ((sec:methods)). Recovered means track the target values along the identity line across the grid (generated output `idealised\_probit\_recovery.png`; `idealised\_probit\_grid.csv`), confirming that the sampler reproduces the intended $(\kappa,\rho)$ geometry and that $\eta$ is approximately unbiased over the admissible range.

**Validation 2 (PEF--information mapping).** At fixed signal strength, analytic $\eta$ and $I(X;Y)$ are strongly positively correlated ($r≈0.87$ within the $\delta/\sigma_A$ slice nearest the empirical median; (sec:results)). Pooled across $\delta/\sigma_A$ the correlation reverses sign ($r≈-0.70$), because signal strength shifts $I(X;Y)$ independently of the $(\kappa,\rho)$ position: the iso-$\eta$ versus iso-$I$ divergence shown in (fig:si_idealised_stratified,fig:si_iso_eta_I). This confirms the manuscript's central caveat that $\eta$ alone does not determine predictive gain.

**Validation 3 (efficiency--power tension).** All 16 Quadrant 4 grid cells with $\eta<1$ produced positive mean machine-learning improvement ((fig:si_idealised_stratified)), reproducing the predicted tension ((sec:eff_power_theory)) in a setting free of empirical confounds.

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

Set $w=(A-\delta/2)/\sigma_A\simN(0,1)$. The posterior is $E[Y\mid A]=\Phi\bigl((d_rel+rw)/\sqrt2-r^2\bigr)$, which is monotone in $A$. The Bayes rule therefore thresholds $A$, and

$$

  acc_A(d_rel,r)  =  E_w\left[\Phi\left(\frac|d_rel+rw|\sqrt2-r^2\right)\right].

$$

The relativisation gain is the two-parameter surface

$$

  \DeltaML(d_rel,r)  =  100 \fracacc_R(d_rel)-acc_A(d_rel,r)acc_A(d_rel,r) .

$$

Across the 64 grid cells this analytic surface reproduces the simulated $\DeltaML$ almost exactly ($r=0.9998$; (eq:si_surface) versus five-fold logistic CV). The machine-learning pipeline therefore attains the Bayes-optimal gain. No third coordinate is needed. The accuracy $acc_A$ increases with $r$ from the majority-class baseline to $acc_R$. At each $d_rel$ the surface is bracketed by two closed-form envelopes:

$$

  0_floor (r\to1)  \le  \DeltaML  \le  \underbrace100\left(\fracg(d_rel)\Phi(d_rel/sqrt(2))-1\right)_ceiling (r\to0) .

$$

The floor is exact. With $X$ Bayes-sufficient, relativisation cannot reduce accuracy in this idealised setting, so $\DeltaML\ge0$. The gain vanishes as $r\to1$, where $A$ coincides with $X$, and under signal saturation, where both accuracies approach one. The ceiling is attained as $r\to0$, where $A$ carries no outcome information and collapses to the marginal rate $\Phi(d_rel/sqrt(2))=\Pr(Y=1)$. From (eq:si_drel), large $\eta$ raises $d_rel$ rather than lowering it. The percentage gain is largest when $d_rel$ is modest, so accuracies have not saturated, and $r$ is small, so $A$ is poorly aligned with $X$. (fig:si_idealised_stratified)C shows the design points between these curves, coloured by $r$. The grid samples $r\in[0.32,0.83]$, so the visible upper edge is the $r=0.32$ contour, not the $r\to0$ ceiling.

**Reproducibility.** The simulation is implemented in `scripts/paper\_pipeline/run\_pef\_idealised\_probit\_sim.m`, with theory helpers in `scripts/paper\_pipeline/lib/pef\_theory\_helpers.m`. The locked configuration (grid, $n$, trials, folds, base seed) is recorded in the script's `PRODUCTION\_CONFIG` block; outputs (`idealised\_probit\_grid.csv`, `idealised\_probit\_scenarios.csv`, `idealised\_probit\_summary.txt`, and the diagnostic figures) are written to `scripts/paper\_pipeline/outputs/`. A `SMOKE\_TEST` flag runs a one-cell sanity check before a full execution.

figure3

> **[Figure]** Idealised probit simulation (Note S2) under (A1)--(A2).
    Grid: $\kappa\in\0.8,1.0,1.2,2.0\

\clearpage

figure4

> **[Figure]** Idealised probit companion (Note S2): iso-$$ vs. iso-$I(X;Y)$.
    (A) Surface at median empirical $/_mathrmA

# SI Section 2: Mathematical Derivations

 Supports the theoretical framework ((sec:theory)). The main text states the closed form ((eq:mi_closed)) and the four-quadrant partition. This section records the omitted algebra for the information-content derivation, the boundary analysis, estimator asymptotics, and the Pitman ARE identity.

## Supplementary Note S3: Mathematical Derivations

 The algebraic derivation of the PEF formula ((eq:pef)) from the variance of correlated differences, together with its reduction to Fisher's classical case at $\kappa=1$, is given in full in (sec:theory) (2.1). This note records the material not reproduced in the main text: the step-by-step information content derivation, the boundary analysis, the statistical properties of the PEF estimator, and the Pitman asymptotic relative efficiency proof.

### Information Content Derivation

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

### Boundary Analysis

Fisher Regime ($\kappa=1$, $\rho=0$)

$$

  \eta = 1,\quad \Var(X) = 2\sigma^2_A,\quad
  I(X;Y) = 1 - H\left(\Phi\left(\delta2\sigma_Asqrt(2)\right)\right).

$$

Independent measurements with equal variances; relativisation is neutral.

Variance Ratio Extremities

**$\kappa\to 0$** (entity B negligible variance):

$$

  \eta\to 1,\quad \Var(X)\to\sigma^2_A,\quad
  I(X;Y)\to 1 - H\left(\Phi\left(\delta2\sigma_A\right)\right).

$$

Reduces to measurement of entity A alone.

**$\kappa\to\infty$** (entity B dominates):

$$

  \eta\to 1,\quad \Var(X)≈ \kappa\sigma^2_A,\quad I(X;Y)\to 0.

$$

Signal drowns in noise from entity B's extreme variability.

Correlation Extremities

**$\rho\to -1$** (perfect negative correlation):

$$

  \eta\to1+\kappa(sqrt(\kappa)+1)^2,\quad
  \Var(X)\to\sigma^2_A(sqrt(\kappa)+1)^2.

$$

For $\kappa=1$: $\eta=0.5$, variance quadrupled. Yet $I(X;Y)$ may remain substantial if $\delta$ is sufficiently large.

**$\rho\to +1$** (perfect positive correlation):

$$

  \eta\to1+\kappa(sqrt(\kappa)-1)^2\to\infty,\quad
  \Var(X)\to\sigma^2_A(sqrt(\kappa)-1)^2\to 0.

$$

Variance vanishes, information content approaches unity.

Summary of Special Cases

center
tabular@lccc@

  **Condition** & $\eta$ & $\Var(X)$ & $I(X;Y)$ \\

  $\kappa=1$, $\rho=0$ (Fisher) & $1$ & $2\sigma^2_A$ & Depends on $\delta/\sigma_A$ \\
  $\kappa=1$, $\rho\to +1$     & $\to\infty$ & $\to 0$ & $\to 1$ \\
  $\kappa=1$, $\rho=-1$        & $0.5$ & $4\sigma^2_A$ & Reduced but non-zero \\
  $\kappa\to 0$                & $1$ & $\sigma^2_A$ & Depends on $\delta/\sigma_A$ \\
  $\kappa\to\infty$            & $1$ & $\to\infty$ & $\to 0$ \\

tabular
center

### Statistical Properties of the PEF Estimator

Estimators

For paired observations $(X_A,i,X_B,i)$, $i=1,…,n$,

$$

  \eta = 1+1+\kappa-2\kappa \rho,

$$

where $\kappa=s^2_B/s^2_A$ and $\rho$ is the Pearson sample correlation.

Asymptotic Distribution

Under bivariate normality and independence, the delta method [lehmann1999] gives

$$

  sqrt(n) (\eta-\eta) d N(0,\sigma^2_\eta),

$$

where $\sigma^2_\eta = g^\top \Sigma_(\kappa,\rho) g$ and $g = (\partial\eta/\partial\kappa, \partial\eta/\partial\rho)^\top$ is evaluated at the true parameter values. Writing $D=1+\kappa-2sqrt(\kappa) \rho$ for the denominator of $\eta$, the partial derivatives are

$$

  (\partial\eta)/(\partial\kappa)
    &= D - (1+\kappa)\bigl(1 - \rho/sqrt(\kappa)\bigr)D^2
     = (1+\kappa)\rho/sqrt(\kappa) - 2sqrt(\kappa) \rhoD^2,
   \\
  (\partial\eta)/(\partial\rho)
    &= 2sqrt(\kappa)(1+\kappa)D^2.

$$

The asymptotic covariance matrix $\Sigma_(\kappa,\rho)$ can be obtained from the delta method applied to $(s^2_A,s^2_B,\rho)$, or estimated directly via bootstrap (see below).

Theoretical Guarantees

- **Consistency:** $\etap\eta$ as $n\to\infty$ (continuous mapping theorem).

- **Bias:** $\eta$ is generally biased due to nonlinearity of the PEF formula; the bias is $O(1/n)$ and vanishes asymptotically. For $\eta>1$ the bias is typically positive (by Jensen's inequality, since $\eta$ is convex in $\rho$ from (eq:d2etadrho2)).

- **Efficiency:** $\eta$ is a continuous function of the MLEs $(\kappa,\rho)$ under bivariate normality; by the invariance of the MLE, $\eta$ is itself the MLE of $\eta$ and is asymptotically efficient [lehmann1999].

Bootstrap Confidence Intervals

$$

  CI_1-\alpha = \bigl[\eta^*_(\alpha/2),\eta^*_(1-\alpha/2)\bigr],

$$

where $\eta^*_(p)$ denotes the $p$th quantile of the bootstrap distribution from resampling paired observations.

### Connection to Classical Tests

The paired $t$-statistic is

$$

  t = Dsqrt(\Var(D)/n),\quad D=X_A-X_B.

$$

Higher $\eta$ (lower $\Var(D)$) increases the $t$-statistic and hence test power. Cohen's $d$ for paired designs,

$$

  d = Dsqrt(\Var(D)),

$$

also increases with $\eta$, yielding larger detectable effect sizes.

### Connection to Pitman Asymptotic Relative Efficiency

This note establishes that, under bivariate normality and equal group sizes, the PEF equals the Pitman asymptotic relative efficiency (ARE) of the paired $t$-test relative to the independent two-sample $t$-test. We state this as a proposition, give a self-contained proof, verify the classical reduction, and record the qualifications that bound the result.

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

# SI Section 3: Information Surface (Theory)

 Extends main-text Figure 2 ((fig:info_surface)) and the signal-strength discussion ((sec:signal_strength,sec:theory)). Figure S1 examines sensitivity of the $I(X;Y)$ surface to $\delta/\sigma_A$ on a controlled grid; empirical KPI positions appear separately in the landscape figures of (sec:si_landscape).

figure0

> **[Figure]** Sensitivity of the information-content surface $I(X;Y)$ to
    $\delta/\sigma_\mathrmA

\clearpage

# SI Section 4: Sports KPI Landscape

 Supports landscape characterisation ((sec:outcome_defs,sec:results)): the full $113$-KPI inventory on the $(,)$ plane, quadrant aggregates, and season-to-season drift. Main-text Figures 1--3 show exemplars and summaries. This section gives per-KPI detail (Figures S2--S3), quadrant-level aggregates (Table S1), further KPIs ranked by $|hat-1|$ (Table S2), and drift alignment (Figure S8). Throughout, $I_pred(X;Y)$ denotes the plug-in of (eq:mi_closed) at the estimated $(hat,hat,hat,hat_A)$. It is not a fitted mutual-information estimator, and it is not a global predictor of $$.

figure1

> **[Figure]** Labelled KPI maps on the PEF landscape (rugby URC; football Championship;
    seasons 23/24--24/25). Open and filled markers show the two seasons;
    arrows show year-on-year change; vermillion highlights cross-quadrant migration.
    Main-text (fig:pef_landscape,fig:info_surface

\clearpage

\setcounterfigure)2

> **[Figure]** Plug-in $I_mathrmpred

| table[h]

  lccccc@

    **Q** | **$n$** | **Mean $\hat\eta$** | **95\% CI** | **\% $\hat\eta>1$** | Mean $\DeltaML$ |
| --- | --- | --- | --- | --- | --- |
| Q1 | 15 | 1.302 | $[1.012,1.591]$ | 100 | -0.0\% |
| Q2 | 13 | 1.508 | $[0.868,2.147]$ | 100 | 0.5\% |
| Q3 | 77 | 0.827 | $[0.801,0.853]$ | 0 | 2.2\% |
| Q4 | 8 | 0.921 | $[0.878,0.964]$ | 0 | 0.0\% |
|
  minipage0.95
    Mean $\DeltaML$: team-blocked five-fold cross-validated accuracy improvement (relative minus absolute features), pooled across KPIs in the quadrant ((sec:ml_cv)). 95\% CIs are $±1.96$ standard errors of the within-quadrant mean $\hat\eta$. Landscape characterisation only; mechanistic confirmation uses (tab:exemplars). The Q3 mean $\DeltaML$ is lifted by outcome-adjacent volume features (goals, points, shots) in a Q3-heavy inventory. It is not a recommendation to relativise generic Q3 KPIs.
  minipage |

*Descriptive quadrant-level statistics across the sports KPI inventory (seasons 23/24--24/25 pooled).*

| table[h]

  .

  llcccc@

    **Q** | **KPI (sport)** | $\hat\kappa$ | $\hat\rho$ | $\hat\eta$ | $|\hat\eta-1|$ |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Q1 | Kick metres (rugby)$^\dagger$ | 1.06 | $+0.65$ | 2.84 | 1.84 |
| Q1 | Kicks from hand (rugby) | 1.13 | $+0.61$ | 2.54 | 1.54 |
| Q1 | Forward passes (football) | 1.06 | $+0.23$ | 1.29 | 0.29 |
| Q2 | Rucks won (rugby) | 0.82 | $+0.82$ | 5.38 | 4.38 |
| Q2 | Regains (football) | 0.96 | $+0.39$ | 1.63 | 0.63 |
| Q2 | Counterpressures (football) | 0.97 | $+0.26$ | 1.35 | 0.35 |
| Q3 | Passes (football)$^\dagger$ | 0.84 | $-0.65$ | 0.61 | 0.39 |
| Q3 | Opposition passes (football) | 0.82 | $-0.60$ | 0.63 | 0.37 |
| Q3 | Sideways passes (football) | 0.81 | $-0.59$ | 0.63 | 0.37 |
| Q4 | Goalkeeper long balls (football)$^\dagger$ | 1.00 | $-0.24$ | 0.81 | 0.19 |
| Q4 | Tackles (rugby) | 1.02 | $-0.16$ | 0.86 | 0.14 |
| Q4 | Set pieces (football) | 1.04 | $-0.13$ | 0.89 | 0.11 |
|
  minipage0.95
    Values from `pef\_landscape\_2season.csv`. Long balls (football, Q2) ranks fourth in Q2 by $|\hat\eta-1|$ and is the confirmatory Q2 exemplar in (tab:exemplars). Rucks won is the high-$\eta$, low-signal counter-example discussed in (sec:exemplars).
  minipage |

*Further sports KPIs ranked by $|\hat\eta-1|$ within each quadrant (top three; seasons 23/24--24/25 pooled). Daggers mark confirmatory exemplars from (tab:exemplars*

## Full Sports KPI Inventory (Reproducibility)

Per-KPI estimates from the canonical pipeline outputs:

- scripts/paper\_pipeline/outputs/pef\_landscape\_2season.csv): $(\hat\kappa,\hat\rho,\hat\eta)$, quadrant label, and match count $n$;

- `scripts/paper\_pipeline/outputs/ml\_empirical\_results.csv`: team-blocked five-fold $\DeltaML$;

- `scripts/paper\_pipeline/outputs/pef\_landscape\_per\_season.csv`: season-specific $(\hat\kappa,\hat\rho)$ for (fig:si_kpi_labelled).

figure7

> **[Figure]** Season-to-season drift versus the local information gradient for rugby URC KPIs
    (seasons 23/24--24/25; $n=24$). Alignment is the cosine of the angle between the
    $(\rho,\log\kappa)$ displacement and $\nabla I(X;Y)$ evaluated at the pooled position.
    The distribution is centred near zero: drift is not systematically toward higher $I$.
    Orange lines mark the 14 KPIs that cross a quadrant boundary.
    Generated by scripts/paper\_pipeline/run\_pef\_finalize\_diagnostics.m

# SI Section 5: Efficiency--Power Diagnostics

 Supports (sec:eff_power,sec:eff_power_theory) and the confirmatory exemplars ((tab:exemplars)). Figure S6 reports team-stratified bootstrap intervals on $\hat\eta$ and $I_pred$. Figure S7 compares team-blocked CV accuracy with the equal-prior Gaussian Bayes accuracy of the absolute feature under (A1)--(A2).

figure5

> **[Figure]** Team-stratified bootstrap 95\% CIs ($B=300$) for $\eta$ and
    $I_\mathrmpred

\clearpage

figure6

> **[Figure]** Quadrant 4 KPIs ($<1$): team-blocked five-fold CV accuracy for absolute
    and relative features, with the equal-prior Gaussian Bayes accuracy of $X_mathrmA

# SI Section 6: Quality Control

 Supports normality and transformation checks in Methods ((sec:qc)) and distributional limitations in Discussion.

## Paired-difference normality

The information-content mapping ((eq:mi_closed)) uses assumption (A1) on the pair $(X_A,X_B)$. The relevant check for that approximation is the per-match paired difference $X=X_A-X_B$, not the separate home or away series. On the two-season primary window, mean Shapiro--Wilk $W$ for the difference series is $0.954$ in rugby and $0.943$ in football, with mean skewness $0.021$ and $0.079$ respectively (`normality\_commentary.csv`). Those figures are the source of the $0.94$--$0.95$ and $≈ 0.02$--$0.08$ ranges quoted in the Introduction and in the Theory remark. Home and away series are more right-skewed, as expected for count KPIs. The PEF formula itself does not require normality.

## Supplementary Note S1: Log-Transformation: Correlation Preservation and KPI-Type Dependence

A logarithmic transformation $Z=\log(X+1)$ was applied to all 24 rugby union KPIs from the primary dataset ($n=283$ games, seasons 23/24--24/25 pooled) to assess whether variance stabilisation improves PEF estimation for right-skewed count-based KPIs.

**Aggregate effect.** The mean ratio $\eta_\log/\eta=1.007$ (median $1.006$; bootstrap 95\% CI approximately $[0.97,1.04]$). A paired $t$-test did not reach significance ($p=0.712$; Cohen's $d=0.076$). The transformation should therefore not be applied indiscriminately: its aggregate benefit is statistically negligible.

**Correlation preservation.** The rank ordering of KPIs by $\rho$ was unchanged (Spearman $r_s=0.997$; mean absolute change $|\rho_\log-\rho|=0.014$, range $0.001$--$0.038$). $\kappa$ moved towards unity in 16/24 cases, with mean $|\kappa_\log-\kappa|=0.08$. The $(\kappa,\rho)$ structure required for valid PEF inference is preserved under the transformation.

**KPI-type dependence.** The greatest gains accrued to count-based KPIs: rucks won ($+37\%$), kick metres ($+23\%$), kicks from hand ($+20\%$), offloads ($+16\%$). These KPIs exhibit approximate Poisson-like variance-to-mean structure for which the log transformation acts as a variance-stabilising function. Percentage-based and binary/rare-event KPIs showed negligible change ($\eta_\log/\eta ≈ 1.00$).

**Practical guidance.** The aggregate PEF change is negligible, so the transformation should not be applied by default. For a right-skewed count KPI that rejects approximate normality, $Z=\log(X+1)$ can be checked as a sensitivity analysis. Recompute $\eta$ on the transformed pairs and compare. A ratio above one is a variance-stabilisation diagnostic, not a more reliable plug-in for (eq:mi_closed). The information-content mapping still requires (A1) on the transformed pair. The transformation is unnecessary for KPIs that are already approximately symmetric.

# SI Section 7: Practitioner Diagnostic

 Implements the six-step procedure in (sec:practical_guidance). Code and repository details: (sec:data_availability).

## Supplementary Note S4: Practitioner Diagnostic (Input Schema and Usage)

**Purpose.** Estimates $(\hat\kappa,\hat\rho,\hat\eta)$, classifies the quadrant, computes $\hat\delta/\hat\sigma_A$ and $I(X;Y)$ under (A1)--(A2), and returns a text recommendation per feature. Does *not* run ML cross-validation.

**Location.** `scripts/practitioner/run\_pef\_diagnostic.m` (repository `pef-empirical`). Depends on `scripts/paper\_pipeline/lib/pef\_theory\_helpers.m` only.

**Input formats (CSV).**

- **Long (preferred):** `feature\_id`, `x\_a`, `x\_b`; optional `unit\_id`.

- **Wide:** paired columns `*\_home`/`*\_away` or `*\_a`/`*\_b`.

Entity A defines $\kappa=s^2_B/s^2_A$; document which entity is A when interpreting $\kappa$.  Each row is one paired observation (e.g. one fixture in sports); $\hat\rho$ is the Pearson correlation between the two margin columns across those $n$ rows (cross-fixture in the sports application), not serial correlation within one margin.

**Output.** One row per feature: `n`, `kappa`, `rho`, `eta`, `quadrant`, `delta`, `sigma\_a`, `delta\_sigma\_a`, `I\_bits`, `recommendation`, `admissible`. Quadrant 4 rows require manual assessment of $I(X;Y)$ alongside $\hat\eta<1$.

**Example run.**
verbatim
cd scripts/practitioner
matlab -batch "run('run_pef_diagnostic.m')"
verbatim
Examples: `examples/pef\_diagnostic\_long.csv`, `pef\_diagnostic\_wide.csv`.

**Minimum sample size.** $n<8$ or zero variance $\Rightarrow$ error recommendation. Bootstrap intervals (cf. (fig:si_bootstrap_exemplars)) are not included; use the full pipeline for publication-grade uncertainty on sports KPIs.
