# Tables and Figures

> **Review copy** from LaTeX. Source of truth: `sections/tables_and_figures.tex`.
> Propose edits in chat (or annotate this file); agreed changes go into the `.tex`.
> Math rendering is approximate.

---

| table[p]

  llccccl@

    **Domain** | **Tier** | **$n$ studies** | **Mean $\eta$** | **SD** | **Efficiency** | **Data source** |
| --- | --- | --- | --- | --- | --- | --- |
| Sports (Rugby) | Primary | 24 | 1.313 | 0.996 | 54.2\% | URC |
| Sports (Football) | Primary | 89 | 0.884 | 0.182 | 16.9\% | English Championship |
| Healthcare | Supporting | $1^\dagger$ | 2.533 | 0.04$^\dagger$ | 100.0\% | [nhanes2017pbxo] |
| Clinical Genomics | Supporting | $3500^\ddagger$ | 2.696 | 1.601 | 97.0\% | [brunner2014earlybreast,geoGSE47462] |
| Finance | Supporting | 18 | 3.129 | 1.108 | 100.0\% | Yahoo Finance |
| Manufacturing | Supporting | $16384^\S$ | 1.382 | 1.401 | 50.5\% | [openml752bosch] |
|

  minipage0.95
    *Note:* Landscape efficiency rate: proportion of units with $\hat\eta>1$ ((sec:outcome_defs)). $^\dagger$Paired NHANES oscillometric records (participants; systolic vs diastolic, first reading); SD column gives a bootstrap standard error for the pooled $\eta$ (not a cross-unit sample SD). $^\ddagger$Genes in the ranked subset of the GSE47462 paired design (see Methods). $^\S$Axis-wise paired process features per Bosch production cycle (OpenML 752); SD is the sample SD of $\eta$ across pairings. Primary empirical tier: landscape characterisation in Figures (fig:pef_landscape)--(fig:pef_ml) and Supplementary (fig:si_kpi_labelled,fig:si_ipred_vs_dml); mechanistic confirmation via quadrant exemplars ((tab:exemplars)). Supporting tier: parameter estimation and PEF calculation summarised here and in (sec:results); mean $(\kappa,\rho)$ overlay in (fig:pef_landscape).
  minipage |

*Validation results across domains.*

| table[p]

  lllll@

    **Q** | **Parameters** | $\eta$ | $I(X;Y)$ | **Recommendation** |
| --- | --- | --- | --- | --- |
| Q1 | $\kappa>1$, $\rho>0$ | $>1$ | High | Use relative features |
| Q2 | $\kappa<1$, $\rho>0$ | $>1$ | Moderate | Use relative features |
| Q3 | $\kappa<1$, $\rho<0$ | $<1$ | Low | Prefer absolute features |
| Q4 | $\kappa>1$, $\rho<0$ | $<1$ | Variable | Analyse both $\eta$ and $I(X;Y)$ |
|
  minipage0.95
    **Examples:** Q1, market-adjusted returns, paired clinical trials; Q2, control charts, quality metrics; Q3, high-volume anti-correlated sports KPIs; Q4, asymmetric head-to-head comparisons (some sports KPIs; competitive business).
  minipage |

*Quadrant taxonomy and practical guidance.*

| table[p]

  lccc@

    **Condition** | $\eta$ | $I(X;Y)$ | **Interpretation** |
| --- | --- | --- | --- |
| $\kappa=1$, $\rho=0$ (Fisher) | 1.000 | 0.056 | Baseline: independent, equal variances |
| $\kappa\to 0$ | 1.000 | 0.108 | Entity B negligible |
| $\kappa\to\infty$ | 1.000 | $\to 0$ | Signal drowned in noise |
| $\rho\to -1$ ($\kappa=1$) | 0.500 | 0.028 | Maximum variance amplification |
| $\rho\to +1$ ($\kappa=1$) | $\to\infty$ | $\to 1$ | Perfect cancellation of noise |
|
  minipage0.95
    *Note:* $I(X;Y)$ computed with $\delta/\sigma_A=1$.
  minipage |

*Boundary behaviour (illustrative).*

> **[Figure]** PEF landscape: $\eta$ as a function of $\rho$ and $\kappa$, with four quadrants labelled.
    Background shading uses a $\log_10

> **[Figure]** Information-theoretic surface $I(X;Y)$ as a function of $$ and $$
    (\crefeq:mi_closed

> **[Figure]** Observed machine learning improvement $mathrmML
