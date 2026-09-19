# Paper formatting — good practices

Author-facing house style for the PEF empirical manuscript. The companion mathematics paper should look like a pair.

**What this file is.** Why figures and captions are laid out as they are, and the checks to run before export.

**What this file is not.** Agent implementation detail. Type sizes, MATLAB helpers, and regeneration commands live in `.cursor/rules/figures.mdc` and `scripts/paper_pipeline/lib/pef_figure_style.m`. Prose and LaTeX conventions live in `.cursor/rules/latex-paper.mdc` and `.cursor/rules/writing-clarity.mdc`. SI section order lives in `documentation/SUPPLEMENTARY_STRUCTURE.md`.

## 1. What belongs on a main-text figure

Main Figures 1--3 argue one claim each. They are not inventory dumps.

| Figure | Job | On the plot | Not on the plot |
|--------|-----|-------------|-----------------|
| 1 | $\eta$ landscape and confirmatory anchors | Four exemplars with season drift; supporting-domain mean triangles | Full rugby/football KPI cloud |
| 2 | $I(X;Y)$ surface at $\delta/\sigma_A=1$ | Same exemplars and triangles as Figure 1 | Full KPI cloud; extra $\delta/\sigma_A$ slices |
| 3 | Confirmatory $\eta$ vs $\Delta\mathrm{ML}$ | Four exemplars at matched signal, plus the rucks-won foil | Full inventory scatter |

The unmarked blue (rugby) and yellow (football) KPI cloud belongs in **Supplementary Figure S4**. The $I_{\mathrm{pred}}$ vs $\Delta\mathrm{ML}$ inventory belongs in **S5**. If a reader needs every KPI, send them to the SI; do not put the cloud back on Figure 1 to “match” an older draft.

Captions and Methods must agree with that split. Do not write “unmarked markers are the 86 action KPIs” on Figure 1 if the script no longer draws them.

## 2. Type hierarchy

Printed figures shrink. Axis titles that look fine on a 1400-pixel MATLAB window become faint in a two-column PDF.

Use one hierarchy, set in `pef_figure_style.config()` (do not hard-code point sizes in published figure scripts):

| Role | Relative size | Current setting |
|------|---------------|-----------------|
| Axis titles, colourbar titles, legends | Same size as each other | 18 pt |
| Numeric tick labels | Two points smaller than titles | 16 pt |
| Quadrant tags Q1--Q4 | Slightly below titles | 16 pt |
| Contour *clabels* | Small; they sit on the surface | 10 pt |
| Panel letters `(A)`, `(B)`, … | Same as axis titles | 18 pt bold |
| KPI notes | Annotation scale | 12 pt |

**Why titles match the legend.** The legend is the first thing a reader uses to decode markers. Axis titles (“Pairwise correlation $\rho$”, “Variance ratio $\kappa$”) should be equally readable.

**Why ticks are smaller, not tiny.** Ticks must stay secondary to titles, but 10 pt on a landscape plot disappears in print.

**Why contour labels stay small.** They collide with Q tags and exemplars if they share the tick size.

## 3. Numeric tick labels

Every numeric label on one axis uses the **same number of decimal places**.

- Landscape $x$: `-0.8, -0.6, …, 0.0, …, 0.8` (one decimal).
- Landscape $y$: `0.5, 1.0, 1.5, 2.0, 2.5, 3.0` (one decimal). Do not mix `1` with `1.5`.
- Figure 3 $x$: `0.0, 1.0, 2.0, 3.0, 5.2, 5.6` (one decimal, including the broken-axis values).
- Figure 3 $y$: `-3.0` through `7.0` (one decimal).
- Colourbar ticks follow the same rule on that scale (Figure 1: one decimal, so `10.0` not `1e+01`; Figure 2: two decimals because the step is `0.05`).

Helper: `pef_figure_style.apply_decimal_ticks` / `decimal_labels`.

## 4. MATLAB pitfalls that undo the style

**Axes `FontSize` resets labels.** `set(ax, 'FontSize', fs_tick)` also overwrites `xlabel` and `ylabel`. Set tick size first, then apply title size, or call `style_landscape_axes` / `style_scatter_axes` (they restore label size).

**Colourbar titles need a free slot.** A long label such as $I(X;Y)$ (bits) will sit on the side legend if it is placed at mid-bar. Put it at the **top** of the colourbar gap (as on Figures 1--2). A single-character $\eta$ can live there too.

**Contour labels are not tick labels.** Keep `fs_contour` separate from `fs_tick`.

**Export at 300 dpi** via `pef_figure_style.export_figure`. White figure background. No on-figure `title` or `sgtitle`.

## 5. Captions, not titles

The PNG has no title. The LaTeX caption carries the narrative.

- Captions live in `sections/tables_and_figures.tex` (main) and `sections/supplementary.tex` (SI).
- Multi-panel captions use (A), (B), (C) to match panel letters inside the axes.
- Do not repeat a figure title in the first sentence and then restate it.
- British English. Cite other figures with `\cref{…}`, not hard-coded “Figure 4”.
- After a plotting change, update the caption in the same edit. Stale captions (“unmarked markers are…”) are worse than a missing sentence.

## 6. Panel letters, legends, and collisions

- Multi-panel: `(A)`, `(B)`, `(C)` **inside** the axes, default northwest, no white patch, 18 pt bold (same as axis labels).
- Single-panel figures do not need a letter.
- Legends: box off, in empty space, not on curves or markers.
- If a KPI name has no free slot, omit the name and keep the marker.
- Dense maps (S4): colour and position carry identity; do not force every name onto the surface.

## 7. Colour and axes

- Quadrants: Q1 green, Q2 blue, Q3 orange, Q4 red (`quadrant_color`).
- Landscape limits: $\rho\in[-0.999,0.999]$, $\kappa\in[0.001,3]$.
- Bar charts of non-negative summaries start at zero. Do not leave an empty negative floor.

## 8. LaTeX and prose (short list)

- British English: recognised, behaviour, rigour, optimisation.
- Greek in math mode (`$\eta$`, `$\kappa$`, `$\rho$`), not Unicode.
- Generated numbers come from `scripts/paper_pipeline/outputs/numbers.tex`. Do not hand-edit those macros.
- Macro names are letter-only after `\`. Digits inside a name break TeX parsing.
- No em-dash asides (`---`). Prefer a new sentence, a comma, or a colon. En-dashes in ranges (`23/24--24/25`) are fine.
- One idea per sentence; split anything that needs a second pass.

Full rules: `.cursor/rules/latex-paper.mdc`, `.cursor/rules/writing-clarity.mdc`.

## 9. Pre-export checklist

1. The figure’s job matches the table in §1 (no inventory cloud on Figures 1--3).
2. No title on the PNG.
3. Axis titles and legend are the same size; ticks are two points smaller; decimals are uniform on each axis.
4. Colourbar title is clear of the legend and of tick numerals.
5. Q tags, contour labels, and exemplars do not sit on each other.
6. Caption describes what is actually plotted and points the inventory to S4/S5.
7. Regeneration used the scripts below, not a one-off MATLAB session with leftover sizes.

## 10. Regeneration

| Figure | Script |
|--------|--------|
| 1 | `scripts/paper_pipeline/regen_fig1.m` |
| 2 | `scripts/paper_pipeline/regen_fig2.m` |
| 3 | `scripts/matlab_figures/regenerate_figure_3_from_outputs.m` |
| Printed S1--S5 | `scripts/matlab_figures/generate_all_si_figures.m` |

After caption or Methods edits, refresh review copies with:

```bash
python3 "Paper Review Process/export_sections_to_md.py"
```

LaTeX in `sections/` remains authoritative.
