# Theoretical Framework

> **Review copy** from LaTeX. Source of truth: `sections/theoretical_framework.tex`.
> Propose edits in chat (or annotate this file); agreed changes go into the `.tex`.
> Math rendering is approximate.

---

# Theoretical Framework

This section develops the theoretical core sketched in the Introduction. We first define how pairing efficiency depends on the variance ratio $\kappa$ and the correlation $\rho$, using only second-moment algebra that requires no distributional assumptions. We then connect efficiency to predictive information under bivariate normality, and translate the resulting $(\kappa,\rho)$ geometry into quadrant-level guidance for relativisation. Readers focused on application may skim the formal derivations and proceed to the quadrant taxonomy ((tab:quadrants)) and the signal-strength discussion ((sec:signal_strength)).

## The Paired Efficiency Factor

### Derivation

We begin from the variance of the difference between two measurements. When entity A and entity B are observed on the same occasion, their values may covary; the variance of $X_A-X_B$ captures how much noise remains after differencing. For random variables $X_A$ and $X_B$ with variances $\sigma^2_A$, $\sigma^2_B$ and correlation $\rho$,

$$

  \Var(X_A - X_B) = \sigma^2_A + \sigma^2_B - 2\rho\sigma_A\sigma_B.

$$

The cross term $-2\rho\sigma_A\sigma_B$ is where correlation enters: positive $\rho$ shrinks the variance of the difference because shared fluctuations partially cancel, whilst negative $\rho$ amplifies it. Introducing $\kappa=\sigma^2_B/\sigma^2_A$ and factoring,

$$

  \Var(X_A - X_B) = \sigma^2_A\bigl(1 + \kappa - 2sqrt(\kappa) \rho\bigr).

$$

The variance ratio $\kappa$ separates *how unequal* the two entity variances are from *how correlated* their measurements are; holding $\kappa$ fixed, $\rho$ alone determines whether differencing helps or harms efficiency.

The efficiency question is how this paired variance compares with treating the two measurements as independent. For unpaired measurements ($\rho=0$), the baseline variance is $\sigma^2_A(1+\kappa)$. The Paired Efficiency Factor is their ratio, i.e. the expression in (eq:pef):

$$

  \eta = 1+1+\kappa-2sqrt(\kappa) \rho.

$$

 with $\eta$, $\kappa$, and $\rho$ as defined for (eq:pef) in (sec:pef_def).

**Remark.** No distributional assumptions are required: (eq:pef,eq:var_factored) hold for any random variables with finite second moments.

### Properties

Intuitively, stronger positive correlation means that shared fluctuations cancel more completely in the difference, so efficiency gain rises as $\rho$ increases. Formally, PEF is strictly increasing in $\rho$ for fixed $\kappa>0$,

$$

  (\partial \eta)/(\partial \rho) = 2sqrt(\kappa)(1+\kappa)\bigl(1+\kappa-2sqrt(\kappa) \rho\bigr)^2 > 0,

$$

and convex in $\rho$,

$$

  \frac\partial^2 \eta\partial \rho^2 = 8\kappa(1+\kappa)\bigl(1+\kappa-2sqrt(\kappa) \rho\bigr)^3 > 0.

$$

The sign of $\eta$ relative to unity partitions pairing into three interpretable regimes:

- $\eta>1$: pairing reduces variance (positive correlation dominates);

- $\eta=1$: pairing provides no efficiency change (Fisher baseline);

- $\eta<1$: pairing increases variance (negative correlation dominates).

(fig:pef_landscape) visualises the PEF landscape across the $(\rho,\kappa)$ parameter space.

### Reduction to Classical Case

When the two competitors have equal variability ($\kappa=1$, so $\sigma_A=\sigma_B$), the general formula simplifies to Fisher's classical result:

$$

  \eta = (2)/(2-2\rho) = (1)/(1-\rho),

$$

recovering the paired-efficiency formula from the Introduction [fisher1935]. That is, positive correlation shrinks the variance of the difference below the independent-measurement baseline ($\eta>1$), whilst negative correlation amplifies it ($\eta<1$). This is exactly the efficiency logic of the paired $t$-test [student1908]. The PEF formula therefore *contains* Fisher's result as a special case; unequal variances ($\kappa≠ 1$) are the ingredient the classical framework cannot represent on its own.

### Provenance and Scope of Contribution

The variance-of-difference identity for unequal variances ((eq:var_sum,eq:var_factored)) is a standard second-moment result, and the efficiency-of-pairing argument under equal variances is due to Fisher [fisher1935]; the same paired-margin machinery underlies the Pitman--Morgan test for equality of correlated variances [pitman1939,morgan1939]. Our contribution is not this algebra but its reframing: we collect it into a single closed-form efficiency ratio ((eq:pef)), parameterised by $(\kappa,\rho)$, and repurpose it from an inferential setting toward feature construction and predictive information in competitive measurement.

## The PEF--Information Content Relationship

Statistical efficiency ($\eta$) alone cannot explain why relative features sometimes improve prediction when $\eta<1$. To address that paradox, we need a second quantity: how much the KPI difference reduces uncertainty about the match outcome.

### Setup and Assumptions

We now connect PEF with predictive power. Let $Y\in\0,1\$ denote the **binary match outcome** (whether entity A outperforms entity B on the measure of interest), and let $X=X_A-X_B$ be the corresponding relative feature. The predictive setting introduces a quantity beyond the second-moment pair $(\kappa,\rho)$ that governs PEF: the **signal**, or mean separation $\delta=\mu_A-\mu_B$ between the two entities. Whereas $(\kappa,\rho)$ fix the variance geometry of the relative feature, it is the magnitude of $\delta$ relative to $\sigma_A$ that determines how much of that geometry translates into predictive power; this distinction is the crux of the efficiency--power tension and its consequences are developed in (sec:signal_strength). To express that link in closed form, two distributional assumptions are needed: one on the paired measurements themselves, and one on how the relative feature relates to the match outcome.

description

- [(A1)] $(X_A,X_B)$ follows a bivariate normal distribution with means $\mu_A$, $\mu_B$, variances $\sigma^2_A$, $\sigma^2_B$, and correlation $\rho$. Under (A1), $X=X_A-X_B$ is normally distributed with mean $\delta=\mu_A-\mu_B$ and variance given by (eq:var_factored).

- [(A2)] The class-conditional distributions of $X$ given $Y$ follow a symmetric Gaussian discriminant model:
  \[
    X  Y=1    N(+()/(2), Var(X)),

    X  Y=0    N(-()/(2), Var(X)),
  \]
  with equal class priors $P(Y=1)=P(Y=0)=(1)/(2)$.
description

Under (A2), $Y$ is *not* a deterministic function of $X$: the outcome depends on many factors beyond the single observed KPI difference, so $H(Y\mid X)>0$. The Gaussian discriminant model is the natural linear classifier for normally distributed features and is consistent with (A1) when the within-class variance equals the marginal $\Var(X)$.

**Remark.** Assumption (A1) is empirically reasonable for the present data: the per-match paired difference series $X=X_A-X_B$ in professional rugby and football are approximately normal (mean Shapiro--Wilk $W$ of $0.94$--$0.95$, near-zero skewness), consistent with the central-limit behaviour of paired differences even where the individual team series are mildly skewed (Supplementary (sec:si_normality)). Note that (A1) is required only for the information content derivation; the PEF formula itself ((eq:pef)) is distribution-free. Assumption (A2) is an additional approximation for the predictive setting and is likewise not required for the PEF formula.

### Derivation

Under (A1) and (A2), predictive information is quantified as the mutual information between the relative feature $X$ and the outcome $Y$. The mutual information [shannon1948,cover2006] between $X$ and $Y$ is

$$

  I(X;Y) = H(Y) - H(Y\mid X).

$$

 Here $I(X;Y)$ is the mutual information (in bits) between the relative feature $X$ and the binary outcome $Y$; $H(Y)$ is the Shannon entropy of $Y$; and $H(Y\mid X)=E_X[H(Y\mid X=x)]$ is the conditional entropy. For equiprobable outcomes, $H(Y)=1$ bit. Under (A2), the posterior probability of winning given the observed KPI difference is
\[
  P(Y=1 X=x) = (xsqrt(Var(X))),
\]
where $\Phi$ is the standard normal CDF. The Bayes error rate is accordingly $\Phi\bigl(-\delta/(2sqrt(\Var(X)))\bigr)$, and the expected conditional entropy evaluates to

$$

  H(Y\mid X) = H\left(\Phi\left(2sqrt(\Var(X))\right)\right),

$$

where $H(p)=-p\log_2p-(1-p)\log_2(1-p)$ is the binary entropy function. (Full derivation in (sec:appendix).) The PEF formula rearranges to $\Var(X)=\sigma^2_A(1+\kappa)/\eta$, linking variance geometry directly to $\eta$. Substituting into (eq:hygx) yields

$$

  I(X;Y) = 1 - H\left(\Phi\left(\delta2\sigma_Asqrt((1+\kappa)/\eta)\right)\right).

$$

 Here $\delta$, $\sigma_A$, $\Phi$, $H(p)$, $\kappa$, and $\eta$ retain their earlier definitions ((sec:mi_setup); (eq:pef,eq:hygx)). This is the **PEF--information content relationship**. $\eta$ and $I(X;Y)$ are functionally linked through the signal-to-noise ratio $\delta/\bigl(2\sigma_Asqrt((1+\kappa)/\eta)\bigr)$. In plain terms, $I(X;Y)$ measures how much knowing the relative KPI value $X$ reduces uncertainty about who wins: higher mutual information means the feature carries more decision-relevant signal about the outcome. (fig:info_surface) visualises the information content surface $I(X;Y)$ across the $(\kappa,\rho)$ parameter space for the nominal case $\delta/\sigma_A=1$; sensitivity of the surface to this parameter is examined in Supplementary (fig:si_info_sensitivity).

### The Efficiency--Power Tension

From (eq:mi_closed), $\eta$ enters the information content formula through the denominator $sqrt((1+\kappa)/\eta)$. Consider two effects of negative correlation ($\rho<0$):

- **Variance increases:** $\eta<1$, meaning $\Var(X)>\Var_unpaired(X)$. This harms statistical efficiency.

- **Signal may increase relative to noise:** if the mean difference $\delta$ is large relative to the amplified standard deviation, $I(X;Y)$ can still be substantial.

Predictive power depends on $I(X;Y)$, not $\eta$ alone. When $\delta$ is sufficiently large relative to the amplified standard deviation, the information content remains high despite increased variance. This accounts for cases where machine learning models benefit from relative features even when $\eta<1$.

## Sources of Correlation in Paired Comparisons

Having linked $\eta$ to predictive information, we turn to the origins of $\rho$ itself. Paired measurements acquire correlation through three generic mechanisms, each of which appears across competitive and non-competitive domains:

- **Shared exogenous factors.** Conditions common to both entities move their measurements together, inducing positive correlation. Examples include market-wide movements in finance, batch, instrument, or site effects in manufacturing and clinical measurement, and weather, venue, or officiating in sport.

- **Zero-sum interaction.** When one entity's gain is the other's loss, their measurements move oppositely, inducing negative correlation. Examples include rivals competing for a fixed market share, and head-to-head contests in which possession or territory ceded by one competitor accrues directly to the other.

- **Non-zero-sum (common-mode) constraints.** When both entities can succeed or fail together, positive correlation can arise even under competition. Examples include firms lifted or depressed by a common sector trend, and matches in which both teams perform well in open, high-tempo play.

The sign and magnitude of $\rho$ therefore reflect which mechanism dominates in a given setting. The PEF formula accommodates all correlation signs within a single expression, covering shared-factor regimes (typically $\rho>0$) and zero-sum competitive regimes (potentially $\rho<0$). The competitive sports KPIs analysed in (sec:results) provide concrete instances spanning this range, including Quadrant 4 cases in which the efficiency--power tension ((sec:eff_power_theory)) is most pronounced. In the primary sports application, each observation is a same-fixture home--away pair and each match contributes one point to the bivariate sample of size $n$; the estimated $\hat\rho$ therefore summarises cross-fixture co-movement between competitors (high home counts tending to co-occur with high or low away counts in the same fixture) rather than serial dependence of a single team's KPI across time. Estimation scope and the associated independence considerations are detailed in (sec:methods).

## Quadrant Taxonomy

Each KPI occupies a position in the $(\kappa,\rho)$ plane shaped by these mechanisms. Dividing that plane at $\kappa=1$ and $\rho=0$ yields four quadrants with distinct statistical and predictive properties ((tab:quadrants)). The same partition appears in (fig:pef_landscape,fig:info_surface), which map $\eta$ and $I(X;Y)$ respectively at nominal signal strength; the four confirmatory exemplars of (tab:exemplars) (one per quadrant, with season-to-season drift segments) are annotated on both figures. The regimes are:

**Quadrant 1 ($\kappa>1$, $\rho>0$): High efficiency, high information.** Positive correlation combined with variance asymmetry produces $\eta>1$ with high information content. Relative features outperform absolute features in this regime. Exemplified by market-adjusted returns and paired clinical trials.

**Quadrant 2 ($\kappa<1$, $\rho>0$): High efficiency, moderate information.** Positive correlation provides variance reduction even with low variance ratio, though information content is lower than Quadrant 1. Exemplified by manufacturing control charts.

**Quadrant 3 ($\kappa<1$, $\rho<0$): Low efficiency, low information.** Negative correlation with low variance asymmetry amplifies variance without commensurate information gain. Absolute features are preferred. Exemplified by high-volume invasion-game KPIs (passes, pressures, duels) and by weakly competitive or near-independent measurements.

**Quadrant 4 ($\kappa>1$, $\rho<0$): Low efficiency, variable information.** This is where the efficiency--power tension is most pronounced. $\eta<1$ indicates statistical harm, yet information content may remain substantial when $\delta$ is large. The decision to relativise requires explicit analysis of both $\eta$ and $I(X;Y)$. Exemplified by asymmetric head-to-head pairings ($\kappa>1$ with $\rho<0$), including some sports KPIs and competitive business comparisons.

## Signal Strength and the Limits of $\eta$
eta as a Predictor

Quadrant position fixes the directional regime; signal strength fixes the magnitude of predictive gain within that regime. The PEF--information content relationship ((eq:mi_closed)) shows that $\eta$ is not the sole determinant of predictive gain. The mutual information $I(X;Y)$ depends on $\eta$ through the denominator $sqrt((1+\kappa)/\eta)$, but also on the signal-to-noise ratio

$$

  \delta\sigma_A = \frac\mu_A - \mu_B\sigma_A,

$$

the standardised mean difference between the two entities. Two KPIs with identical $(\kappa,\rho)$ positions, and therefore identical $\eta$, will yield different information content if their signal strengths differ.

This has a practical consequence: $\eta$ alone does not determine ML gain. $\eta$ encodes the $(\kappa,\rho)$ position and identifies the quadrant regime, but two KPIs in the same quadrant will yield different ML outcomes if their signal strengths differ. The appropriate diagnostic is therefore the $(\kappa,\rho,\delta/\sigma_A)$ triple: quadrant for the directional prediction, $\delta/\sigma_A$ estimated from data for the magnitude. Supplementary (fig:si_iso_eta_I) shows how iso-$\eta$ and iso-$I(X;Y)$ contours diverge once $\delta/\sigma_A$ varies.

The practical implication is that the four-quadrant taxonomy and the $I(X;Y)$ formula together constitute the appropriate predictive tool, with $\delta/\sigma_A$ estimated from data. (sec:exemplars) illustrates this with four quadrant exemplars spanning the empirical range of $(\kappa,\rho,\delta/\sigma_A)$ values.

## Cross-Domain Connections

The quadrant logic applies uniformly across fields. (tab:cross_domain) situates familiar methods on the $(\kappa,\rho)$ plane.

| table[t]

  llll@

    **Field** | **Method** | **Correlation source** | **Typical PEF regime** |
| --- | --- | --- | --- |
| Statistics | Paired $t$-test | Repeated measures | $\eta=1/(1-\rho)$ when $\kappa=1$ |
| Finance | Market-adjusted returns | Market factors | Q1: $\eta>1$, high $\rho$ |
| Healthcare | Paired clinical trials | Temporal/biological | Q1--Q2: $\eta\gg 1$ |
| Manufacturing | Control charts | Process dynamics | Q2: $\eta>1$, moderate $\rho$ |
| Sports | Relative metrics | Environmental/competitive | Q3-dominant; Q4 when $\kappa>1$ |

*Cross-domain mapping of familiar methods to typical PEF regimes.*

When two domains share similar $(\kappa,\rho)$ values, techniques from one may transfer to the other, for example, methods from healthcare (high-$\rho$ settings) to manufacturing contexts with similar correlation structures.
