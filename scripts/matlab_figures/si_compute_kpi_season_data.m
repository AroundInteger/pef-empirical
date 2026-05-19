function [kpi_data, stems] = si_compute_kpi_season_data(paired, kpi_names, seasons, sport_label)
%SI_COMPUTE_KPI_SEASON_DATA  Per-season (kappa, rho, eta) tensor for SI overlays.
%   kpi_data(n_kpi, n_season, 3) with pages [kappa, rho, eta].
%   Uses compute_pef from PEF_Normality_4seasons (same as run_paper_pipeline).

    if nargin < 4
        sport_label = "";
    end

    n_kpi = numel(kpi_names);
    n_szn = numel(seasons);
    kpi_data = nan(n_kpi, n_szn, 3);
    stems = kpi_names(:);

    season_col = paired.season;
    if ~isstring(season_col)
        season_col = string(season_col);
    end

    for s = 1:n_szn
        mask = season_col == string(seasons{s});
        sub = paired(mask, :);
        if height(sub) < 10
            continue
        end
        pp = compute_pef(sub, cellstr(stems), sport_label);
        for k = 1:n_kpi
            row = pp(pp.kpi == string(stems{k}), :);
            if height(row) == 1
                kpi_data(k, s, 1) = row.kappa(1);
                kpi_data(k, s, 2) = row.rho(1);
                kpi_data(k, s, 3) = row.eta(1);
            end
        end
    end
end
