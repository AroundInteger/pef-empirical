# Abstract

> **Review copy** from LaTeX. Source of truth: `sections/abstract.tex`.
> Propose edits in chat (or annotate this file); agreed changes go into the `.tex`.
> Math rendering is approximate.

---

In rugby union and association football, team key performance indicators (KPIs) are widely used to summarise match play and to predict match outcomes. Those KPIs can be represented in absolute terms or relative to the opponent. Whether relativisation helps match-outcome prediction is unsettled: it sometimes improves accuracy and sometimes does not, and there has been no general account of when it does.

We demonstrate that the answer depends on two measurable properties of the two teams' KPI values: how much they differ in variability, and how strongly those values tend to rise and fall together. We combine these into the Paired Efficiency Factor (PEF), which generalises Fisher's classical efficiency result for paired measurements to the unequal-variance conditions typical of competitive sport. The PEF also connects a KPI's statistical efficiency to how much information its relative form carries about the outcome. Combined KPIs can interact in complex ways in predictive models, so we deliberately analyse each one on its own, establishing the single-indicator case as a foundation for the multivariate models practitioners ultimately use.

Across a broad inventory of $113$ team KPIs from professional rugby union and association football, covering different count, rate, and event measures, we assess each KPI on its own. The PEF places every metric in one of four regimes that indicate whether relativisation should help. Anti-correlation is common in this inventory, especially for high-volume competitive counts, and absolute measures are then usually preferable. Nevertheless, relativisation can improve prediction when it raises variance: a feature can carry more outcome information even when it is less statistically efficient. An idealised simulation of paired measurements and match outcomes reproduces this tension under controlled conditions. Representative KPIs from each regime then confirm the predicted direction of change under cross-validation. The same pairing structure recurs in healthcare, genomics, finance, and manufacturing.

The PEF turns an ad hoc feature-engineering choice into a transparent, data-informed diagnostic for when to relativise performance metrics in competitive prediction.
