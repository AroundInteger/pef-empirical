%% generate_figure_S3_info_sensitivity.m
%
% Supplementary Figure S3: Sensitivity of I(X;Y) to delta/sigma_A.
% Three panels at delta/sigma_A = 0.5, 1.0, 2.0 (centre matches main Fig. 2).
%
% Theory panels only: controlled I(X;Y) surfaces with optional idealised
% factorial (kappa, rho) design points. Empirical KPI overlays live in the
% landscape SI figures (S4--S5), not on this pedagogical surface.
%
% Output: figures/Figure_S3_info_sensitivity.png  (300 dpi, pef_figure_style)

close all; clc;

script_dir = fileparts(mfilename('fullpath'));
cfg = si_figure_config();
addpath(cfg.normality_dir);
addpath(fullfile(fileparts(script_dir), 'paper_pipeline', 'lib'));

ST = pef_figure_style.config();
fig_dir = cfg.fig_dir;
delta_sigma_A_values = [0.5, 1.0, 2.0];
panel_letters = {'(A)', '(B)', '(C)'};

% Idealised probit factorial design points (controlled coordinates), if available.
ideal_csv = fullfile(fileparts(script_dir), 'paper_pipeline', 'outputs', ...
    'idealised_probit_grid.csv');
grid_pts = [];
if isfile(ideal_csv)
    ideal = readtable(ideal_csv);
    if all(ismember({'rho','kappa'}, ideal.Properties.VariableNames))
        grid_pts = unique([ideal.rho, ideal.kappa], 'rows');
    end
end

fig = pef_figure_style.new_figure(1800, 620);
ax_handles = gobjects(1, 3);

for p = 1:3
    ax = subplot(1, 3, p);
    ax_handles(p) = ax;
    pef_figure_style.draw_I_surface(ax, delta_sigma_A_values(p), 1.0, ST, ...
        ST.I_panel_caxis, true);
    if ~isempty(grid_pts)
        hold(ax, 'on');
        scatter(ax, grid_pts(:, 1), grid_pts(:, 2), 28, [0.92, 0.92, 0.92], 'o', ...
            'MarkerEdgeColor', [0.15, 0.15, 0.15], 'LineWidth', 0.6, ...
            'MarkerFaceAlpha', 0.85, 'HandleVisibility', 'off');
    end
    pef_figure_style.add_panel_letter(ax, panel_letters{p}, ST, ...
        'Note', sprintf('\\delta/\\sigma_A = %.1f', delta_sigma_A_values(p)));
    if p > 1
        ylabel(ax, '');
    end
end

colormap(ax_handles(3), parula(256));
cb = colorbar(ax_handles(3));
cb.Label.String = 'I(X;Y)  [bits]';
cb.Label.FontSize = ST.fs_label;
cb.FontSize = ST.fs_tick;
I_ticks = 0:0.2:1;
cb.Ticks = I_ticks;
cb.TickLabels = pef_figure_style.decimal_labels(I_ticks, 1);

out_png = fullfile(fig_dir, 'Figure_S3_info_sensitivity.png');
pef_figure_style.export_figure(fig, out_png);
close(fig);
fprintf('Saved: %s (theory surfaces + idealised design points only)\n', out_png);
