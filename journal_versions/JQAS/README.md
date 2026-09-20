# JQAS manuscript package

De Gruyter / *Journal of Quantitative Analysis in Sports* submission files. The working draft in the repo root (`main.tex`, `sections/`) is unchanged.

Compile **from this directory**. Overleaf: set the main document to `manuscript_review.tex` for ScholarOne, or `main.tex` for the production look.

## What to upload to ScholarOne

| File | Role |
|------|------|
| `manuscript_review.pdf` (+ `.tex` source) | Blinded article. US letter, 12 pt, single column, double-spaced, author-date references. |
| `title_page.pdf` | Identified title page. Not sent to reviewers. |
| `si.pdf` (optional) | Standalone Supplementary Information if you turn SI off in the review compile. |
| `figures/Figure_1.png`, `Figure_2.png`, `Figure_3.png` | Separate figure files (journal also accepts EPS / TIF / JPG). Tables stay in the manuscript. |
| `COVER_LETTER.md` | Cover letter text to paste into ScholarOne. |

## Compile commands

```bash
cd journal_versions/JQAS

# ScholarOne review PDF (blinded)
pdflatex manuscript_review
biber manuscript_review
pdflatex manuscript_review
pdflatex manuscript_review

# Identified title page
pdflatex title_page

# De Gruyter production look (identified)
pdflatex main
biber main
pdflatex main
pdflatex main
```

This machine did not have `pdflatex` on the shell `PATH` when the package was generated. Compile on Overleaf or after installing MacTeX.

To upload a shorter main PDF and a separate SI file, set `\jqasincludesifalse` in `manuscript_review.tex` and compile `si.tex`.

## Constraints applied

- Abstract cut to ~200 words (five-part skeleton; no equations; rugby + football only).
- Five keywords that do not repeat the title: paired comparisons; rugby union; association football; feature engineering; logistic regression.
- Author-date (`biblatex` `authoryear`), not Vancouver numeric.
- Blind review wrapper + separate title page.
- JQAS venue citations: Brill, Yurko and Wyner (2025); Baron et al. (2024); Guan, Sarkar and Swartz (2024).
- Q4 recipe: estimate $\delta/\sigma_A$, then confirm with team-blocked CV. $I(X;Y)$ is a prior.
- Companion geometry / $\psi$ / partition function reduced to one “in preparation” sentence (anonymised when blinded).
- Finance Methods match Results (S&P 100 vs S&P 500, 2020–2023, $n=18$).
- Shapiro–Wilk numbers moved out of the Introduction.
- Table 1 column renamed “% with $\eta>1$”.
- Absolute baseline stated as $X_A$ only.
- Pipeline / MATLAB R2025b reproducibility paragraph added.

## Still open before upload

- Co-author sign-off on order and departmental affiliations (roadmap D4).
- Local `latexmk` / Overleaf compile; fix any undefined references.
- Confirm `pef-tools` URL in the unblinded data statement.
- Export figures as TIF/EPS if ScholarOne rejects PNG.
- Do not quote the July 2026 matrix $\Delta$ML row (Q4 is $-0.3\%$, not $+2.2\%$).
