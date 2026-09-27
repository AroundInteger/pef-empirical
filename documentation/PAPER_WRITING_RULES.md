# Paper writing rules — `pef-empirical`

Inventory of the writing skills and house rules that govern the empirical PEF manuscript. This file records what is already implemented. It does not add new rules.

**Venue default:** *Journal of Quantitative Analysis in Sports* (JQAS). Sports spine first (rugby and football); supporting domains in the supplementary information.

**Language:** British English throughout (`recognised`, `behaviour`, `rigour`, `optimisation`, `generalised`).

---

## 1. Where the rules live

| Source | Applies when | What it governs |
|---|---|---|
| `.cursor/rules/latex-paper.mdc` | Editing `**/*.tex` | British English, maths, file structure, generated numbers, tone |
| `.cursor/rules/writing-clarity.mdc` | Editing `**/*.tex` and `Paper Review Process/**/*.md` | Sentence length, em dashes, one idea per sentence, section jobs |
| `.cursor/rules/figures.mdc` | Figures, figure scripts, captions | Type sizes, panel letters, legends, export |
| `documentation/PAPER_FORMATTING.md` | Author-facing | Why figures and captions are laid out as they are |
| `documentation/SUPPLEMENTARY_STRUCTURE.md` | SI edits | SI section order, figure labels, citation style |
| `Paper Review Process/abstract-structure-guide.md` | Abstract drafting and review | Five-part abstract, sentence digestibility |
| `Paper Review Process/review-communication.md` | Review sessions | Written quality and visual communication audit |
| `Paper Review Process/review-pef-papers.md` | Review sessions | Scope boundary, narrative traps, JQAS emphasis |
| `.cursor/rules/companion-paper.mdc` | Always | What this paper owns, and what stays in the companion |
| `.cursor/rules/project-context.mdc` | Always | Writing defaults, including “do not edit manuscript `.tex` unless asked” |

Agent default: do not edit manuscript `.tex` unless the user asks.

---

## 2. What this paper is allowed to claim

`pef-empirical` owns the empirical argument. The companion (`pef-mathematics`) owns geometry. Cite the companion; do not reproduce its proofs at length.

**This paper’s contributions**

- Distribution-free \(\eta = (1+\kappa)/(1+\kappa-2\sqrt{\kappa}\,\rho)\) and the four-quadrant taxonomy.
- Primary validation on rugby and football KPIs (seasons 23/24–24/25 pooled), plus supporting domains.
- Gaussian link \(\eta \leftrightarrow I(X;Y)\) under assumptions (A1)–(A2), labelled as such.
- Empirical machine learning: `home_win`, absolute versus relative KPI features.
- A weak global \(\eta\) to ML mapping, reported honestly.

**Leave in the companion**

- Canonical form in \(\tau\), the \(\kappa \leftrightarrow 1/\kappa\) involution, Möbius linearisation, Chebyshev and Poisson series.
- Sphere identity, partition function, Fisher–Rao coordinate \(\psi\), and the regime change at \(\rho = 0\).
- Do not promote \(\psi\) or partition-function proofs into empirical Results as primary contributions.

**Narrative traps (auto-flag in review)**

| If the draft says | The rule is |
|---|---|
| Sports KPIs populate Q4, or “sports = Q4” | Rugby and football are Q3-heavy (`outputs/pef_landscape_2season.csv`) |
| Strong global \(\eta\)–ML correlation | Retired from the headline; exemplars plus an honest limitation |
| `eq:dml_poly` in the main text | Absent from the main text; optional SI footnote only |
| Synthetic landscape ML script as KPI evidence | That script is Monte Carlo, not a KPI rerun |
| \(\psi\) or the partition function as an empirical result | Belongs in the companion |

**JQAS emphasis**

- Lead with the rugby and football KPI question and practitioner quadrant guidance.
- Absolute versus relative feature engineering is the core narrative.
- Cross-domain detail belongs in the SI; the main text stays sports-spined.
- Prefer *represent* or *formulate* over a vague *model* when the choice is absolute versus relative features.
- Modest claims. Empirical statements need a statistic or a citation.

---

## 3. Prose clarity

From `writing-clarity.mdc`, adapted from the Football-TDA / Paper A house style.

### Em dashes

Do not use an em dash as a parenthetical aside. In LaTeX that means avoid `---` and the Unicode em dash for clause interruptions.

Prefer a comma, a colon, or a new sentence.

Number ranges stay as en dashes: `$0.94$--$0.95$`, `23/24--24/25`.

At most one aside (a parenthesis or a short comma gloss) per sentence. Use none if the sentence already has a subordinate clause (*which*, *where*, *because*, *whilst*).

### One sentence, one message

1. One idea per sentence. Split independent claims.
2. Target 25–30 words. Rewrite anything over about 35.
3. At most one subordinate clause. Do not stack *because…, which…, where…*.
4. Put the subject and main verb early.
5. Do not pack a list in which every item carries an example, a rationale, and a citation. Use separate sentences or an `itemize` / `enumerate`.
6. Prefer full stops to semicolons. Reserve a semicolon for a tight, symmetrical pair.
7. One citation cluster per clause (`\parencite{…}`). Do not interleave several cite commands through one argument.
8. Read-aloud test: if a second pass is needed to find the main claim, split the sentence.

Before finishing a prose edit, skim for `---` asides and sentences over about 35 words.

### Section jobs

Every concept named in a heading should be addressed and evidenced in that section. Verbatim repetition of the heading word is not required.

Keep one section’s job out of another. Do not bury Results claims in Methods, or Discussion impact in the Introduction.

Functional roles for this manuscript (reviewers should not flag a missing IMRaD heading if the job is done under another title):

| Role | File |
|---|---|
| Methods / design | `sections/methodology.tex` |
| Theory / framework | `sections/theoretical_framework.tex` |
| Results | `sections/results.tex` |
| Discussion and close | `sections/discussion.tex`, `sections/conclusion.tex` |

Review checks that sit on top of the house style (`review-communication.md`):

- Introduction funnels from context to gap to this paper’s contributions, and promises only what the paper delivers.
- Methods are in the order applied, with key choices justified, in past tense.
- Results report findings; interpretation belongs in the Discussion when the journal splits those sections.
- Every estimate carries uncertainty unless it is a count or an exact value.
- The Discussion opens by answering the research question, separates interpretation from speculation, and states specific limitations.
- The Conclusion adds no new claims, results, or references.

---

## 4. LaTeX conventions

From `latex-paper.mdc` and `review-pef-papers.md` §9.

- Greek letters in math mode: `$\eta$`, `$\kappa$`, `$\rho$`, `$\psi$`. Do not type Unicode κ or ρ in `.tex`.
- Displayed equations use `\begin{equation}...\end{equation}` with `\label{eq:...}`, cited as `\ref{eq:...}` (or `\cref`).
- Fractions use `\frac{}{}`. Subscripts use braces: `$\sigma^2_A$`.
- One `\section` per file under `sections/`. `main.tex` holds the preamble and `\input` lines only.
- Cite figures and SI sections with `\cref{…}`, not a hard-coded “Figure 4” or a frozen S-number.
- `sections/` is authoritative. Review markdown is exported from it (`Paper Review Process/export_sections_to_md.py`).

### Generated numbers

Counts and pipeline statistics come from:

```latex
\input{scripts/paper_pipeline/outputs/numbers.tex}
```

Do not hand-edit macro values that the pipeline owns. After a numeric change, re-run `scripts/paper_pipeline/run_paper_pipeline.m`, then commit outputs only if asked.

Macro names are letter-only after `\`. A digit inside the name breaks TeX parsing (`\PEFkappaL2Pass` is read as `\PEFkappaL` plus `2Pass`). `write_numbers_tex` skips invalid names. See `README.md`, section “LaTeX numeric inputs”.

Stale `???` placeholders are treated as significant or critical near submission.

---

## 5. Abstract

Canonical file: `sections/abstract.tex`. Guide: `Paper Review Process/abstract-structure-guide.md`. Target register: an informed sports analyst who remembers introductory statistics.

**Five rhetorical moves, about 230–270 prose words. No equations.**

| Part | Job | In the current abstract |
|---|---|---|
| 1. Background | Situate the domain | Paragraph 1, sentence 1: absolute versus relative KPIs |
| 2. Problem | State the gap | Paragraph 1, sentence 2: relativisation sometimes helps and sometimes does not |
| 3. Methods | Plain language, not a Methods paste | Paragraph 2: measurable properties, then PEF, then Fisher in words, then univariate scope |
| 4. Key results | Some numbers, honest scope | Paragraph 3: scale, four regimes, Q3-dominant pattern, efficiency–information tension |
| 5. Conclusion | One idea only | Paragraph 4: one sentence, ad hoc choice to a transparent diagnostic |

**Sentence rules specific to the abstract**

- One *which* clause on a noun. Do not chain two.
- Motivate before naming classical results. Say what is measurable (variability, co-movement) before naming Fisher. Do not open with a formula.
- Do not start a sentence with *Because*. Prefer context, then the action.
- No \(\eta\), \(\kappa\), \(\rho\), \(\delta/\sigma_A\), (A1)–(A2), or quadrant labels in the abstract. Use words: variability, co-movement, four regimes, information about the outcome.
- Study scale and one headline pattern, plus one tension finding. Do not reproduce tables, exemplar KPI names, or the full cross-domain catalogue.
- Univariate scope is a Methods sentence, not a disclaimer paragraph.
- Conclusion pattern: the tool turns an old practice into a new practice. No new methods and no new numbers.
- Define KPI on first use. Sports names in the background or results; cross-domain as one clause.
- Honest ML: the abstract claims regime and exemplar logic, not a universal \(\eta\) to ML mapping.

Review flags equations, axiom labels, sentence-initial *Because*, and chained *which* clauses as significant on a submission draft.

---

## 6. Figures and captions

Author rationale: `documentation/PAPER_FORMATTING.md`. Agent sizes: `.cursor/rules/figures.mdc`. Implementation: `scripts/paper_pipeline/lib/pef_figure_style.m` (`config`, `add_panel_letter`, `style_scatter_axes`, `export_figure`). Do not set font sizes or titles by hand in published figure scripts.

Diagnostic notebooks and the synthetic ML / probit smoke plots are exempt.

### What each main figure is for

| Figure | Job | On the plot | Off the plot |
|---|---|---|---|
| 1 | \(\eta\) landscape and confirmatory anchors | Four exemplars with season drift; supporting-domain mean triangles | Full rugby/football KPI cloud |
| 2 | \(I(X;Y)\) surface at \(\delta/\sigma_A = 1\) | Same exemplars and triangles as Figure 1 | Full KPI cloud; extra \(\delta/\sigma_A\) slices |
| 3 | Confirmatory \(\eta\) versus \(\Delta\mathrm{ML}\) | Four exemplars at matched signal, plus the rucks-won foil | Full inventory scatter |

The unmarked KPI cloud is Supplementary Figure S4. The \(I_{\mathrm{pred}}\) versus \(\Delta\mathrm{ML}\) inventory is S5. Captions and Methods must match what the script actually draws.

### Type (print hierarchy)

| Element | Size |
|---|---|
| Axis labels, colourbar labels, legends, panel letters | 18 pt (panel letters bold) |
| Tick labels, Q1–Q4 tags | 16 pt |
| KPI names, \(n=\), notes | 12 pt |
| Contour labels | 10 pt |

Export at 300 dpi on a white background. Every numeric label on one axis uses the same number of decimal places.

### Layout

- No axes `title` or `sgtitle`. The narrative lives in the LaTeX caption.
- Multi-panel letters `(A)`, `(B)`, `(C)` sit inside the axes, default northwest, no white patch. Single-panel figures need no letter.
- Captions in `sections/tables_and_figures.tex` and `sections/supplementary.tex` use (A), (B), (C) to match. Do not open a caption by restating a figure title.
- Legends at 18 pt, box off, in empty space. If a KPI name has no free slot, omit the name and keep the marker.
- Quadrant colours: Q1 green, Q2 blue, Q3 orange, Q4 red.
- Landscape limits: \(\rho \in [-0.999, 0.999]\), \(\kappa \in [0.001, 3]\).
- Bar charts of non-negative summaries start at zero.

### Regeneration

| Figure | Script |
|---|---|
| 1 | `scripts/paper_pipeline/regen_fig1.m` |
| 2 | `scripts/paper_pipeline/regen_fig2.m` |
| 3 | `scripts/matlab_figures/regenerate_figure_3_from_outputs.m` |
| Printed S1–S5 | `scripts/matlab_figures/generate_all_si_figures.m` |

After a plotting change, update the caption in the same edit.

---

## 7. Supplementary information

From `documentation/SUPPLEMENTARY_STRUCTURE.md`. Three blocks, in this order. Figures S1–S5 are numbered by order of appearance. Disk file names keep generator tags and need not match the printed number.

| SI section | Contents |
|---|---|
| §1 Theoretical derivations | \(\tau = \tfrac12\log\kappa\), \(I(X;Y)\) algebra, Pitman ARE, Figure S1 |
| §2 Idealised probit validation | Specification, validations 2–4, Figures S2–S3 |
| §3 Empirical analysis | Figures S4–S5, Table S1, quality control |

Design rules:

1. Specification and figures for the same analysis stay in the same SI section.
2. Each SI section opens with a short bridge (2–4 sentences) to the main text.
3. Main text cites `\cref{fig:si_...}`, `\cref{tab:si_...}`, `\cref{sec:si_...}`.
4. Script paths, CSV names, and the practitioner schema live in `README.md`, not in the SI body.
5. Do not freeze old S-numbers with `\setcounter{figure}`.

Table S1 is the only SI table. There are no numbered “Note S” labels.

---

## 8. How review skills use these rules

The Paper Review Process skills do not replace the Cursor rules. They audit the manuscript against them.

| Skill | Writing job |
|---|---|
| `abstract-structure-guide.md` | Draft and revise the abstract before word-level polish |
| `review-communication.md` | Line-level clarity, section flow, figure and table standards |
| `review-pef-papers.md` | Scope boundary, narrative traps, JQAS versus companion voice |
| `project-instructions.md` | Read the applicable skills before a review; separate writing issues from scientific issues; every criticism needs a fix |

Default review order for a full pass: calibration, then science, then communication, then severity. A partial revision does not re-run the full review.

The review system does not ghostwrite submission prose. It gives structure, annotated direction, and suggested rewording.
