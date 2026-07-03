# SKILL: Communication Quality Review
**File:** `review-communication.md`  
**Role:** Audit writing quality, argument structure, and visual/figure communication  
**Read after:** `review-science.md`

---

## 1. Purpose

Excellent science communicated poorly is routinely rejected. This skill audits the two components of communication that most commonly determine whether a paper is accepted or rejected by reviewers who have already judged the science sound: (A) written quality and (B) visual communication. These are reviewed separately because they require different expertise and have different remediation paths.

---

## 2. Part A — Written communication audit

### 2.1 Abstract quality

The abstract is the most-read part of any paper and the primary filter for reviewers. Evaluate it independently:

- **Structure (for structured abstracts):** Are all required sections present (Background, Methods, Results, Conclusions / Objectives, Design, Setting, etc.)?
- **Structure (for unstructured abstracts):** Does it cover: why this matters, what was done, what was found, what it means?
- **Standalone completeness:** Can a reader understand the contribution without reading the paper?
- **Claim accuracy:** Do the abstract's claims accurately represent the paper's findings? (Overclaiming in the abstract is a frequent and damaging error)
- **Specificity:** Are quantitative results reported in the abstract (with effect sizes, not just "significant improvement")? Vague abstracts are a red flag
- **Length:** Is it within the venue's word limit?
- **No undefined abbreviations:** Every abbreviation in the abstract must be defined in the abstract itself

**PEF empirical (`pef-empirical`):** Apply the five-part structure and sentence-level rules in `abstract-structure-guide.md` (JQAS-facing; canonical example in `sections/abstract.tex`). Flag equations, axiom labels, sentence-initial *Because*, and chained *which* clauses as [SIGNIFICANT] for submission drafts.

### 2.2 Introduction
- **Funnel structure:** Does the introduction move from broad context → specific problem → gap in knowledge → this paper's approach → overview of contributions? Absence of this structure leads to introductions that fail to justify the work
- **Problem motivation:** Is the problem clearly motivated? Does the reader understand why this problem matters?
- **Gap identification:** Is the gap in existing knowledge clearly and specifically identified? "Little is known about X" without evidence is not a gap statement
- **Contribution statement:** Is there an explicit statement of contributions (what this paper does, not just what the field needs)? This should be specific and enumerable
- **Scope:** Does the introduction promise only what the paper delivers?

### 2.3 Methods / Methodology section
- **Replication sufficiency:** Could an expert in the field reproduce the methods from this description alone?
- **Sequence:** Are methods presented in the order they were applied?
- **Justification of choices:** Are key methodological choices justified (not just described)? "We used random forest because it handles non-linear relationships and provides feature importance" > "We used random forest"
- **Parameters and settings:** Are all parameters reported?
- **Appropriate tense and voice:** Methods are conventionally past tense; passive vs active depends on venue style — flag inconsistency
- **Forward references:** Does the methods section refer to results not yet shown? If so, flag

### 2.4 Results section
- **Separation from interpretation:** Are results and their interpretation kept separate? (In journals using a Discussion section, results should report findings without extensive interpretation)
- **Complete reporting:** Are all analyses described in the methods reported in results? (Missing analyses suggest post-hoc selection)
- **Figure/table integration:** Is the text directing the reader to specific results in figures/tables, and does this guidance add interpretive value beyond what the figure caption already says?
- **Numerical precision:** Are numbers reported to appropriate significant figures? (5.3127 ± 0.0003 and 5.31 ± 0.0003 are both fine; 5.3127 ± 0.3 suggests false precision)
- **Uncertainty everywhere:** Every reported estimate should have an associated uncertainty (CI, SD, SE, range) unless the quantity is a count or exact value

### 2.5 Discussion
- **Addresses the research question:** Does the discussion open by directly answering the research question?
- **Contextualisation:** Are findings situated in the literature? Are they compared explicitly to prior work?
- **Interpretation vs speculation:** Is the distinction between interpretation (supported by data) and speculation (possible explanations) maintained?
- **Limitations:** Are limitations discussed honestly and specifically? Generic limitations ("larger sample sizes would be beneficial") are insufficient — the limitation should connect to a specific finding or inference
- **Implications:** Are practical/theoretical implications stated? Are they appropriately hedged?
- **Future directions:** Are future directions grounded in the actual findings, not generic extensions?

### 2.6 Conclusions
- **No new information:** Conclusions should not introduce new claims, results, or references not already in the paper
- **Direct answer to research question:** Does the conclusion directly and explicitly answer the research question?
- **Appropriate scope:** Conclusions should not exceed what the data support
- **Brevity:** Conclusions should be concise; a conclusion that repeats the abstract word-for-word is poor practice

### 2.7 Language and clarity
Apply the following line-level checks. These are [POLISH] level unless they systematically obscure meaning (which elevates them to [SIGNIFICANT]):

- **Precision:** Are technical terms used precisely and consistently? Flag any term used with different meanings in different parts of the paper
- **Hedging calibration:** Is uncertainty appropriately hedged? Both under-hedging ("this proves") and over-hedging ("this might possibly perhaps suggest") are problems
- **Sentence complexity:** Flag paragraph-length sentences that can be split without loss of meaning
- **Passive voice overuse:** Acceptable in methods; excessive throughout introduction and discussion weakens voice
- **Jargon calibration:** Is jargon appropriate for the target venue? Interdisciplinary work requires more lay explanation
- **Consistency:** Are technical terms, abbreviations, and proper nouns consistent (e.g. "support vector machine" vs "SVM" vs "Support Vector Machine" all appearing in one paper)
- **Tense consistency:** Past tense for methods and results; present tense for established facts and discussion of figures

### 2.8 Structure and flow
- **Section balance:** Are sections proportioned appropriately? (A 300-word methods section and a 2000-word results section suggests under-described methodology)
- **Signposting:** Does the paper guide the reader through its structure? Are transitions between sections clear?
- **Internal cross-references:** Does the text reference the correct figure/table numbers?
- **Paragraph structure:** Does each paragraph have a clear topic sentence and a single main point?

### 2.9 Non-IMRaD and theory-first papers

Standard IMRaD checks still apply by **function**, not section title. When a paper uses a non-standard structure:

| Functional role | PEF empirical examples | PEF companion examples |
|---|---|---|
| Methods / design | `methodology.tex`, three-tier validation | Proof setup in theory sections |
| Theory / framework | `theoretical_framework.tex` | `canonical_form.tex` … `fisher_rao.tex` |
| Results | `results.tex`, SI figures S1–S8 | `numerical_validation.tex` (imported CSVs) |
| Discussion | `discussion.tex`, `conclusion.tex` | `discussion.tex` |

**Do not** flag “missing Methods” if replication detail appears under an equivalent section — flag **replication sufficiency** instead.

**PEF empirical:** Evaluate whether landscape characterisation vs quadrant exemplar roles are signposted clearly in abstract, methods, and results (Strand 2 v2).

**PEF companion:** Evaluate whether §7 prose matches CSV columns and manifest commit; figures cite pipeline outputs, not hand-typed numbers.

**Generated numbers:** Empirical `\input{numbers.tex}` macros must not be hand-edited; flag stale `???` placeholders as [SIGNIFICANT] or [CRITICAL] near submission.

---

## 3. Part B — Visual communication audit

### 3.1 General figure standards
Apply to every figure in the document:

- **Self-contained:** Can each figure be understood from its caption alone, without reading the text? If not, the caption is incomplete
- **Necessity:** Does the figure add information not already conveyed in the text? Decorative figures waste space
- **Resolution:** Is the figure at publication quality? (300 dpi minimum for raster; vector preferred for line plots and diagrams)
- **Font size:** Is all text in the figure legible at print size? Text below 7pt is typically unreadable in print
- **Colour accessibility:** Is the colour palette accessible to colour-blind readers? (Red-green combinations are a known failure; check against Ishihara-type criteria). Note if not assessed
- **Caption completeness:** Does the caption include: what is shown, what the axes represent (with units), what the error bars represent, sample sizes, and statistical test details where relevant?

### 3.2 Data visualisation rigour

**Axes and scales**
- Are y-axes zero-based where a non-zero baseline would be misleading? (Bar charts with truncated y-axes are a common misleading practice)
- Are axes labelled with units?
- Are axis limits appropriate — not zoomed to exaggerate effect sizes?
- For log scales: is the log scale clearly labelled and justified?

**Uncertainty representation**
- Are error bars present on all plots where variability exists?
- Is the error bar type specified? (SD, SE, 95% CI are not interchangeable and must be labelled)
- For box plots: is the notch type and whisker definition specified?
- For shaded regions around curves: is the shading type specified?

**Overplotting and distribution display**
- For small-to-moderate n: are individual data points shown (either as raw points, beeswarm, or strip plots) rather than hidden behind a mean ± SD?
- For large datasets: are density representations appropriate (violin, KDE) rather than sparse scatter?
- **Best practice note:** Bar + error bars that hide the distribution are increasingly considered poor practice at leading journals; suggest violin + jitter where sample size permits

**Statistical annotation**
- Are significance annotations correct? (p < 0.05 marked * only if the test is specified; "ns" labels are good practice)
- Are multiple comparisons corrections reflected in significance annotations?

**Figure types — common specific issues**

*Line plots:* Are lines only connecting data points where interpolation is meaningful? (Connecting discrete categorical data with lines implies continuity)

*Scatter plots:* Is overplotting addressed (alpha transparency, jitter) for large n? Is a regression line shown only when a statistical model justifies it?

*Heatmaps:* Is the colour scale specified? Is the scale diverging (when zero is meaningful) or sequential? Are dendrograms based on a stated distance metric and linkage method?

*Network/graph visualisations:* Is the layout algorithm specified? Are node and edge attributes described?

*Geographical maps:* Is the projection specified? Are regional boundaries sourced and the source cited?

*Flow diagrams (CONSORT, PRISMA):* Are participant/study flow numbers consistent with the reported sample sizes in the text?

**PEF empirical figures (when present):**
- **Landscape (Figure 1 / `pef_landscape`):** Caption and text must not mischaracterise quadrant occupancy (rugby/football inventory is Q3-heavy, not “mostly Q4”)
- **η surface + ML (Figure 3):** Four quadrant exemplar points annotated and consistent with `tab:exemplars`; pooled \(\eta\)–ML correlation not presented as headline if main text retires global mapping claims
- **SI volume (S1–S8):** Captions self-contained; cross-ref from main text sufficient for submission

**PEF companion figures:**
- **Sphere realisation (Figure 4):** Consistent with §4 equations and numerical residuals in §7

### 3.3 Schematics and conceptual figures
- **Accuracy:** Does the schematic correctly represent the described process or system? (Inaccurate conceptual figures are [SIGNIFICANT])
- **Completeness:** Are all key components shown?
- **Directionality:** If the schematic shows a process or workflow, is directionality unambiguous?
- **Labels:** Are all components labelled or enumerable from the caption?
- **Consistency with text:** Does the schematic match the textual description exactly?

### 3.4 Tables
- **Necessity:** Could the table be replaced by a figure that better communicates trends? Or by one or two sentences? If so, suggest the alternative
- **Structure:** Are rows and columns the right way round? (Variables in columns, observations in rows is standard)
- **Headers:** Are column headers clear, with units where applicable?
- **Alignment:** Numbers in columns should be right-aligned or decimal-aligned (not centre-aligned)
- **Rounding:** Are values in a column rounded consistently?
- **Footnotes:** Are abbreviations in table footnotes, not in column headers?
- **Significance stars:** If used, are they defined in a footnote?

### 3.5 Equations (in figures and text)
- **Consistency with text:** Does the equation notation match the notation defined in the text?
- **Numbering:** Are equations that are referenced from elsewhere numbered?
- **Typesetting:** Are equations typeset correctly (not as plain text or screenshots)?

---

## 4. Grant-specific communication checks

For UKRI grant applications, the communication standard differs from journal papers. Apply these additional checks:

### 4.1 Case for Support — narrative structure
- **First page impact:** The first page must orient a non-specialist panel member to the problem and its significance within ~3 paragraphs. Does it?
- **Logical argument chain:** Challenge → gap → approach → outcome. Is this chain explicit and compelling?
- **Concrete benefits:** Are beneficiaries of the research named specifically (not just "the research community" or "society")?
- **Plain language:** Can the first two pages be understood by an intelligent non-specialist? Panel members from adjacent fields will read these pages

### 4.2 Impact case
- **Specificity:** Generic impact statements ("this work could inform policy") are weak; name the policy area, the mechanism of influence, and the realistic timeline
- **Pathways credibility:** Are the pathways to impact credible? Does the team have the connections and capacity to realise them?
- **Non-academic beneficiaries:** Are genuine non-academic beneficiaries identified, not just downstream academic impact?

### 4.3 Work plan legibility
- **Gantt chart clarity:** Can work packages, milestones, and dependencies be understood without reading the full proposal?
- **Milestone concreteness:** Are milestones observable outcomes (not "ongoing work")?
- **Personnel allocation:** Is FTE allocation visible and consistent with budget?
- **Risk legibility:** Does the risk register use plain language? (Risk descriptions should be understood by a non-specialist panel member)

---

## 5. Communication review output format

```
COMMUNICATION AUDIT

Abstract
  [severity] [issue] — [resolution]

Introduction
  [severity] [issue] — [resolution]

Methods
  [severity] [issue] — [resolution]

Results
  [severity] [issue] — [resolution]

Discussion / Conclusions
  [severity] [issue] — [resolution]

Language and clarity
  [severity] [issue] — [resolution]

VISUAL COMMUNICATION AUDIT

Figure [N] — [brief descriptor]
  [severity] [issue] — [resolution]

Tables
  [severity] [issue] — [resolution]

Schematics / diagrams
  [severity] [issue] — [resolution]
```

Pass findings to `review-outputs.md` for integration with science audit and final report generation.
