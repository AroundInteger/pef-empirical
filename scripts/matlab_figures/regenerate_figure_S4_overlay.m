%% regenerate_figure_S4_overlay.m
% Idealised grid in PEF coordinates:
%   (A) locator of the 16 (rho, tau) design points, tau = (1/2) log kappa
%   (B) I vs DeltaML (log x): colour = delta/sigma_A; marker = sign of rho;
%       grey trajectories join the same (kappa, rho) across the four signals.
%   (C) master surface: DeltaML vs relative-feature signal d_rel, colour = r,
%       with the two bounding curves (floor r->1, ceiling r->0).
% Boundary cells (kappa=1 or rho=0) are included.
%
% Canonical coordinates (sigma_A = 1, probit-regression model):
%   d_rel = delta / sqrt(Var X)          standardised mean of the relative feature
%   r     = corr(A, X) = (1 - rho*sqrt(kappa)) / sqrt(Var X)
% acc_R depends on d_rel alone; DeltaML = F(d_rel, r) to R^2 ~ 0.99 and equals the
% Bayes-optimal gain.  Envelopes: DeltaML = 0 as r->1 (relative feature is Bayes-
% sufficient); DeltaML = 100*(g(d_rel)/Phi(d_rel/sqrt2) - 1) as r->0 (absolute
% feature reduced to the majority-class baseline).
%
% Output: figures/Figure_S4b_idealised_I_vs_dML_overlay.png
% Safe to run() from finalize diagnostics (does not clear the workspace).

THIS = fileparts(mfilename('fullpath'));
if isempty(THIS)
    THIS = pwd;
end
REPO = fileparts(fileparts(THIS));
OUT  = fullfile(REPO, 'scripts', 'paper_pipeline', 'outputs');
FIG  = fullfile(REPO, 'figures');
addpath(fullfile(REPO, 'scripts', 'paper_pipeline', 'lib'));

ideal = readtable(fullfile(OUT, 'idealised_probit_grid.csv'));
ST = pef_figure_style.config();

ideal.tau = 0.5 * log(ideal.kappa);
dr_u = sort(unique(ideal.delta_ratio));
cmap = [ ...
    0.20, 0.63, 0.17; ...  % 0.3
    0.12, 0.47, 0.71; ...  % 0.5
    0.89, 0.47, 0.07; ...  % 1.0
    0.77, 0.15, 0.16];     % 2.0

Y_LIM = [0, 30];
fig = pef_figure_style.new_figure(1720, 540);
tl = tiledlayout(fig, 1, 3, 'Padding', 'compact', 'TileSpacing', 'compact');

% ---- (A) Locator on (rho, tau) ------------------------------------------
axA = nexttile(tl);
hold(axA, 'on');
xline(axA, 0, 'k--', 'LineWidth', 1.2, 'HandleVisibility', 'off');
yline(axA, 0, 'k--', 'LineWidth', 1.2, 'HandleVisibility', 'off');

pts = unique(ideal(:, {'kappa','rho'}), 'rows');
pts.tau = 0.5 * log(pts.kappa);
for i = 1:height(pts)
    [mk, msz] = rho_marker(pts.rho(i));
    scatter(axA, pts.rho(i), pts.tau(i), msz, [0.25, 0.25, 0.25], ...
        'filled', 'Marker', mk, 'MarkerEdgeColor', 'k', 'LineWidth', 0.4);
end
text(axA, 0.42, 0.30, 'Q1', 'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.35, 0.35, 0.35]);
text(axA, 0.42, -0.21, 'Q2', 'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.35, 0.35, 0.35]);
text(axA, -0.78, -0.21, 'Q3', 'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.35, 0.35, 0.35]);
text(axA, -0.78, 0.30, 'Q4', 'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.35, 0.35, 0.35]);
xlim(axA, [-0.85, 0.65]);
ylim(axA, [-0.25, 0.42]);
xlabel(axA, '\rho', 'FontSize', ST.fs_label, 'Interpreter', 'tex');
ylabel(axA, '\tau = (1/2) log \kappa', 'FontSize', ST.fs_label, 'Interpreter', 'tex');
title(axA, '(A)  Design points in canonical PEF coordinates', ...
    'FontSize', ST.fs_title, 'FontWeight', 'bold', 'Interpreter', 'tex');
pef_figure_style.style_scatter_axes(axA, ST);
text(axA, 0.04, 0.58, {'○  \rho>0 (shared)', '□  \rho=0 (Fisher)', '▽  \rho<0 (competitive)'}, ...
    'Units', 'normalized', 'FontSize', 8.5, 'Color', [0.25, 0.25, 0.25], ...
    'Interpreter', 'tex', 'VerticalAlignment', 'top');

% ---- (B) Outcome space: trajectories in I vs DeltaML --------------------
axB = nexttile(tl);
hold(axB, 'on');

keys = unique(ideal(:, {'kappa','rho'}), 'rows');
for i = 1:height(keys)
    m = abs(ideal.kappa - keys.kappa(i)) < 1e-9 & abs(ideal.rho - keys.rho(i)) < 1e-9;
    sub = sortrows(ideal(m, :), 'delta_ratio');
    plot(axB, max(sub.Ixy, 1e-4), sub.acc_impr_pct_mean, '-', ...
        'Color', [0.62, 0.62, 0.62], 'LineWidth', 0.9, ...
        'HandleVisibility', 'off');
end

leg_h = gobjects(numel(dr_u), 1);
leg_s = strings(numel(dr_u), 1);
for di = 1:numel(dr_u)
    dr = dr_u(di);
    sub = ideal(abs(ideal.delta_ratio - dr) < 1e-9, :);
    xI = max(sub.Ixy, 1e-4);
    for i = 1:height(sub)
        [mk, msz] = rho_marker(sub.rho(i));
        scatter(axB, xI(i), sub.acc_impr_pct_mean(i), msz, cmap(di, :), ...
            'filled', 'Marker', mk, 'MarkerEdgeColor', 'k', 'LineWidth', 0.35, ...
            'HandleVisibility', 'off');
    end
    leg_h(di) = plot(axB, NaN, NaN, 'o', 'MarkerFaceColor', cmap(di, :), ...
        'MarkerEdgeColor', 'k', 'MarkerSize', 7);
    leg_s(di) = sprintf('\\delta/\\sigma_A = %.1f', dr);
end

set(axB, 'XScale', 'log');
ylim(axB, Y_LIM);
xlabel(axB, 'I(X;Y)  [bits]', 'FontSize', ST.fs_label);
ylabel(axB, 'Mean \DeltaML  (%)', 'FontSize', ST.fs_label);
title(axB, '(B)  Same (\kappa,\rho) across signal (log x)', ...
    'FontSize', ST.fs_title, 'FontWeight', 'bold', 'Interpreter', 'tex');
legend(axB, leg_h, cellstr(leg_s), 'Location', 'northeast', 'Box', 'off', ...
    'FontSize', ST.fs_panel, 'Interpreter', 'tex');
pef_figure_style.style_scatter_axes(axB, ST);
set(axB, 'XScale', 'log');
ylim(axB, Y_LIM);
grid(axB, 'on');

% ---- (C) Master surface: DeltaML vs d_rel, bounded by r = corr(A,X) -----
% In the probit-regression model, acc_R depends on d_rel alone and DeltaML is a
% near-exact function of (d_rel, r).  The two bounding curves are:
%   floor   (r -> 1): DeltaML = 0   (relative feature is Bayes-sufficient)
%   ceiling (r -> 0): DeltaML = 100*(g(d_rel)/Phi(d_rel/sqrt2) - 1)
%                     (absolute feature reduced to the majority-class baseline)
axC = nexttile(tl);
hold(axC, 'on');

% Per-point canonical coordinates.
ideal.varX  = 1 + ideal.kappa - 2 .* sqrt(ideal.kappa) .* ideal.rho;
ideal.d_rel = ideal.delta_ratio ./ sqrt(ideal.varX);
ideal.r_ax  = (1 - ideal.rho .* sqrt(ideal.kappa)) ./ sqrt(ideal.varX);

% Deterministic Gaussian quadrature for E_{w~N(0,1)}[.].
wq  = linspace(-9, 9, 4001);
pwq = exp(-wq.^2 / 2); pwq = pwq / sum(pwq);
accR_fun = @(d) sum(pwq .* normcdf(abs(d + wq)));
accA_fun = @(d, r) sum(pwq .* normcdf(abs((d + r .* wq) ./ sqrt(2 - r.^2))));
dml_fun  = @(d, r) 100 * (accR_fun(d) - accA_fun(d, r)) ./ accA_fun(d, r);

dd  = linspace(min(ideal.d_rel), max(ideal.d_rel), 200);
r_min = min(ideal.r_ax);
y_ceil = arrayfun(@(d) 100 * (accR_fun(d) / normcdf(d / sqrt(2)) - 1), dd);  % r -> 0
y_edge = arrayfun(@(d) dml_fun(d, r_min), dd);                              % grid iso-r_min

% Bounding curves (draw before points).
yline(axC, 0, '-', 'Color', [0.30, 0.30, 0.30], 'LineWidth', 1.4, 'HandleVisibility', 'off');
h_ceil = plot(axC, dd, y_ceil, '--', 'Color', [0.20, 0.20, 0.20], 'LineWidth', 1.6);
h_edge = plot(axC, dd, y_edge, '-',  'Color', [0.55, 0.55, 0.55], 'LineWidth', 1.4);

% Points coloured by r = corr(A,X), marker encodes sign(rho) (consistent with A/B).
for i = 1:height(ideal)
    [mk, msz] = rho_marker(ideal.rho(i));
    scatter(axC, ideal.d_rel(i), ideal.acc_impr_pct_mean(i), msz, ...
        ideal.r_ax(i), 'filled', 'Marker', mk, ...
        'MarkerEdgeColor', 'k', 'LineWidth', 0.35, 'HandleVisibility', 'off');
end
colormap(axC, parula(256));
clim(axC, [min(ideal.r_ax), max(ideal.r_ax)]);
cb = colorbar(axC);
cb.Label.String = 'r = corr(A, X)';
cb.Label.Interpreter = 'tex';
cb.Label.FontSize = ST.fs_label;

xlabel(axC, 'Relative-feature signal  d_{rel} = \delta / \surd Var(X)', ...
    'FontSize', ST.fs_label, 'Interpreter', 'tex');
ylabel(axC, 'Mean \DeltaML  (%)', 'FontSize', ST.fs_label, 'Interpreter', 'tex');
title(axC, '(C)  Master surface bounded by r', ...
    'FontSize', ST.fs_title, 'FontWeight', 'bold', 'Interpreter', 'tex');
ylim(axC, Y_LIM);
pef_figure_style.style_scatter_axes(axC, ST);
grid(axC, 'on');
legend(axC, [h_ceil, h_edge], ...
    {'ceiling: r\rightarrow0 (majority baseline)', sprintf('grid edge: r = %.2f', r_min)}, ...
    'Location', 'northeast', 'Box', 'off', 'FontSize', ST.fs_panel, 'Interpreter', 'tex');
text(axC, 0.96, 0.60, {'floor: \DeltaML = 0', '(r\rightarrow1, Bayes-sufficient)'}, ...
    'Units', 'normalized', 'HorizontalAlignment', 'right', ...
    'FontSize', ST.fs_panel, 'Interpreter', 'tex', 'Color', [0.25, 0.25, 0.25]);

out = fullfile(FIG, 'Figure_S4b_idealised_I_vs_dML_overlay.png');
pef_figure_style.export_figure(fig, out);
close(fig);
fprintf('Saved %s\n', out);

function [mk, msz] = rho_marker(rho)
    if rho > 1e-9
        mk = 'o'; msz = 58;
    elseif rho < -1e-9
        mk = 'v'; msz = 58;
    else
        mk = 's'; msz = 50;
    end
end
