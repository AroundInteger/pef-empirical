function stems = si_stems_with_labels(kpi_names)
%SI_STEMS_WITH_LABELS  Build {id, display_label} pairs for SI figure labelling.
    kpi_names = cellstr(kpi_names);
    n = numel(kpi_names);
    stems = cell(n, 2);
    for k = 1:n
        stems{k, 1} = kpi_names{k};
        stems{k, 2} = si_pretty_kpi_label(kpi_names{k});
    end
end

function lbl = si_pretty_kpi_label(name)
    lbl = strrep(char(name), '_', ' ');
    lbl(1) = upper(lbl(1));
end
