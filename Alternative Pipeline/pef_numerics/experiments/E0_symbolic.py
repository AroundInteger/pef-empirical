"""Phase 0: symbolic verification of P1-P5, the sech form, Theorems B and C,
and Proposition D (STRATEGY.md). Each check returns True only if sympy
reduces the required expression to exactly zero (or proves the inequality
via an explicit sum-of-squares decomposition)."""
import csv
import os
import sympy as sp

k = sp.symbols("kappa", positive=True)
r = sp.symbols("rho", real=True)
s = sp.symbols("s", positive=True)          # s = sqrt(kappa)
eta = (1 + k) / (1 + k - 2 * sp.sqrt(k) * r)
eta_s = eta.subs(k, s ** 2)                  # eta written in terms of s
results = []


def check(cid, desc, ok):
    results.append(dict(id=cid, claim=desc, passed=bool(ok)))
    print(f"{'PASS' if ok else 'FAIL'}  {cid:6s} {desc}")


def zero(expr):
    return sp.simplify(sp.expand(sp.simplify(expr))) == 0


# --- Definition: variance identity gives eta
sA, sB = sp.symbols("sigma_A sigma_B", positive=True)
varD = sA**2 + sB**2 - 2 * r * sA * sB
eta_def = (sA**2 + sB**2) / varD
check("DEF", "eta = (sA^2+sB^2)/Var(A-B) equals (1+k)/(1+k-2 sqrt(k) rho)",
      zero(eta_def - eta.subs(k, sB**2 / sA**2)))

# --- sech form
lam = sp.log(k)
check("SECH1", "sech(ln(k)/2) = 2 sqrt(k)/(1+k)",
      zero(sp.sech(lam / 2).rewrite(sp.exp) - 2 * sp.sqrt(k) / (1 + k)))
reff = r * 2 * sp.sqrt(k) / (1 + k)
check("SECH2", "eta = 1/(1 - rho_eff)", zero(eta - 1 / (1 - reff)))

# --- Denominator decomposition (key to P1, P3): 1+s^2-2 s rho = (s-rho)^2 + (1-rho^2)
den = 1 + s**2 - 2 * s * r
check("DEN", "1+k-2 sqrt(k) rho = (sqrt(k)-rho)^2 + (1-rho^2)  [>0 unless rho=1,k=1]",
      zero(den - ((s - r) ** 2 + (1 - r**2))))

# --- P1: eta - 1 = 2 sqrt(k) rho / den, den > 0  =>  sign(eta-1) = sign(rho)
check("P1", "eta - 1 = 2 sqrt(k) rho / den, hence eta>1 iff rho>0",
      zero((eta_s - 1) - 2 * s * r / den))

# --- P2: reciprocal symmetry
check("P2", "eta(k, rho) = eta(1/k, rho)", zero(eta - eta.subs(k, 1 / k)))

# --- P3: boundary values and lower bound
check("P3a", "eta(k, 1) = (1+k)/(1-sqrt(k))^2",
      zero(eta_s.subs(r, 1) - (1 + s**2) / (1 - s) ** 2))
check("P3b", "eta(k, -1) = (1+k)/(1+sqrt(k))^2",
      zero(eta_s.subs(r, -1) - (1 + s**2) / (1 + s) ** 2))
# eta >= 1/2  <=>  2(1+k) - den >= 0  <=>  (s+rho)^2 + (1-rho^2) >= 0
check("P3c", "2(1+k) - den = (sqrt(k)+rho)^2 + (1-rho^2) >= 0, hence eta >= 1/2",
      zero(2 * (1 + s**2) - den - ((s + r) ** 2 + (1 - r**2))))
check("P3d", "eta(1, -1) = 1/2 (minimum attained)", zero(eta.subs({k: 1, r: -1}) - sp.Rational(1, 2)))

# --- P4: g(k) = 2 sqrt(k)/(1+k) has g' = (1-k)/(sqrt(k)(1+k)^2): max at k=1
g = 2 * sp.sqrt(k) / (1 + k)
check("P4", "d/dk [2 sqrt(k)/(1+k)] = (1-k)/(sqrt(k)(1+k)^2)  => |rho_eff| max at k=1",
      zero(sp.diff(g, k) - (1 - k) / (sp.sqrt(k) * (1 + k) ** 2)))

# --- P5: limits
check("P5", "eta -> 1 as k->0 and k->oo",
      sp.limit(eta, k, 0) == 1 and sp.limit(eta, k, sp.oo) == 1)

# --- Theorem B: R^2_D / R^2_full = cos^2 in Sigma_K metric (general 2x2 SPD)
a11, a12, a22, n11, n12, n22, bA, bB, se = sp.symbols(
    "s11 s12 s22 n11 n12 n22 b_A b_B sigma_eps", real=True)
SS = sp.Matrix([[a11, a12], [a12, a22]])
SN = sp.Matrix([[n11, n12], [n12, n22]])
SK = SS + SN
b = sp.Matrix([bA, -bB])
c = sp.Matrix([1, -1])
varM = (b.T * SS * b)[0] + se**2
beta = SK.inv() * SS * b
R2full = (b.T * SS * SK.inv() * SS * b)[0] / varM
R2D = ((c.T * SS * b)[0]) ** 2 / ((c.T * SK * c)[0] * varM)
cos2 = ((c.T * SK * beta)[0]) ** 2 / ((c.T * SK * c)[0] * (beta.T * SK * beta)[0])
check("B", "R2_D / R2_full = cos^2(theta_K) for general Sigma_S, Sigma_N, b",
      zero(sp.together(R2D / R2full - cos2)))

# --- Theorem C: Rel(D) = 1/(1 + Lambda eta_S/eta_N), general 2x2
etaS = (a11 + a22) / (c.T * SS * c)[0]
etaN = (n11 + n22) / (c.T * SN * c)[0]
Lam = (n11 + n22) / (a11 + a22)
relD = (c.T * SS * c)[0] / (c.T * SK * c)[0]
check("C", "Var(S_D)/Var(D) = 1/(1 + Lambda * eta_S/eta_N), general 2x2",
      zero(sp.together(relD - 1 / (1 + Lam * etaS / etaN))))

# --- Proposition D: exchangeable, b = c => R2_D/R2_A = 2/(1 - rho_total)
vS, vN = sp.symbols("v_S v_N", positive=True)
rS, rN = sp.symbols("rho_S rho_N", real=True)
SSx = sp.Matrix([[vS, rS * vS], [rS * vS, vS]])
SNx = sp.Matrix([[vN, rN * vN], [rN * vN, vN]])
SKx = SSx + SNx
eA = sp.Matrix([1, 0])
vM = (c.T * SSx * c)[0] + se**2
R2Dx = ((c.T * SSx * c)[0]) ** 2 / ((c.T * SKx * c)[0] * vM)
R2Ax = ((eA.T * SSx * c)[0]) ** 2 / (SKx[0, 0] * vM)
rho_tot = (rS * vS + rN * vN) / (vS + vN)
check("D", "exchangeable, b=c: R2_D/R2_A = 2/(1-rho_total) = 2*eta_total",
      zero(sp.together(R2Dx / R2Ax - 2 / (1 - rho_tot))))
# exchangeable, b=c => beta proportional to c  (so D is lossless in population)
betax = SKx.inv() * SSx * c
check("D2", "exchangeable, b=c: beta_A + beta_B = 0 (beta proportional to c)",
      zero(betax[0] + betax[1]))

# --- Proposition D, general dimensionless form.
# R2_D/R2_A = (c' Sig_S b)^2 / (e_A' Sig_S b)^2 * (Sig_K)_AA / (c' Sig_K c).
# It reduces to 2*eta(1, rho_total) only when kappa_S = kappa_N = b_ratio = 1.
w, kS, kN, br = sp.symbols("w kappa_S kappa_N b_ratio", positive=True)
rS, rN = sp.symbols("rho_S rho_N", real=True)
SSd = sp.Matrix([[w, rS * w * sp.sqrt(kS)], [rS * w * sp.sqrt(kS), kS * w]])
SNd = sp.Matrix([[1 - w, rN * (1 - w) * sp.sqrt(kN)],
                 [rN * (1 - w) * sp.sqrt(kN), kN * (1 - w)]])
SKd = SSd + SNd
bd = sp.Matrix([1, -br])
num_d = ((c.T * SSd * bd)[0] ** 2) * SKd[0, 0]
den_d = ((eA.T * SSd * bd)[0] ** 2) * (c.T * SKd * c)[0]
ratio_d = sp.together(num_d / den_d)
rho_tot_d = w * rS + (1 - w) * rN
reduced = ratio_d.subs({kS: 1, kN: 1, br: 1}) - 2 / (1 - rho_tot_d)
check("DGEN", "dimensionless R2_D/R2_A reduces to 2*eta when kappa_S=kappa_N=b_ratio=1",
      zero(reduced))
formula_path = os.path.join("results", "E0_proposition_d.txt")
os.makedirs("results", exist_ok=True)
with open(formula_path, "w") as fh:
    fh.write("R2_D/R2_A = (c' Sigma_S b)^2 / (e_A' Sigma_S b)^2 "
             "* (Sigma_K)_AA / (c' Sigma_K c)\n")
    fh.write("with Sigma_S, Sigma_N from (w, kappa_S, kappa_N, rho_S, rho_N) "
             "and b = (1, -b_ratio).\n")
    fh.write("Exchangeable reduction: 2/(1 - rho_total) = 2*eta(1, rho_total), ")
    fh.write("rho_total = w*rho_S + (1-w)*rho_N.\n")

# --- General (non-exchangeable) single-entity ratio, b = c: record closed form
R2D_g = ((c.T * SS * c)[0]) ** 2 / ((c.T * SK * c)[0])
R2A_g = ((eA.T * SS * c)[0]) ** 2 / SK[0, 0]
ratio_general = sp.simplify(R2D_g / R2A_g)
print("\nGeneral R2_D/R2_A (b=c):", ratio_general)

# --- Negative controls: false identities that the checker MUST reject
neg = {
    "NEG1: eta = 1/(1-rho) for all kappa": zero(eta - 1 / (1 - r)),
    "NEG2: v13 claim eta(k,1) infinite, i.e. den(k,1)=0 for all k": zero(den.subs(r, 1)),
    "NEG3: R2_D/R2_A = 2*eta_total for general (non-exchangeable) 2x2":
        zero(sp.together(ratio_general - 2 * (s11p := (a11 + n11 + a22 + n22))
                         / (c.T * SK * c)[0])),
    "NEG4: b_A = b_B alone implies beta prop. to c (general noise)":
        zero(sp.simplify((SK.inv() * SS * c)[0] + (SK.inv() * SS * c)[1])),
}
for desc, wrongly_zero in neg.items():
    check("NEG", desc + "  [control: must be rejected]", not wrongly_zero)

os.makedirs("results", exist_ok=True)
with open("results/E0_symbolic.csv", "w", newline="") as f:
    wr = csv.DictWriter(f, fieldnames=["id", "claim", "passed"])
    wr.writeheader()
    wr.writerows(results)
n_pass = sum(r_["passed"] for r_ in results)
print(f"\n{n_pass}/{len(results)} symbolic checks passed")
