# SI §1 Mathematical Derivations

> **Review copy** from LaTeX. Source of truth: `sections/appendix.tex`.
> Propose edits in chat (or annotate this file); agreed changes go into the `.tex`.
> Math rendering is approximate.

---

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
