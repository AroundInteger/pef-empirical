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
    'o', H, ST);
pef_figure_style.add_panel_letter(ax1, '(A)', ST, 'Note', 'Rugby URC');

ax2 = subplot(1, 2, 2);
pef_figure_style.draw_eta_surface(ax2, ST, true);
plot_kpi_panel(ax2, kpi_football, football_stems, ST.football, ST.migrate, ...
    's', H, ST);
pef_figure_style.add_panel_letter(ax2, '(B)', ST, 'Note', 'Football Championship');

cb = pef_figure_style.add_eta_colorbar(ax2);
cb.Label.String = 'PEF \eta';

set(fig, 'Units', 'normalized');
ax1.Position = [0.04, 0.08, 0.42, 0.84];
ax2.Position = [0.53, 0.08, 0.38, 0.84];

out_png = fullfile(cfg.fig_dir, 'Figure_2_SI.png');
pef_figure_style.export_figure(fig, out_png);
close(fig);
fprintf('Saved: %s\n', out_png);

function plot_kpi_panel(ax, kpi_data, stems, clr_cat, clr_migrate, marker, H, ST)
    axes(ax); %#ok<LAXES>
    n_kpi = size(kpi_data, 1);
    rows = [];
    for k = 1:n_kpi
        rh1 = kpi_data(k, 1, 2);  kp1 = kpi_data(k, 1, 1);
        rh2 = kpi_data(k, 2, 2);  kp2 = kpi_data(k, 2, 1);
        if any(isnan([rh1, kp1, rh2, kp2])), continue; end
        q1 = H.classify_quadrant(kp1, rh1);
        q2 = H.classify_quadrant(kp2, rh2);
        migrate = ~strcmp(q1, q2);
        move = abs(rh2 - rh1) + abs(kp2 - kp1);
        rows = [rows; k, rh1, kp1, rh2, kp2, double(migrate), move]; %#ok<AGROW>
    end
    if isempty(rows)
        return
    end
    % Migrating KPIs first, then largest year-on-year moves.
    rows = sortrows(rows, [-6, -7]);

    placed = zeros(0, 4);  % [x0 x1 y0 y1] data-space boxes
    % Keep the northwest panel letter and west legend clear of KPI names.
    placed(end+1, :) = [-0.99, -0.20, 2.45, 3.00];
    placed(end+1, :) = [-0.99, -0.42, 0.65, 1.70];
    for ri = 1:size(rows, 1)
        k = rows(ri, 1);
        rh1 = rows(ri, 2); kp1 = rows(ri, 3);
        rh2 = rows(ri, 4); kp2 = rows(ri, 5);
        migrate = rows(ri, 6) > 0.5;
        clr = clr_cat;
        if migrate, clr = clr_migrate; end

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
        [ok, dx, dy] = find_label_slot(rh2, kp2, lbl, placed);
        if ~ok
            continue
        end
        ha = dx_align(dx);
        text(rh2 + dx, kp2 + dy, lbl, 'FontSize', ST.fs_annot, 'Color', clr, ...
            'HorizontalAlignment', ha, 'VerticalAlignment', 'middle', ...
            'Interpreter', 'none', 'Clipping', 'on');
        placed(end+1, :) = label_box(rh2, kp2, dx, dy, lbl); %#ok<AGROW>
    end

    h1 = plot(nan, nan, marker, 'MarkerFaceColor', 'none', ...
        'MarkerEdgeColor', clr_cat, 'MarkerSize', 9, 'LineWidth', 1.4);
    h2 = plot(nan, nan, marker, 'MarkerFaceColor', clr_cat, ...
        'MarkerEdgeColor', 'w', 'MarkerSize', 9, 'LineWidth', 1);
    h3 = plot(nan, nan, marker, 'MarkerFaceColor', clr_migrate, ...
        'MarkerEdgeColor', 'w', 'MarkerSize', 9, 'LineWidth', 1);
    legend([h1, h2, h3], ...
        {'Season 1 (23/24)', 'Season 2 (24/25)', 'Quadrant migration'}, ...
        'Location', 'west', 'Box', 'off', 'FontSize', ST.fs_panel, ...
        'TextColor', ST.quad_text);
end

function [ok, dx, dy] = find_label_slot(x, y, lbl, placed)
    % Eight directions, two radii; skip the label if nothing is free.
    dirs = [ 1  0.6;  1 -0.6; -1  0.6; -1 -0.6; ...
             0.4  1;  0.4 -1; -0.4  1; -0.4 -1];
    radii = [0.10, 0.18, 0.28];
    ok = false; dx = 0; dy = 0;
    for r = 1:numel(radii)
        for d = 1:size(dirs, 1)
            cand_dx = dirs(d, 1) * radii(r);
            cand_dy = dirs(d, 2) * radii(r);
            box = label_box(x, y, cand_dx, cand_dy, lbl);
            if box(1) < -0.98 || box(2) > 0.98 || box(3) < 0.05 || box(4) > 2.95
                continue
            end
            hit = false;
            for p = 1:size(placed, 1)
                if boxes_overlap(box, placed(p, :))
                    hit = true;
                    break
                end
            end
            if ~hit
                ok = true; dx = cand_dx; dy = cand_dy;
                return
            end
        end
    end
end

function box = label_box(x, y, dx, dy, lbl)
    w = max(0.20, 0.034 * max(strlength(string(lbl)), 1));
    h = 0.15;
    xc = x + dx;
    yc = y + dy;
    if dx >= 0
        box = [xc, xc + w, yc - h/2, yc + h/2];
    else
        box = [xc - w, xc, yc - h/2, yc + h/2];
    end
end

function tf = boxes_overlap(a, b)
    tf = ~(a(2) < b(1) || a(1) > b(2) || a(4) < b(3) || a(3) > b(4));
end

function ha = dx_align(dx)
    if dx >= 0, ha = 'left'; else, ha = 'right'; end
end
