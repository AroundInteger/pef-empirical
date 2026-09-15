#!/usr/bin/env python3
"""Export empirical LaTeX sections to Markdown review copies.

Usage (from pef-empirical root):
  python3 "Paper Review Process/export_sections_to_md.py"

LaTeX in sections/ remains authoritative.
"""
from __future__ import annotations

import re
import pathlib

ROOT = pathlib.Path(__file__).resolve().parents[1]
OUT_DIR = pathlib.Path(__file__).resolve().parent / "section-md"

ORDER = [
    ("00_abstract", "sections/abstract.tex", "Abstract"),
    ("01_introduction", "sections/introduction.tex", "Introduction"),
    ("02_theoretical_framework", "sections/theoretical_framework.tex", "Theoretical Framework"),
    ("03_methodology", "sections/methodology.tex", "Methods"),
    ("04_results", "sections/results.tex", "Results"),
    ("05_discussion", "sections/discussion.tex", "Discussion"),
    ("06_conclusion", "sections/conclusion.tex", "Conclusion"),
    ("07_data_availability", "sections/data_availability.tex", "Data Availability"),
    ("08_appendix", "sections/appendix.tex", "SI Note S3 (Mathematical Derivations)"),
    ("09_tables_and_figures", "sections/tables_and_figures.tex", "Tables and Figures"),
    ("10_supplementary", "sections/supplementary.tex", "Supplementary Information"),
]


def load_macros() -> dict[str, str]:
    macros: dict[str, str] = {}
    for rel in (
        "scripts/paper_pipeline/outputs/numbers.tex",
        "scripts/paper_pipeline/outputs/finalize_correlations.tex",
    ):
        path = ROOT / rel
        if not path.exists():
            continue
        for line in path.read_text(encoding="utf-8").splitlines():
            m = re.match(r"\\(?:re)?newcommand\{\\([^}]+)\}\{([^}]*)\}", line)
            if m:
                macros[m.group(1)] = m.group(2)
            m = re.match(r"\\providecommand\{\\([^}]+)\}\{([^}]*)\}", line)
            if m and m.group(1) not in macros:
                macros[m.group(1)] = m.group(2)
    return macros


def expand_inputs(tex: str) -> str:
    """Inline \\input{...} so SI review copies include Note S3."""

    def repl(m: re.Match[str]) -> str:
        rel = m.group(1)
        path = ROOT / rel
        if path.suffix == "":
            path = path.with_suffix(".tex")
        if path.exists():
            return path.read_text(encoding="utf-8")
        return m.group(0)

    return re.sub(r"\\input\{([^}]+)\}", repl, tex)


def expand_macros(text: str, macros: dict[str, str]) -> str:
    def repl(m: re.Match[str]) -> str:
        return macros.get(m.group(1), m.group(0))

    text = re.sub(r"\\(PEF[A-Za-z]+)\{\}", repl, text)
    text = re.sub(r"\\(PEF[A-Za-z]+)\b", repl, text)
    return text


def tex_to_md(tex: str, title: str, path: str, macros: dict[str, str]) -> str:
    s = re.sub(r"(?<!\\)%.*", "", tex)
    s = expand_macros(s, macros)

    s = s.replace(r"\begin{abstract}", "").replace(r"\end{abstract}", "")
    s = re.sub(r"\\begin\{equation\*?\}", "\n$$\n", s)
    s = re.sub(r"\\end\{equation\*?\}", "\n$$\n", s)
    s = re.sub(r"\\begin\{align\*?\}", "\n$$\n", s)
    s = re.sub(r"\\end\{align\*?\}", "\n$$\n", s)
    s = s.replace(r"\begin{itemize}", "").replace(r"\end{itemize}", "")
    s = s.replace(r"\begin{enumerate}", "").replace(r"\end{enumerate}", "")
    s = re.sub(r"\\item\s*", "\n- ", s)

    def table_block(m: re.Match[str]) -> str:
        body = m.group(0)
        cap = re.search(r"\\caption\{([^}]*)\}", body)
        caption = cap.group(1) if cap else ""
        body = re.sub(r"\\begin\{tabular\}\{[^}]*\}", "", body)
        body = re.sub(r"\\end\{tabular\}", "", body)
        for tok in (r"\hline", r"\toprule", r"\midrule", r"\bottomrule", r"\centering"):
            body = body.replace(tok, "")
        body = re.sub(r"\\caption\{[^}]*\}", "", body)
        body = re.sub(r"\\label\{[^}]*\}", "", body)
        body = body.replace(r"\end{table}", "")
        lines = []
        for row in re.split(r"\\\\", body):
            row = row.strip()
            if not row:
                continue
            cells = [c.strip() for c in row.split("&")]
            if any(cells):
                lines.append("| " + " | ".join(cells) + " |")
        if not lines:
            return f"\n> **[Table]** {caption}\n"
        ncols = lines[0].count("|") - 1
        sep = "| " + " | ".join(["---"] * ncols) + " |"
        out = "\n" + lines[0] + "\n" + sep + "\n" + "\n".join(lines[1:]) + "\n"
        if caption:
            out += f"\n*{caption}*\n"
        return out

    s = re.sub(r"\\begin\{table\}.*?\\end\{table\}", table_block, s, flags=re.S)

    def fig_block(m: re.Match[str]) -> str:
        cap = re.search(r"\\caption\{([^}]*)\}", m.group(0))
        return "\n> **[Figure]** " + (cap.group(1) if cap else "(see LaTeX)") + "\n"

    s = re.sub(r"\\begin\{figure\}.*?\\end\{figure\}", fig_block, s, flags=re.S)

    s = re.sub(r"\\section\*?\{([^}]*)\}", r"\n# \1\n", s)
    s = re.sub(r"\\subsection\*?\{([^}]*)\}", r"\n## \1\n", s)
    s = re.sub(r"\\subsubsection\*?\{([^}]*)\}", r"\n### \1\n", s)

    s = re.sub(r"\\parencite\{([^}]*)\}", r"[\1]", s)
    s = re.sub(r"\\textcite\{([^}]*)\}", r"\1", s)
    s = re.sub(r"\\cite\{([^}]*)\}", r"[\1]", s)
    s = re.sub(r"\\[cC]ref\{([^}]*)\}", r"(\1)", s)
    s = re.sub(r"\\eqref\{([^}]*)\}", r"(\1)", s)
    s = re.sub(r"\\ref\{([^}]*)\}", r"(\1)", s)

    s = re.sub(r"\\emph\{([^{}]*)\}", r"*\1*", s)
    s = re.sub(r"\\textbf\{([^{}]*)\}", r"**\1**", s)
    s = re.sub(r"\\textit\{([^{}]*)\}", r"*\1*", s)
    s = re.sub(r"\\texttt\{([^{}]*)\}", r"`\1`", s)

    for a, b in [
        (r"\noindent", ""),
        (r"\newpage", ""),
        (r"\medskip", ""),
        (r"\smallskip", ""),
        (r"\bigskip", ""),
        (r"\centering", ""),
        (r"\,", " "),
        (r"\;", " "),
        (r"\!", ""),
        (r"\ ", " "),
        ("~", " "),
        (r"\ldots", "…"),
        (r"\dots", "…"),
        (r"\times", "×"),
        (r"\approx", "≈"),
        (r"\leq", "≤"),
        (r"\geq", "≥"),
        (r"\neq", "≠"),
        (r"\pm", "±"),
        (r"\cdot", "·"),
    ]:
        s = s.replace(a, b)

    s = re.sub(r"\\label\{[^}]*\}", "", s)
    s = re.sub(r"\\frac\{([^{}]*)\}\{([^{}]*)\}", r"(\1)/(\2)", s)
    s = re.sub(r"\\tfrac\{([^{}]*)\}\{([^{}]*)\}", r"(\1)/(\2)", s)
    s = re.sub(r"\\sqrt\{([^{}]*)\}", r"sqrt(\1)", s)

    for _ in range(3):
        s = re.sub(r"\\[a-zA-Z]+\*?\{([^{}]*)\}", r"\1", s)

    parts = re.split(r"(\$\$[\s\S]*?\$\$|\$[^$]+\$)", s)
    keep = {"Var", "Cov", "Corr", "hat", "bar", "tilde", "mathrm", "operatorname", "mathbb", "text"}
    out_parts = []
    for part in parts:
        if part.startswith("$"):
            out_parts.append(part)
        else:
            part = re.sub(
                r"\\([a-zA-Z]+)\*?",
                lambda m: m.group(1) if m.group(1) in keep else "",
                part,
            )
            out_parts.append(part)
    s = "".join(out_parts)
    s = s.replace("{", "").replace("}", "")
    s = re.sub(r"[ \t]+\n", "\n", s)
    s = re.sub(r"\n{3,}", "\n\n", s).strip() + "\n"

    header = (
        f"# {title}\n\n"
        f"> **Review copy** from LaTeX. Source of truth: `{path}`.\n"
        f"> Propose edits in chat (or annotate this file); agreed changes go into the `.tex`.\n"
        f"> Math rendering is approximate.\n\n---\n\n"
    )
    return header + s


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    macros = load_macros()
    index = [
        "# Empirical paper — Markdown review copies",
        "",
        "Generated for Cursor read-through. **LaTeX in `sections/` remains authoritative.**",
        "",
        "**Workflow:** review here → agree wording → apply to `.tex` → commit/push → Overleaf for co-author comments.",
        "",
        "Regenerate: `python3 \"Paper Review Process/export_sections_to_md.py\"`",
        "",
        "| # | Section | Markdown | LaTeX |",
        "|---|---------|----------|-------|",
    ]
    for i, (stem, path, title) in enumerate(ORDER, 1):
        tex = expand_inputs((ROOT / path).read_text(encoding="utf-8"))
        md = tex_to_md(tex, title, path, macros)
        (OUT_DIR / f"{stem}.md").write_text(md, encoding="utf-8")
        index.append(f"| {i} | {title} | [`{stem}.md`]({stem}.md) | [`{path}`](../../{path}) |")
        print(f"wrote {stem}.md ({len(md)} chars)")

    index += [
        "",
        "## Suggested review order",
        "",
        "1. Abstract → Introduction",
        "2. **Methods** (current focus)",
        "3. Theoretical framework (skim)",
        "4. Results → Discussion → Conclusion",
        "5. Tables/figures captions → SI as needed",
        "",
    ]
    (OUT_DIR / "README.md").write_text("\n".join(index), encoding="utf-8")
    print(f"macros loaded: {len(macros)}")


if __name__ == "__main__":
    main()
