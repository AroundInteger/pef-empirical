# Methods

> **Review copy** from LaTeX. Source of truth: `sections/methodology.tex`.
> Propose edits in chat (or annotate this file); agreed changes go into the `.tex`.
> Math rendering is approximate.

---

# Methodology

## Study Design

The validation proceeds in three tiers of increasing empirical complexity. The first tier is a **theoretical/numerical foundation**: an idealised probit simulation ((sec:results)) that generates bivariate-normal $(X_A,X_B)$ on a $(\kappa,\rho,\delta/\sigma_A)$ grid under assumptions (A1)--(A2) and confirms the closed-form mapping from PEF to information content ((eq:mi_closed)) in a controlled setting where those assumptions hold by construction (full model specification and validation in Supplementary (sec:si_probit)). Because the sports KPIs analysed here are well approximated by bivariate normality (normality testing, (sec:qc)), this idealisation provides an informative reference for the empirical data rather than a disconnected model. The second tier is the **primary empirical analysis** on professional sports KPIs. Here the full KPI inventory ($86$ studies: $22$ rugby, $64$ football) provides a *landscape characterisation* of where real metrics sit on the $(\kappa,\rho)$ plane (Supplementary (fig:si_kpi_labelled,fig:si_ipred_vs_dml)), whilst *mechanistic confirmation* rests on four single-KPI exemplars, one per quadrant, with comparable signal strength ((fig:pef_ml,sec:exemplars,tab:exemplars)). The third tier is **supporting validation** on published data from four additional domains, assessing generalisability. Across these tiers the objectives were to: (1) validate the PEF--information content relationship ((eq:mi_closed)), (2) confirm quadrant-specific predictions and the role of signal strength $\delta/\sigma_A$ as a moderator, (3) characterise the efficiency--power tension in Quadrant 4, and (4) test cross-domain applicability.

## Primary Data: Sports KPIs

The primary analysis uses match-level KPI data from two professional leagues:

- **Rugby union.** United Rugby Championship (URC): $n=283$ games pooled across seasons 23/24 and 24/25 ($m=16$ teams, double round-robin). KPIs include rucks won, kick metres, kicks from hand, carries, penalties conceded, turnovers won, and others (Supplementary (fig:si_kpi_labelled)).

- **Football.** English Championship: $n=1114$ games pooled across the same two seasons ($m=24$ teams, double round-robin). KPIs include duels, pressures, interceptions, fouls, and shot volume (Supplementary (fig:si_kpi_labelled)). Association-football score and outcome modelling has a long econometric lineage [dixon1997,boulier2003], with contemporary machine-learning approaches incorporating domain knowledge [berrar2019].

Head-to-head matchups provide natural pairing through shared environmental conditions (weather, venue, officiating), and KPI variability across matches is well documented in professional sport [malcata2014]. Those rugby union lines of work motivate treating head-to-head KPIs as a primary testbed for the present framework [bennett2019descriptive,bennett2021predicting,mosey2020,scott2023urc,scott2023womens]. The sports data are well suited to testing the framework because the KPIs span a range of correlation values (including negative correlation from competitive dynamics) and variance ratios, populating all four quadrants.  To assess temporal stability, we compute $(\kappa,\rho)$ for each KPI in both seasons separately; (fig:pef_landscape,fig:info_surface) show the four confirmatory exemplars of (tab:exemplars) with season 23/24--24/25 drift segments, whilst Supplementary (fig:si_kpi_labelled) visualises the full KPI cloud.

## Supporting Data: Cross-Domain Validation

To assess generalisability beyond sports, we applied the framework to four additional domains. Domain-level summaries are reported in (tab:validation); mean $(\kappa,\rho)$ positions for the supporting tier appear as overlay markers in (fig:pef_landscape).

**Healthcare.** Paired systolic (BPXOSY1) and diastolic (BPXODI1) blood pressure readings from the same oscillometric measurement event, drawn from the NHANES 2017 public-use examination file `P\_BPXO` [nhanes2017pbxo]. Each participant contributes one (systolic, diastolic) pair; pulse pressure $PP=SBP-DBP$ is the relative feature, an established cardiovascular risk biomarker [franklin1999,blacher1999]. Observations with $SBP\leDBP$ were excluded as physiologically implausible ($N=10,352$ retained).

**Clinical Genomics.** Normalised RNA-seq gene-level expression from GEO series GSE47462: patient-matched normal breast tissue vs early neoplasia [geoGSE47462,brunner2014earlybreast]. Pairs were defined by shared subject identifiers in the series sample annotations; per-gene PEF summaries aggregate correlation and variance-ratio structure across those paired specimens.

**Finance.** Daily log returns for $18$ S\&P 100 constituents relativised to the S\&P 500 over the pinned window 2020--2023, obtained from Yahoo Finance. Market-adjusted returns provide the pairing [sharpe1966,sharpe1994,fama1970,carhart1997,fama1993].

**Manufacturing.** Real industrial process telemetry from the Bosch production-line CNC dataset on OpenML (dataset id 752) [openml752bosch]. For each production cycle (one row), paired vectors are formed axis-wise: angular position $\theta_i$ versus angular velocity $\dot\theta_i$ ($i=1,…,6$) and torque $\tau_j$ versus displacement metric $dm_j$ ($j=1,…,5$), yielding two PEF estimates per cycle. Summaries aggregate $N=16,384$ such pairings (8,192 cycles $×$ two pairing types). The NASA C-MAPSS turbofan simulation [saxena2008] was used in earlier drafts but is not the default supporting manufacturing source here because it is simulated rather than observational plant data.

## Parameter Estimation

For each dataset, the variance ratio and correlation were estimated using standard sample estimators

$$

  \kappa = \fracs^2_Bs^2_A,
  \quad
  \rho =
  \frac\sum_i=1^n(X_A,i-X_A)(X_B,i-X_B)
       \sqrt\sum_i=1^n(X_A,i-X_A)^2
              \sum_i=1^n(X_B,i-X_B)^2.

$$

Under bivariate normality (Assumption (A1)), these are maximum likelihood estimators. PEF was computed by substituting into (eq:pef). For sports KPIs, index $i$ runs over fixtures; $X_A,i$ and $X_B,i$ denote the home and away KPI counts from game $i$, so $(\hat\kappa,\hat\rho)$ characterise the cross-fixture distribution of those paired observations rather than correlation within a single match or serial correlation of one team's time series.

## Empirical Units and Outcome Definitions

Each sports KPI constitutes one *study*: match-level home and away measurements pooled across seasons 23/24 and 24/25, yielding a single $(\hat\kappa,\hat\rho,\hat\eta)$ estimate per KPI. The inventory comprises $86$ studies ($22$ rugby union, $64$ football). Score, scoring events, cards, expected-goals and on-ball-value models, and shots on target are omitted, because those quantities are circular with the binary match outcome. Action KPIs (passes, carries, shot volume, tackles) are retained. Per-KPI estimates, season-to-season positions, and machine-learning outcomes for this inventory are reported in Supplementary (sec:si_landscape) (Figures (fig:si_kpi_labelled,fig:si_ipred_vs_dml) and the accompanying table).

Two reporting roles are distinguished. **Landscape characterisation** uses the full inventory to map where invasion-game KPIs populate the $(\kappa,\rho)$ plane, to summarise domain-level distributions, and to provide context for Figures (fig:pef_landscape)--(fig:info_surface). These aggregates are descriptive: the inventory is Q3-heavy ($64.0\%$ of KPIs), so pooled statistics primarily reflect the dominant negative-correlation regime rather than a balanced sample of the quadrant space. **Mechanistic confirmation** uses the idealised probit simulation (Tier 1) together with four confirmatory exemplars, one per quadrant ((fig:pef_ml,tab:exemplars)), at broadly comparable $\delta/\sigma_A$ (range $0.16$--$0.32$). The lines $\kappa=1$ and $\rho=0$ define a coarse partition only: $\eta$ and $I(X;Y)$ are nonlinear in $(\kappa,\rho,\delta/\sigma_A)$, so KPIs within a quadrant can differ in $\DeltaML$. Geometric identities of $\eta$ are developed in a companion paper [brownPEFmath]. The exemplars are fixed anchor points at distinct $(\hat\kappa,\hat\rho)$ positions that test directional predictions locally, not linear representatives of whole-quadrant behaviour. One action KPI was taken from each quadrant, omitting quantities circular with the match outcome, with $\delta/\sigma_A$ held in a common band ($0.16$--$0.32$). The Q4 row sits on the $\kappa=1$ boundary and is therefore a limited-signal boundary case, not a strong-$\kappa$ tension demonstration. Supplementary (tab:si_quad_landscape) summarises the remaining inventory by quadrant.

Where domain summaries report a **landscape efficiency rate**, this is the proportion of KPI studies with $\hat\eta>1$ (pairing reduces variance relative to independent measurement). This is a descriptive summary of the $(\kappa,\rho)$ inventory, not a hypothesis-test outcome; quadrant-level aggregates appear in Supplementary (tab:si_quad_landscape).

## Machine Learning Validation

To assess the relationship between quadrant position and ML performance, logistic regression was fitted with five-fold cross-validation [kohavi1995], implemented in MATLAB (`glmfit`, Statistics and Machine Learning Toolbox). The signed change $\DeltaML=100(acc_rel-acc_abs)/acc_abs$ compares the relative feature $X_A-X_B$ with the absolute feature $X_A$ only. A two-feature absolute model $(X_A,X_B)$ would be a multivariate comparator and is outside the univariate scope of this paper. Positive $\DeltaML$ means relativisation improves classification. Negative $\DeltaML$ means it is predictively harmful: the difference is a worse univariate predictor than the raw KPI. Signal strength was estimated as $\delta/\sigma_A = (X_A-X_B)/s_A$ ((eq:delta_ratio)).

**Team-blocked cross-validation.** Each match is one observation, but teams recur across fixtures, so random match-level folds can place the same side in both training and test sets and inflate accuracy. We therefore partition teams (not matches) into five disjoint sets with a fixed random seed. A match is assigned to the fold of its home team; for fold $f$, the test set comprises all matches whose home team belongs to set $f$, and the training set comprises the remaining matches. No home team therefore appears in both partitions within a fold. Away opponents may appear in training when facing a held-out home side, a mild, standard form of leakage in league settings that still removes the dominant source of dependence (repeated home-side observations). The same fold assignment is used for absolute and relative features so that $\DeltaML$ compares like with like. Landscape $\DeltaML$ values characterise the inventory; mechanistic claims rest on the quadrant exemplars at comparable $\delta/\sigma_A$ ((sec:exemplars)).

## Inference and Quality Control

The 86-KPI landscape is descriptive. It is not a family-wise hypothesis battery, so Bonferroni, FDR, and Holm corrections are not applied. Uncertainty for $(\hat\kappa,\hat\rho,\hat\eta)$ uses a team-cluster bootstrap: teams are resampled with replacement and all home-side matches for each drawn team are retained [efron1979]. Supplementary (sec:si_qc) reports the Quadrant 4 check ($B=300$). Predictive comparisons use team-blocked $\DeltaML$ ((sec:ml_cv)). The companion effect size is the standardised mean difference $\delta/\sigma_A$ ((eq:delta_ratio)), not Cohen's $d$ or partial $\eta^2$.

Paired-difference series were checked with the Shapiro--Wilk test. Mean $W$ was $0.977$ in rugby and $0.986$ in football, with mean skewness $0.028$ and $0.069$ (Supplementary (sec:si_normality)). Analysis code was version-controlled. The canonical run is `run\_paper\_pipeline.m` in MATLAB R2025b with the Statistics and Machine Learning Toolbox ((sec:data_availability)).

## Sports Data: Independence Considerations

The sports datasets present a hierarchical structure requiring careful treatment. Each team appears in multiple games, inducing correlation across observations involving the same team through latent team ability $\theta_j$:

$$

  X_j,i = \theta_j + \epsilon_j,i.

$$

We model game-level observations using a bivariate normal approximation

$$

  \bigl(X_A(i), X_B(i)\bigr) \sim N(\mu,\Sigma),
  \quad i=1,…,n,

$$

treating games as conditionally independent. Three considerations justify this approximation for PEF analysis:

- **Target of inference.** PEF focuses on cross-fixture (same-occasion) correlation $\rho=\Corr(X_A,i,X_B,i)$ summarised over fixtures $i=1,…,n$, capturing shared environmental factors and competitive dynamics on each game occasion rather than serial dependence of a single team across games. Team quality primarily affects mean structure rather than the correlation structure driving PEF.

- **Variance estimation.** The total variance $\sigma^2_A=\Var(\theta_j)+\Var(\epsilon_j,i)$ correctly reflects the observable variance relevant to feature engineering decisions.

- **Robustness checks.** For $(\hat\kappa,\hat\rho,\hat\eta)$, bootstrap confidence intervals resample *teams* with replacement and retain all home-side matches for each drawn team (cluster bootstrap on the home-team index; Supplementary (sec:si_qc)). For predictive validation, team-blocked cross-validation ((sec:ml_cv)) prevents home teams from appearing in both training and test folds. Together, these checks address the main dependence induced by recurring teams without altering the distribution-free PEF formula itself.

This parallels established practice in sports analytics [benaim2006,owen2014] and panel data econometrics [cameron2015,wooldridge2010].
