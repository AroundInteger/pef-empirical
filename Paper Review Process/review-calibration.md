# SKILL: Review Calibration
**File:** `review-calibration.md`  
**Role:** Establish field profile, venue/funder standards, and discipline-specific norms before any review begins  
**Read after:** `review-orchestrator.md`

---

## 1. Purpose

Before any substantive evaluation, the review must be calibrated to the correct standards. What counts as adequate statistical power, appropriate novelty, acceptable figure quality, or sufficient impact differs enormously across fields and venues. Miscalibrated reviews are the most common source of unhelpful feedback.

---

## 2. Document classification protocol

On first encountering a document, extract the following in order:

### 2.1 Document type
- **Journal paper** (original research / review / methods / short communication / letter)
- **Conference paper** (proceedings / extended abstract / workshop)
- **Preprint** (arXiv / bioRxiv / medRxiv / SSRN / OSF)
- **UKRI grant application** → proceed to §4
- **Other** (thesis chapter, report, technical note) → flag and adapt

### 2.2 Research field detection
Identify primary field from: title, abstract, methodology keywords, citation patterns, author affiliations if visible. Classify at two levels:
- **Broad domain** (e.g. mathematics, life sciences, engineering, social sciences, computer science, health research, physical sciences)
- **Sub-discipline** (e.g. topological data analysis, sports biomechanics, NHS service delivery, reinforcement learning)

Where a paper is genuinely interdisciplinary, identify the **primary methodological community** (who would review it) and the **application domain** separately — they may have different standards.

### 2.3 Target venue
Extract from: cover letter, submission header, journal name in template, formatting clues (column width, reference style), explicit statement by user.

If unknown, ask once: "Which journal or conference are you targeting?" — or infer from field + scope and state the inference explicitly.

---

## 3. General field calibration matrix

Apply these calibration standards once field and venue are established.

### 3.1 Experimental sciences (biology, chemistry, medicine, neuroscience)
- **Novelty bar:** Incremental improvement on known method is acceptable in most journals; paradigm shift expected only at CNS/Nature family level
- **Reproducibility standard:** Methods must be sufficient for independent replication; reagent/code availability expected at most venues (mandatory at many)
- **Statistics:** Appropriate test selection, effect sizes, confidence intervals, multiple comparisons correction; p<0.05 alone is insufficient at most venues
- **Sample size:** Power calculation or justification expected; n=3 biological replicates is a known weak point — note if present
- **Controls:** Positive and negative controls expected; their absence is a significant issue
- **Figures:** Publication-quality required; raw gel images, microscopy data, flow cytometry require specific standards

### 3.2 Mathematical sciences (pure and applied mathematics, statistics)
- **Proof standard:** Theorems require complete proofs or explicit statement that proof is in supplementary; lemmas used without proof require citation of the source
- **Notation consistency:** Introduce all notation; never reuse a symbol for two purposes in the same paper
- **Computational claims:** If numerical results support a theorem, implementation must be described and code made available or reproducible from the methods
- **Novelty bar:** Mathematical novelty is distinct from application novelty; a novel proof of a known result is publishable; a known proof applied to a new dataset is not a mathematical contribution
- **Literature coverage:** Mathematics has long citation timescales; missing a key 1970s result can be as damaging as missing a 2023 paper
- **Applied maths:** Clearly delineate theoretical contribution from computational validation from application demonstration — three distinct contributions, each with its own standard

### 3.3 Computer science and AI/ML
- **Benchmark standard:** Comparison against relevant baselines is non-negotiable; cherry-picked baselines are a significant red flag
- **Reproducibility:** Code, hyperparameters, random seeds, hardware specs expected at most ML venues; ICML/NeurIPS/ICLR have formal reproducibility checklists
- **Statistical reporting:** Report mean ± std over multiple runs; a single-run result is not publishable at top venues
- **Ablation studies:** Expected at top venues; absence is a notable gap
- **Claim precision:** "State of the art" requires evidence; "competitive with" is safer when baselines are not exhaustively covered
- **Theory vs empirical:** If claiming theoretical guarantees, the proof must hold; if empirical only, frame as such

### 3.4 Engineering and physical sciences
- **Validation standard:** Simulation results require experimental validation or explicit framing as simulation-only; the gap between simulation and reality must be acknowledged
- **Uncertainty quantification:** Error bars, tolerances, uncertainty propagation expected
- **Applicability claims:** Be precise about the regime of validity; overgeneralised engineering claims are a frequent weakness
- **Standards compliance:** Reference relevant standards where applicable (ISO, IEEE, ASTM)

### 3.5 Health research and clinical sciences
- **Reporting standards:** CONSORT (RCTs), STROBE (observational), PRISMA (systematic reviews), STARD (diagnostic), TRIPOD (prediction models) — check compliance
- **Ethics statement:** Required; IRB/REC approval and consent process must be described
- **Patient/participant data:** Anonymisation, GDPR/data sharing compliance must be addressed
- **Clinical significance vs statistical significance:** Always evaluate both; a statistically significant result with no clinical meaning is a major framing problem
- **NHS/health system context (Wales/UK):** Acknowledge service delivery constraints; NHS data via SAIL requires specific governance language

### 3.6 Social sciences and interdisciplinary research
- **Positionality:** Where relevant (qualitative work, community research), positionality statement expected
- **Mixed methods:** Clearly justify why mixed methods are used; integration of qual/quant strands must be explicit
- **Generalisability:** Sample size and selection effects must be discussed; claims to generalisability require justification
- **Theory–data relationship:** Clearly delineate inductive from deductive components

---

## 4. UKRI funder calibration

### 4.1 Scheme identification
Identify the specific scheme before applying any standards. Key distinctions:

| Scheme | Key characteristics |
|---|---|
| EPSRC Standard Research | Blue-sky or applied; case for support 6pp; JeS form |
| EPSRC New Investigator Award | PI must be within 6 years of first academic post; leadership narrative critical |
| EPSRC Future Leaders Fellowship (FLF) | Vision and independence are primary criteria; track record weighted heavily |
| MRC Project Grant | Hypothesis-driven; preliminary data essential; clinical translation pathway expected |
| MRC Programme Grant | Long-term research programme; established team; strategic narrative |
| ESRC Standard Grant | Social science; impact and knowledge exchange prominent |
| Innovate UK Smart / KTP | Commercial viability is primary criterion; IP strategy expected |
| Wellcome Trust | PI-led; interdisciplinary encouraged; narrative CV format |
| HCRW (Health and Care Research Wales) | Welsh Government priorities; NHS Wales partnerships; Welsh language plan |
| Welsh Government Health Technology Fund | Implementation pathway in NHS Wales; health economics framing |

### 4.2 UKRI panel framing principles
- Panels are mixed-expertise; the non-specialist panel member must be able to follow the narrative
- Avoid unexplained jargon in the first two pages of Case for Support; build technical depth from page 3
- Excellent science is necessary but not sufficient — value for money, feasibility, and team strength are evaluated independently
- Reviewers are instructed to evaluate against the scheme's specific criteria, not generic research quality

### 4.3 Required UKRI sections — audit checklist
For any UKRI Case for Support, verify presence and quality of:
- [ ] Vision / overview paragraph (first page — critical first impression)
- [ ] Clear statement of research question(s)
- [ ] Justification of novelty and timeliness
- [ ] Preliminary data or proof-of-concept (required for most schemes)
- [ ] Methodology (sufficient detail to assess feasibility)
- [ ] Work plan / Gantt chart (feasibility and milestone sequencing)
- [ ] Risk register (at least 3 substantive risks with mitigations)
- [ ] Team composition and role justification
- [ ] Pathways to Impact (distinct from academic impact; requires specific non-academic beneficiaries)
- [ ] National Importance statement (EPSRC) / Public Health significance (MRC)
- [ ] Budget justification (every line must be justified; panel flags unexplained items)
- [ ] Data Management Plan reference
- [ ] Ethics statement (or explicit justification if not required)

---

## 5. Field-specific calibration: Rowan's primary domains

These heuristics apply when the document falls within the following identified research areas. They supplement (not replace) the general calibration above.

### 5.1 Mathematical sciences — topological data analysis, dynamical systems, p-adic methods
- **Theoretical contributions:** Proofs of novel results in TDA (persistence homology, Betti numbers, Wasserstein distances) must be rigorous; computational shortcuts must be clearly labelled as approximations
- **Applied TDA:** When applying TDA to empirical data (e.g. sports tracking, health signals), the connection between the topological invariant and the domain interpretation must be explicit and justified; "interesting topology" is not a claim
- **Dynamical systems:** Phase space reconstruction (Takens' theorem applications) requires explicit embedding dimension and delay justification; visual phase portraits without quantitative validation are insufficient at research level
- **p-adic methods:** Non-standard application area; expect reviewer unfamiliarity; define all p-adic constructs from first principles regardless of audience; the connection to the empirical problem must be motivated before technical development
- **Novelty framing:** For novel mathematical frameworks applied to sports/health: the mathematical contribution and the domain contribution must be articulated separately; reviewers from each community will evaluate different things

### 5.2 Sports analytics
- **Community standards:** Sports analytics sits between sports science, statistics, and computer vision; calibrate to the target venue (JQAS, SportRxiv, IJCSS, sports science journals vs ML conferences)
- **Ground truth:** Player tracking data (e.g. Tracab, StatsBomb) has known limitations (occlusion, ID instability, temporal resolution) — these must be acknowledged; failure to acknowledge them is a significant weakness
- **Tactical validity:** Computational findings must be grounded in sport-specific tactical interpretation; a purely mathematical result with no coaching relevance has limited sports science value
- **Statistical baselines:** Compare against established metrics (xG, PPDA, etc.) where relevant; a novel metric that outperforms nothing known is not a contribution
- **Data access and ethics:** Club data partnerships require data governance statement; confirm anonymisation and permission where player-level data is used

### 5.3 Health informatics and NHS data science (SAIL / NHS Wales)
- **SAIL-specific:** Data access via SAIL databank requires explicit governance section; state the data asset(s) used, approval reference, and any data minimisation measures
- **NHS Wales context:** Acknowledge structural characteristics of Welsh NHS (health boards, NWIS, DHCW); claims that generalise from Wales to UK NHS without justification will be challenged
- **Clinical co-design:** Reviewers in this space increasingly expect clinician involvement in research design; if absent, address why
- **Implementation pathway:** HCRW and Welsh Government funders weight implementation readiness heavily; a technically sound system that has no deployment pathway is not a fundable deliverable in this context
- **Patient and public involvement (PPI):** Expected in most health research grant applications; its absence must be justified; perfunctory PPI is almost as weak as no PPI
- **Health economics:** NICE-style cost-effectiveness framing (QALY, incremental cost) is not always required but is valued for technology assessment grants

### 5.4 Applied AI and machine learning for real-world systems
- **Deployment gap:** Reviewers are increasingly sensitive to the gap between model performance in a controlled evaluation and real-world deployment; address this explicitly
- **Fairness and bias:** For AI systems applied to people (health, welfare, criminal justice), fairness evaluation is expected; its absence is a significant gap at most venues
- **Explainability:** In health and public-sector contexts, black-box models require strong justification; explainability is not optional cosmetics
- **Data leakage:** A common and serious error; verify that train/validation/test splits are temporally correct for time-series data and that no target-correlated features leak through preprocessing
- **Compute and reproducibility:** State hardware, training time, number of runs; results that required 1000 GPU-hours are not reproducible by most research groups without acknowledgement

### 5.5 PEF split publication (`pef-empirical` + `pef-mathematics`)

When either manuscript is under review, read `review-pef-papers.md` in full. Summary:

| Paper | Owns | Must not headline |
|---|---|---|
| **Empirical** | Distribution-free \(\eta\), four-quadrant taxonomy, sports KPI ML, Gaussian (A1)–(A2) MI link, six-domain validation | \(\psi\), partition-function proofs, sphere geometry depth |
| **Companion** | Canonical form, symmetries, sphere, partition function, Fisher–Rao \(\psi\), §7 CSV tests | New six-domain ML; KPI tables duplicated from empirical |

**Default venues:** empirical → **JQAS**; companion → **AoAS** (see `TARGET_JOURNAL_MATRIX.md` in empirical repo).

**Primary methodological community vs application domain:** empirical JQAS reviewers weight sports KPI narrative and honest ML limits; companion AoAS reviewers weight proof completeness and §7 falsifiability.

**Do not** apply TDA/p-adic heuristics (§5.1) to PEF reviews unless the document is explicitly about those topics.

---

## 6. Venue tier calibration

Apply these general tier standards when evaluating whether the work is appropriately scoped for the target venue.

| Tier | Examples | Novelty expected | Methodological standard |
|---|---|---|---|
| Flagship / CNS | Nature, Science, Cell, PNAS | Paradigm-shifting or major advance | Exhaustive; multiple independent validations |
| Top field journal | JMLR, Lancet, Annals of Math, **Annals of Applied Statistics** | Significant contribution to field | Rigorous; reproducible; well-situated in literature |
| Strong field journal | PLOS Comp Bio, **JQAS**, Bioinformatics, **JRSS Series C** | Clear advance on existing methods | Sound; appropriate controls/baselines |
| Solid mid-tier | Applied Mathematics and Computation, IJCSS, **EJSS/JSAMS** | Incremental advance or novel application | Adequate; honest about limitations |
| Workshop / short paper | NeurIPS workshops, sports analytics workshops | Promising preliminary work | Work-in-progress norms apply |

**PEF venue notes (detail in `review-pef-papers.md` §7):**

| Venue | Paper | Reviewer emphasis |
|---|---|---|
| **JQAS** | Empirical | Sports KPI spine; absolute vs relative features; quadrant practitioner guide; honest observational ML limits |
| **AoAS** | Companion | Proof completeness; geometric §7 tests; Fisher–Rao \(\psi\); cross-cite empirical data |
| **Series C** | Either (backup) | Applied statistics; cross-domain CSV validation; application hook in title if empirical |

If the work as submitted is clearly under- or over-scoped for the stated target venue, flag this explicitly and recommend either (a) additional work to meet the venue standard, or (b) a more appropriate target.

---

## 7. Calibration output

At the end of calibration, produce a brief internal profile (shown to the user) before beginning scientific review:

```
CALIBRATION PROFILE
Document type:    [type]
Primary field:    [broad domain → sub-discipline]
Target venue:     [journal/funder/scheme] — Tier [X]
Applicable norms: [list key standards, checklists, reporting guidelines]
Special context:  [e.g. SAIL data, Welsh health system, interdisciplinary panel]
Review mode:      [Mode A / B / C / D]

PEF fields (when applicable):
Paper role:       [empirical | companion | joint]
Sibling paper:    [in prep | draft shared | submitted | n/a]
Pipeline status:  [numbers.tex current | manifest synced | refresh needed]
Reference docs:   [PEF_PROJECT_MEMORY.md, TARGET_JOURNAL_MATRIX.md]
```

This profile is shown before the review begins so the user can correct any misidentification.
