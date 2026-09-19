function regenerate_figure_3_from_outputs(fpath)
%REGENERATE_FIGURE_3_FROM_OUTPUTS  Confirmatory eta vs DeltaML (no inventory).
%
%  Four quadrant exemplars at comparable delta/sigma_A, plus rucks won as a
%  high-eta, low-signal foil. The x-axis is broken so the foil stays on scale.
%  Full KPI cloud lives in SI (S4, S5). Called from run_paper_pipeline.m.

if nargin < 1 || isempty(fpath)
    THIS = fileparts(mfilename('fullpath'));
    REPO = fileparts(fileparts(THIS));
    fpath = fullfile(REPO, 'figures', 'Figure_3.png');
end

THIS = fileparts(mfilename('fullpath'));
REPO = fileparts(fileparts(THIS));
OUT  = fullfile(REPO, 'scripts', 'paper_pipeline', 'outputs');
addpath(fullfile(REPO, 'scripts', 'paper_pipeline', 'lib'));

pef = readtable(fullfile(OUT, 'pef_landscape_2season.csv'));
ml  = readtable(fullfile(OUT, 'ml_empirical_results.csv'));
pef.sport = string(pef.sport);
pef.kpi   = string(pef.kpi);
ml.sport  = string(ml.sport);
ml.kpi    = string(ml.kpi);

keep = {'sport','kpi','kappa','rho','eta','quadrant','mean_home','mean_away','var_home'};
pef_s = pef(:, keep);
ml_all = outerjoin(ml, pef_s, 'Keys', {'sport','kpi'}, 'MergeKeys', true, ...
    'Type', 'left');
ml_all.delta_ratio = abs(ml_all.mean_home - ml_all.mean_away) ./ sqrt(ml_all.var_home);

ST = pef_figure_style.config();

% Broken x-axis: left pane shows the four exemplars; right pane the foil.
X_LEFT   = 3.40;
X_GAP    = 0.16;
X_RIGHT0 = 5.05;
X_RIGHT1 = 5.75;
Y_LIM    = [-3.5, 7.1];

rows = [ ...
    "rugby",    "kick_metres",            "Q1: kick metres",   "exemplar"; ...
    "football", "long_balls",             "Q2: long balls",    "exemplar"; ...
    "football", "passes",                 "Q3: passes",        "exemplar"; ...
    "football", "goalkeeper_long_balls",  "Q4: gk long balls", "exemplar"; ...
    "rugby",    "rucks_won",              "rucks won",         "foil" ...
    ];
xoff = [ 0.18,  0.22,  0.00,  0.22,  0.10];
yoff = [ 0.55,  0.45, -1.20,  0.35,  0.70];
halign = {'left','left','center','left','left'};

fig = pef_figure_style.new_figure(820, 560);
ax = axes(fig); hold(ax, 'on');

xline(ax, map_eta(1), 'k:', 'LineWidth', 1.0, 'HandleVisibility', 'off');
yline(ax, 0, 'k:', 'LineWidth', 0.8, 'HandleVisibility', 'off');

n_ok = 0;
for i = 1:size(rows, 1)
    mask = ml_all.sport == rows(i, 1) & ml_all.kpi == rows(i, 2) & ...
        ~isnan(ml_all.eta) & ~isnan(ml_all.acc_improvement);
    if ~any(mask)
        warning('Figure 3: missing %s / %s', rows(i, 1), rows(i, 2));
        continue
    end
    n_ok = n_ok + 1;
    xe = map_eta(ml_all.eta(mask));
    ye = ml_all.acc_improvement(mask);
    dr = ml_all.delta_ratio(mask);
    q  = ml_all.quadrant(mask);
    is_foil = rows(i, 4) == "foil";

    plot(ax, [xe, xe], [0, ye], '-', 'Color', [0.70 0.70 0.70], ...
        'LineWidth', 1.0, 'HandleVisibility', 'off');

    if is_foil
        scatter(ax, xe, ye, ST.ms_exemplar, [0.45 0.45 0.45], 'd', ...
            'LineWidth', 1.8, 'HandleVisibility', 'off');
        lbl = {char(rows(i, 3)), sprintf('\\delta/\\sigma_A = %.2f', dr)};
        col = [0.35 0.35 0.35];
    else
        scatter(ax, xe, ye, ST.ms_exemplar, ...
            pef_figure_style.quadrant_color(q), 'filled', ...
            'MarkerEdgeColor', [0.10 0.10 0.10], 'LineWidth', 0.8, ...
            'DisplayName', char(q));
        lbl = {char(rows(i, 3)), sprintf('\\delta/\\sigma_A = %.2f', dr)};
        col = [0.10 0.10 0.10];
    end
    text(ax, xe + xoff(i), ye + yoff(i), lbl, ...
        'FontSize', ST.fs_annot, 'FontWeight', 'bold', 'Color', col, ...
        'HorizontalAlignment', halign{i}, 'VerticalAlignment', 'middle', ...
        'Interpreter', 'tex', 'HandleVisibility', 'off');
end
if n_ok < 5
    error('Figure 3: expected 5 confirmatory points, found %d.', n_ok);
end

text(ax, 2.55, 6.72, 'relativisation helps', ...
    'FontSize', ST.fs_annot, 'Color', [0.40 0.40 0.40], ...
    'HorizontalAlignment', 'center', 'HandleVisibility', 'off');
text(ax, 2.05, -2.70, 'relativisation hurts', ...
    'FontSize', ST.fs_annot, 'Color', [0.40 0.40 0.40], ...
    'HorizontalAlignment', 'center', 'HandleVisibility', 'off');

xlim(ax, [0, map_eta(X_RIGHT1)]);
ylim(ax, Y_LIM);
eta_ticks = [0, 1, 2, 3, 5.2, 5.6];
xticks(ax, map_eta(eta_ticks));
yticks(ax, -3:1:7);
pef_figure_style.style_scatter_axes(ax, ST);
xlabel(ax, '\eta (PEF)', 'FontSize', ST.fs_label);
ylabel(ax, '\DeltaML accuracy (%)', 'FontSize', ST.fs_label);
ax.XTickLabel = pef_figure_style.decimal_labels(eta_ticks, 1);
ax.YTickLabel = pef_figure_style.decimal_labels(ax.YTick, 1);
lgd = legend(ax, 'Location', 'northwest', 'Box', 'off', 'FontSize', ST.fs_legend);
lgd.ItemTokenSize = [18, 10];
draw_x_break(ax, X_LEFT, X_LEFT + X_GAP);
hold(ax, 'off');

pef_figure_style.export_figure(fig, fpath);
close(fig);
fprintf('Saved %s\n', fpath);

    function xp = map_eta(eta)
        eta = double(eta);
        xp = eta;
        right = eta > X_LEFT;
        xp(right) = X_LEFT + X_GAP + (eta(right) - X_RIGHT0);
    end
end

function draw_x_break(ax, xL, xR)
    yl = ylim(ax);
    yw = 0.04 * (yl(2) - yl(1));
    xw = 0.045;
    plot(ax, [xL, xR], [yl(1), yl(1)], 'w-', 'LineWidth', 2.5, ...
        'Clipping', 'off', 'HandleVisibility', 'off');
    plot(ax, [xL, xR], [yl(2), yl(2)], 'w-', 'LineWidth', 2.5, ...
        'Clipping', 'off', 'HandleVisibility', 'off');
    slash = { ...
        [xL - xw, xL + xw], [yl(1) - yw, yl(1) + yw]; ...
        [xR - xw, xR + xw], [yl(1) - yw, yl(1) + yw]; ...
        [xL - xw, xL + xw], [yl(2) - yw, yl(2) + yw]; ...
        [xR - xw, xR + xw], [yl(2) - yw, yl(2) + yw]};
    for si = 1:size(slash, 1)
        plot(ax, slash{si, 1}, slash{si, 2}, 'k-', 'LineWidth', 1.0, ...
            'Clipping', 'off', 'HandleVisibility', 'off');
    end
end
