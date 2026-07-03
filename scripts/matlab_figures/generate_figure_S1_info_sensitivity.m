%% generate_figure_S1_info_sensitivity.m
%
% Supplementary Figure S1: Sensitivity of I(X;Y) to delta/sigma_A.
% Three panels at delta/sigma_A = 0.5, 1.0, 2.0 (centre matches main Fig. 2).
%
% Output: figures/Figure_1_SI.png  (300 dpi, pef_figure_style)

close all; clc;

script_dir = fileparts(mfilename('fullpath'));
cfg = si_figure_config();
addpath(cfg.normality_dir);
addpath(fullfile(fileparts(script_dir), 'paper_pipeline', 'lib'));

ST = pef_figure_style.config();
fig_dir = cfg.fig_dir;
delta_sigma_A_values = [0.5, 1.0, 2.0];
panel_labels = {'(A)  \delta/\sigma_A = 0.5', ...
                '(B)  \delta/\sigma_A = 1.0', ...
                '(C)  \delta/\sigma_A = 2.0'};

RUGBY_SEASONS    = cfg.rugby_seasons;
FOOTBALL_SEASONS = cfg.football_seasons;

if ~exist(cfg.rugby_raw, 'file')
    error('Rugby raw data not found: %s', cfg.rugby_raw);
end
[rugby_paired, rugby_kpis] = load_rugby_paired(cfg.rugby_raw);
mask_r = ismember(string(rugby_paired.season), string(RUGBY_SEASONS));
rugby_paired = rugby_paired(mask_r, :);
[kpi_rugby, ~] = si_compute_kpi_season_data( ...
    rugby_paired, rugby_kpis, RUGBY_SEASONS, "rugby");

if ~exist(cfg.foot_dir, 'dir')
    warning('Football data directory not found: %s', cfg.foot_dir);
    kpi_football = nan(1, 2, 3);
else
    [foot_paired, foot_kpis] = load_football_paired(cfg.foot_dir, cfg.foot_2s);
    mask_f = ismember(string(foot_paired.season), string(FOOTBALL_SEASONS));
    foot_paired = foot_paired(mask_f, :);
    [kpi_football, ~] = si_compute_kpi_season_data( ...
        foot_paired, foot_kpis, FOOTBALL_SEASONS, "football");
end

fig = pef_figure_style.new_figure(1800, 620);
ax_handles = gobjects(1, 3);

for p = 1:3
    ax = subplot(1, 3, p);
    ax_handles(p) = ax;
    pef_figure_style.draw_I_surface(ax, delta_sigma_A_values(p), 1.0, ST, ...
        ST.I_panel_caxis, true);
    overlay_kpi_segments(ax, kpi_rugby, ST.rugby, 'o');
    overlay_kpi_segments(ax, kpi_football, ST.football, 's');
    title(ax, panel_labels{p}, 'FontSize', ST.fs_title, 'FontWeight', 'bold', ...
        'Interpreter', 'tex');
    if p > 1
        ylabel(ax, '');
    end
end

colormap(ax_handles(3), parula(256));
cb = colorbar(ax_handles(3));
cb.Label.String = 'I(X;Y)  [bits]';
cb.Label.FontSize = ST.fs_label;
cb.FontSize = ST.fs_tick;
cb.Ticks = 0:0.2:1;

axes(ax_handles(2));
h_r = plot(nan, nan, 'o', 'MarkerFaceColor', ST.rugby, ...
    'MarkerEdgeColor', 'w', 'MarkerSize', 8);
h_f = plot(nan, nan, 's', 'MarkerFaceColor', ST.football, ...
    'MarkerEdgeColor', 'w', 'MarkerSize', 8);
legend([h_r, h_f], ...
    {'Rugby URC (mean \pm season range)', ...
     'Football Championship (mean \pm season range)'}, ...
    'Location', 'southoutside', 'Orientation', 'horizontal', ...
    'Box', 'off', 'FontSize', ST.fs_panel);

out_png = fullfile(fig_dir, 'Figure_1_SI.png');
pef_figure_style.export_figure(fig, out_png);
close(fig);
fprintf('Saved: %s\n', out_png);

function overlay_kpi_segments(ax, kpi_data, clr, marker)
    n_kpi = size(kpi_data, 1);
    axes(ax); %#ok<LAXES>
    for k = 1:n_kpi
        rh1 = kpi_data(k, 1, 2);  kp1 = kpi_data(k, 1, 1);
        rh2 = kpi_data(k, 2, 2);  kp2 = kpi_data(k, 2, 1);
        if any(isnan([rh1, kp1, rh2, kp2])), continue; end
        plot(ax, [rh1, rh2], [kp1, kp2], '-', 'Color', [clr, 0.50], ...
            'LineWidth', 1.2, 'HandleVisibility', 'off');
        plot(ax, [rh1, rh2], [kp1, kp2], 'x', 'Color', clr, ...
            'MarkerSize', 6, 'LineWidth', 1.1, 'HandleVisibility', 'off');
        plot(ax, mean([rh1, rh2]), mean([kp1, kp2]), marker, ...
            'MarkerFaceColor', clr, 'MarkerEdgeColor', 'w', ...
            'MarkerSize', 8, 'LineWidth', 0.8, 'HandleVisibility', 'off');
    end
end
