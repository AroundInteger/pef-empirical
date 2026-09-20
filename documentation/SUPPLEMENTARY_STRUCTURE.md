# Supplementary Information — agreed structure

The SI is organised into **three scientific blocks** that follow the main paper: theory, idealised probit validation, then empirical analysis. **Figures S1–S5 are numbered in order of appearance.** File names on disk retain generator tags and need not match the printed S-number. There are no numbered “Note S” labels; cite SI sections. Log-transform ratios and Q4 bootstrap intervals sit in SI §3 (`sec:si_qc`). Table S1 is the only SI table. Main-text citations use `\cref{fig:si_...}` and `\cref{sec:si_...}` so printed numbers follow the SI counter.

Former printed figures S6–S8 and Table S2 are not included. Former `sec:si_note_s*` labels are kept as silent aliases.

## Roadmap (section order in PDF)

| SI section | Main paper anchor | Contents (printed labels) |
|---|---|---|
| **§1 Theoretical derivations** | Theory (`\cref{sec:theory}`); Fig.~2; Introduction (Pitman ARE) | \(\tau=\tfrac12\log\kappa\); \(I(X;Y)\) algebra; `\cref{sec:pitman}`; Figure S1 (disk: `Figure_S3_info_sensitivity.png`) |
| **§2 Idealised probit validation** | Methods Tier 1; Results | Specification; Validations 2–4; Figure S2 (disk: `Figure_S1_idealised_I_vs_dML_overlay.png`); Figure S3 (disk: `Figure_S2_iso_eta_I_tension.png`) |
| **§3 Empirical analysis** | Methods; Results; Discussion | Figure S4; Figure S5; Table S1; QC (Shapiro–Wilk, log-transform, Q4 bootstrap) |

## Design rules

1. **Thematic grouping** — specification and figures for the same analysis appear in the same SI section (e.g. the probit specification with printed Figures S2–S3).
2. **Bridge paragraphs** — each SI section opens with 2–4 sentences linking to main-text sections (see `sections/supplementary.tex`).
3. **Cite labels, not hard-coded S-numbers** — main text cites `\cref{fig:si_...}`, `\cref{tab:si_...}`, `\cref{sec:si_...}`.
4. **Reproducibility detail** — script paths, CSV names, and the practitioner schema live in `README.md`, not in the SI body.
5. **SI §1** — information-content derivation and Pitman ARE (`sections/appendix.tex`). QC sits under §3.
6. **Sequential figures** — do not use `\setcounter{figure}` to freeze old S-numbers. The SI counter runs from S1 at the first figure environment.

## Label reference

| Label | Printed as |
|---|---|
| `sec:si_maths` | SI §1 |
| `sec:si_note_s3` (`sec:appendix` alias) | SI §1 (silent alias) |
| `sec:pitman` | Pitman ARE (inside SI §1) |
| `sec:si_theory` | Information surface (inside SI §1) |
| `sec:si_probit` (`sec:si_note_s2` alias) | SI §2 |
| `sec:si_landscape` | SI §3 |
| `sec:si_qc` | Quality control (inside SI §3) |
| `sec:si_practitioner` (`sec:si_note_s4` alias) | Repository pointer (inside SI §3) |
| `fig:si_info_sensitivity` | Figure S1 |
| `fig:si_idealised_stratified` | Figure S2 |
| `fig:si_iso_eta_I` | Figure S3 |
| `fig:si_kpi_labelled` | Figure S4 |
| `fig:si_ipred_vs_dml` | Figure S5 |
| `tab:si_quad_landscape` | Table S1 |
| `sec:si_normality` | Paired-difference Shapiro--Wilk |
| `sec:si_landscape_qc` (`sec:si_note_s1` alias) | Log-transform and Q4 bootstrap (in SI §3) |
