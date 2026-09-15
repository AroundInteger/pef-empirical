# Appendix

> **Review copy** from LaTeX. Source of truth: `sections/appendix.tex`.
> Propose edits in chat (or annotate this file); agreed changes go into the `.tex`.
> Math rendering is approximate.

---

# Mathematical Appendix

 The algebraic derivation of the PEF formula ((eq:pef)) from the variance of correlated differences, together with its reduction to Fisher's classical case at $\kappa=1$, is given in full in (sec:theory) (2.1). This appendix records the material not reproduced in the main text: the step-by-step information content derivation, the boundary analysis, the statistical properties of the PEF estimator, and the Pitman asymptotic relative efficiency proof.

## Information Content Derivation

### Setup

Under Assumption (A1), $X=X_A-X_B\simN\bigl(\delta,\sigma^2_A(1+\kappa-2sqrt(\kappa) \rho)\bigr)$ with $\delta=\mu_A-\mu_B$.

The binary outcome $Y\in\0,1\$ is the match outcome; it is *not* a deterministic function of $X$. Under Assumption (A2) (Gaussian discriminant model, (sec:mi_setup)), the class-conditional distributions are
\[
  X Y=1(+/2, Var(X)), X Y=0(-/2, Var(X)),
\]
with equal priors. Mutual information:

$$

  I(X;Y) = H(Y) - H(Y\mid X).

$$

### Unconditional Entropy

For equiprobable outcomes ($P(Y=1)=P(Y=0)=0.5$),

$$

  H(Y) = 1  bit.

$$

### Conditional Entropy

Under (A2), the posterior is $P(Y=1\mid X=x)=\Phi(x/sqrt(\Var(X)))$, so the expected conditional entropy is

$$

  H(Y\mid X) &= E_X\bigl[H\bigl(P(Y=1\mid X)\bigr)\bigr].

$$

Evaluating this expectation under the marginal distribution of $X$ (which has mean $\delta/2$ under the equal-prior mixture) yields the closed-form approximation

$$

  H(Y\mid X) ≈ H\left(\Phi\left(2sqrt(\Var(X))\right)\right),

$$

where $H(p)=-p\log_2p-(1-p)\log_2(1-p)$ is the binary entropy function and the right-hand side equals the binary entropy of the Bayes error rate $\Phi(-\delta/(2sqrt(\Var(X))))$.

### Substitution

From (eq:pef): $1+\kappa-2sqrt(\kappa) \rho=(1+\kappa)/\eta$. Therefore $\Var(X)=\sigma^2_A(1+\kappa)/\eta$, giving

$$

  I(X;Y) = 1 - H\left(\Phi\left(\delta2\sigma_Asqrt((1+\kappa)/\eta)\right)\right).

$$

## Boundary Analysis

### Fisher Regime ($\kappa=1$, $\rho=0$)

$$

  \eta = 1,\quad \Var(X) = 2\sigma^2_A,\quad
  I(X;Y) = 1 - H\left(\Phi\left(\delta2\sigma_Asqrt(2)\right)\right).

$$

Independent measurements with equal variances; relativisation is neutral.

### Variance Ratio Extremities

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

### Correlation Extremities

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

### Summary of Special Cases

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

## Statistical Properties of the PEF Estimator

### Estimators

For paired observations $(X_A,i,X_B,i)$, $i=1,…,n$,

$$

  \eta = 1+1+\kappa-2\kappa \rho,

$$

where $\kappa=s^2_B/s^2_A$ and $\rho$ is the Pearson sample correlation.

### Asymptotic Distribution

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

### Theoretical Guarantees

- **Consistency:** $\etap\eta$ as $n\to\infty$ (continuous mapping theorem).

- **Bias:** $\eta$ is generally biased due to nonlinearity of the PEF formula; the bias is $O(1/n)$ and vanishes asymptotically. For $\eta>1$ the bias is typically positive (by Jensen's inequality, since $\eta$ is convex in $\rho$ from (eq:d2etadrho2)).

- **Efficiency:** $\eta$ is a continuous function of the MLEs $(\kappa,\rho)$ under bivariate normality; by the invariance of the MLE, $\eta$ is itself the MLE of $\eta$ and is asymptotically efficient [lehmann1999].

### Bootstrap Confidence Intervals

$$

  CI_1-\alpha = \bigl[\eta^*_(\alpha/2),\eta^*_(1-\alpha/2)\bigr],

$$

where $\eta^*_(p)$ denotes the $p$th quantile of the bootstrap distribution from resampling paired observations.

## Connection to Classical Tests

The paired $t$-statistic is

$$

  t = Dsqrt(\Var(D)/n),\quad D=X_A-X_B.

$$

Higher $\eta$ (lower $\Var(D)$) increases the $t$-statistic and hence test power. Cohen's $d$ for paired designs,

$$

  d = Dsqrt(\Var(D)),

$$

also increases with $\eta$, yielding larger detectable effect sizes.

## Connection to Pitman Asymptotic Relative Efficiency

This section establishes that, under bivariate normality and equal group sizes, the PEF equals the Pitman asymptotic relative efficiency (ARE) of the paired $t$-test relative to the independent two-sample $t$-test. We state this as a proposition, give a self-contained proof, verify the classical reduction, and record the qualifications that bound the result.

### Proposition

**Proposition (PEF as Pitman ARE).** *Under Assumption (A1) and equal allocation ($n$ observations per group), the Pitman ARE of the paired $t$-test relative to the independent two-sample $t$-test equals*

$$

  ARE_paired/indep = 1+1+\kappa-2sqrt(\kappa) \rho = \eta.

$$

### Proof

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

### Classical Verification

Setting $\kappa=1$:

$$

  ARE_paired/indep = (2)/(2-2\rho) = (1)/(1-\rho),

$$

recovering Fisher's classical paired-design efficiency [fisher1935]. The PEF is therefore the direct generalisation of Fisher's result to unequal variances, expressed in the language of Pitman efficiency.

### Qualifications

Three conditions bound (eq:are_pef):

- **Normality.** Steps 1--2 use the normal noncentrality parameter. Under non-normality, the central limit theorem ensures the limiting noncentrality is still given by (eq:ncp_paired,eq:ncp_unpaired) under finite second moments, so the ARE result is asymptotically robust; however, the small-sample comparison may differ.

- **Equal group allocation.** Step 2 assumes $n_A=n_B=n$. Under Neyman-optimal allocation $n_A/n_B=\sigma_A/\sigma_B=1/sqrt(\kappa)$, the noncentrality of the independent test becomes $\deltasqrt(N)/(2\sigma_Asqrt(\kappa)/(1+sqrt(\kappa))·sqrt(1+\kappa))$, which modifies the ARE. Equal allocation is the natural comparison when paired and unpaired designs collect data in the same proportions.

- **Fixed alternative.** The result above uses a fixed $\delta$ and $n\to\infty$. Under local (Pitman) contiguous alternatives $\delta_n=c/sqrt(n)$, the noncentrality parameters remain $O(1)$ and the same ratio $\eta$ is obtained in the limit, so the result is unchanged [lehmann1999].

 The PEF formula is distribution-free ((eq:pef)); only the ARE *interpretation* in (eq:are_pef) requires normality. The distribution-free efficiency characterisation (the variance ratio) is the primary result; the Pitman ARE connection provides a classical testing-theory corroboration.
