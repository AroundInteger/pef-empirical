# PEF Framework: Theoretical and Numerical Strategy

**Status:** working reference, version 0.1 (25 October 2026)
**Rule:** nothing enters the manuscript until it appears in the claims register (Section 7) as *Verified*.

---

## 1. The questions

| | Question | Governing quantity (hypothesis) |
|---|---|---|
| **Q1 Inference** | When does working with the paired difference D = A − B improve precision for estimating the mean difference δ = μ_A − μ_B? | η, the Paired Efficiency Factor |
| **Q2 Prediction** | When does replacing the features (A, B) by D improve out-of-sample prediction of a binary outcome Y? | Alignment of the optimal predictor with (1, −1); finite-sample variance; η_N / η_S |
| **Q3 Paradox** | How can η < 1 (worse inference) coexist with better prediction? | Where the correlation sits: signal or noise |

Q1 and Q2 are different questions. The programme must answer each one exactly and then state precisely how they connect.

---

## 2. Definitions and the inferential PEF (Q1)

Let (A, B) have variances σ²_A, σ²_B and correlation ρ. Write κ = σ²_B / σ²_A.

**Definition (PEF).**

$$\eta \;=\; \frac{\sigma_A^2 + \sigma_B^2}{\operatorname{Var}(A-B)} \;=\; \frac{1+\kappa}{1+\kappa-2\sqrt{\kappa}\,\rho}.$$

**Reparameterisation.** With λ = ln κ,

$$\eta = \frac{1}{1-\rho_{\mathrm{eff}}}, \qquad \rho_{\mathrm{eff}} = \rho\,\operatorname{sech}(\lambda/2) = \rho\,\frac{2\sqrt{\kappa}}{1+\kappa}.$$

Here sech(λ/2) is the ratio of the geometric to the arithmetic mean of the two variances.

**Properties to verify (Phase 0):**

| ID | Statement |
|---|---|
| P1 | η > 1 ⇔ ρ > 0, for every κ > 0. The η = 1 boundary is the line ρ = 0. Negative correlation gives η < 1. |
| P2 | η(κ, ρ) = η(1/κ, ρ). |
| P3 | η ∈ [½, ∞). The minimum ½ occurs at ρ = −1, κ = 1. η → ∞ only at ρ = 1, κ = 1. In general η(κ, 1) = (1+κ)/(1−√κ)² and η(κ, −1) = (1+κ)/(1+√κ)². |
| P4 | For fixed ρ > 0, η is maximised at κ = 1, giving 1/(1−ρ). For fixed ρ < 0, η is minimised at κ = 1. |
| P5 | η → 1 as κ → 0 or κ → ∞. |
| P6 | With n pairs versus two independent samples of size n, Var(δ̂_unpaired) / Var(δ̂_paired) = η. |

**Literature anchor (positioning, must be cited).** ρ_eff = 2σ_AB / (σ²_A + σ²_B) is Lin's (1989, *Biometrics*) concordance correlation coefficient with the location-shift term set to zero, and sech(½ ln κ) appears to be Lin's scale-shift factor. *To verify against the original paper before citing.* The reparameterisation is therefore not new. What is new is using it to read η, and the predictive theory of Section 3. Also relevant: the intraclass correlation for pairs, and the design-effect literature.

**Degrees-of-freedom penalty (E2b).** At η = 1, the paired t-test loses about 0.6 percentage points of power to Welch's test at n = 10–50, because it has n − 1 rather than about 2n − 2 degrees of freedom. The practical break-even η is therefore slightly above 1 in small samples. The inferential guidance should state this.

**CI method comparison (E2c, 1,000 reps × 40 cells, B = 999).** Share of cells within ±1.5 pp of 95% at n ≥ 50:

| Method | Share of cells |
|---|---|
| Fisher-z (delta) | 97% |
| Delta on log η | 83% |
| BCa | 73% |
| Percentile bootstrap (v13 method) | 70% |

All methods undercover at n = 20 (about 0.92), which motivated the E2e small-sample corrections and the P6d recommendation.

**Inferential numerics (Phase 2):**
- Power of the paired t-test versus the Welch test as a function of (ρ_eff, d = δ/σ_D, n).
- Sampling distribution of the estimator η̂ = (s²_A + s²_B) / s²_D.
- Coverage of confidence intervals for η: percentile bootstrap, BCa, delta method on log η, and Fisher-z on ρ̂_eff.

---

## 3. The predictive model (Q2)

### 3.1 Generative model

| Component | Definition |
|---|---|
| Signal | S = (S_A, S_B) ~ N(μ, Σ_S), with μ = (μ_A, μ_B) and δ = μ_A − μ_B (signed) |
| Measurement noise | N ~ N(0, Σ_N), independent of S |
| Observed features | K = S + N, with Σ_K = Σ_S + Σ_N |
| Outcome margin | M = bᵀS + ε, with b = (b_A, −b_B) and ε ~ N(0, σ²_ε) |
| Binary outcome | Y = 1(M > 0) |

Write c = (1, −1), so D = cᵀK. The baseline case is b = c, where the outcome depends on the signal difference.

**Interpretation.**
- S is true pre-match strength, observed only through K.
- Noise correlation ρ_N represents shared measurement conditions, such as weather, referee or league effects.
- Signal correlation ρ_S represents shared or zero-sum structure in true strength.

**Feature sets compared:**
- **Full:** F_full = (A, B).
- **Relativised:** F_D = D.
- **Single entity:** F_A = A.

### 3.2 Population results (Gaussian)

Let β = Σ_K⁻¹ Σ_S b be the best linear predictor of M from K, and σ²_M = bᵀΣ_S b + σ²_ε.

$$R^2_{\text{full}} = \frac{\beta^\top \Sigma_K \beta}{\sigma_M^2},\qquad
R^2_{D} = \frac{(c^\top \Sigma_S b)^2}{(c^\top\Sigma_K c)\,\sigma_M^2},\qquad
R^2_{A} = \frac{(e_A^\top \Sigma_S b)^2}{(\Sigma_K)_{AA}\,\sigma_M^2}.$$

**Theorem A (reduction).** Under joint Gaussianity, for any feature set F with linear index L_F,

$$P(Y=1 \mid F) = \Phi\!\left(\frac{z + r_F u}{\sqrt{1-r_F^2}}\right),$$

where z = μ_M / σ_M, r_F² = R²_F, and u is the standardised index.

Every population metric is then a function of (z, r²_F) alone:
- Bayes log-loss: E_u[H_b(p)];
- mutual information: I(F; Y) = H_b(Φ(z)) − E_u[H_b(p)];
- Brier score;
- accuracy, which at z = 0 equals ½ + arcsin(r)/π (Sheppard);
- AUC.

Log-loss, Brier, MI and AUC are strictly monotone in r²_F at fixed z. Accuracy is only *weakly* monotone: for |z| > 0 and small r, the Bayes classifier always predicts the favoured side and accuracy stays at Φ(|z|) until r passes a threshold. *Consequence for reporting:* lead with log-loss or Brier, not accuracy, because accuracy can hide real differences in r².

*Consequence:* in the Gaussian model, comparing feature sets reduces exactly to comparing R². This also supplies the correct "information content", replacing the v13 formula.

**Theorem B (sufficiency and alignment).** R²_D ≤ R²_full always. More generally, the Bayes risk using D is never lower than the Bayes risk using (A, B), by the data-processing inequality; this holds for any distribution. Exactly,

$$\frac{R^2_D}{R^2_{\text{full}}} = \cos^2\theta_K, \qquad \cos\theta_K = \frac{c^\top\Sigma_K\beta}{\sqrt{c^\top\Sigma_K c}\,\sqrt{\beta^\top\Sigma_K\beta}}.$$

This is the squared cosine between β and c in the Σ_K inner product, so equality holds iff β ∝ c.

*Note:* b_A = b_B is neither necessary nor sufficient for β ∝ c in general. It is sufficient in the exchangeable case (E0 check D2). With general covariances, b = c does **not** imply β ∝ c (E0 negative control NEG4, confirmed symbolically). Asymmetric signal or noise variances therefore break the losslessness of D even when the outcome depends only on the signal difference. The size of this loss across realistic κ_S and κ_N is a Phase 5 question.

**Theorem C (reliability law, second moments only, no Gaussianity).** Write Rel(D) = Var(S_D) / Var(D), where S_D = S_A − S_B and N_D = N_A − N_B. Then

$$\mathrm{Rel}(D) = \frac{1}{1+\Lambda\,\eta_S/\eta_N}, \qquad \Lambda = \frac{\operatorname{tr}\Sigma_N}{\operatorname{tr}\Sigma_S},$$

where η_S and η_N are the PEF of the signal and noise components. Relativisation multiplies the pair-level noise-to-signal ratio by η_S / η_N.

- When b = c, R²_D = Rel(D) · q, with outcome determinism q = Var(S_D) / σ²_M.
- *This is the correct form of the "η_N / η_S law".* Total η alone does not determine R²_D (counterexample: total η = 2 fixed, R²_D ∈ {0.80, 0.33, 0.00}).

**Proposition D (relativised versus single entity, exchangeable, b = c).**

$$\frac{R^2_D}{R^2_A} = \frac{2}{1-\rho} = 2\eta,$$

where ρ is the *total* feature correlation. If this verifies, η does govern the gain of the relativised feature over a single-entity feature; the factor 2 comes from using both entities and η is the pairing gain. This partially rescues the v13 claim for that specific comparator. The general non-exchangeable form must be derived and checked.

### 3.3 Finite-sample results

**Theorem E (parameter-saving gain).** If β ∝ c and the fitted model is correctly specified (probit with intercept), then

$$\mathbb{E}[\mathrm{LL}_{\text{full}} - \mathrm{LL}_D] = \frac{1}{2n} + o(1/n),$$

where LL is expected test log-loss. The full model fits 3 parameters and the relativised model fits 2. For logistic regression, which is slightly misspecified here, use the Takeuchi trace correction tr(J⁻¹V)/(2n) in place of p/(2n).

**Theorem F (crossover).** If Δ∞ = LL_D,∞ − LL_full,∞ > 0, which is computable exactly from Theorem A, then the relativisation advantage is approximately 1/(2n) − Δ∞. The crossover sample size is therefore n* ≈ 1/(2Δ∞).

**Conjecture G (model class).** For learners that cannot represent A − B cheaply, such as axis-aligned trees, the finite-sample advantage of D is larger and decays more slowly than 1/(2n).

---

## 4. Parameterisation

All quantities are dimensionless.

**Core (exchangeable) parameters:**

| Symbol | Meaning | Grid |
|---|---|---|
| z | Standardised mean margin δ/σ_M (signed) | 0, 0.25, 0.5, 1 |
| ρ_S | Signal correlation | −0.9 … 0.9 |
| ρ_N | Noise correlation | −0.9 … 0.9 |
| w | Signal fraction σ²_S / (σ²_S + σ²_N) | 0.2, 0.5, 0.8 |
| q | Outcome determinism Var(bᵀS) / σ²_M | 0.5, 0.8, 0.95 |
| n | Sample size (finite-sample phases only) | 20 … 10,000, log-spaced |

**Asymmetry parameters (stress tests):**
- κ_S and κ_N: variance ratios within signal and within noise.
- b_B / b_A: outcome coefficient asymmetry, with misspecification m = b_A − b_B.

For pure inference (Q1), the parameters (κ, ρ, δ) suffice, and in fact (ρ_eff, d) do.

---

## 5. Numerical programme

| Phase | Content | Pass criterion |
|---|---|---|
| **0 Symbolic** | sympy proofs of P1–P5, the sech form, Theorem B ratio, Theorem C, Proposition D | Each identity simplifies to 0, or the inequality is proved |
| **1 Closed forms vs MC** | R², log-loss, Brier, accuracy, MI and AUC by quadrature versus Monte Carlo (n = 10⁶) on ≥ 200 random parameter draws, including asymmetric ones | Every metric within 3 MC standard errors; no systematic bias (z-score mean ≈ 0, sd ≈ 1) |
| **2 Inference** | P6, test power, η̂ distribution, CI coverage | Variance ratio within MC error; coverage within ±1.5% of nominal at n ≥ 50 |
| **3 Finite sample** | Theorem E for probit and logistic; Theorem F crossover | n · gain → ½ as n grows; empirical n* within the predicted band |
| **4 Model classes** | Logistic, L2-logistic, gradient boosting, random forest on full / D / A | Conjecture G accepted or rejected, with effect sizes and MC SE |
| **5 Stress tests** | Multivariate t (ν = 3, 5); skewed margins; bivariate Poisson / Skellam scores; ordinal outcomes; the n* = 300 coefficient asymmetry; repeated-measures team effects; 5% contamination. Run: `experiments/E5_stress.py` | Report which results survive. Theorem C and the B-inequality should; Theorem A's metric mapping may not. Recorded in E5 |
| **6 Real data** | Likelihood-ratio test of H₀: β_A + β_B = 0; team-blocked log-loss of A, D and (A, B); repeated-team η_S/η_N, quoted only if E5 recovers it. Run: `experiments/export_matches.m`, then `experiments/E6_sports.py` | Primary summaries are the distribution of LR statistics and the median blocked log-loss gap, not per-KPI discoveries |

**Engineering rules:**
- Fixed seeds.
- Every experiment writes a CSV to `results/` and a figure.
- A pytest suite re-checks all closed forms.
- MC standard errors are reported for every simulated number.
- No result is quoted without its SE.

---

## 6. Claims to retire or reframe from v13

| v13 claim | Status | Replacement |
|---|---|---|
| ρ = 1 ⇒ η → ∞ | False unless κ = 1 | P3 |
| Quadrants split by high or low κ | Contradicts P2 | Axes ρ (or ρ_eff) and \|ln κ\| |
| I = 1 − H(Φ(δ / (2σ_A…))) is mutual information | Mislabelled; also has a factor-2 error | Theorem A mutual information |
| ρ = 0.900 between η and I as empirical validation | Algebraic, not empirical | Drop |
| ML gain = 0.234(η − 1) + 0.089(η − 1)² | Empirical fit labelled as theory | Theorems B–F, plus Proposition D if verified |
| PEF assumes bivariate normality | Mis-stated | η is moment-based; normality is needed only for Theorem A's mapping and t-inference |
| Spearman or Kendall as alternatives inside η | Invalid | Diagnostics only |

---

## 7. Claims register

| ID | Claim | Derived | Symbolic | Monte Carlo | Stress-tested |
|---|---|---|---|---|---|
| P1–P5 | PEF properties | ✓ | ✓ E0 (plus sum-of-squares proofs) | n/a | n/a |
| P6 | Inferential meaning of η | ✓ | | ✓ E2a: 18 cells, η 0.56–20, \|z\| ≤ 2.8 | |
| P6b | Paired-t power = noncentral t(n−1, δ√n/σ_D) | ✓ (exact) | n/a | ✓ E2b, replicated: mean z −0.06, sd 1.00 | |
| P6c | Var(atanh ρ̂_eff) ≈ (1−ρ²)ρ²_eff / ((1−ρ²_eff)ρ²n); equals 1/n at κ = 1 | ✓ delta method | ✓ equals Lin (1989) to machine precision | ✓ E2c/E2e coverage (below) | E5: the Gaussian variance under-covers for t margins and for 5% contamination; see P6d |
| P6d | Recommended CI for η: tanh(atanh ρ̂_eff ± t₀.₉₇₅,ₙ₋₂ · √(v̂/(n−2))), mapped by η = 1/(1−ρ_eff) | — | n/a | ✓ E2e: worst cell ≥ 0.949 for n ≥ 15; error ≤ 0.9 pp at n = 20, ≤ 0.3 pp at n = 50 (20,000 reps × 21 cells per n) | E5, n = 50, 400 reps. Gaussian coverage 0.94 and 0.96. t₃: 0.80 and 0.75. t₅: 0.88 and 0.92. Five per cent contamination: 0.52 and 0.56. Nominal coverage does not survive heavy tails or contamination |
| A | Reduction to (z, r²) | ✓ | quadrature vs Sheppard to 10⁻⁸ | ✓ E1: 200 draws × 6 metrics × 3 feature sets; replicated at 4×10⁶ with fresh seeds; deviations scale as 1/√n, no per-draw persistence | E5 (40 × 2,500). Log-loss matches for the Gaussian law and for the repeated-team law, which is marginally Gaussian. It fails for t₃, t₅, gamma margins, bivariate Poisson and the ordinal cut. Five per cent contamination is borderline (one cell \|z\| = 3.00) |
| B | Alignment ratio cos²θ_K | ✓ | ✓ E0, general 2×2 | ✓ pytest, 300 random draws | E5: sample R²_D/R²_full matches cos²θ at both design points for every stress law, to within 0.01 or 3 SE |
| C | Reliability law | ✓ | ✓ E0, general 2×2 | ✓ E1 (z mean 0.04, sd 1.00) | E5: holds at both design points for every law except one repeated-team cell (0.733 against 0.753, z = −3.2) |
| D | R²_D / R²_A = 2η (exchangeable) | ✓ | ✓ E0; fails for general Σ (negative control NEG3). General form in (ρ_S, ρ_N, w, κ_S, κ_N, b_ratio) reduces to 2η when κ_S = κ_N = b_ratio = 1 (DGEN) | ✓ pytest, including the reduction and a non-exchangeable failure | E5 stores three η = 2 cases with R²_D = 0.80, 0.33 and 0 |
| E | 1/(2n) gain | ✓ (standard theory) | n/a | ✓ E3: leading coefficient 0.491, 0.503, 0.489 (± 0.007) at three parameter points, n = 50–5000, 3000 reps per cell, exact test loss. Second-order term c/n² with c ≈ 16 ± 2, similar across points (empirical) | Not re-estimated on the stress laws. It uses the (z, r²) map, which fails where Theorem A fails |
| F | Crossover n* | ✓ | n/a | ✓ E3: second-order form n* = [½ + √(¼ + 4cΔ∞)]/(2Δ∞), with c from the aligned cells (out of sample), predicts 125/329/1031 vs empirical 125/328/980; noise-asymmetry case 329 vs 342 | Not re-estimated on the stress laws. Same caveat as E |
| G | Trees benefit more | conjecture | n/a | ✓ **E4b (tuned per feature set, 12 reps, 3 regimes × n = 10³, 3×10³, 10⁴).** D helps both GBM and RF in all 18 cells. Gain at n = 10⁴ is 3.3–11.8 mn, versus 0.04–0.05 mn for logistic. Gain decays as n^−0.3 to n^−0.7, versus n^−1.05 for logistic. In the misaligned regime D still helps trees at n = 10⁴ (+2.0 GBM, +5.4 RF), while logistic loses 1.8 mn. The untuned negative RF result in E4 was a tuning artefact (D needs larger leaves: tuned leaf 200 vs 50 for full). | Trees were not refit. The Gaussian Bayes floor in E4 is the map E5 shows fails for t, skew, counts and the ordinal cut |
| G′ | Caveat to G | — | n/a | Trees with D stay above the Bayes floor. Plain logistic regression reaches Bayes in every regime, because the data-generating process is linear-Gaussian. G is a statement about learners that cannot represent A − B, not a claim that trees with D are the best model. E5 shows the Gaussian (z, r²) floor itself fails for t, skew, counts and the ordinal cut; the trees were not refit on those laws. | |
| H | Augmenting with D never hurts trees | observation | n/a | ✓ E4b: LL(full) − LL(full+D) ≥ 3.1 mn in every tuned cell. D alone beats full+D except under misalignment at large n, where full+D wins (GBM 0.4860 vs 0.4873), as expected: augmentation retains the ability to correct asymmetry. **Practical rule: give trees (A, B, D).** | Trees were not refit under the stress laws. See G |
| R | Reproducibility | — | n/a | ✓ A clean-package rerun reproduced every CSV bit-for-bit (E0, E1rep, E2a–e, E3, E4). E1 primary differs only in R² rows (by ≤ 2×10⁻⁵) because the bias correction was added after the first run. | |
| S | Repeated-team η_S/η_N | pre-specified model | Woodbury likelihood matches a dense covariance | ✓ E5: truth 0.337. Rugby size (16 teams, 240 matches, 60 reps) coverage 0.983, bias +0.003. Football size (24 teams, 1,104 matches, 30 reps) coverage 0.967, bias −0.002 | Phase 6 quotes the split only when the cluster-bootstrap interval does not span a factor of ten: 50 of 64 football KPIs and 6 of 22 rugby KPIs |
| Emp | Alignment on the primary seasons | pre-registered | n/a | ✓ E6, seasons 23/24 and 24/25, draws coded as not a home win. Football, 64 KPIs, 1,114 matches: median LR 0.71 (IQR 0.17–2.01); median team-blocked log-loss 0.690 (A), 0.689 (D), 0.690 (A, B); median ll_D − ll_(A,B) = −0.0006 nats. Rugby, 22 KPIs, 283 matches: median LR 0.67 (IQR 0.16–1.59); log-loss 0.646 (A), 0.640 (D), 0.640 (A, B); median gap −0.0024 nats. The four exemplars were not reselected. | Cluster bootstrap of the out-of-bag gap; see `results/E6_sports.csv` |

---

## 8. Software layout

```
pef_numerics/
├── STRATEGY.md          this document
├── pef/                 library: covariance builders, closed forms, samplers, fitting
├── experiments/         one script per phase, plus export_matches.m
├── data/                matches_long.csv exported by the MATLAB loaders
├── tests/               pytest checks of closed forms
└── results/             CSV outputs and figures
```

## 8b. Practical sensitivity (from the E3 design)

With base parameters z = 0, ρ_S = 0.2, ρ_N = 0.6, w = 0.5, q = 0.8, the crossover reaches n* = 300 with only:
- an 18% outcome-coefficient asymmetry (b_B/b_A = 1.18), or
- a 33% noise-variance asymmetry (κ_N = 1.33, with b_A = b_B).

Relativisation is therefore a small-sample device unless symmetry is close to exact.

## 9. Open questions

0. Is the second-order coefficient c (about 16) universal for a one-parameter restriction in a probit model, or does it depend on (z, r²)? A theoretical derivation would make the crossover formula fully a priori.

1. **Answered (E0, check DGEN).** For general (ρ_S, ρ_N, w, κ_S, κ_N) and b = (1, −b_ratio),
   R²_D / R²_A = (c′ Σ_S b)² / (e_A′ Σ_S b)² · (Σ_K)_AA / (c′ Σ_K c).
   This reduces to 2η(1, ρ_total), with ρ_total = w ρ_S + (1 − w) ρ_N, when κ_S = κ_N = b_ratio = 1. The exchangeable claim stays exactly as restricted by negative control NEG3. Three explicit η = 2 cases, with R²_D equal to 0.80, 0.33 and 0, are stored in `results/E5_eta2_counterexample.csv`. The zero case has c′ Σ_S b = 0 while the summed covariance still has η = 2.

2. Is there a closed form for AUC under Theorem A? It should be computable from the bivariate normal.
3. How does Theorem C extend to count data, where the variance depends on the mean?
4. **Answered (E5 and E6).** The pre-specified split is X_A = μ_A + u_h − λ u_a + ε_A and X_B = μ_B + u_a − λ u_h + ε_B, with u_i i.i.d. and (ε_A, ε_B) the noise. η_S and η_N are functions of (λ, τ², Σ_ε), not of the marginal pair covariance. Gaussian maximum likelihood, with a Woodbury likelihood checked against a dense covariance, recovers η_S/η_N in simulation: truth 0.337, rugby-like coverage 0.983 (bias +0.003, 60 reps), football-like coverage 0.967 (bias −0.002, 30 reps). On the exported primary-season matches the ratio is quoted only with a team-cluster bootstrap interval, and only when that interval does not span a factor of ten. That is 50 of 64 football KPIs and 6 of 22 rugby KPIs. `lineout_throws_lost` is one of the four fixed exemplars and is not separated (interval 0.44 to 505).
