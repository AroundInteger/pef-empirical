%% regenerate_figure_3_from_outputs.m
% Rebuild figures/Figure_3.png from pipeline CSVs (no full pipeline re-run).
% Matches figure_3_ml_mapping in run_paper_pipeline.m.

clear; clc; close all;

THIS = fileparts(mfilename('fullpath'));
REPO = fileparts(fileparts(THIS));
OUT  = fullfile(REPO, 'scripts', 'paper_pipeline', 'outputs');
FIG  = fullfile(REPO, 'figures');
addpath(fullfile(REPO, 'scripts', 'paper_pipeline', 'lib'));

pef = readtable(fullfile(OUT, 'pef_landscape_2season.csv'));
ml  = readtable(fullfile(OUT, 'ml_empirical_results.csv'));

ml.sport = string(ml.sport);
ml.kpi   = string(ml.kpi);
pef.sport = string(pef.sport);
pef.kpi   = string(pef.kpi);

keep = {'sport','kpi','kappa','rho','eta','quadrant'};
pef_s = pef(:, keep);
ml_all = outerjoin(ml, pef_s, 'Keys', {'sport','kpi'}, 'MergeKeys', true, ...
    'Type', 'left');

ST = pef_figure_style.config();
X_LIM = [0, 5.5];
Y_LIM = [-5, 10];
quads = ["Q1","Q2","Q3","Q4"];
qcol  = [0.20 0.63 0.17; 0.12 0.47 0.71; 0.89 0.47 0.07; 0.77 0.15 0.16];
valid = ~isnan(ml_all.eta) & ~isnan(ml_all.acc_improvement);
n_clip = sum(valid & (ml_all.eta > X_LIM(2) | ...
    ml_all.acc_improvement < Y_LIM(1) | ml_all.acc_improvement > Y_LIM(2)));

fig = pef_figure_style.new_figure(950, 650);

ax1 = subplot(1,2,1); hold on;
for qi = 1:4
    qm = valid & ml_all.quadrant == quads(qi);
    if ~any(qm), continue; end
    scatter(ml_all.eta(qm), ml_all.acc_improvement(qm), 45, qcol(qi,:), ...
        'filled','MarkerEdgeColor','k','LineWidth',0.3,'MarkerFaceAlpha',0.35, ...
        'DisplayName', char(quads(qi)));
end
xline(1, 'k:', 'LineWidth',1.0, 'HandleVisibility','off');
yline(0, 'k:', 'LineWidth',0.8, 'HandleVisibility','off');

exemplar_sport = ["rugby","football","football","football"];
exemplar_kpi   = ["kick_metres","long_balls","passes","goalkeeper_long_balls"];
exemplar_label = ["Q1: kick metres","Q2: long balls","Q3: passes","Q4: gk long balls"];
exemplar_xoff  = [0.18, 0.55, 0.16, 0.85];
exemplar_yoff  = [1.15, 2.40, -2.70, -2.15];
for ei = 1:4
    emask = valid & ml_all.sport == exemplar_sport(ei) & ml_all.kpi == exemplar_kpi(ei);
    if ~any(emask), continue; end
    xe = ml_all.eta(emask); ye = ml_all.acc_improvement(emask);
    scatter(xe, ye, 160, 'k', 'o', 'LineWidth', 2.0, 'HandleVisibility','off');
    text(xe + exemplar_xoff(ei), ye + exemplar_yoff(ei), exemplar_label(ei), ...
        'FontSize', ST.fs_annot, 'FontWeight', 'bold');
end
rmask = valid & ml_all.sport == "rugby" & ml_all.kpi == "rucks_won";
if any(rmask)
    scatter(ml_all.eta(rmask), ml_all.acc_improvement(rmask), 130, ...
        [0.5 0.5 0.5], 'd', 'LineWidth', 1.5, 'HandleVisibility','off');
    text(ml_all.eta(rmask) - 0.12, ml_all.acc_improvement(rmask) + 0.35, ...
        'rucks won', 'FontSize', ST.fs_annot, 'Color', [0.35 0.35 0.35], ...
        'HorizontalAlignment', 'right');
end
xlim(X_LIM); ylim(Y_LIM);
xlabel('\eta (PEF)','FontSize',ST.fs_label);
ylabel('\DeltaML accuracy (%)','FontSize',ST.fs_label);
legend('Location','northeast','Box','off','FontSize',ST.fs_panel);
pef_figure_style.add_panel_letter(ax1, '(A)', ST);
if n_clip > 0
    text(ax1, 0.98, 0.02, sprintf('%d pt(s) outside shown range', n_clip), ...
        'Units', 'normalized', 'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'bottom', 'FontSize', ST.fs_tick, ...
        'Color', [0.45 0.45 0.45], 'HandleVisibility', 'off');
end
pef_figure_style.style_scatter_axes(ax1, ST);
grid on; hold off;

ax2 = subplot(1,2,2); hold on;
q_means = zeros(4,1); q_se = zeros(4,1); q_n = zeros(4,1);
for qi = 1:4
    vals = ml_all.acc_improvement(valid & ml_all.quadrant == quads(qi));
    q_n(qi) = numel(vals);
    q_means(qi) = mean(vals, 'omitnan');
    q_se(qi) = std(vals, 'omitnan') / sqrt(max(q_n(qi), 1));
end
bh = bar(1:4, q_means, 0.7, 'FaceColor','flat');
for qi = 1:4, bh.CData(qi,:) = qcol(qi,:); end
for qi = 1:4
    y0 = q_means(qi);
    y1 = q_means(qi) + q_se(qi);
    plot([qi, qi], [max(y0, 0), y1], 'k-', 'LineWidth', 1.2, 'HandleVisibility','off');
    plot([qi-0.08, qi+0.08], [y1, y1], 'k-', 'LineWidth', 1.2, 'HandleVisibility','off');
end
xlim(ax2, [0.4, 4.6]);
xticks(1:4); xticklabels(cellstr(quads));
xlabel('Quadrant','FontSize',ST.fs_label);
ylabel('Mean \DeltaML accuracy (%)','FontSize',ST.fs_label);
y_hi = max(q_means + q_se);
pef_figure_style.ylim_bars_from_zero(ax2, y_hi);
yl = ax2.YLim;
ymax = yl(2);
for qi = 1:4
    if q_means(qi) > 0.28 * ymax
        ty = q_means(qi) * 0.45;
        tc = [1 1 1];
    else
        ty = max(q_means(qi), 0) + q_se(qi) + 0.05 * ymax;
        tc = [0.15 0.15 0.15];
    end
    text(qi, ty, sprintf('n=%d', q_n(qi)), ...
        'HorizontalAlignment','center','FontSize',ST.fs_annot, ...
        'Color', tc, 'FontWeight','bold');
end
pef_figure_style.add_panel_letter(ax2, '(B)', ST);
pef_figure_style.style_scatter_axes(ax2, ST);
grid on; hold off;

out = fullfile(FIG, 'Figure_3.png');
pef_figure_style.export_figure(fig, out);
close(fig);
fprintf('Saved %s\n', out);
