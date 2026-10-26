"""Regenerate every summary statistic reported for the PEF numerical
programme from the CSVs in ./results, and write results/SUMMARY.md.

Run from the package root (or the quick-mode folder): python analysis/summarise.py
Each section is independent. A missing or failed section is reported in the
summary rather than stopping the script.
"""
import os
import sys
import traceback
import numpy as np
import pandas as pd
from scipy import stats
from scipy.optimize import curve_fit

R = "results"
OUT = os.path.join(R, "SUMMARY.md")
sections = []


def md(df, digits=4, index=True):
    return df.round(digits).to_markdown(index=index)


def section(title):
    def deco(fn):
        def run():
            try:
                body = fn()
            except FileNotFoundError as e:
                body = f"*Not available: {os.path.basename(str(e.filename))} not found.*"
            except Exception:
                body = "*Section failed:*\n```\n" + traceback.format_exc() + "```"
            sections.append(f"## {title}\n\n{body}\n")
        return run
    return deco


def rd(name):
    return pd.read_csv(os.path.join(R, name))


# --------------------------------------------------------------------- E0
@section("E0  Symbolic verification")
def e0():
    d = rd("E0_symbolic.csv")
    return (f"**{int(d.passed.sum())}/{len(d)} checks passed** "
            f"(including {int((d.id == 'NEG').sum())} negative controls, which pass when the false identity is rejected).\n\n"
            + md(d, index=False))


# --------------------------------------------------------------------- E1
def zsummary(df):
    t19 = stats.t(19)
    g = df.groupby("metric").zscore
    out = pd.DataFrame({"mean_z": g.mean(), "sd_z": g.std(),
                        "max_abs_z": g.apply(lambda s: s.abs().max()),
                        "frac_abs_z_gt_3": g.apply(lambda s: (s.abs() > 3).mean())})
    head = (f"Overall: {len(df)} comparisons, mean z = {df.zscore.mean():.3f}, sd z = {df.zscore.std():.3f}, "
            f"fraction |z| > 3 = {(df.zscore.abs() > 3).mean():.4f} (t₁₉ reference {2 * t19.sf(3):.4f}).")
    return head, out


@section("E1  Closed forms (Theorems A, C) versus Monte Carlo")
def e1():
    a = rd("E1_population_mc.csv")
    h, t = zsummary(a)
    s = "**Primary run.** " + h + "\n\n" + md(t, 3)
    if os.path.exists(os.path.join(R, "E1_replication_4M.csv")):
        b = rd("E1_replication_4M.csv")
        hb_, tb = zsummary(b)
        rows = []
        for m in sorted(b.metric.unique()):
            za = a[a.metric == m].pivot_table(index="draw", columns="feature", values="zscore").mean(axis=1)
            zb = b[b.metric == m].pivot_table(index="draw", columns="feature", values="zscore").mean(axis=1)
            da = (a[a.metric == m].mc - a[a.metric == m].theory).abs().mean()
            db = (b[b.metric == m].mc - b[b.metric == m].theory).abs().mean()
            rows.append(dict(metric=m, mean_z_primary=za.mean(), p_primary=stats.ttest_1samp(za, 0).pvalue,
                             mean_z_replication=zb.mean(), p_replication=stats.ttest_1samp(zb, 0).pvalue,
                             absdev_ratio=db / da, corr_of_draw_z=np.corrcoef(za, zb)[0, 1]))
        s += ("\n\n**Replication (fresh seeds, larger n).** " + hb_ + "\n\n" + md(tb, 3)
              + "\n\nPersistence check (per-draw mean z; a real discrepancy would persist across runs, "
              "giving a positive correlation; pure Monte Carlo noise gives ≈ 0, and an absolute-deviation "
              "ratio of ≈ 0.5 at 4× n):\n\n" + md(pd.DataFrame(rows), 4, False))
    rel = a[a.metric == "reliability"]
    s += f"\n\nTheorem C law versus direct computation: max |difference| = {rel.law_vs_direct.max():.2e}."
    return s


# --------------------------------------------------------------------- E2
@section("E2a  P6: variance ratio equals η")
def e2a():
    d = rd("E2a_variance_ratio.csv")
    return (f"{len(d)} cells, η from {d.eta_theory.min():.2f} to {d.eta_theory.max():.1f}; "
            f"max |z| = {d.z.abs().max():.2f}, mean z = {d.z.mean():.2f}.\n\n" + md(d, 4, False))


@section("E2b  Paired-t power versus noncentral-t theory, and the Welch comparison")
def e2b():
    s = ""
    for f, lab in (("E2b_power.csv", "Primary"), ("E2b_power_rep.csv", "Replication")):
        if not os.path.exists(os.path.join(R, f)):
            continue
        b = rd(f)
        x = b[b.power_paired_theory < 0.995]
        s += (f"**{lab}:** paired-t z over {len(b)} cells: mean {b.z_paired.mean():.3f}, sd {b.z_paired.std():.3f}, "
              f"max |z| {b.z_paired.abs().max():.2f}. Excluding cells with power ≥ 0.995 (binomial z ill-conditioned): "
              f"mean {x.z_paired.mean():.3f}, sd {x.z_paired.std():.3f}, max |z| {x.z_paired.abs().max():.2f}.\n\n")
    b = rd("E2b_power.csv")
    z = b[b.rho == 0].assign(gap=lambda d: d.power_paired_mc - d.power_welch_mc)
    s += ("Degrees-of-freedom penalty at η = 1 (ρ = 0): paired minus Welch power, averaged by n:\n\n"
          + md(z.groupby("n").gap.mean().to_frame("paired_minus_welch_power"), 4))
    return s


@section("E2c  Confidence intervals for η: method comparison")
def e2c():
    c = rd("E2c_coverage.csv")
    s = md(c.groupby(["method", "n"]).coverage.mean().unstack(), 3)
    big = c[c.n >= 50]
    share = big.assign(ok=(big.coverage - .95).abs() <= .015).groupby("method").ok.mean()
    s += ("\n\nShare of cells with n ≥ 50 within ±1.5 pp of 95%:\n\n" + md(share.to_frame("share"), 2)
          + "\n\nMedian interval width on the η scale:\n\n"
          + md(c.pivot_table(index="n", columns="method", values="median_width_eta", aggfunc="median"), 3))
    return s


@section("E2d  Delta-method variance versus Lin (1989)")
def e2d():
    d = rd("E2d_lin.csv")
    return f"Max relative difference over {len(d)} cells: {d.rel_diff.abs().max():.2e}.\n\n" + md(d, 6, False)


@section("E2e  Small-sample corrections for the Fisher-z interval")
def e2e():
    d = rd("E2e_smallsample.csv")
    g = d.groupby(["variant", "n"]).coverage
    err = d.assign(e=(d.coverage - .95).abs()).groupby(["variant", "n"]).e.max().unstack()
    return ("Mean coverage:\n\n" + md(g.mean().unstack(), 3) + "\n\nWorst cell:\n\n" + md(g.min().unstack(), 3)
            + "\n\nMax |coverage − 0.95|:\n\n" + md(err, 3)
            + "\n\nRecommended variant: `n-2/t` (Lin's variance with divisor n − 2 and a t(n−2) quantile).")


# --------------------------------------------------------------------- E3
@section("E3  Finite-sample gain (Theorem E) and crossover (Theorem F)")
def e3():
    df = rd("E3_finite_sample.csv")
    a = df[df.label.str.startswith("A")].copy()
    a["n_gain"], a["n_se"] = a.n * a.gain_probit, a.n * a.se_probit
    fits = []
    for lab, g in a.groupby("label"):
        p, cov = curve_fit(lambda n, a0, c: a0 + c / n, g.n, g.n_gain, sigma=g.n_se,
                           absolute_sigma=True, p0=[.5, 10])
        fits.append(dict(label=lab, leading=p[0], se_leading=np.sqrt(cov[0, 0]), c=p[1], se_c=np.sqrt(cov[1, 1])))
    fits = pd.DataFrame(fits)
    c_pool = float(np.average(fits.c, weights=1 / fits.se_c ** 2))
    s = ("Aligned cells: n·E[LL_full − LL_D] (theory → 0.5):\n\n"
         + md(a.pivot_table(index="n", columns="label", values="n_gain"), 3)
         + "\n\nFit n·gain = a + c/n (weighted):\n\n" + md(fits, 3, False)
         + f"\n\nPooled second-order coefficient c = {c_pool:.1f}.")
    if "gain_logit" in a:
        l = a[a.label == "A1"]
        s += "\n\nLogistic regression (A1), n·gain: " + ", ".join(
            f"n={int(n)}: {v:.3f}" for n, v in zip(l.n, l.n * l.gain_logit))
    b = df[~df.label.str.startswith("A")]
    rows = []
    for lab, g in b.groupby("label"):
        g = g.sort_values("n")
        x, y, se = np.log(g.n.values), g.gain_probit.values, g.se_probit.values
        D = g.delta_inf.iloc[0]

        def cross(yy):
            j = np.where(np.diff(np.sign(yy)) != 0)[0]
            return np.exp(x[j[0]] - yy[j[0]] * (x[j[0] + 1] - x[j[0]]) / (yy[j[0] + 1] - yy[j[0]])) if len(j) else np.nan

        emp = cross(y)
        rng = np.random.default_rng(0)
        bs = np.array([cross(y + rng.standard_normal(len(y)) * se) for _ in range(2000)])
        bs = bs[np.isfinite(bs)]
        lo, hi = (np.percentile(bs, [2.5, 97.5]) if len(bs) else (np.nan, np.nan))
        rows.append(dict(cell=lab, delta_inf=f"{D:.3e}", nstar_first_order=1 / (2 * D),
                         nstar_second_order=(0.5 + np.sqrt(0.25 + 4 * c_pool * D)) / (2 * D),
                         nstar_empirical=emp, ci_lo=lo, ci_hi=hi))
    s += ("\n\nCrossover sample size. Second-order prediction n* = [½ + √(¼ + 4cΔ∞)]/(2Δ∞) uses the pooled c "
          "from the aligned cells, so it is an out-of-sample prediction:\n\n" + md(pd.DataFrame(rows), 1, False))
    return s


# --------------------------------------------------------------------- E4
def gain_table(df, base="full"):
    w = df.pivot_table(index=["regime", "n", "rep", "model"], columns="features", values="logloss").reset_index()
    w["gain_D"] = w[base] - w["D"]
    if "full+D" in w:
        w["gain_aug"] = w[base] - w["full+D"]
    g = w.groupby(["regime", "model", "n"])
    out = pd.DataFrame({"gain_D_mn": 1000 * g.gain_D.mean(), "se_D_mn": 1000 * g.gain_D.std() / np.sqrt(g.gain_D.count())})
    if "gain_aug" in w:
        out["gain_aug_mn"] = 1000 * g.gain_aug.mean()
        out["se_aug_mn"] = 1000 * g.gain_aug.std() / np.sqrt(g.gain_aug.count())
    return w, out


@section("E4  Model classes, untuned (Conjecture G, first pass)")
def e4():
    df = rd("E4_model_classes.csv")
    w, t = gain_table(df)
    s = ("Gains in milli-nats of test log-loss (positive means D, or adding D, helps). "
         "`gain_D` = LL(full) − LL(D); `gain_aug` = LL(full) − LL(full+D), trees only.\n\n" + md(t, 2))
    rows = []
    for (reg, m), g in w.groupby(["regime", "model"]):
        sm = g.groupby("n").gain_D.mean()
        sm = sm[sm > 0]
        if len(sm) >= 3:
            rows.append(dict(regime=reg, model=m, decay_exponent=np.polyfit(np.log(sm.index), np.log(sm.values), 1)[0]))
    s += "\n\nDecay exponent of the D gain (slope of log gain on log n, positive-gain cells):\n\n" + md(pd.DataFrame(rows), 2, False)
    return s


@section("E4b  Tree models, tuned per feature set (Conjecture G, admissible test)")
def e4b():
    df = rd("E4b_tuned_trees.csv")
    w, t = gain_table(df)
    reps = df.groupby(["regime", "n"]).rep.nunique().unstack()
    s = ("Replicates per cell:\n\n" + md(reps, 0) + "\n\nGains in milli-nats (positive means helps):\n\n" + md(t, 2))
    best = df.groupby(["regime", "n", "model", "features"]).logloss.mean().unstack()
    s += "\n\nMean test log-loss by feature set:\n\n" + md(best, 4)
    hp = df.groupby(["model", "features", "n"]).hp.agg(lambda x: x.value_counts().index[0]).unstack()
    s += "\n\nMost frequently selected hyperparameters:\n\n" + hp.to_markdown()
    return s


if __name__ == "__main__":
    for fn in (e0, e1, e2a, e2b, e2c, e2d, e2e, e3, e4, e4b):
        fn()
    head = ("# PEF numerical programme: results summary\n\nGenerated by `analysis/summarise.py` from `results/*.csv`. "
            "See STRATEGY.md for definitions and the claims register.\n\n")
    if os.environ.get("PEF_QUICK") == "1":
        head += "> **QUICK MODE: replicate counts were reduced. These numbers check the pipeline only; do not cite them.**\n\n"
    open(OUT, "w").write(head + "\n".join(sections))
    print(f"wrote {OUT}")
    failed = [s.split("\n")[0] for s in sections if "Section failed" in s]
    if failed:
        print("FAILED sections:", *failed, sep="\n  ")
        sys.exit(1)
