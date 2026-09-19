%% generate_figure_S4_labelled_kpis.m
%
% Supplementary Figure S4: season-specific KPI maps and quadrant occupancy.
% (A, B) rugby 23/24 and 24/25; (C, D) football 23/24 and 24/25; (E) quadrant
% share. Identity of a KPI is not traced year-on-year (arrows overstate
% boundary jitter). Colour encodes quadrant.
%
% Output: figures/Figure_S4_labelled_kpis.png  (300 dpi, pef_figure_style)

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

if ~exist(cfg.foot_dir, 'dir')
    error('Football data directory not found: %s', cfg.foot_dir);
end
[foot_paired, foot_kpis] = load_football_paired(cfg.foot_dir, cfg.foot_2s);
mask_f = ismember(string(foot_paired.season), string(FOOTBALL_SEASONS));
foot_paired = foot_paired(mask_f, :);
[kpi_football, foot_kpis] = si_compute_kpi_season_data( ...
    foot_paired, foot_kpis, FOOTBALL_SEASONS, "football");

fig = pef_figure_style.new_figure(1600, 1180);
tl = tiledlayout(fig, 3, 2, 'Padding', 'loose', 'TileSpacing', 'compact');

axA = nexttile(tl, 1);
draw_season_map(axA, kpi_rugby, 1, 'o', H, ST);
pef_figure_style.add_panel_letter(axA, '(A)', ST, 'Note', 'Rugby  23/24');

axB = nexttile(tl, 2);
draw_season_map(axB, kpi_rugby, 2, 'o', H, ST);
pef_figure_style.add_panel_letter(axB, '(B)', ST, 'Note', 'Rugby  24/25');

axC = nexttile(tl, 3);
draw_season_map(axC, kpi_football, 1, 's', H, ST);
pef_figure_style.add_panel_letter(axC, '(C)', ST, 'Note', 'Football  23/24');

axD = nexttile(tl, 4);
draw_season_map(axD, kpi_football, 2, 's', H, ST);
pef_figure_style.add_panel_letter(axD, '(D)', ST, 'Note', 'Football  24/25');

cb = pef_figure_style.add_eta_colorbar(axD);
cb.Label.String = 'PEF \eta';

axE = nexttile(tl, 5, [1 2]);
plot_quadrant_share(axE, kpi_rugby, kpi_football, H, ST);
pef_figure_style.add_panel_letter(axE, '(E)', ST);

out_png = fullfile(cfg.fig_dir, 'Figure_S4_labelled_kpis.png');
pef_figure_style.export_figure(fig, out_png);
close(fig);
fprintf('Saved: %s\n', out_png);

function draw_season_map(ax, kpi_data, season_idx, marker, H, ST)
    pef_figure_style.draw_eta_surface(ax, ST, true);
    n_kpi = size(kpi_data, 1);
    for k = 1:n_kpi
        kp = kpi_data(k, season_idx, 1);
        rh = kpi_data(k, season_idx, 2);
        if any(isnan([kp, rh])), continue; end
        q = H.classify_quadrant(kp, rh);
        plot(ax, rh, kp, marker, ...
            'MarkerFaceColor', pef_figure_style.quadrant_color(q), ...
            'MarkerEdgeColor', 'w', 'MarkerSize', 8, 'LineWidth', 0.8, ...
            'HandleVisibility', 'off');
    end
end

function plot_quadrant_share(ax, kpi_rugby, kpi_football, H, ST)
    qkeys = {'Q1', 'Q2', 'Q3', 'Q4'};
    Y = zeros(4, 4);  % groups x quadrants, per cent
    Y(1, :) = season_share(kpi_rugby, 1, H, qkeys);
    Y(2, :) = season_share(kpi_rugby, 2, H, qkeys);
    Y(3, :) = season_share(kpi_football, 1, H, qkeys);
    Y(4, :) = season_share(kpi_football, 2, H, qkeys);

    x = [1, 2, 4, 5];
    b = bar(ax, x, Y, 0.85, 'stacked');
    for qi = 1:4
        b(qi).FaceColor = pef_figure_style.quadrant_color(qkeys{qi});
        b(qi).EdgeColor = 'w';
        b(qi).LineWidth = 0.4;
    end
    hold(ax, 'on');
    xlim(ax, [0.3, 5.7]);
    pef_figure_style.ylim_bars_from_zero(ax, 100);
    set(ax, 'XTick', x, ...
        'XTickLabel', {'Rugby 23/24', 'Rugby 24/25', 'Football 23/24', 'Football 24/25'}, ...
        'FontSize', ST.fs_tick, 'Box', 'on', 'TickLabelInterpreter', 'none', ...
        'XTickLabelRotation', 0, 'YGrid', 'on', 'XGrid', 'off');
    ylabel(ax, 'Share of KPIs  (%)', 'FontSize', ST.fs_label);
    legend(ax, b, qkeys, 'Location', 'north', 'Box', 'off', ...
        'FontSize', ST.fs_panel);
end

function sh = season_share(kpi_data, season_idx, H, qkeys)
    n_kpi = size(kpi_data, 1);
    counts = zeros(1, 4);
    n_ok = 0;
    for k = 1:n_kpi
        kp = kpi_data(k, season_idx, 1);
        rh = kpi_data(k, season_idx, 2);
        if any(isnan([kp, rh])), continue; end
        q = H.classify_quadrant(kp, rh);
        n_ok = n_ok + 1;
        qi = find(strcmp(qkeys, q), 1);
        if ~isempty(qi)
            counts(qi) = counts(qi) + 1;
        end
    end
    if n_ok == 0
        sh = zeros(1, 4);
    else
        sh = 100 * counts / n_ok;
    end
end
