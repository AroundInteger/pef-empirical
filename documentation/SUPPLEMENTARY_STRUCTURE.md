# Supplementary Information — agreed structure

The SI is organised into **thematic sections** ordered by the main paper narrative. **Figure, table, and note labels (S1–S8, Note S1/S2/S4) are fixed** for cross-references; section order differs from numeric S-order where grouping requires it. Each figure environment sets `\setcounter{figure}{...}` so printed labels stay S1–S8.

## Roadmap (section order in PDF)

| SI section | Main paper anchor | Contents (fixed labels) |
|---|---|---|
| **§1 Idealised probit validation** | Introduction (contributions); Methods Tier 1; Results (foundation, `\cref{sec:eff_power}`) | Note S2; Figure S4; Figure S5 |
| **§2 Information surface (theory)** | Theory (`\cref{sec:theory}`, `\cref{fig:info_surface}`, `\cref{sec:signal_strength}`) | Figure S1 |
| **§3 Sports KPI landscape** | Methods (`\cref{sec:outcome_defs}`); Results landscape; Discussion (stationarity) | Figure S2; Figure S3; Table S1; Table S2 (ranked by $\|\hat\eta-1\|$); inventory CSVs; Figure S8 |
| **§4 Efficiency–power diagnostics** | Results (`\cref{sec:eff_power}`); `\cref{tab:exemplars}` | Figure S6; Figure S7 |
| **§5 Quality control** | Methods (`\cref{sec:qc}`); Discussion (limitations) | Paired-difference Shapiro--Wilk note; Note S1 |
| **§6 Practitioner diagnostic** | Discussion (`\cref{sec:practical_guidance}`); `\cref{sec:data_availability}` | Note S4 |

## Design rules

1. **Thematic grouping** — notes and figures for the same analysis appear in the same SI section (e.g. probit Note S2 with Figures S4–S5).
2. **Bridge paragraphs** — each SI section opens with 2–4 sentences linking to main-text sections (see `sections/supplementary.tex`).
3. **Stable S-labels** — main text cites `\cref{fig:si_...}`, `\cref{tab:si_...}`, `\cref{sec:si_note_...}`; avoid hard-coded “Figure~S2” in body `.tex` where possible.
4. **Reproducibility detail** — script paths and CSV names live in SI notes and `README.md`, not in the main paper body.
5. **No Note S3** — KPI inventory is prose under §3 (landscape), not a separate numbered note.

## Label reference

| Label | Printed as |
|---|---|
| `sec:si_probit` | SI §1 |
| `sec:si_theory` | SI §2 |
| `sec:si_landscape` | SI §3 |
| `sec:si_effpower` | SI §4 |
| `sec:si_qc` | SI §5 |
| `sec:si_practitioner` | SI §6 |
| `fig:si_info_sensitivity` | Figure S1 |
| `fig:si_kpi_labelled` | Figure S2 |
| `fig:si_ipred_vs_dml` | Figure S3 |
| `fig:si_idealised_stratified` | Figure S4 |
| `fig:si_iso_eta_I` | Figure S5 |
| `fig:si_bootstrap_exemplars` | Figure S6 |
| `fig:si_q4_bayes_gap` | Figure S7 |
| `fig:si_season_drift` | Figure S8 |
| `tab:si_quad_landscape` | Table S1 |
| `tab:si_quad_ranked` | Table S2 |
| `sec:si_normality` | Paired-difference Shapiro--Wilk note |
| `sec:si_note_s1` | Note S1 |
| `sec:si_note_s2` | Note S2 |
| `sec:si_note_s4` | Note S4 |
