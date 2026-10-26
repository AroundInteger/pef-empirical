function regenerate_figure_3_from_outputs(fpath)
%REGENERATE_FIGURE_3_FROM_OUTPUTS  Confirmatory eta vs DeltaML (no inventory).
%
%  The four KPIs in confirmatory_exemplars.csv. The vertical coordinate is the
%  mean of the five paired fold-wise accuracy changes. Full KPI cloud: SI S4--S5.

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

keep = {'sport','kpi','kappa','rho','eta','quadrant'};
if ismember('d_Y', pef.Properties.VariableNames)
    keep{end+1} = 'd_Y';
end
pef_s = pef(:, keep);
ml_all = outerjoin(ml, pef_s, 'Keys', {'sport','kpi'}, 'MergeKeys', true, ...
    'Type', 'left');

conf = readtable(fullfile(OUT, 'confirmatory_exemplars.csv'), 'TextType', 'string');
ST = pef_figure_style.config();
fig = pef_figure_style.new_figure(820, 560);
ax = axes(fig); hold(ax, 'on');
xline(ax, 1, 'k:', 'LineWidth', 1.0, 'HandleVisibility', 'off');
yline(ax, 0, 'k:', 'LineWidth', 0.8, 'HandleVisibility', 'off');

n_ok = 0;
for i = 1:height(conf)
    mask = ml_all.sport == conf.sport(i) & ml_all.kpi == conf.kpi(i) & ...
        ~isnan(ml_all.eta);
    if ~any(mask)
        warning('Figure 3: missing %s / %s', conf.sport(i), conf.kpi(i));
        continue
    end
    j = find(mask, 1);
    if ismember('dml_fold_mean', ml_all.Properties.VariableNames) && isfinite(ml_all.dml_fold_mean(j))
        ye = ml_all.dml_fold_mean(j);
    else
        ye = ml_all.acc_improvement(j);
    end
    if ~isfinite(ye)
        continue
    end
    n_ok = n_ok + 1;
    xe = ml_all.eta(j);
    if ismember('d_Y', ml_all.Properties.VariableNames) && isfinite(ml_all.d_Y(j))
        dlab = sprintf('d_Y = %.2f', ml_all.d_Y(j));
    else
        dlab = '';
    end
    q = ml_all.quadrant(j);
    plot(ax, [xe, xe], [0, ye], '-', 'Color', [0.70 0.70 0.70], ...
        'LineWidth', 1.0, 'HandleVisibility', 'off');
    scatter(ax, xe, ye, ST.ms_exemplar, ...
        pef_figure_style.quadrant_color(q), 'filled', ...
        'MarkerEdgeColor', [0.10 0.10 0.10], 'LineWidth', 0.8, ...
        'DisplayName', char(conf.quadrant_target(i)));
    pretty = char(strrep(conf.kpi(i), '_', ' '));
    text(ax, xe, ye, {pretty, dlab}, ...
        'FontSize', ST.fs_annot, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', ...
        'Interpreter', 'none', 'HandleVisibility', 'off');
end
if n_ok < 4
    error('Figure 3: expected 4 confirmatory points, found %d.', n_ok);
end

pef_figure_style.style_scatter_axes(ax, ST);
xlabel(ax, '\eta (PEF)', 'FontSize', ST.fs_label);
ylabel(ax, '\DeltaML accuracy (%)', 'FontSize', ST.fs_label);
lgd = legend(ax, 'Location', 'best', 'Box', 'off', 'FontSize', ST.fs_legend);
lgd.ItemTokenSize = [18, 10];
hold(ax, 'off');

pef_figure_style.export_figure(fig, fpath);
close(fig);
fprintf('Saved %s\n', fpath);
end
