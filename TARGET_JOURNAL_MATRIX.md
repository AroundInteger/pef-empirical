# Target journal matrix — `pef-empirical`

**Date:** 2026-06-25  
**Assumptions:** Bennett/Kilduff/Scott co-author group; sports-facing primary venue; Strand 2 = quadrant exemplars (not pooled *r*); `eq:dml_poly` retired from main text; companion (`pef-mathematics`) → AoAS or Series C.

---

## Executive recommendation

| Priority | Empirical (`pef-empirical`) | Companion (`pef-mathematics`) |
|----------|-----------------------------|-------------------------------|
| **1 (primary)** | **Journal of Quantitative Analysis in Sports (JQAS)** | **Annals of Applied Statistics (AoAS)** |
| **2 (backup)** | European Journal of Sport Science (EJSS) / JSAMS — visibility with rugby group | **JRSS Series C (Applied Statistics)** |
| **3 (fallback)** | International Journal of Performance Analysis in Sport | Statistics and Computing |

**Rationale:** JQAS is the ASA’s dedicated sports-stats outlet; your rugby URC + Championship KPI story, absolute-vs-relative framing, and honest limitation narrative match recent JQAS papers on feature construction, win-probability scepticism, and logistic match models. AoAS fits the companion’s geometry + numerical validation depth; Series C fits if you want the companion to emphasise cross-domain CSV tests over Fisher–Rao ψ.

---

## Literature scan (2023–2025, curated)

### JQAS — closest precedents

| Paper | Year | Relevance to PEF empirical |
|-------|------|---------------------------|
| **Miss it like Messi** (Baron et al.) — off-target shots, soccer | 2024 | Feature engineering + value extraction; soccer outcome modelling |
| **Exploring the difficulty of estimating win probability** (JQAS 2024-0130) | 2025 | *Honest* limits of observational ML in sports — aligns with dropping pooled η→ML |
| **A comprehensive survey of home advantage in American football** (Benz et al.) | 2024 | Large-scale football data; structured cross-level comparison |
| **Comparison of individual playing styles in football** (Guan et al.) | 2024 | Multivariate normal / KL divergence for football features |
| **Bayesian bivariate Conway–Maxwell–Poisson… soccer** (Florez et al.) | 2024 | Count-data modelling; home/away correlation structure |
| **Estimating player contribution in hockey with regularized logistic regression** (Gramacy et al.) | 2013 | Canonical JQAS logistic + shrinkage precedent |
| **Meta-analytics: statistical properties of sports metrics** (Franks et al.) | 2016 | Bornn line — understanding metric behaviour before prediction |
| **Testing styles of play… football** (Palazzo et al.) | 2023 | Team-level football structure; network indicators |

**Gap JQAS does not fill often:** explicit *paired* variance efficiency (Fisher / unequal κ) as the organising principle — that is your novelty within a sports venue.

**Your direct citation line:** Scott et al. (2023) JSAMS URC KPIs; Bennett et al. — positions PEF as statistical formalisation of “relative beats isolated” already shown empirically in rugby.

### JRSS Series C — closest precedents

| Paper | Year | Relevance |
|-------|------|-----------|
| **Flexible marked spatio-temporal point processes… football** (Narayanan et al.) | 2023 | Event-sequence football; methods + application central |
| **Bayesian state-space models… Premier League** (Ridall et al.) | 2025 | EPL prediction; application-driven methodology |
| **Dixon & Coles** — football scores inefficiency | 1997 | Classic Series C football benchmark |
| **Predicting outcomes of annual sporting contests** (Baker & Scarf) | 2006 | Rugby/cricket/football paired contests |
| **Ridge regression for paired comparisons… Premier League** (Varin & Firth) | 2024 | Paired football data; predictive criterion |

**Series C fit for empirical:** Strong if rugby/football stay in the **title** and cross-domain blocks are SI-only. Weak if main text reads as “general statistics paper with sports appendix.”

### Annals of Applied Statistics — closest precedents

| Paper | Year | Relevance |
|-------|------|-----------|
| **Spatiotemporal analysis of team sports** (Bornn et al.) | 2021 | Team sports + substantial methodology |
| **Expected points above average (NBA)** (Williams et al.) | 2025 | New metric + hierarchical Bayes + honest comparison to legacy metrics |
| **Athlete rating… rugby, fencing** (Che & Glickman) | 2024 | Rugby mentioned; monotone transforms for non-normal scores |
| **Fourth-down MDP / NFL risk** (Sandholtz et al.) | 2024 | Strategy + uncertainty quantification |
| **Miss it like Messi** | 2024 | Also AoAS-adjacent soccer analytics |

**AoAS fit for companion:** ψ scale, partition function, §7 falsifiability — matches AoAS depth. **AoAS fit for empirical:** Possible but slower review; sports must not feel secondary.

---

## Fit matrix (empirical paper)

| Criterion | JQAS | Series C | AoAS | EJSS/JSAMS |
|-----------|------|----------|------|------------|
| Rugby + football KPI spine | ●●● | ●● | ●● | ●●● |
| Bennett/Scott co-author fit | ●●● | ●● | ●● | ●●● |
| Distribution-free η + MI theory | ●● | ●●● | ●●● | ● |
| Quadrant exemplars (Strand 2 v2) | ●●● | ●● | ●● | ●● |
| No fitted η→ML surface in main | ●●● | ●●● | ●●● | ●● |
| Cross-domain (NHANES, finance…) | ● (SI) | ●● | ●● | ● |
| SI S1–S8 volume | ●●● | ●●● | ●●● | ● |
| Review timeline (typical) | ●● | ●● | ● | ●●● |
| Open access (2024+ JQAS S2O) | ●●● | ● | ● | ● |

Legend: ●●● strong · ●● moderate · ● weak

---

## Strand 2 v2 — journal alignment

Replacing pooled *r* = 0.033 with **one exemplar per quadrant** (with δ/σ_A, κ, ρ, η, ΔML) is *better* for all three statistical venues:

| Quadrant | Exemplar (pipeline) | η | δ/σ_A | ΔML | Theory check |
|----------|---------------------|---|-------|-----|----------------|
| Q1 | rugby `kick_metres` | 2.84 | 0.19 | +4.8% | η > 1, positive ΔML ✓ |
| Q2 | football `long_balls` | 1.30 | 0.16 | +4.4% | η > 1, positive ΔML ✓ |
| Q3 | football `passes` | 0.61 | 0.32 | −0.5% | strong negative ρ, η < 1, negative ΔML ✓ |
| Q4 | football `goalkeeper_long_balls` | 0.81 | 0.26 | +2.2% | η < 1 but positive ΔML — efficiency–power tension ✓ |

All four implemented in `tab:exemplars` in `results.tex` and annotated on Figure 3 (2026-06-25, Phase 1–2).

Counter-exemplar for Discussion: rugby `rucks_won` (Q2: η = 5.38, δ/σ_A = 0.07, ΔML = 0%) — highest η in dataset but zero ML gain due to negligible signal strength; confirms δ/σ_A is a necessary moderator even when η ≫ 1.

**`eq:dml_poly` retired** (2026-06-25, Phase 1): removes the main reviewer attack surface (“r = 0.033 contradicts your mapping equation”). Pooled correlation in `\PEFcorrEtaML` macro (Figure 3 caption); not a headline claim.

---

## Suggested title variants

### JQAS (primary)

1. **When should team KPIs be relativised? Paired efficiency, information content, and match-outcome prediction in rugby union and football**
2. **Relative versus absolute performance indicators in head-to-head sport: a paired efficiency framework for rugby and football**
3. **Beyond Fisher’s paired efficiency: choosing relative team metrics when variances differ** *(stats-forward; still JQAS-acceptable)*

### JRSS Series C (empirical backup)

1. **Paired efficiency factors for performance indicators in rugby union and English Championship football**
2. **Correlation-based variance reduction in competitive team sports: URC and Championship case studies**

### AoAS (empirical — only if willing to wait)

1. **Statistical efficiency versus predictive power for relativised team performance indicators**

### Companion (`pef-mathematics`)

| Venue | Title sketch |
|-------|----------------|
| **AoAS** | **Geometric structure of the paired efficiency factor: symmetries, partition functions, and Fisher–Rao coordinates** |
| **Series C** | **The paired efficiency factor η(κ, ρ): canonical form, numerical validation, and ψ-scale meta-analysis** |

---

## Submission packaging notes

| Item | JQAS | Series C / AoAS |
|------|------|-----------------|
| Main text length | ~8–12k words + SI typical | Similar; theory may move to supplement |
| Cross-domain table | Main or brief; detail in SI | Main text OK if application-led |
| Figure 3 | η surface + **four exemplar points** annotated | Same |
| `eq:dml_poly` | Omit main; optional SI footnote | Omit main |
| Companion cite | “Brown (in prep.)” + minimal ψ | Full cross-cite |
| Data/code | MATLAB pipeline README + repo | Same |

---

## Action checklist (pre-submit)

- [x] Implement Strand 2 v2 in `results.tex` / `theoretical_framework.tex` (exemplar table; retire poly mapping from main) — **done** 2026-06-25, `draft/strand2-reframe`
- [x] Reframe abstract: lead sports KPI question; η/MI as resolution of absolute-vs-relative debate — **done** 2026-06-25
- [x] Annotate Figure 3 with four exemplar points — **done** 2026-06-25 (Phase 2)
- [ ] `latexmk` compile — fix any undefined refs (Roadmap D1)
- [ ] JQAS cover letter: cite Scott 2023 URC + JQAS win-probability scepticism paper; emphasise **practitioner quadrant guide**
- [ ] Confirm co-author order with Bennett/Kilduff/Scott group (Roadmap D4)
- [ ] Author block, affiliations, data/code availability statement (Roadmap D2)
- [x] Mark roadmap **D3** complete — venue chosen: **JQAS** (primary)

---

*Scan sources: JQAS vol. 19–20 (2023–2024) contents + ahead-of-publication; Series C qlad085, qlae075; AoAS 18–19 (2023–2025); project `validation_inputs` and pipeline CSVs.*
