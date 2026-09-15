# Conclusion

> **Review copy** from LaTeX. Source of truth: `sections/conclusion.tex`.
> Propose edits in chat (or annotate this file); agreed changes go into the `.tex`.
> Math rendering is approximate.

---

# Conclusion

The Paired Efficiency Factor $\eta=(1+\kappa)/(1+\kappa-2sqrt(\kappa) \rho)$ generalises Fisher's classical paired efficiency to unequal-variance settings. The formula is distribution-free. Under bivariate normality, a functional relationship between $\eta$ and information content clarifies when and why relative features can improve predictions even when $\eta<1$: information content and efficiency measure distinct quantities that can diverge.

The primary analysis maps each of the $113$ sports KPIs onto the $(\kappa,\rho)$ plane, spanning all four quadrants (landscape summaries in (tab:validation); per-KPI detail in Supplementary (fig:si_kpi_labelled,fig:si_ipred_vs_dml)). Four exemplars at comparable signal strength confirm directional predictions ((tab:exemplars)). The efficiency--power tension is reproduced by the idealised probit simulation (Supplementary (sec:si_note_s2)) and appears in parts of the KPI landscape. Supporting validation across healthcare ($\eta=2.533$), clinical genomics ($\eta=2.696$), finance ($\eta=3.129$), and manufacturing ($\eta=1.382$ on real Bosch CNC telemetry) shows domain-specific heterogeneity in mean $\hat\eta$ and in the proportion of units with $\hat\eta>1$ (50.5--100.0\% in the supporting tier). The four-quadrant taxonomy provides structured feature engineering guidance when read alongside signal strength $\delta/\sigma_A$.

Practices that appear domain-specific, market-adjusted returns, paired clinical designs, control charts, relative performance metrics, can be understood as instances of correlation-based variance reduction with different $(\kappa,\rho)$ values. The PEF framework connects classical statistical principles with modern machine learning practice for the question of when relative features outperform absolute features.
