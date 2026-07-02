# SKILL: Scientific Rigour and Numerical Pipeline Review
**File:** `review-science.md`  
**Role:** Audit scientific integrity, methodological soundness, novelty, and numerical/computational pipeline validity  
**Read after:** `review-calibration.md`

---

## 1. Purpose

This skill governs the most substantive component of any academic review: whether the science is sound. It separates two distinct but related concerns — (A) scientific rigour (claims, methodology, novelty, literature) and (B) numerical and computational pipeline integrity (mathematics, code, data handling, validation). A paper can fail on either or both independently.

---

## 2. Part A — Scientific rigour audit

Work through each dimension below. Flag issues by severity: [CRITICAL], [SIGNIFICANT], [MINOR].

### 2.1 Research question and hypothesis
- Is the central research question clearly stated? If not, can it be inferred — and if inferred, is it coherent?
- Is there a hypothesis (or, for exploratory work, a clearly stated exploratory objective)? Are these distinct?
- Is the scope of the question appropriate for the venue and page limit?
- **Red flags:** Circular hypothesis ("we investigate whether X predicts X-related outcomes"), overly broad question with narrow methodology, question answered by existing literature

### 2.2 Novelty assessment
- What is the claimed contribution? (theoretical / methodological / empirical / applied)
- Is the novelty genuine relative to the cited literature?
- Has the author correctly identified the most relevant prior work? Check for:
  - Missing foundational papers that would significantly alter the novelty claim
  - Missing recent papers (last 2–3 years) that may partially or fully overlap
  - Overclaiming novelty by ignoring related work in adjacent fields
- **Field-specific note:** In mathematics, a genuinely new proof of a known result is novel; in applied ML, applying an existing method to a new dataset is usually not novel unless the dataset itself is the contribution

### 2.3 Methodology soundness
Apply the following checks, calibrated to field norms from `review-calibration.md`:

**Design appropriateness**
- Is the chosen methodology fit for the research question?
- Are alternative methodologies acknowledged and their exclusion justified?
- Is the study design (experimental / observational / computational / theoretical) the right choice?

**Experimental/empirical controls**
- Are appropriate controls present? (positive, negative, active comparators)
- Is blinding described where appropriate?
- Are confounding variables identified and addressed?

**Sample / dataset adequacy**
- Is sample size justified? (power calculation, or explicit justification for why this is not applicable)
- Is the dataset representative of the target population/domain?
- Is data collection/curation described in sufficient detail for replication?
- Are known dataset limitations acknowledged?

**Causal vs correlational claims**
- Are causal claims made from correlational data? Flag this as [CRITICAL] if so
- Is the distinction between association and causation maintained throughout?

### 2.4 Statistical validity
This section applies to all empirical work regardless of field.

- **Test selection:** Is the statistical test appropriate for the data type and distribution? (e.g. parametric tests on non-normal data without justification)
- **Multiple comparisons:** If multiple tests are performed, is correction applied? (Bonferroni, FDR, etc.) Absence is [SIGNIFICANT]
- **Effect sizes:** Are effect sizes reported alongside p-values? p-values alone are insufficient
- **Confidence intervals:** Are 95% CIs reported? Point estimates without uncertainty are weak
- **Model assumptions:** Are distributional assumptions stated and checked?
- **Overfitting indicators:** In predictive modelling — is performance reported on a held-out test set? Is there evidence of hyperparameter tuning on the test set?
- **Reporting bias:** Are all conducted analyses reported, or is there evidence of selective reporting?

**PEF empirical note:** Inventory-scale sports KPI work often reports per-KPI bootstrap intervals and FDR/Bonferroni/Holm where formal tests run, rather than a single global power calculation. Calibrate to sports analytics / observational ML norms (JQAS), not clinical trial CONSORT standards. See `review-pef-papers.md` §4.2.

### 2.5 Reproducibility
- Is the methodology described in sufficient detail that an independent researcher could replicate the work?
- Is code available (or is its absence justified)?
- Are data available (or is access route described for restricted data)?
- Are random seeds, software versions, and hardware specifications reported for computational work?
- **Minimum standard:** Another researcher should be able to reconstruct the main result from the methods section alone, given the same data

### 2.6 Literature situatedness
- Is the literature review comprehensive for the field?
- Does the introduction accurately characterise the state of the art?
- Are limitations of prior work correctly represented?
- Is the paper's contribution correctly positioned relative to this prior work?
- **Recency check:** Is there a suspiciously long gap between the most recent citations and submission date? (May indicate an arXiv version not updated before journal submission)

### 2.7 Conclusions and claims
- Are conclusions supported by the results, or do they overreach?
- Is uncertainty in findings appropriately communicated?
- Are limitations discussed honestly? (A limitations section that lists only trivial limitations is a red flag)
- Are future work suggestions grounded in the actual findings?
- Are implications (clinical, policy, practical) appropriately hedged?

---

## 3. Part B — Numerical and computational pipeline audit

This section is applied when the paper contains: mathematical derivations, computational experiments, data analysis pipelines, simulations, or trained ML models.

### 3.1 Mathematical derivations
- **Notation:** Is all notation introduced before use? Is it consistent throughout? Inconsistent notation is [SIGNIFICANT]
- **Proof completeness:** Are all theorem/proposition/lemma proofs provided, or are they explicitly deferred (to appendix/supplementary)? An unjustified "it can be shown" is [SIGNIFICANT]
- **Proof correctness:** Check key steps for logical gaps. Common issues:
  - Interchanging limits and integrals without justification
  - Applying theorems outside their domain of validity
  - Sign errors, dropped terms, incorrect index bounds
  - Circular arguments (conclusion assumed in hypothesis)
- **Dimensionality:** Do dimensions/units work out? Check boundary cases
- **Assumptions:** Are mathematical assumptions stated at the beginning of each theorem? Are they realistic for the application domain?
- **Approximation quality:** Where approximations are made, are they justified and is their error characterised?

### 3.2 Computational implementation
- **Algorithm description:** Is the algorithm described with sufficient precision (pseudocode, full mathematical form, or code) to re-implement?
- **Complexity:** Is computational complexity stated? Is it consistent with claimed scalability?
- **Numerical stability:** Are there potential numerical instabilities? (Division by small numbers, catastrophic cancellation, ill-conditioned matrices, floating-point edge cases)
- **Hyperparameters:** Are all hyperparameters reported? Is the tuning procedure described?
- **Initialisation:** For iterative methods and trained models, is initialisation described?
- **Convergence:** Is convergence criteria stated? Are convergence curves shown?

### 3.3 Data pipeline integrity
Work through the pipeline in order:

**Ingestion and preprocessing**
- Is raw data format described?
- Are preprocessing steps fully enumerated? (normalisation, imputation, filtering, transformation)
- Is the preprocessing applied consistently to train/validation/test sets? (A common failure: normalising using test set statistics)
- Are outliers handled? Is the handling procedure justified?

**Feature engineering**
- Are all features described?
- Are features that could encode the target variable identified and excluded? (data leakage)
- For time-series data: is the temporal ordering respected throughout? No future information leaking into past-window features?

**Train/validation/test split**
- Is the split procedure described?
- For time-series data: is a temporal split used rather than random split? Random splitting of temporal data is [CRITICAL]
- Is the test set used only once (final evaluation only)? Multiple evaluations against test set inflate performance estimates — flag as [SIGNIFICANT]
- Is the split proportion appropriate for dataset size?
- For cross-validation: is the fold assignment strategy appropriate? (e.g. group-aware CV when samples are not independent)

**Model training**
- Is the loss function appropriate for the task?
- Is the optimiser and learning schedule described?
- Is early stopping or regularisation used? Described?

**Evaluation**
- Are evaluation metrics appropriate for the task and data distribution? (Accuracy is misleading on imbalanced datasets; use AUROC, F1, MCC etc.)
- Are metrics computed on the correct set (test, not validation)?
- Is performance variability reported? (multiple runs, confidence intervals on metrics)
- For comparison against baselines: are baselines reimplemented fairly or taken from their original papers? (different datasets/conditions invalidate comparison)

### 3.4 Simulation-specific checks
- Is the simulation model described in full (equations, boundary conditions, initial conditions)?
- Is the numerical solver described (method, step size, accuracy order)?
- Is a convergence/sensitivity study reported? (varying mesh resolution, step size, number of particles)
- Is the simulation validated against analytical solutions or experimental data in a known regime?
- Are the computational resources and run time reported?

### 3.5 Software and reproducibility
- Is software identified by name and version?
- Are custom scripts/tools described and (ideally) linked?
- Is there a requirements file, environment specification, or Docker image?
- Could the results be reproduced from the described procedure within a reasonable resource envelope?

**PEF pipeline (when applicable):** Apply the checklist in `review-pef-papers.md` §5 — `run_paper_pipeline.m`, `numbers.tex`, `sync_to_companion.sh`, `_manifest.csv`, and `pef_theory_helpers.m` as single source of truth.

---

## 4. Interdisciplinary tension points

Where a paper combines mathematical/computational methods with an empirical application domain, check for these specific failure modes:

**Mathematical validity ≠ domain relevance**
The mathematics may be entirely correct but the connection to the application may be unmotivated or spurious. Ask: "If the mathematical framework is removed and replaced with a standard method, does the empirical result change? If not, the framework is not earning its complexity."

**Application claims not warranted by computational results**
A model that achieves 70% accuracy on a lab dataset does not "enable real-time decision support" in a clinical setting. Flag any gap between reported performance and claimed application.

**Metrics that optimise for the wrong thing**
A sports analytics system optimising RMSE on position predictions may perform poorly on tactically relevant questions. A health model optimising AUC may be clinically useless if calibration is poor. Check that the optimised metric aligns with the stated application goal.

**Benchmark dataset problems**
Public benchmark datasets often have well-known issues (label noise, distributional shift, train/test contamination in published splits). If the paper relies on a benchmark dataset, check whether its limitations are acknowledged.

**Split-paper scope creep (PEF and similar projects)**
When theory and empirical validation are split across linked manuscripts, check that each paper claims only what it owns. Empirical papers must not headline companion-only theory; theory papers must not re-derive empirical ML tables or invent numbers not in stamped validation CSVs. Cross-cite discipline failures are often [CRITICAL]. See `review-pef-papers.md` §3.

**Imported numerical validation (companion / theory papers)**
When §7-style validation imports pipeline CSVs rather than re-running analysis, verify: manifest/provenance stated, column names match prose, Level 1 implementation checks are not oversold as empirical discoveries, and stale commit hashes are flagged [CRITICAL].

**Landscape vs mechanistic inference (PEF empirical)**
Descriptive KPI inventories (e.g. Q3-heavy sports landscape) must not support mechanistic claims unless exemplars or controlled simulations are clearly separated. Pooled weak correlations (e.g. global \(\eta\)–ML) must not be headline claims if retired from main text. See `review-pef-papers.md` §4.1 and §6.

---

## 5. Science review output format

Produce findings as a structured audit, not a narrative. Use this structure:

```
SCIENTIFIC RIGOUR AUDIT

Research question / hypothesis: [clear / unclear / absent] — [comment]
Novelty claim: [genuine / overstated / insufficient evidence] — [comment]

Methodology
  [CRITICAL / SIGNIFICANT / MINOR] [issue description] — [resolution]
  ...

Statistical treatment
  [severity] [issue] — [resolution]
  ...

Reproducibility
  [severity] [issue] — [resolution]
  ...

Literature coverage
  [severity] [issue] — [resolution]
  ...

Conclusions vs evidence
  [severity] [issue] — [resolution]
  ...

PEF scope / split-paper (if applicable)
  [severity] [issue] — [resolution]
  ...

NUMERICAL PIPELINE AUDIT (if applicable)

Mathematics
  [severity] [issue] — [resolution]
  ...

Data pipeline
  [severity] [issue] — [resolution]
  ...

Evaluation
  [severity] [issue] — [resolution]
  ...
```

After completing this audit, pass findings to `review-outputs.md` for severity triage and report generation.
