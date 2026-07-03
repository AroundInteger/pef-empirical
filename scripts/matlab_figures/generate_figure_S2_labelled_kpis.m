%% generate_figure_S2_labelled_kpis.m
%
% Supplementary Figure S2: Labelled KPI maps (rugby + football, two seasons).
%
% Output: figures/Figure_2_SI.png  (300 dpi, pef_figure_style)

close all; clc;

script_dir = fileparts(mfilename('fullpath'));
cfg = si_figure_config();
addpath(cfg.normality_dir);
addpath(fullfile(fileparts(script_dir), 'paper_pipeline', 'lib'));

ST = pef_figure_style.config();
H = pef_theory_helpers();

RUGBY_SEASONS    = cfg.rugby_seasons;
FOOTBALL_SEASONS = cfg.football_seasons;

if ~exist(cfg.rugby_raw, 'file')
    error('Rugby raw data not found: %s', cfg.rugby_raw);
end
[rugby_paired, rugby_kpis] = load_rugby_paired(cfg.rugby_raw);
mask_r = ismember(string(rugby_paired.season), string(RUGBY_SEASONS));
rugby_paired = rugby_paired(mask_r, :);
[kpi_rugby, rugby_kpis] = si_compute_kpi_season_data( ...
    rugby_paired, rugby_kpis, RUGBY_SEASONS, "rugby");
rugby_stems = si_stems_with_labels(rugby_kpis);

if ~exist(cfg.foot_dir, 'dir')
    warning('Football data directory not found: %s', cfg.foot_dir);
    kpi_football = nan(1, 2, 3);
    football_stems = {'kpi', 'KPI'};
else
    [foot_paired, foot_kpis] = load_football_paired(cfg.foot_dir, cfg.foot_2s);
    mask_f = ismember(string(foot_paired.season), string(FOOTBALL_SEASONS));
    foot_paired = foot_paired(mask_f, :);
    [kpi_football, foot_kpis] = si_compute_kpi_season_data( ...
        foot_paired, foot_kpis, FOOTBALL_SEASONS, "football");
    football_stems = si_stems_with_labels(foot_kpis);
end

fig = pef_figure_style.new_figure(1800, 820);

ax1 = subplot(1, 2, 1);
pef_figure_style.draw_eta_surface(ax1, ST, true);
plot_kpi_panel(ax1, kpi_rugby, rugby_stems, ST.rugby, ST.migrate, ...
    'o', 'URC Rugby — all KPIs, seasons 23/24 \rightarrow 24/25', H, ST);

ax2 = subplot(1, 2, 2);
pef_figure_style.draw_eta_surface(ax2, ST, true);
plot_kpi_panel(ax2, kpi_football, football_stems, ST.football, ST.migrate, ...
    's', 'Championship Football — all KPIs, seasons 23/24 \rightarrow 24/25', H, ST);

cb = pef_figure_style.add_eta_colorbar(ax2);
cb.Label.String = 'PEF \eta';

set(fig, 'Units', 'normalized');
ax1.Position = [0.04, 0.08, 0.42, 0.84];
ax2.Position = [0.53, 0.08, 0.38, 0.84];

annotation('textbox', [0.01, 0.93, 0.98, 0.06], ...
    'String', ...
    ['{\bf Season symbols:}  open marker = season 1 (23/24);  ' ...
     'filled marker = season 2 (24/25);  arrow = direction of change;  ' ...
     '{\color[rgb]{0.84,0.37,0.00}vermillion} = quadrant migration'], ...
    'EdgeColor', 'none', 'FontSize', ST.fs_panel, ...
    'HorizontalAlignment', 'center', 'Interpreter', 'tex');

out_png = fullfile(cfg.fig_dir, 'Figure_2_SI.png');
pef_figure_style.export_figure(fig, out_png);
close(fig);
fprintf('Saved: %s\n', out_png);

function plot_kpi_panel(ax, kpi_data, stems, clr_cat, clr_migrate, marker, ttl, H, ST)
    axes(ax); %#ok<LAXES>
    n_kpi = size(kpi_data, 1);
    label_offsets = compute_label_offsets(kpi_data, n_kpi);

    for k = 1:n_kpi
        rh1 = kpi_data(k, 1, 2);  kp1 = kpi_data(k, 1, 1);
        rh2 = kpi_data(k, 2, 2);  kp2 = kpi_data(k, 2, 1);
        if any(isnan([rh1, kp1, rh2, kp2])), continue; end

        q1 = H.classify_quadrant(kp1, rh1);
        q2 = H.classify_quadrant(kp2, rh2);
        clr = clr_cat;
        if ~strcmp(q1, q2), clr = clr_migrate; end

        dr = rh2 - rh1;  dk = kp2 - kp1;
        if abs(dr) + abs(dk) > 1e-4
            quiver(rh1, kp1, dr * 0.85, dk * 0.85, 0, ...
                'Color', clr, 'LineWidth', 1.2, ...
                'MaxHeadSize', 0.6, 'HandleVisibility', 'off');
        end

        plot(rh1, kp1, marker, 'MarkerFaceColor', 'none', ...
            'MarkerEdgeColor', clr, 'MarkerSize', 9, 'LineWidth', 1.4, ...
            'HandleVisibility', 'off');
        plot(rh2, kp2, marker, 'MarkerFaceColor', clr, ...
            'MarkerEdgeColor', 'w', 'MarkerSize', 9, 'LineWidth', 1, ...
            'HandleVisibility', 'off');

        lbl = stems{k, 2};
        dx = label_offsets(k, 1);
        dy = label_offsets(k, 2);
        text(rh2 + dx, kp2 + dy, lbl, 'FontSize', 9, 'Color', clr, ...
            'HorizontalAlignment', dx_align(dx), ...
            'VerticalAlignment', 'middle', 'Interpreter', 'none');
    end

    h1 = plot(nan, nan, marker, 'MarkerFaceColor', 'none', ...
        'MarkerEdgeColor', clr_cat, 'MarkerSize', 9, 'LineWidth', 1.4);
    h2 = plot(nan, nan, marker, 'MarkerFaceColor', clr_cat, ...
        'MarkerEdgeColor', 'w', 'MarkerSize', 9, 'LineWidth', 1);
    h3 = plot(nan, nan, marker, 'MarkerFaceColor', clr_migrate, ...
        'MarkerEdgeColor', 'w', 'MarkerSize', 9, 'LineWidth', 1);
    legend([h1, h2, h3], ...
        {'Season 1 (23/24)', 'Season 2 (24/25)', 'Quadrant migration'}, ...
        'Location', 'southeast', 'Box', 'off', 'FontSize', ST.fs_panel, ...
        'TextColor', ST.quad_text);

    title(ttl, 'FontSize', ST.fs_title, 'FontWeight', 'bold');
end

function offsets = compute_label_offsets(~, n_kpi)
    offsets = repmat([0.03, 0.06], n_kpi, 1);
    for k = 1:n_kpi
        if mod(k, 2) == 0
            offsets(k, 2) = -0.08;
        end
    end
end

function ha = dx_align(dx)
    if dx >= 0, ha = 'left'; else, ha = 'right'; end
end
