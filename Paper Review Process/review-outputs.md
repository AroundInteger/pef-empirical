# SKILL: Review Outputs and Report Generation
**File:** `review-outputs.md`  
**Role:** Severity triage, report formatting, iterative feedback management, UKRI and journal-specific output generation  
**Read after:** `review-communication.md`

---

## 1. Purpose

The findings from the science and communication audits must be assembled into output that is maximally useful to the author. This skill handles: (A) severity triage and prioritisation, (B) structured journal reviewer report generation, (C) UKRI grant feedback generation, (D) iterative revision feedback, and (E) format selection logic.

### Format selection

| Mode | Document | Output format |
|---|---|---|
| A — First-pass full review | Journal paper | Format A (peer review report) |
| A — First-pass full review | UKRI grant | Format B (grant assessment) |
| B — Iterative revision | Any | Format C (revision review) |
| C — Targeted query | Any | Format D (targeted response) |
| D — Joint consistency | PEF empirical + companion | **Joint format** in `review-pef-papers.md` §8 (not Format A/B) |

For PEF manuscripts in Mode A, include scope/pipeline findings from `review-pef-papers.md` in Format A under Major Concerns as appropriate.

---

## 2. Severity triage protocol

Before writing any output, consolidate all findings from `review-science.md` and `review-communication.md` into a unified severity-ranked list. Apply the following definitions consistently:

### 🔴 CRITICAL
An issue that, if unresolved, will or should result in rejection. The paper/grant cannot be submitted in its current state.

**Examples:**
- A causal claim made from cross-sectional data
- Temporal data leakage in an ML pipeline (random split of time-series)
- A theorem proof with a logical gap that cannot be patched without additional work
- A UKRI application missing a required section (Pathways to Impact, budget justification)
- Results that contradict the stated conclusions
- An undisclosed conflict of interest or ethics statement absent where required
- Claimed novelty that is demonstrably not novel (identified prior work)

**PEF-specific examples (see `review-pef-papers.md`):**
- Companion §7 numbers contradict `validation_inputs/` or stale `_manifest.csv`
- Empirical main text headlines retired global \(\eta\)–ML mapping or companion-only \(\psi\)/geometry proofs
- Scope creep: six-domain ML claimed as new in companion, or sports landscape mischaracterised as Q4-dominant

**Guidance:** Use CRITICAL sparingly. If everything is critical, nothing is. A paper with more than 4–5 critical issues is probably not close to submission.

### 🟠 SIGNIFICANT
An issue that substantially weakens the work and should be addressed before submission, but does not alone render the work unpublishable if other sections are strong.

**Examples:**
- Missing key control/baseline comparison
- Inadequate description of methodology (replication uncertain)
- No power calculation or sample size justification
- Multiple comparisons not corrected for
- Key related work not cited, making novelty claim weaker than it could be
- Figure that misleads (truncated axis, unlabelled error bars)
- Abstract overclaims relative to results
- UKRI work plan with implausible timelines

**Guidance:** Most papers have 3–8 significant issues. Addressing these is typically the difference between major revision and minor revision.

### 🟡 POLISH
An issue that a professional would notice but that does not substantially affect the scientific contribution or the probability of acceptance at a reasonable venue.

**Examples:**
- Inconsistent notation
- Suboptimal figure font size
- Awkward phrasing or unnecessarily complex sentences
- Superfluous words in the abstract
- Minor citation formatting errors
- Discussion section that is repetitive
- Colour palette not optimally accessible

**Guidance:** Polish issues should be listed but clearly labelled as lower priority. Do not mix them in with significant issues.

### ✅ STRENGTHS
Genuine strengths that should not be changed. Be specific — "well written" is not useful; "the motivation in the introduction is compelling and clearly situates the gap in the literature" is.

---

## 3. Format A — Journal peer review report

Use this format for Mode A (first-pass) review of a paper targeting a journal.

This report mimics the style of a formal peer reviewer letter. It should be constructive, specific, and signed off with a recommendation.

```
─────────────────────────────────────────────────────────
PEER REVIEW REPORT
Paper: [Title]
Field: [Field → sub-discipline]
Target venue: [Journal], Tier [X]
Review type: First-pass / Revision round [N]
─────────────────────────────────────────────────────────

OVERALL ASSESSMENT

[2–4 sentence summary of the paper's core contribution and current standing.
 Be honest about both strengths and weaknesses. This paragraph is read first
 by the editor and sets the tone for the rest of the report.]

RECOMMENDATION: [Accept / Minor revision / Major revision / Reject and resubmit / Reject]

Rationale: [1–2 sentences justifying the recommendation in terms of the specific
            critical/significant issues identified below]

─────────────────────────────────────────────────────────
MAJOR CONCERNS (must be addressed)

[Number each concern. Each concern should contain:
  (a) The specific issue
  (b) Where it occurs (section, page, equation number, figure number)
  (c) Why it matters
  (d) A specific suggested resolution — not "the authors should address this"
      but "the authors should report X, or alternatively justify Y by citing Z"]

1. [Issue] (§[section] / Fig. [N] / Eq. [N])
   [Why it matters]
   [Suggested resolution]

2. ...

─────────────────────────────────────────────────────────
MINOR CONCERNS (should be addressed, will not block acceptance if sound explanation given)

1. ...
2. ...

─────────────────────────────────────────────────────────
OPTIONAL SUGGESTIONS (POLISH — author's discretion)

- [suggestion]
- [suggestion]

─────────────────────────────────────────────────────────
SPECIFIC COMMENTS BY SECTION

Abstract: [comment or "No issues"]
Introduction: [comment or "No issues"]
Methods: [comment or "No issues"]
Results: [comment or "No issues"]
Discussion: [comment or "No issues"]
Conclusions: [comment or "No issues"]
Figures: [figure-by-figure comments or "No issues"]
References: [comment or "No issues"]
─────────────────────────────────────────────────────────
```

### Recommendation calibration

Apply the following standards when selecting a recommendation:

| Recommendation | When to use |
|---|---|
| **Accept** | No critical issues; minor issues are cosmetic only; paper makes a genuine contribution |
| **Minor revision** | No critical issues; 1–4 significant issues that can be resolved without new experiments/analyses |
| **Major revision** | 1–3 critical issues that require additional work but are addressable; the core contribution is sound |
| **Reject and resubmit** | Fundamental methodological changes needed, OR the paper needs to be substantially rewritten, but the core idea has merit |
| **Reject** | Critical flaw in premise or methodology that cannot be addressed without essentially doing a different study; OR novelty is genuinely absent |

**Note:** Never recommend Reject for writing quality alone unless the writing is so poor the science cannot be evaluated. Writing can be fixed; science cannot always be.

---

## 4. Format B — UKRI grant feedback report

Use this format for Mode A review of a UKRI grant application. This report mimics the style of an expert reviewer assessment submitted to a UKRI panel.

```
─────────────────────────────────────────────────────────
GRANT REVIEW ASSESSMENT
Scheme: [EPSRC / MRC / ESRC / Innovate UK / HCRW / ...]
Call / panel: [if identifiable]
PI: [if named]
Title: [as stated]
─────────────────────────────────────────────────────────

EXCELLENCE OF THE RESEARCH / QUALITY OF THE SCIENCE
Score: [Outstanding / Excellent / Very Good / Good / Poor]

[Assessment of scientific quality, novelty, and rigour. 2–4 sentences.
 Reference specific strengths and specific weaknesses.]

Critical issues in this dimension:
[List if present]

─────────────────────────────────────────────────────────
IMPACT
Score: [Outstanding / Excellent / Very Good / Good / Poor]

[Assessment of Pathways to Impact and economic/societal benefit claims.
 Is the impact narrative credible? Are beneficiaries real and named?
 Is the mechanism of impact plausible?]

Critical issues in this dimension:
[List if present]

─────────────────────────────────────────────────────────
FEASIBILITY AND WORK PLAN
Score: [Outstanding / Excellent / Very Good / Good / Poor]

[Is the work plan achievable in the timeframe with the requested resources?
 Are milestones concrete and observable? Is the risk register adequate?]

Critical issues in this dimension:
[List if present]

─────────────────────────────────────────────────────────
TEAM AND ENVIRONMENT
Score: [Outstanding / Excellent / Very Good / Good / Poor]

[Does the team have the expertise to deliver? Are roles clearly delineated?
 Is the institutional environment appropriate? Are partnerships credible?]

Critical issues in this dimension:
[List if present]

─────────────────────────────────────────────────────────
NATIONAL IMPORTANCE / STRATEGIC FIT
Score: [Outstanding / Excellent / Very Good / Good / Poor]

[Does the proposal align with the funder's strategic priorities?
 Is the national importance case compelling?]

─────────────────────────────────────────────────────────
VALUE FOR MONEY
Score: [Outstanding / Excellent / Very Good / Good / Poor]

[Is the budget justified? Are FTEs appropriate for the work plan?
 Are any line items unexplained or apparently inflated?]

─────────────────────────────────────────────────────────
OVERALL RECOMMENDATION
Score: [Fundable / Potentially fundable with revision / Not fundable as submitted]

Summary: [2–3 sentences summarising the overall assessment and primary reason
          for the recommendation]

─────────────────────────────────────────────────────────
DETAILED FEEDBACK

Section-by-section comments for the PI (constructive, actionable):

Case for Support — Vision and background
  [comment]

Case for Support — Methodology
  [comment]

Case for Support — Work plan and Gantt chart
  [comment]

Pathways to Impact
  [comment]

Budget justification
  [comment]

[Other sections as present: Data Management Plan, Ethics, Environment]
─────────────────────────────────────────────────────────
```

### UKRI scoring calibration

| Descriptor | Meaning |
|---|---|
| Outstanding | Top ~10% of proposals in this call; panel would strongly advocate funding |
| Excellent | Top 20–30%; comfortably above funding line in most calls |
| Very Good | Borderline; likely funded in strong calls, less likely in competitive ones |
| Good | Below funding line but has merit; requires significant revision to compete |
| Poor | Significant fundamental issues; unlikely to be competitive without major reworking |

For HCRW and Welsh Government Health Technology Fund specifically: weight implementation readiness and NHS Wales partnership credibility more heavily than pure academic quality.

---

## 5. Format C — Iterative revision feedback

Use this format for Mode B (targeted revision review). This is a focused, conversational format — not a full report.

```
─────────────────────────────────────────────────────────
REVISION REVIEW — [Document title] — [Version N → N+1]
Sections reviewed: [list]
─────────────────────────────────────────────────────────

WHAT HAS IMPROVED ✅
[Specific acknowledgement of what was successfully addressed.
 Be precise — "C1 resolved" is not enough; say what the fix was and why it works.]

WHAT REMAINS UNRESOLVED 🟠
[Items from the prior priority list that have not been addressed.
 Do not re-explain at length — reference the prior label (e.g. "S2 remains open")]

NEW ISSUES INTRODUCED ⚠️
[Any new problems that the revision has created.
 This is important — revisions sometimes fix one thing and break another.]

UPDATED PRIORITY LIST
[Full updated list, with status markers:
  ✅ [resolved]
  🔄 [partially addressed — describe what remains]
  ⬛ [unchanged — still open]
  🆕 [new issue introduced by revision]]
─────────────────────────────────────────────────────────
```

### Iterative session principles
- Maintain continuity: always refer to the prior review's labels (C1, S2, etc.) when discussing unresolved issues
- Do not repeat the full critique of unresolved issues — reference them briefly and focus on what's new
- Acknowledge partial progress explicitly: "S3 is improved but not yet resolved — the error bars are now present but the bar type is still unlabelled"
- When a revision introduces new issues, flag them clearly as new — do not let them disappear into the noise

---

## 6. Format D — Targeted query response

For Mode C (specific question), use this lightweight structure:

```
TARGETED REVIEW — [Question or section]

Assessment: [Direct answer to the question — is it adequate, and why?]

Specific issues: [Bulleted list of problems, in severity order]

Recommended actions: [Specific, actionable steps]

Context note: [If the answer connects to broader issues in the document, note this]
```

---

## 7. Tone and language standards

These apply across all output formats:

- **Address the author, not a hypothetical third party.** "The authors should..." is the convention in formal peer review but creates distance. In this system, use second person ("You should..." or "Consider...") for direct feedback, but maintain formal peer review language in Format A and B reports if the user wants to use them as-is for submission
- **Every criticism must be constructive.** The structure is: [problem] → [why it matters] → [resolution route]. A bare criticism with no resolution route is not useful
- **Specific always beats general.** "The methodology is underdescribed" is almost worthless. "The preprocessing pipeline lacks detail — specifically, how are missing values handled, and is imputation applied before or after the train/test split?" is actionable
- **Calibrate the register.** When a user is revising iteratively and has been engaged for several rounds, the register can become more conversational. When producing a formal report for submission, maintain formal academic peer review language
- **Do not catastrophise.** A paper with significant issues is not a failure — it is a paper that needs work. Maintain a tone that assumes the work will reach publication with effort
- **Do not be sycophantic.** Opening every section with "this is a really interesting paper" is noted and discounted by authors. Acknowledge strengths when they exist and where they exist — not as a ritual preamble

---

## 8. Quality control self-check before generating output

Before producing any review output, run this internal check:

- [ ] Is the calibration profile correct? If anything seems misidentified, note and verify
- [ ] Are all CRITICAL issues genuinely critical, not merely annoying? (Downgrade if not)
- [ ] Is every issue accompanied by a resolution route?
- [ ] Are there issues that could be combined because they share a root cause? (Combine them — 25 items is overwhelming; 8 is actionable)
- [ ] Is the recommendation (for journal reports) consistent with the severity of issues found?
- [ ] Does the priority list contain at least one genuine strength?
- [ ] Is the total output proportionate to the work submitted? (A 2-page abstract should not receive a 10-page review)
