# Abstract structure guide — `pef-empirical` (JQAS-facing)

**Purpose:** Reusable template for the empirical PEF abstract and for revising abstracts in review sessions.  
**Canonical example:** `sections/abstract.tex` (adopted 2026-07-03).  
**Target:** ~250 words of prose; self-contained; clarity over jargon.

---

## 1. Macro structure (five parts → four paragraphs)

Map the abstract to **exactly five rhetorical moves**. Unstructured JQAS abstracts still benefit from this internal skeleton.

| Part | Rhetorical job | Length | PEF empirical paragraph |
|------|----------------|--------|-------------------------|
| **1. Background** | Situate the reader in the application domain | 1–2 sentences | Para 1, sentence 1: absolute vs relative KPIs in head-to-head sport |
| **2. Problem / objective** | State the gap or question | 1 sentence | Para 1, sentence 2: relativisation sometimes helps, sometimes not; no general account |
| **3. Methods** | What you did, in plain language (not Methods-section paste) | 2–4 short sentences | Para 2: measurable properties → PEF → Fisher in words → efficiency vs information → deliberate univariate scope |
| **4. Key results** | Findings with **some** numbers; honest scope | 2–4 sentences | Para 3: 113 KPIs, leagues, four regimes, Q3-dominant pattern, efficiency–information tension, exemplars, cross-domain |
| **5. Conclusion** | Broader impact; one idea only | 1 sentence | Para 4: ad hoc choice → transparent diagnostic |

**Paragraph rule:** One paragraph per “block” above is fine, but **Methods** may need a full paragraph; **Conclusion** must stay a single sentence.

---

## 2. Sentence-level rules (digestibility)

These rules produced the readable abstract revision (2026-07-03). Apply in order when drafting or editing.

### 2.1 One sentence, one job

- Do not chain two *which* clauses on one noun (“PEF, which … and which …”). Split into separate sentences.
- **Good pattern:** Introduce acronym → sentence 2 on generalisation → sentence 3 on second property.

**Example (PEF):**

```
We combine these into the Paired Efficiency Factor (PEF), which generalises Fisher's …
The PEF also connects a KPI's statistical efficiency to …
```

### 2.2 Motivate before naming classical results

- Do not open with Fisher, formulas, or Greek symbols.
- First say **what measurable properties of the data matter** (variability, co-movement within a match).
- Then introduce Fisher as “classical efficiency result for paired measurements” **in words**, not $1/(1-\rho)$.

### 2.3 Context before decision (avoid sentence-initial *Because*)

- Abstracts should not start a sentence with *Because* — it reads as a footnote or apology.
- Prefer **context → so → action**:

**Avoid:**

```
Because KPIs can interact in complex ways when combined, we deliberately …
```

**Prefer:**

```
Combined KPIs can interact in complex ways in predictive models, so we deliberately analyse each one on its own, …
```

Alternative: lead with the scope decision (“We analyse each KPI on its own …”) and fold the reason in mid-sentence with *since* or a semicolon.

### 2.4 Plain language before notation

| Avoid in abstract | Prefer |
|-------------------|--------|
| $\eta$, $\kappa$, $\rho$, $\delta/\sigma_{\mathrm{A}}$ | variability, co-movement, variance increases, signal strength (or omit) |
| Equations | None in JQAS-facing abstract |
| (A1)–(A2), mutual information in symbols | “how much information its relative form carries about the outcome” |
| “distribution-free diagnostic” without setup | “data-informed diagnostic” after PEF is defined in words |
| Q1–Q4, quadrant taxonomy | “four regimes that indicate whether relativisation should help” |

Symbols and axioms belong in the **body**; the abstract sells the story.

### 2.5 Quantitative results: sparing but concrete

- Include **study scale** (pooled KPI count via `\PEFtotalStudies`; sport names only—omit league and match totals).
- Include **one headline pattern** (e.g. most KPIs anti-correlate → absolute usually preferable).
- Include **one tension finding** (relative can help even when variance rises).
- Do not reproduce tables, exemplar KPI names, or full cross-domain catalogue.

### 2.6 Scope and limitations as a methods sentence, not a disclaimer paragraph

- If the paper is deliberately univariate, say so in **Methods**, not Conclusion.
- Link to practitioner reality: multivariate models are the norm; single-KPI analysis is the **foundation**.

### 2.7 Conclusion: imperative and practical

- One sentence; no new methods, no new numbers.
- Pattern: **[Tool] turns [old practice] into [new practice].**

**Example:**

```
The PEF turns an ad hoc feature-engineering choice into a transparent, data-informed diagnostic for when to relativise performance metrics in competitive prediction.
```

---

## 3. Tone consistency

The abstract failed earlier review when **paragraph 1 read like a story** and **paragraphs 2–3 read like a methods preprint** (equations, axioms, dense clauses).

**Target register throughout:** informed sports analyst who remembers introductory statistics — not a theorem-first statistics journal.

Check: read paragraph 2 aloud after paragraph 1; if the voice shifts, simplify paragraph 2.

---

## 4. JQAS-specific notes

- **Word count:** Aim ~230–270 prose words (LaTeX `wc` over-counts macros and markup).
- **Sports spine:** Rugby + football in Background or Key results; cross-domain one clause in results, not a second methods lecture.
- **Honest ML:** Pooled η→ML weak globally; abstract claims **regime/exemplar** logic, not universal mapping.
- **Abbreviations:** Define KPI on first use; avoid undefined acronyms (URC/Championship names spelled out once).

---

## 5. Annotated walkthrough (current `abstract.tex`)

**Paragraph 1 — Background + Problem**

1. *Background:* head-to-head sport; absolute vs relative KPI framing.  
2. *Problem:* prediction sometimes improves, sometimes not; no general account.

**Paragraph 2 — Methods (four sentences, four jobs)**

1. *Bridge:* answer = two measurable properties (variability; co-movement).  
2. *Introduce PEF + Fisher:* one *which* clause only; unequal-variance sport hook.  
3. *Second property of PEF:* efficiency vs information (words, not MI formula).  
4. *Scope:* combined KPI interaction → deliberate univariate analysis → foundation for multivariate practice.

**Paragraph 3 — Key results**

1. *Design:* 113 KPIs, two leagues (macros for match counts).  
2. *Main pattern:* four regimes; anti-correlation dominant; absolute usually preferable.  
3. *Tension:* variance can rise yet prediction improves; efficiency ≠ information.  
4. *Validation:* exemplars confirm direction; cross-domain alignment (one sentence).

**Paragraph 4 — Conclusion**

1. *Impact:* ad hoc → transparent diagnostic for relativisation.

---

## 6. Pre-submission checklist

- [ ] Five parts present (Background → Problem → Methods → Results → Conclusion)
- [ ] No displayed equations; no (A1)–(A2) in abstract
- [ ] No sentence begins with *Because*
- [ ] No sentence with two chained *which* clauses on PEF/η
- [ ] Fisher (if named) appears after KPI variance/covariance motivation
- [ ] Univariate scope stated if paper is single-KPI (Methods sentence)
- [ ] Conclusion is one sentence; no new claims
- [ ] Word count ~250 (±30) prose
- [ ] `\PEF…` macros compile (pipeline current)

---

## 7. Use in review workflow

- **Mode A (full review):** Compare abstract to §5–6 checklist; flag register shift between paragraphs.
- **Mode B (abstract revision):** Apply §2 sentence rules before debating word-level polish.
- **Author drafting:** Start from §1 table (five sentences minimum), then expand Methods and Results to short paragraphs.

Cross-reference: `review-communication.md` §2.1; `review-pef-papers.md` §7 (JQAS emphasis).
