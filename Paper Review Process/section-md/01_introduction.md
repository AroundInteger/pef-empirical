# Introduction

> **Review copy** from LaTeX. Source of truth: `sections/introduction.tex`.
> Propose edits in chat (or annotate this file); agreed changes go into the `.tex`.
> Math rendering is approximate.

---

# Introduction

## Why Relativisation? From Cross-Domain Practice to Sport

Across quantitative disciplines, a recurring analysis decision is whether to represent a measurement in absolute terms or relative to a comparator. In many cases, the relative quantity is preferred because it cancels a shared baseline and isolates the signal of interest. For example, in finance, asset returns are routinely benchmarked against the market [sharpe1966,fama1970]; in clinical medicine, pulse pressure, the difference between systolic and diastolic blood pressure, is an established relative biomarker [franklin1999,blacher1999]; and in industrial process control, statistical control charts track deviations from a reference rather than raw values [montgomery2012]. Management research more broadly emphasises that competitive benchmarking shifts attention from absolute totals to relative performance [keiningham2015].

The same choice arises especially sharply in competitive sport: whether to represent a team's performance in absolute terms or relative to the opponent. In rugby union and association football, several studies contrast absolute and relative team-level formulations of key performance indicators (KPIs) for match-outcome prediction [bennett2019descriptive,bennett2021predicting,scott2023urc,scott2023womens]. These studies typically assess KPIs by building match-outcome classifiers, most commonly logistic regression, from team-level features, evaluated by cross-validated predictive accuracy [dixon1997,berrar2019]. Quantitative international sports ratings illustrate the same long-standing reliance on structured comparison under common rules [stefani2011]. The reported results run in both directions: relative formulations improve accuracy in the United Rugby Championship [scott2023urc] but show no significant improvement over absolute features in international women's rugby [scott2023womens]. Those studies treat the choice as help versus no help. They do not give a regime in which relativisation should be avoided. The central question of this paper is therefore simple to state: *why does relativisation of some KPIs improve outcome prediction, while for others it is predictively harmful?*

Underlying this question is an apparent paradox. The baseline-cancellation rationale above presumes that differencing reduces noise. Yet when two competitors are negatively associated, so that one performs well precisely when the other performs poorly, the difference can have *larger* variance than either raw measurement. Classical reasoning treats that larger variance as harmful to inference. Practitioners nonetheless observe that relative features can predict better in exactly these competitive settings. How can a feature with higher variance carry more predictive information? Answering this requires returning to the statistical principle that underlies relativisation.

## Fisher's Paired Efficiency

The principle that correlated measurements yield more efficient inference than independent samples has been recognised since Fisher's work on experimental design [fisher1935]. For two correlated measurements $X_A$ and $X_B$ with equal variances $\sigma^2$ and correlation $\rho$, the variance of their difference is

$$

  \Var(X_A - X_B) = 2\sigma^2(1-\rho).

$$

Compared to independent measurements (variance $2\sigma^2$), the efficiency gain is $1/(1-\rho)$. This result, which is purely algebraic and requires no distributional assumptions beyond finite second moments, underpins the paired $t$-test [student1908] and decades of experimental design across medicine, psychology, and agriculture [fisher1935].

This classical formula, however, rests on a single structural assumption: equal variances. The competitive data that motivate our question routinely violate it [welch1947]. Examining KPIs from professional rugby union and football, we observe two features Fisher's equal-variance relation cannot represent. First, for each KPI the per-match paired-difference series $X_A,i-X_B,i$ is a sampled distribution across fixtures; Shapiro--Wilk tests indicate that, to a good first approximation, these differences are compatible with normality (mean $W$ of $0.98$ with near-zero skewness, $≈ 0.03$--$0.07$), even where the individual team series are mildly right-skewed, the behaviour expected of paired differences. Second, the two teams' per-match series rarely share a common variance (typical $\hat\kappa$ roughly $1.0$--$2.5$; (tab:validation)), and their cross-fixture correlation takes both positive values (from shared environmental conditions) and negative values (from competitive dynamics) depending on the KPI. Variance asymmetry and signed correlation are therefore the norm rather than the exception, and Fisher's equal-variance formula cannot by itself answer when relativisation helps.

## The Paired Efficiency Factor

These observations, approximately normal differences with non-zero means and unequal second moments, motivate a formula parameterised jointly by the variance ratio and the correlation. We allow unequal variances $\sigma^2_A$ and $\sigma^2_B$ with variance ratio $\kappa=\sigma^2_B/\sigma^2_A$. The variance of the difference in this case then becomes

$$

  \Var(X_A - X_B) = \sigma^2_A\bigl(1 + \kappa - 2sqrt(\kappa) \rho\bigr).

$$

Defining the Paired Efficiency Factor as the ratio of unpaired to paired variance, similar to the Fisher efficiency gain relation above, we have:

$$

  \eta = 1+1+\kappa-2sqrt(\kappa) \rho.

$$

 where $\eta>1$ indicates that pairing reduces variance. Across sports KPIs, $\kappa$ spans approximately $1.0$--$2.5$, with a broader empirical range in wider scientific domains ((tab:validation)). Specifically, $\rho=\Corr(X_A,X_B)$ is the Pearson correlation between the home and away KPI values *across fixtures*: for each match $i$, $X_A,i$ and $X_B,i$ are the two teams' counts from the same game, and $\hat\rho$ is computed from the $n$ such paired observations ((sec:methods)). The magnitude of $\rho$ ranges from approximately $-0.3$ to $+0.4$ in competitive sports and frequently exceeds $0.5$ in repeat-measurement clinical designs ((tab:validation)).

Like the classical result, this formula is purely algebraic, and it recovers Fisher's equal-variance ($\kappa=1$) as a special case. Thus, $\eta$  depends jointly on correlation strength and variance asymmetry, a dependence the classical formula cannot express. Under bivariate normality and equal group sizes, the PEF equals the Pitman asymptotic relative efficiency of the paired t‑test versus the independent two-sample t‑test, confirming the variance-ratio formula (see Supplementary (sec:pitman) and [lehmann1999] for the general framework).

## Resolving the Tension: Efficiency versus Information

From (eq:pef) it is clear that negative correlation yields $\eta<1$: pairing increases the variance of the difference relative to independent measurement, which classical reasoning treats as harmful. Yet match-outcome models routinely find that relative features ($X_A-X_B$) outperform absolute features ($X_A$, $X_B$) in precisely these competitive settings [bennett2019descriptive,scott2023urc]. The resolution requires distinguishing between **statistical efficiency**, how precisely parameters can be estimated, and **information content**, how much a feature reduces uncertainty about outcomes. We show these quantities are functionally related but can diverge, and we derive the conditions under which they do.

Resolving this tension carries a concrete practical payoff. Feature engineering, the choice between absolute and relative features, is currently governed largely by trial-and-error cross-validation. When $\kappa$, $\rho$, and the signal strength $\delta/\sigma_A$ can be estimated reliably, they provide a principled first-pass diagnostic for that choice, supplementing rather than replacing cross-validated checks. For the contested question of how predictable competitive outcomes really are, the framework supplies a per-feature account of both directions. It explains why a relative measure can carry more decision-relevant information than its absolute counterpart. It also identifies when the difference is the worse classifier. That account is a potential foundation on which multi-feature predictability studies can build.

## Scope and Contributions

The primary empirical analysis draws on KPI data from professional rugby union and football, where head-to-head matchups produce natural pairing across a range of $(\kappa,\rho)$ values, including negative within-match correlation. Performance-indicator construction in invasion games is well established [hughes2002], and modern team-sports analytics emphasises spatiotemporal and match-context structure [bornn2021]. We supplement this with validation data from healthcare (NHANES oscillometric systolic and diastolic readings on the same visit), transcriptomics (GEO GSE47462), finance, and manufacturing (real CNC process telemetry) to assess generalisability. Supporting-domain summaries appear in (tab:validation). The Supplementary Information records the mathematical derivations, the sports KPI landscape, and the simulation diagnostics.

This paper makes the following contributions:

- **PEF generalisation.** We extend Fisher's paired efficiency to unequal variances through a distribution-free formula ((eq:pef)).

- **Information content relationship.** Under bivariate normality, we derive a closed-form relationship between $\eta$ and the mutual information $I(X;Y)$ [cover2006,guyon2003], clarifying the efficiency--power tension.

- **Quadrant taxonomy.** We partition the $(\kappa,\rho)$ parameter space into four regimes with distinct statistical and predictive properties, each with corresponding feature engineering guidance.

- **Mechanistic confirmation.** We confirm the predicted mechanism in two stages. An idealised probit simulation under assumptions (A1)--(A2) reproduces the $\eta$--$I(X;Y)$ mapping and the efficiency--power tension in a controlled setting ((sec:results); Supplementary (sec:si_probit)). Four single-KPI exemplars, one per quadrant, then test the sign of $\DeltaML$ in real data when signal strength ($\delta/\sigma_A$) is held comparable ((fig:pef_ml,tab:exemplars)). The exemplars confirm help and harm at matched signal. They are not a claim of large Quadrant 4 predictive gain. Multi-KPI feature interactions are identified as a direct extension ((sec:discussion)).

- **Cross-domain applicability.** We show that market-adjusted returns, paired clinical designs, manufacturing control charts, and relative sports metrics are all instances of correlation-based variance reduction, differing only in their $(\kappa,\rho)$ values. Supporting validation across four additional domains is consistent with the framework's generalisability.

## Organisation

(sec:theory) develops the theoretical framework: the PEF formula, the PEF--information content relationship, and boundary analysis. (sec:methods) describes the validation methodology. (sec:results) presents results. (sec:discussion) discusses implications and limitations. Mathematical derivations with full intermediate steps appear in Supplementary (sec:si_maths).
