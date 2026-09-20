# Discussion

> **Review copy** from LaTeX. Source of truth: `sections/discussion.tex`.
> Propose edits in chat (or annotate this file); agreed changes go into the `.tex`.
> Math rendering is approximate.

---

# Discussion

This study set out to establish, at the level of individual features, when relativisation improves outcome prediction and when it is predictively harmful. The work is organised around four objectives ((sec:methods)). Each is addressed by the results. First, the PEF--information content relationship ((eq:mi_closed)) was confirmed on the idealised probit grid under (A1)--(A2), where $\eta$ and $I(X;Y)$ are strongly correlated at fixed signal strength. Second, the quadrant exemplars confirmed that the $(\kappa,\rho)$ taxonomy correctly predicts the *sign* of $\DeltaML$ once $\delta/\sigma_A$ is held comparable. Q1 and Q2 improve; Q3 is harmful; the Q4 row is near zero at that matched signal. It is not offered as a large relative-feature gain. Third, the efficiency--power tension was characterised empirically ((sec:eff_power)). Relative features can improve prediction despite $\eta<1$ in the idealised grid and in parts of the sports landscape. Fourth, the supporting domains show that similar $(\kappa,\rho)$ geometry appears in healthcare, clinical genomics, finance, and manufacturing, without repeating the sports machine-learning protocol.

The central consequence is that the absolute-versus-relative feature decision, often settled by trial-and-error cross-validation, can be informed by three estimable quantities $(\kappa,\rho,\delta/\sigma_A)$: the framework offers a structured diagnostic before model fitting, with directional predictions confirmed at comparable signal strength in the quadrant exemplars ((tab:exemplars)). We develop the theoretical implications, this practical payoff, and the limitations of these findings in turn.

## Theoretical Implications

Statistical efficiency ($\eta$) and predictive power ($I(X;Y)$), though functionally related through (eq:mi_closed), measure distinct aspects of paired measurements. Classical variance-reduction reasoning, which advises against relativisation when $\eta<1$, addresses only one dimension of feature engineering decisions because it does not account for information content. Given estimates of $\kappa$, $\rho$, and $\delta/\sigma_A$, $\eta$ and $I(X;Y)$ supply a prior for the feature choice. That prior is then checked with team-blocked cross-validation.

The distribution-free PEF formula ((eq:pef)) holds for any paired measurements with finite second moments. The information content relationship ((eq:mi_closed)) requires the stronger assumption of bivariate normality (A1). This distinction is important: the efficiency characterisation is broadly applicable, whilst the predictive-power analysis is contingent on distributional form.

This analysis deliberately operates at the level of individual KPIs. At the single-KPI level, the mechanism is established: $\eta$ and $I(X;Y)$ together identify the theoretical regime, and the quadrant exemplars confirm that directional predictions hold in practice at specific $(\hat\kappa,\hat\rho)$ anchor points ((sec:exemplars)). Quadrant membership is a coarse guide. The PEF surface is nonlinear in $(\kappa,\rho)$ and $\delta/\sigma_A$, so two KPIs in the same quadrant need not share the same $\DeltaML$. The confirmatory table tests local agreement with the taxonomy, not a linear quadrant effect. This single-KPI foundation is a prerequisite for any principled extension to the multivariate case. It also supplies a diagnostic for studies of match-level predictability: estimate $(\kappa,\rho)$ for each candidate KPI, classify its quadrant, then check the signed $\DeltaML$ under team-blocked cross-validation.

The prior studies that motivated this work [bennett2019descriptive,bennett2021predicting,mosey2020,scott2023urc,scott2023womens] used multi-KPI models, where inter-feature correlations and joint classification boundaries introduce additional structure not captured by univariate PEF. Reported $\DeltaML$ values here are therefore conservative: they benchmark one paired feature at a time under team-blocked cross-validation ((sec:ml_cv)), not a joint classifier, and the exemplars test directional agreement with the taxonomy rather than maximising match-outcome accuracy. How per-feature gains compound, cancel, or interact when multiple relativised KPIs are combined in a single classifier remains an open question. Multivariate extensions that characterise joint efficiency across feature sets are a natural next step, building on the per-KPI regime characterisation established here.

## Cross-Domain Unification

Practices that appear domain-specific, market-adjusted returns, paired clinical designs, control charts, relative sports metrics, can be understood as instances of correlation-based variance reduction with different $(\kappa,\rho)$ values. Where two domains share similar parameter structures, methods from one may apply to the other. Analogous relativisation appears in education, where value-added formulations benchmark teacher performance against comparable cohorts [hanushek2010].

The framework also accounts for why certain practices succeed in some domains but not others. Healthcare (Quadrant 2, high $\rho$) consistently benefits from pairing. Sports KPIs span all four quadrants, with the balance between regimes depending on the specific KPI type: kicking and set-piece KPIs tend toward positive correlation (Quadrant 1--2), whilst defensive and discipline KPIs sit predominantly in Quadrants 3--4, requiring explicit analysis of both $\eta$ and $I(X;Y)$ to guide relativisation decisions.

## Practical Guidance

The framework suggests the following procedure:

- Estimate $\kappa$ and $\rho$ from available data.

- Compute $\eta$ using (eq:pef).

- Identify the quadrant from (tab:quadrants).

- For Quadrants 1--2, use relative features (they improve both statistical efficiency and information content).

- For Quadrant 3, prefer absolute features: relativisation is predictively harmful.

- For Quadrant 4, estimate $\delta/\sigma_A$ from the same sample and confirm the sign of $\DeltaML$ under team-blocked cross-validation. The (A1)--(A2) formula for $I(X;Y)$ is a prior for whether relativisation could help, not a substitute for that check.

The sporting studies that motivate this work report improvement or its absence [bennett2019descriptive,mosey2020,scott2023urc,scott2023womens,brito2026]. They do not classify a regime in which relativisation should be avoided. Possession-normalised rates are a different form of relativisation from opponent differences [sever2026]. They adjust for game state rather than pairing two teams' counts. The signed harm result fills that gap for this inventory.

This reduces blind reliance on trial-and-error cross-validation: steps 1--6 supply a transparent prior for feature strategy. That prior is then checked against predictive performance on the task at hand. An open implementation is provided (Supplementary (sec:si_practitioner); (sec:data_availability)). The wider significance is twofold. For practitioners, it structures feature engineering around estimable correlation geometry rather than an unstructured empirical sweep alone. For the research literature on the predictability of competitive outcomes, the framework offers a principled, per-feature account of which measurements carry decision-relevant information and why. Debate persists in that literature over how much of a result is skill versus chance.

## Limitations

**Distributional assumptions.** The PEF formula is distribution-free, but the information content relationship ((eq:mi_closed)) assumes bivariate normality. Whilst the central limit theorem provides some robustness, strongly skewed or multimodal distributions may require non-parametric extensions. For count-based KPIs, the transformation $Z=\log(X+1)$ can improve normality whilst preserving the $(\kappa,\rho)$ structure: across 22 rugby KPIs the rank ordering by $\rho$ was largely preserved (Spearman $r_s=0.967$) and the aggregate PEF change was not significant ($\eta_\log/\eta=1.085$, $p=0.357$; Supplementary (sec:si_qc)), though individual count-based KPIs can move substantially (rucks won). Systematic characterisation of the skewness threshold beyond which variance-stabilising transforms become necessary remains an active area of investigation.

**Stationarity.** The framework treats $\kappa$ and $\rho$ as fixed parameters, yet they may vary across time, conditions, or subpopulations. Temporal instability in correlation structure, regime changes in financial markets, and seasonal effects in sports could reduce prediction reliability if parameters are estimated from one period and applied to another. In the sports KPI inventory, per-season $(\hat\kappa,\hat\rho)$ positions and connecting segments on the PEF surface ((fig:pef_landscape,fig:info_surface); full inventory in Supplementary (fig:si_kpi_labelled)) show that most KPIs drift modestly between seasons 23/24 and 24/25, though a minority of rugby KPIs cross quadrant boundaries. Pooled two-season estimates (as in (tab:exemplars)) therefore summarise a moving target; rolling or season-specific calibration may be preferable when temporal stability is in doubt.

**Sample size requirements.** Reliable estimation of $\kappa$ and $\rho$ requires sufficient observations. The framework's mathematical correctness holds for any parameter values, but empirical estimation imposes practical constraints on minimum sample sizes.

**Binary outcomes.** The closed-form information content relationship ((eq:mi_closed)) and the sports validation protocol both target binary classification: here, predicting which team wins a head-to-head match from paired KPI features. That choice matches the probit link under (A1)--(A2) and keeps the empirical comparison across KPIs on a common scale. Generalisation to multi-class outcomes, continuous targets, and richer prediction tasks would require corresponding extensions of the information-theoretic mapping; the per-KPI $(\kappa,\rho)$ diagnostic nevertheless remains applicable wherever paired absolute and relative features can be formed.

**Strategic interactions.** In invasion-game sport, teams respond to opponents' tactics and game state, so the $(\kappa,\rho)$ structure of a KPI is partly an equilibrium property of competition rather than a fixed physical law. The present analysis estimates parameters from observed match data without modelling within-game adaptation or strategic feedback. Where such dynamics are material, $(\kappa,\rho)$ should be interpreted as descriptive summaries of the data-generating process at the chosen time scale, not as invariant constants.

**Primary evidence base.** The deepest empirical work, comprising the full KPI inventory, machine-learning validation, and quadrant exemplars, rests on rugby union and football. Healthcare, clinical genomics, finance, and manufacturing provide supporting checks that the same $(\kappa,\rho)$ geometry recurs elsewhere ((tab:validation)), but without the same per-unit ML scrutiny or temporal replication. Cross-domain consistency is encouraging; domain-specific confirmation at sports-level depth remains desirable before transferring the practical guidance wholesale.

## Future Directions

The present analysis establishes the per-KPI mechanism under fixed $(\kappa,\rho)$; several extensions follow naturally from the limitations above and from the multivariate gap noted in the theoretical implications.

The information-content mapping ((eq:mi_closed)) rests on bivariate normality, whilst the efficiency formula ((eq:pef)) does not. A priority is therefore to develop *distribution-free* analogues of the predictive-power side, for example rank-based correlation measures or permutation-based inference, so that Quadrant 4 decisions can be guided without relying on Gaussian approximations when skewness or heavy tails are material (Supplementary (sec:si_qc)).

At the single-feature level, the quadrant taxonomy is validated; prior sports work that motivated this study combined many KPIs in one classifier [bennett2019descriptive,bennett2021predicting,mosey2020,scott2023urc,scott2023womens], where inter-feature correlations and joint decision boundaries are not captured by univariate $\eta$. Multivariate generalisations, such as PEF-style matrices or joint summaries of efficiency across several paired features, would clarify how per-KPI relativisation gains compound, cancel, or interact when features enter a model together.

A complementary extension is *within-quadrant landscape design*. The confirmatory tier uses one anchor KPI per quadrant at comparable $\delta/\sigma_A$; a more rigorous test would stratify explicitly across high and low $\kappa$ and high and low $|\rho|$ *within* each quadrant. For example, one could contrast $(\kappa\ll 1, |\rho|≈ 0)$ with $(\kappa\gg 1, |\rho|≈ 0.8)$ in Q3, with signal strength held fixed where possible. That design would ask whether $\DeltaML$ tracks local iso-$\eta$ or iso-$I(X;Y)$ structure rather than quadrant labels alone. The full $86$-KPI inventory already populates the $(\kappa,\rho)$ plane; what remains is pre-specified corner sampling and within-quadrant directional hypotheses.

Parameter drift between seasons (Supplementary (fig:si_kpi_labelled)) also motivates *time-varying* formulations: rolling-window or state-space estimates of $(\kappa,\rho)$ could track regime change in financial markets, clinical cohorts, or competition structure, and indicate when pooled calibration is misleading. For predictive validation specifically, *season-blocked* or strictly chronological cross-validation, training on earlier fixtures and testing on later ones, would tighten temporal leakage beyond the team-blocked folds used here ((sec:ml_cv)).

Separately, relativisation is often justified as baseline cancellation rather than variance reduction alone; connecting PEF geometry to causal estimands would clarify when correlation-based differencing preserves interpretable treatment or exposure effects and when it introduces collider or selection bias.

Finally, the supporting-domain checks here are cross-sectional and shallower than the sports tier ((tab:validation)). Replication in social-science panel designs, environmental paired measurements, and engineering telemetry, with the same per-unit ML scrutiny applied to rugby and football, would test whether the $(\kappa,\rho)$ taxonomy transfers before the practical guidance is adopted outside invasion-game sport.
