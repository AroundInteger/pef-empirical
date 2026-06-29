function figure_quad_exemplars(ax, pef_2s, pef_per_season, metric, delta, sigmaA)
%FIGURE_QUAD_EXEMPLARS  Four confirmatory exemplars (tab:exemplars) with season drift.
%   metric: 'eta' (default) or 'I' for legend annotation on (kappa,rho) axes.

    if nargin < 4 || isempty(metric)
        metric = 'eta';
    end
    if nargin < 5 || isempty(delta)
        delta = 1.0;
    end
    if nargin < 6 || isempty(sigmaA)
        sigmaA = 1.0;
    end

    rugby_clr = [0.12 0.47 0.71];
    foot_clr  = [0.90 0.40 0.05];

    spec = { ...
        'Q1', "rugby",    "kick_metres",           'Kick metres (rugby)',          rugby_clr, 'o'; ...
        'Q2', "football", "long_balls",            'Long balls (football)',        foot_clr,  's'; ...
        'Q3', "football", "passes",                'Passes (football)',            foot_clr,  's'; ...
        'Q4', "football", "goalkeeper_long_balls", 'GK long balls (football)',     foot_clr,  's'};

    FS_MARKER = 12;
    season_early = "23/24";
    season_late  = "24/25";

    for i = 1:size(spec, 1)
        q_lbl   = spec{i, 1};
        sport   = spec{i, 2};
        kpi     = spec{i, 3};
        leg_lbl = spec{i, 4};
        clr     = spec{i, 5};
        mk      = spec{i, 6};

        [rp_pool, kp_pool, val_pool] = lookup_pooled(pef_2s, sport, kpi, metric, delta, sigmaA);
        [rp1, kp1] = lookup_season(pef_per_season, sport, kpi, season_early);
        [rp2, kp2] = lookup_season(pef_per_season, sport, kpi, season_late);

        if isfinite(rp1) && isfinite(kp1) && isfinite(rp2) && isfinite(kp2)
            plot(ax, [rp1 rp2], [kp1 kp2], '-', 'Color', clr, 'LineWidth', 1.4, ...
                'HandleVisibility', 'off');
            scatter(ax, rp1, kp1, 72, clr, mk, 'LineWidth', 1.0, ...
                'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k', ...
                'HandleVisibility', 'off');
        end

        rp_plot = rp2;
        kp_plot = kp2;
        if ~isfinite(rp_plot) || ~isfinite(kp_plot)
            rp_plot = rp_pool;
            kp_plot = kp_pool;
        end

        if strcmpi(metric, 'I')
            leg_str = sprintf('%s  (I=%.3f)', leg_lbl, val_pool);
        else
            leg_str = sprintf('%s  (\\eta=%.2f)', leg_lbl, val_pool);
        end

        scatter(ax, rp_plot, kp_plot, 130, clr, mk, 'filled', ...
            'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', leg_str);

        q_num = q_lbl(2);
        text(ax, rp_plot, kp_plot, q_num, ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
            'FontSize', FS_MARKER, 'FontWeight', 'bold', 'Color', 'w', ...
            'HandleVisibility', 'off');
    end
end

% -------------------------------------------------------------------------
function [rp, kp, val] = lookup_pooled(pef_tbl, sport_str, kpi_str, metric, delta, sigmaA)
    rp = NaN;
    kp = NaN;
    val = NaN;
    if isempty(pef_tbl) || height(pef_tbl) == 0
        return
    end
    m = pef_tbl.sport == sport_str & pef_tbl.kpi == kpi_str;
    if ~any(m)
        return
    end
    idx = find(m, 1);
    rp  = pef_tbl.rho(idx);
    kp  = pef_tbl.kappa(idx);
    if strcmpi(metric, 'I')
        val = mi_at_point(kp, rp, delta, sigmaA);
    else
        val = pef_tbl.eta(idx);
    end
end

% -------------------------------------------------------------------------
function [rp, kp] = lookup_season(pef_ps, sport_str, kpi_str, season_str)
    rp = NaN;
    kp = NaN;
    if isempty(pef_ps) || height(pef_ps) == 0
        return
    end
    if ~ismember('season', pef_ps.Properties.VariableNames)
        return
    end
    m = pef_ps.sport == sport_str & pef_ps.kpi == kpi_str & pef_ps.season == season_str;
    if ~any(m)
        return
    end
    idx = find(m, 1);
    rp  = pef_ps.rho(idx);
    kp  = pef_ps.kappa(idx);
end

% -------------------------------------------------------------------------
function Ixy = mi_at_point(kappa, rho, delta, sigmaA)
    den = 1 + kappa - 2 * sqrt(kappa) * rho;
    if den <= 0 || ~isfinite(kappa) || ~isfinite(rho)
        Ixy = NaN;
        return
    end
    eta = (1 + kappa) / den;
    sep = normcdf(delta / (2 * sigmaA * sqrt((1 + kappa) / eta)));
    sep = min(max(sep, 1e-12), 1 - 1e-12);
    Ixy = 1 - (-sep * log2(sep) - (1 - sep) * log2(1 - sep));
end
