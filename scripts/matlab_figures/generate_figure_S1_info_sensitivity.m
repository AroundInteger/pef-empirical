%% generate_figure_S1_info_sensitivity.m
%
% Supplementary Figure S1: Sensitivity of the information-content surface
% I(X;Y) to the signal-to-noise ratio delta/sigma_A.
%
% Three side-by-side panels share identical axes and colour scaling:
%   Panel A (left):   delta/sigma_A = 0.5   (weak signal)
%   Panel B (centre): delta/sigma_A = 1.0   (nominal case; same as Fig. 2)
%   Panel C (right):  delta/sigma_A = 2.0   (strong signal)
%
% KPI positions (rugby URC, football Championship) are overlaid on each
% panel using the same two-season segment representation as Figure 1
% (generate_figure_1_season_ellipses.m).
%
% Output: figures/Figure_1_SI.png   (300 dpi)
%
% Dependencies: Statistics and Machine Learning Toolbox (normcdf); PEF via
%   ../scripts/pef_calculation_script_matlab.m (pef_from_paired_vectors).
%
% Formula (from Eq. (5) in the main text):
%   eta    = (1+kappa) / (1+kappa - 2*sqrt(kappa)*rho)
%   SNR(x) = delta / (2*sigma_A * sqrt((1+kappa)/eta))
%          = delta * sqrt(eta) / (2*sigma_A * sqrt(1+kappa))
%   I(X;Y) = 1 - H(Phi(SNR))        [bits]
%   H(p)   = -p*log2(p) - (1-p)*log2(1-p)

clear; close all; clc;

script_dir = fileparts(mfilename('fullpath'));
cfg = si_figure_config();
addpath(cfg.normality_dir);

rugby_raw_file = cfg.rugby_raw;
fig_dir        = cfg.fig_dir;

% -------------------------------------------------------------------------
%% 1.  Parameter grid
% -------------------------------------------------------------------------

rho_vec   = linspace(-0.999, 0.999, 800);
kappa_vec = linspace(0.01,   4.0,   800);
[R, K]    = meshgrid(rho_vec, kappa_vec);

ETA = (1 + K) ./ (1 + K - 2.*sqrt(K).*R);
% Clip extreme values to avoid numerical issues
ETA = max(min(ETA, 1e4), -1e4);

SNR_denominator = sqrt((1 + K) ./ max(ETA, 1e-8));   % sigma_A * this = noise

delta_sigma_A_values = [0.5, 1.0, 2.0];
panel_labels = {'(A)  \delta/\sigma_A = 0.5', ...
                '(B)  \delta/\sigma_A = 1.0', ...
                '(C)  \delta/\sigma_A = 2.0'};

% -------------------------------------------------------------------------
%% 2.  Load sports KPI data (two seasons each)
% -------------------------------------------------------------------------

RUGBY_SEASONS    = cfg.rugby_seasons;
FOOTBALL_SEASONS = cfg.football_seasons;

if ~exist(rugby_raw_file, 'file')
    error('Rugby raw data not found: %s', rugby_raw_file);
end
[rugby_paired, rugby_kpis] = load_rugby_paired(rugby_raw_file);
mask_r = ismember(string(rugby_paired.season), string(RUGBY_SEASONS));
rugby_paired = rugby_paired(mask_r, :);
[kpi_rugby, rugby_kpis] = si_compute_kpi_season_data( ...
    rugby_paired, rugby_kpis, RUGBY_SEASONS, "rugby");

foot_dir = cfg.foot_dir;
if ~exist(foot_dir, 'dir')
    warning('Football data directory not found: %s', foot_dir);
    kpi_football = nan(1, 2, 3);
else
    [foot_paired, foot_kpis] = load_football_paired(foot_dir, cfg.foot_2s);
    mask_f = ismember(string(foot_paired.season), string(FOOTBALL_SEASONS));
    foot_paired = foot_paired(mask_f, :);
    [kpi_football, ~] = si_compute_kpi_season_data( ...
        foot_paired, foot_kpis, FOOTBALL_SEASONS, "football");
end

% -------------------------------------------------------------------------
%% 3.  Draw figure
% -------------------------------------------------------------------------

fig = figure('Position', [50, 50, 1800, 600], 'Color', 'white');

clr_rugby    = [0   119 187]/255;
clr_football = [230 159   0]/255;

% Common colour limits: I(X;Y) in [0,1] bits; fix scale so panels compare.
clim_vals = [0, 1];

ax_handles = zeros(1, 3);
img_handles = zeros(1, 3);

for p = 1:3
    dsa = delta_sigma_A_values(p);

    % Information content surface
    SNR  = dsa .* sqrt(max(ETA, 0)) ./ (2 .* sqrt(1 + K));
    % Clamp SNR to avoid normcdf saturation issues
    SNR  = min(max(SNR, -8), 8);
    p_win = normcdf(SNR);
    MI   = 1 - binary_entropy(p_win);   % bits; MI in [0,1]
    MI   = max(MI, 0);                  % guard against floating-point negatives

    ax = subplot(1, 3, p);
    ax_handles(p) = ax;

    h = imagesc(rho_vec, kappa_vec, MI);
    img_handles(p) = h;
    set(ax, 'YDir', 'normal');
    hold on;

    % Quadrant boundaries
    plot([0 0],  [0.01 4], 'k-', 'LineWidth', 2.5, 'HandleVisibility', 'off');
    plot([-1 1], [1 1],    'k-', 'LineWidth', 2.5, 'HandleVisibility', 'off');

    % Quadrant labels
    text( 0.38, 3.6, 'Q1', 'FontSize', 13, 'Color', [1 1 1], 'FontWeight', 'bold');
    text( 0.38, 0.4, 'Q2', 'FontSize', 13, 'Color', [1 1 1], 'FontWeight', 'bold');
    text(-0.55, 0.4, 'Q3', 'FontSize', 13, 'Color', [1 1 1], 'FontWeight', 'bold');
    text(-0.55, 3.6, 'Q4', 'FontSize', 13, 'Color', [1 1 1], 'FontWeight', 'bold');

    % KPI positions (rugby)
    overlay_kpi_segments(ax, kpi_rugby,    clr_rugby,    'o');
    overlay_kpi_segments(ax, kpi_football, clr_football, 's');

    % Contour lines at 0.1-bit intervals
    contour(rho_vec, kappa_vec, MI, 0:0.1:1, 'w:', 'LineWidth', 0.7);

    colormap(ax, hot(256));
    clim(clim_vals);
    xlim([-1 1]);  ylim([0.01 4]);
    xticks(-1:0.5:1);   xticklabels(compose('%.1f', -1:0.5:1));
    yticks(0:0.5:4);    yticklabels(compose('%.1f', 0:0.5:4));
    xlabel('Correlation Coefficient (\rho)', 'FontSize', 12);
    if p == 1
        ylabel('Variance Ratio (\kappa)', 'FontSize', 12);
    end
    title(panel_labels{p}, 'FontSize', 13, 'FontWeight', 'bold');
    set(ax, 'FontSize', 11);
    grid off;
end

% Shared colourbar on the right of panel C
cb = colorbar(ax_handles(3));
cb.Label.String   = 'I(X;Y)  [bits]';
cb.Label.FontSize = 12;
cb.Ticks          = 0:0.1:1;
cb.TickLabels     = compose('%.1f', 0:0.1:1);

% Legend (single dummy legend beneath panel B)
ax_handles(2);
axes(ax_handles(2));
h_r = plot(nan, nan, 'o', 'MarkerFaceColor', clr_rugby,    'MarkerEdgeColor', 'w', 'MarkerSize', 8);
h_f = plot(nan, nan, 's', 'MarkerFaceColor', clr_football, 'MarkerEdgeColor', 'w', 'MarkerSize', 8);
legend([h_r h_f], {'Rugby URC (mean \pm season range)', ...
                   'Football Championship (mean \pm season range)'}, ...
       'Location', 'southoutside', 'Orientation', 'horizontal', ...
       'Box', 'off', 'FontSize', 10);

% Save
out_png = fullfile(fig_dir, 'Figure_1_SI.png');
exportgraphics(fig, out_png, 'Resolution', 300);
fprintf('Saved: %s\n', out_png);

% =========================================================================
%% Local functions
% =========================================================================

function h = binary_entropy(p)
%BINARY_ENTROPY  Binary entropy H(p) = -p*log2(p) - (1-p)*log2(1-p).
%   Handles p == 0 and p == 1 gracefully (H = 0 at boundaries).
    eps_guard = 1e-12;
    p  = max(min(p, 1 - eps_guard), eps_guard);
    h  = -p .* log2(p) - (1 - p) .* log2(1 - p);
end

function overlay_kpi_segments(ax, kpi_data, clr, marker)
%OVERLAY_KPI_SEGMENTS  Draw two-season segments + mean marker for each KPI.
%   kpi_data(k, season, [kappa rho eta])
    n_kpi = size(kpi_data, 1);
    axes(ax); %#ok<LAXES>
    for k = 1:n_kpi
        rh1 = kpi_data(k, 1, 2);  kp1 = kpi_data(k, 1, 1);
        rh2 = kpi_data(k, 2, 2);  kp2 = kpi_data(k, 2, 1);
        if any(isnan([rh1 kp1 rh2 kp2])), continue; end
        % Connector segment
        plot([rh1 rh2], [kp1 kp2], '-', 'Color', [clr 0.50], ...
             'LineWidth', 1.2, 'HandleVisibility', 'off');
        % Season endpoints
        plot([rh1 rh2], [kp1 kp2], 'x', 'Color', clr, ...
             'MarkerSize', 6, 'LineWidth', 1.1, 'HandleVisibility', 'off');
        % Two-season mean marker
        plot(mean([rh1 rh2]), mean([kp1 kp2]), marker, ...
             'MarkerFaceColor', clr, 'MarkerEdgeColor', 'w', ...
             'MarkerSize', 8, 'LineWidth', 0.8, 'HandleVisibility', 'off');
    end
end

