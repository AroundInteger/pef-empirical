%% generate_figure_S2_labelled_kpis.m
%
% Supplementary Figure S2: Full labelled KPI maps — two panels.
%
%   Panel A (left):  All rugby URC KPIs, seasons 23/24 and 24/25.
%   Panel B (right): All football Championship KPIs, seasons 23/24 and 24/25.
%
% Each KPI is plotted as:
%   - Season 1 point  (open circle / square)
%   - Season 2 point  (filled circle / square)
%   - Arrow from season 1 → season 2
%   - Text label at the season-2 point
%
% KPIs whose position does not change quadrant across seasons are plotted in
% the category colour; KPIs that migrate quadrant are highlighted in red.
%
% Output: figures/Figure_2_SI.png   (supplementary)
%
% Dependencies: scripts/pef_calculation_script_matlab.m (via pef_from_paired_vectors)

clear; close all; clc;

script_dir = fileparts(mfilename('fullpath'));
cfg = si_figure_config();
addpath(cfg.normality_dir);
addpath(fullfile(fileparts(script_dir), 'paper_pipeline', 'lib'));

rugby_raw_file = cfg.rugby_raw;
fig_dir        = cfg.fig_dir;

RUGBY_SEASONS    = cfg.rugby_seasons;
FOOTBALL_SEASONS = cfg.football_seasons;

% -------------------------------------------------------------------------
%% 1–2.  Load data and compute per-season PEF parameters (pipeline loaders)
% -------------------------------------------------------------------------

if ~exist(rugby_raw_file, 'file')
    error('Rugby raw data not found: %s', rugby_raw_file);
end
[rugby_paired, rugby_kpis] = load_rugby_paired(rugby_raw_file);
mask_r = ismember(string(rugby_paired.season), string(RUGBY_SEASONS));
rugby_paired = rugby_paired(mask_r, :);
[kpi_rugby, rugby_kpis] = si_compute_kpi_season_data( ...
    rugby_paired, rugby_kpis, RUGBY_SEASONS, "rugby");
rugby_stems = si_stems_with_labels(rugby_kpis);

foot_dir = cfg.foot_dir;
if ~exist(foot_dir, 'dir')
    warning('Football data directory not found: %s', foot_dir);
    kpi_football = nan(1, 2, 3);
    football_stems = {'kpi', 'KPI'};
else
    [foot_paired, foot_kpis] = load_football_paired(foot_dir, cfg.foot_2s);
    mask_f = ismember(string(foot_paired.season), string(FOOTBALL_SEASONS));
    foot_paired = foot_paired(mask_f, :);
    [kpi_football, foot_kpis] = si_compute_kpi_season_data( ...
        foot_paired, foot_kpis, FOOTBALL_SEASONS, "football");
    football_stems = si_stems_with_labels(foot_kpis);
end

% -------------------------------------------------------------------------
%% 3.  Draw two-panel figure
% -------------------------------------------------------------------------

fig = figure('Position', [50, 50, 1800, 820], 'Color', 'white');

clr_rugby    = [0   119 187]/255;
clr_football = [230 159   0]/255;
clr_migrate  = [213  94   0]/255;   % vermillion — quadrant migration

rho_vec   = linspace(-0.999, 0.999, 600);
kappa_vec = linspace(0.0,    4.0,   600);
[R, K]    = meshgrid(rho_vec, kappa_vec);
PEF_surf  = (1 + K) ./ (1 + K - 2.*sqrt(K).*R);
PEF_log   = log10(min(max(PEF_surf, 0.01), 100));

% ------------------------------------------------------------------
% Panel A — Rugby
% ------------------------------------------------------------------
ax1 = subplot(1, 2, 1);
draw_landscape(ax1, R, K, PEF_log);
plot_kpi_panel(ax1, kpi_rugby, rugby_stems, clr_rugby, clr_migrate, ...
               'o', 'URC Rugby — all KPIs, seasons 23/24 \rightarrow 24/25');

% ------------------------------------------------------------------
% Panel B — Football
% ------------------------------------------------------------------
ax2 = subplot(1, 2, 2);
draw_landscape(ax2, R, K, PEF_log);
plot_kpi_panel(ax2, kpi_football, football_stems, clr_football, clr_migrate, ...
               's', 'Championship Football — all KPIs, seasons 23/24 \rightarrow 24/25');

% Shared colourbar
cb = colorbar(ax2);
cb.Label.String  = 'PEF \eta (log_{10} scale)';
cb.Label.FontSize = 12;
colormap(fig, parula(256));

% Tighten layout
set(fig, 'Units', 'normalized');
ax1.Position = [0.04, 0.08, 0.42, 0.84];
ax2.Position = [0.53, 0.08, 0.38, 0.84];

% Season legend (common to both panels)
annotation('textbox', [0.01, 0.93, 0.98, 0.06], ...
    'String', ...
    ['{\bf Season symbols:}  open marker = season 1 (23/24) ;  ' ...
     'filled marker = season 2 (24/25) ;  arrow: direction of change ;  ' ...
     '{\color[rgb]{0.84,0.37,0.00}vermillion} = quadrant migration'], ...
    'EdgeColor', 'none', 'FontSize', 11, 'HorizontalAlignment', 'center', ...
    'Interpreter', 'tex');

% Save
out_png = fullfile(fig_dir, 'Figure_2_SI.png');
exportgraphics(fig, out_png, 'Resolution', 300);
fprintf('Saved: %s\n', out_png);

% =========================================================================
%% Local functions
% =========================================================================

function draw_landscape(ax, R, K, PEF_log)
%DRAW_LANDSCAPE  Render PEF surface + quadrant lines on axes ax.
    axes(ax); %#ok<LAXES>
    contourf(R, K, PEF_log, 40, 'LineStyle', 'none');
    hold on;
    pef_cv = [0.5:0.1:1.0, 1.2, 1.5, 2:5, 10, 20];
    contour(R, K, PEF_log, log10(pef_cv), 'w:', 'LineWidth', 0.8);
    set(findobj(ax, 'Type', 'contour'), 'HandleVisibility', 'off');
    plot([0,0],  [0,4], 'k-', 'LineWidth', 2.5, 'HandleVisibility', 'off');
    plot([-1,1], [1,1], 'k-', 'LineWidth', 2.5, 'HandleVisibility', 'off');
    text( 0.38, 3.5, 'Q1', 'FontSize', 13, 'Color', 'y', 'FontWeight', 'bold');
    text( 0.38, 0.4, 'Q2', 'FontSize', 13, 'Color', 'y', 'FontWeight', 'bold');
    text(-0.55, 0.4, 'Q3', 'FontSize', 13, 'Color', 'y', 'FontWeight', 'bold');
    text(-0.55, 3.5, 'Q4', 'FontSize', 13, 'Color', 'y', 'FontWeight', 'bold');
    colormap(ax, parula(256));
    clim([log10(0.3), log10(20)]);
    xlim([-1, 1]);  ylim([0, 4]);
    xticks(-1:0.5:1);   xticklabels(compose('%.1f', -1:0.5:1));
    yticks(0:0.5:4);    yticklabels(compose('%.1f', 0:0.5:4));
    xlabel('Correlation Coefficient (\rho)', 'FontSize', 13);
    ylabel('Variance Ratio (\kappa)',         'FontSize', 13);
    set(ax, 'FontSize', 11);
    grid on;
end

function plot_kpi_panel(ax, kpi_data, stems, clr_cat, clr_migrate, marker, ttl)
%PLOT_KPI_PANEL  Plot per-season KPI positions with arrows and labels.
%
%   kpi_data(k, season, [kappa rho eta])
    axes(ax); %#ok<LAXES>
    n_kpi = size(kpi_data, 1);

    label_offsets = compute_label_offsets(kpi_data, n_kpi);

    H = pef_theory_helpers();

    for k = 1:n_kpi
        rh1 = kpi_data(k, 1, 2);  kp1 = kpi_data(k, 1, 1);
        rh2 = kpi_data(k, 2, 2);  kp2 = kpi_data(k, 2, 1);

        % Skip KPIs with missing data in either season
        if any(isnan([rh1 kp1 rh2 kp2])), continue; end

        % Detect quadrant migration via the canonical pef_theory_helpers
        % classifier (note arg order: kappa, rho). Boundary cases (kappa==1
        % or rho==0) return "boundary" rather than being absorbed into a
        % neighbouring quadrant; in continuous KPI data this is measure-zero
        % and the visual outcome matches the previous local quadrant_id.
        q1 = H.classify_quadrant(kp1, rh1);
        q2 = H.classify_quadrant(kp2, rh2);
        clr = clr_cat;
        if ~strcmp(q1, q2), clr = clr_migrate; end

        % Arrow from season 1 → season 2
        dr = rh2 - rh1;  dk = kp2 - kp1;
        if abs(dr) + abs(dk) > 1e-4
            quiver(rh1, kp1, dr*0.85, dk*0.85, 0, ...
                   'Color', clr, 'LineWidth', 1.2, ...
                   'MaxHeadSize', 0.6, 'HandleVisibility', 'off');
        end

        % Season 1: open marker
        plot(rh1, kp1, marker, 'MarkerFaceColor', 'none', ...
             'MarkerEdgeColor', clr, 'MarkerSize', 9, 'LineWidth', 1.4, ...
             'HandleVisibility', 'off');

        % Season 2: filled marker
        plot(rh2, kp2, marker, 'MarkerFaceColor', clr, ...
             'MarkerEdgeColor', 'w', 'MarkerSize', 9, 'LineWidth', 1, ...
             'HandleVisibility', 'off');

        % Label at season-2 position
        lbl = stems{k, 2};
        dx  = label_offsets(k, 1);
        dy  = label_offsets(k, 2);
        text(rh2 + dx, kp2 + dy, lbl, ...
             'FontSize', 9, 'Color', clr, ...
             'HorizontalAlignment', dx_align(dx), ...
             'VerticalAlignment',   'middle', ...
             'Interpreter', 'none');
    end

    % Dummy handles for legend
    h1 = plot(nan, nan, marker, 'MarkerFaceColor', 'none', ...
              'MarkerEdgeColor', clr_cat, 'MarkerSize', 9, 'LineWidth', 1.4);
    h2 = plot(nan, nan, marker, 'MarkerFaceColor', clr_cat, ...
              'MarkerEdgeColor', 'w',   'MarkerSize', 9, 'LineWidth', 1);
    h3 = plot(nan, nan, marker, 'MarkerFaceColor', clr_migrate, ...
              'MarkerEdgeColor', 'w',   'MarkerSize', 9, 'LineWidth', 1);
    legend([h1 h2 h3], {'Season 1 (23/24)', 'Season 2 (24/25)', 'Quadrant migration'}, ...
           'Location', 'southeast', 'Box', 'off', 'FontSize', 10, 'TextColor', 'w');

    title(ttl, 'FontSize', 13, 'FontWeight', 'bold');
end

function offsets = compute_label_offsets(kpi_data, n_kpi)
%COMPUTE_LABEL_OFFSETS  Simple stagger to reduce label overlap.
%   Returns [drho, dkappa] offset per KPI.
    offsets = repmat([0.03, 0.06], n_kpi, 1);
    % Alternate above/below for adjacent KPIs
    for k = 1:n_kpi
        if mod(k, 2) == 0
            offsets(k, 2) = -0.08;
        end
    end
end

function ha = dx_align(dx)
    if dx >= 0, ha = 'left'; else, ha = 'right'; end
end

% -------------------------------------------------------------------------

function kpi_data = compute_all_kpis(T, stems, seasons, season_col)
%COMPUTE_ALL_KPIS  Compute (kappa,rho,eta) per KPI per season from a table.
    n_kpi = size(stems, 1);
    kpi_data = nan(n_kpi, 2, 3);
    for s = 1:2
        mask = strcmp(string(T.(season_col)), string(seasons{s}));
        Ts   = T(mask, :);
        for k = 1:n_kpi
            h_col = [stems{k,1} '_home'];
            a_col = [stems{k,1} '_away'];
            if ~ismember(h_col, Ts.Properties.VariableNames), continue; end
            x_h = Ts.(h_col);
            x_a = Ts.(a_col);
            valid = ~isnan(x_h) & ~isnan(x_a) & isfinite(x_h) & isfinite(x_a);
            if sum(valid) < 10, continue; end
            stem = stems{k, 1};
            [kp, rh, et] = pef_from_paired_vectors(x_h(valid), x_a(valid), stem, ...
                'ApplyLogTransform', false, 'Verbose', false);
            kpi_data(k, s, :) = [kp, rh, et];
        end
    end
end

