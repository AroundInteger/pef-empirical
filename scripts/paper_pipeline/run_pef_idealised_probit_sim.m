%% RUN_PEF_IDEALISED_PROBIT_SIM
% Idealised probit simulation aligned to PEF theory (assumptions A1--A2).
%
% Generates bivariate-normal (X_A, X_B) on a (kappa, rho, delta/sigma_A)
% grid, labels outcomes via the probit link P(Y=1|X) = Phi(X/sqrt(Var(X))),
% and compares paper-aligned ML: X_A only vs X_A - X_B (5-fold logistic CV).
%
% Outputs (scripts/paper_pipeline/outputs/):
%   idealised_probit_grid.csv
%   idealised_probit_scenarios.csv
%   idealised_probit_summary.txt
%   idealised_probit_*.png  (five diagnostic figures)
%
% Run:
%   cd scripts/paper_pipeline
%   /Applications/MATLAB_R2025b.app/bin/matlab -batch "run('run_pef_idealised_probit_sim.m')"
%
% Set SMOKE_TEST = true for a one-minute sanity check (1 cell, 2 trials).
% Set USE_PARFOR = true to parallelise over grid cells (requires Parallel Computing Toolbox).

clear; clc; close all;
RNG_BASE = 20260520;
rng(RNG_BASE, 'twister');

THIS_DIR = fileparts(mfilename('fullpath'));
OUT_DIR  = fullfile(THIS_DIR, 'outputs');
if ~exist(OUT_DIR, 'dir')
    mkdir(OUT_DIR);
end
addpath(fullfile(THIS_DIR, 'lib'));

H = pef_theory_helpers();

% ---- Runtime flags ------------------------------------------------------
SMOKE_TEST   = false;   % true: 1 admissible cell, n=500, 2 trials
USE_PARFOR   = true;    % parfor over grid/scenario cells
PARPOOL_SIZE = [];      % [] = default local workers; or e.g. 6

% ---- PRODUCTION_CONFIG (paper-locked; do not change without re-run) -----
% Idealised probit simulation under (A1)--(A2).  Matches empirical ML:
% 5-fold logistic CV in run_paper_pipeline.m and methodology.tex.
% Grid: 4 kappa x 4 rho x 4 delta/sigma_A = 64 admissible cells.
% delta/sigma_A = 0.3 is nearest grid point to median empirical KPI
% delta/sigma_A (~0.28 from finalize diagnostics).  No delta = 0 slice
% (null signal; stratified corr undefined).
PRODUCTION_CONFIG = struct( ...
    'SIGMA_A',     1.0, ...
    'N_PER_CELL',  5000, ...
    'N_TRIALS',    50, ...
    'K_FOLD',      5, ...
    'KAPPA_GRID',  [0.8, 1.0, 1.2, 2.0], ...
    'RHO_GRID',    [-0.3, -0.15, 0, 0.4], ...
    'DELTA_RATIO', [0.3, 0.5, 1.0, 2.0]);

SIGMA_A     = PRODUCTION_CONFIG.SIGMA_A;
N_PER_CELL  = PRODUCTION_CONFIG.N_PER_CELL;
N_TRIALS    = PRODUCTION_CONFIG.N_TRIALS;
K_FOLD      = PRODUCTION_CONFIG.K_FOLD;
KAPPA_GRID  = PRODUCTION_CONFIG.KAPPA_GRID;
RHO_GRID    = PRODUCTION_CONFIG.RHO_GRID;
DELTA_RATIO = PRODUCTION_CONFIG.DELTA_RATIO;

if SMOKE_TEST
    N_PER_CELL  = 500;
    N_TRIALS    = 2;
    KAPPA_GRID  = 2.0;
    RHO_GRID    = -0.3;
    DELTA_RATIO = 1.0;
    USE_PARFOR  = true;
end

NAMED_SCENARIOS = table( ...
    ["High competitive dynamics"; ...
     "Moderate competitive dynamics"; ...
     "Environmental dynamics"; ...
     "Balanced (Fisher baseline)"], ...
    [2.0; 1.2; 1.1; 1.0], ...
    [-0.3; -0.15; 0.4; 0.0], ...
    [1.0; 1.0; 1.0; 1.0], ...
    'VariableNames', {'scenario', 'kappa', 'rho', 'delta_ratio'});

fprintf('=== Idealised probit simulation (A1--A2) ===\n');
if SMOKE_TEST
    fprintf('*** SMOKE_TEST mode ***\n');
end
fprintf('n=%d, trials=%d, k-fold=%d, parfor=%d\n\n', ...
    N_PER_CELL, N_TRIALS, K_FOLD, USE_PARFOR);

if USE_PARFOR
    if isempty(gcp('nocreate'))
        if isempty(PARPOOL_SIZE)
            pool = parpool('local');
        else
            pool = parpool('local', PARPOOL_SIZE);
        end
        fprintf('Started parpool with %d workers.\n\n', pool.NumWorkers);
    else
        pool = gcp('nocreate');
        fprintf('Using existing parpool (%d workers).\n\n', pool.NumWorkers);
    end
end

log_lines = {};
log_lines{end+1} = '=== Idealised probit simulation summary ===';
log_lines{end+1} = sprintf('Date: %s', datestr(now));
log_lines{end+1} = sprintf('PRODUCTION_CONFIG: n=%d trials=%d k-fold=%d', ...
    N_PER_CELL, N_TRIALS, K_FOLD);
log_lines{end+1} = sprintf('kappa grid: %s', mat2str(KAPPA_GRID));
log_lines{end+1} = sprintf('delta/sigma_A grid: %s', mat2str(DELTA_RATIO));
if USE_PARFOR && ~isempty(gcp('nocreate'))
    log_lines{end+1} = sprintf('parpool workers: %d', gcp('nocreate').NumWorkers);
end
log_lines{end+1} = '';

% ---- Build full factorial grid ------------------------------------------
grid_rows = [];
for ik = 1:numel(KAPPA_GRID)
    for ir = 1:numel(RHO_GRID)
        for id = 1:numel(DELTA_RATIO)
            kappa = KAPPA_GRID(ik);
            rho   = RHO_GRID(ir);
            dr    = DELTA_RATIO(id);
            if ~H.is_admissible(kappa, rho)
                continue
            end
            grid_rows(end+1, :) = [kappa, rho, dr]; %#ok<AGROW>
        end
    end
end
n_cells = size(grid_rows, 1);
fprintf('Admissible grid cells: %d\n', n_cells);

grid_tbl = run_simulation_block(H, grid_rows, SIGMA_A, N_PER_CELL, N_TRIALS, K_FOLD, ...
    repmat("", n_cells, 1), USE_PARFOR, RNG_BASE);

% ---- Named paper scenarios ----------------------------------------------
scenario_rows = [NAMED_SCENARIOS.kappa, NAMED_SCENARIOS.rho, NAMED_SCENARIOS.delta_ratio];
scenario_tbl  = run_simulation_block(H, scenario_rows, SIGMA_A, N_PER_CELL, N_TRIALS, K_FOLD, ...
    NAMED_SCENARIOS.scenario, USE_PARFOR, RNG_BASE);

% Progress for named scenarios (parfor cannot fprintf per cell reliably)
for r = 1:height(scenario_tbl)
    fprintf('Scenario %-30s eta=%.3f I=%.4f impr=%+.1f%% +/- %.1f%%\n', ...
        scenario_tbl.scenario(r), scenario_tbl.eta(r), scenario_tbl.Ixy(r), ...
        scenario_tbl.acc_impr_pct_mean(r), scenario_tbl.acc_impr_pct_std(r));
end

% ---- Write CSV outputs --------------------------------------------------
writetable(grid_tbl, fullfile(OUT_DIR, 'idealised_probit_grid.csv'));
writetable(scenario_tbl, fullfile(OUT_DIR, 'idealised_probit_scenarios.csv'));
fprintf('\nWrote %s\n', fullfile(OUT_DIR, 'idealised_probit_grid.csv'));
fprintf('Wrote %s\n', fullfile(OUT_DIR, 'idealised_probit_scenarios.csv'));

% ---- Console / summary correlations ------------------------------------
valid = ~isnan(grid_tbl.Ixy) & ~isnan(grid_tbl.acc_impr_pct_mean);
if sum(valid) >= 3
    r_I  = corr(grid_tbl.Ixy(valid), grid_tbl.acc_impr_pct_mean(valid));
    r_eta = corr(grid_tbl.eta(valid), grid_tbl.acc_impr_pct_mean(valid));
else
    r_I = NaN;
    r_eta = NaN;
end

q4 = grid_tbl.quadrant == "Q4";
n_q4_pos = sum(q4 & grid_tbl.eta < 1 & grid_tbl.acc_impr_pct_mean > 0);
n_q4_all = sum(q4);

fprintf('\n--- Summary correlations (full grid) ---\n');
fprintf('corr(I(X;Y), mean %% ML improvement) = %.3f\n', r_I);
fprintf('corr(eta, mean %% ML improvement)     = %.3f\n', r_eta);
fprintf('Q4 cells with eta<1 and mean impr>0: %d / %d\n', n_q4_pos, n_q4_all);

log_lines{end+1} = '--- Correlations (full grid) ---';
log_lines{end+1} = sprintf('corr(I(X;Y), mean ML improvement) = %.4f', r_I);
log_lines{end+1} = sprintf('corr(eta, mean ML improvement)     = %.4f', r_eta);
log_lines{end+1} = sprintf('Q4 cells eta<1 and mean impr>0: %d / %d', n_q4_pos, n_q4_all);
log_lines{end+1} = '';

log_lines{end+1} = '--- Stratified corr(I, ML) by delta/sigma_A ---';
dr_u = unique(grid_tbl.delta_ratio);
dr_u = sort(dr_u);
for ii = 1:numel(dr_u)
    dr = dr_u(ii);
    sl = abs(grid_tbl.delta_ratio - dr) < 1e-9 & valid;
    if sum(sl) >= 3
        r_sl = corr(grid_tbl.Ixy(sl), grid_tbl.acc_impr_pct_mean(sl));
    else
        r_sl = NaN;
    end
    log_lines{end+1} = sprintf('  delta/sigma_A=%.1f  n=%d  corr=%.4f', dr, sum(sl), r_sl);
    fprintf('  Stratified delta/sigma_A=%.1f: corr(I, ML)=%.3f (n=%d)\n', dr, r_sl, sum(sl));
end
log_lines{end+1} = '';

log_lines{end+1} = '--- Named scenarios ---';
for r = 1:height(scenario_tbl)
    log_lines{end+1} = sprintf('%s: eta=%.3f I=%.4f bayes=%.3f impr=%.1f+/-%.1f%%', ...
        scenario_tbl.scenario(r), scenario_tbl.eta(r), scenario_tbl.Ixy(r), ...
        scenario_tbl.bayes_acc(r), scenario_tbl.acc_impr_pct_mean(r), ...
        scenario_tbl.acc_impr_pct_std(r));
end

write_summary(fullfile(OUT_DIR, 'idealised_probit_summary.txt'), log_lines);

% ---- Figures ------------------------------------------------------------
fprintf('\nGenerating figures...\n');
make_idealised_figures(grid_tbl, scenario_tbl, OUT_DIR);
fprintf('\nSimulation complete.\n');

% =========================================================================
function tbl = run_simulation_block(H, param_rows, sigmaA, nPerCell, nTrials, kFold, ...
        scenario_names, use_parfor, rng_base)
    if nargin < 9 || isempty(rng_base)
        rng_base = 20260520;
    end
    n = size(param_rows, 1);
    cols = {'scenario','kappa','rho','delta_ratio','delta','sigma_a', ...
            'eta','var_x','Ixy','bayes_acc','quadrant', ...
            'kappa_hat_mean','rho_hat_mean','eta_hat_mean', ...
            'acc_A_mean','acc_A_std','acc_R_mean','acc_R_std', ...
            'acc_AB_mean','acc_AB_std', ...
            'acc_impr_pct_mean','acc_impr_pct_std'};
    M = cell(n, numel(cols));

    if use_parfor && n > 1
        parfor i = 1:n
            M(i, :) = simulate_one_cell(H, param_rows(i, :), sigmaA, nPerCell, ...
                nTrials, kFold, scenario_names(i), i, rng_base);
        end
    else
        for i = 1:n
            M(i, :) = simulate_one_cell(H, param_rows(i, :), sigmaA, nPerCell, ...
                nTrials, kFold, scenario_names(i), i, rng_base);
            if mod(i, max(1, floor(n / 8))) == 0 || i == n
                fprintf('  Completed %d / %d cells\n', i, n);
            end
        end
    end

    tbl = cell2table(M, 'VariableNames', cols);
end

% =========================================================================
function row = simulate_one_cell(H, params, sigmaA, nPerCell, nTrials, kFold, ...
        scen_in, cell_idx, rng_base)
    kappa = params(1);
    rho   = params(2);
    dr    = params(3);
    delta = dr * sigmaA;

    eta_v  = H.eta_pef(kappa, rho);
    varX   = H.var_diff(kappa, rho, sigmaA);
    Ixy    = H.mi_closed(kappa, rho, delta, sigmaA);
    bayes  = H.bayes_acc_x(delta, varX);
    quad   = H.classify_quadrant(kappa, rho);

    acc_A_t   = nan(nTrials, 1);
    acc_R_t   = nan(nTrials, 1);
    acc_AB_t  = nan(nTrials, 1);
    impr_t    = nan(nTrials, 1);
    kappa_h   = nan(nTrials, 1);
    rho_h     = nan(nTrials, 1);
    eta_h     = nan(nTrials, 1);

    for t = 1:nTrials
        rng(rng_base + cell_idx * 10000 + t, 'twister');
        [A, B] = H.sample_bvn_ab(kappa, rho, delta, sigmaA, nPerCell);
        X = A - B;
        Y = H.sample_y_a2(X, varX);

        acc_A_t(t)  = H.cv_logistic_sim(A, Y, kFold);
        acc_R_t(t)  = H.cv_logistic_sim(X, Y, kFold);
        acc_AB_t(t) = H.cv_logistic_sim([A, B], Y, kFold);
        impr_t(t)   = 100 * (acc_R_t(t) - acc_A_t(t)) / max(acc_A_t(t), 0.01);

        vA = var(A, 0);
        vB = var(B, 0);
        if vA > 0
            kappa_h(t) = vB / vA;
            rmat = corrcoef(A, B);
            rho_h(t) = rmat(1, 2);
            eta_h(t) = H.eta_pef(kappa_h(t), rho_h(t));
        end
    end

    if strlength(scen_in) > 0
        scen = scen_in;
    else
        scen = "";
    end

    row = {scen, kappa, rho, dr, delta, sigmaA, ...
        eta_v, varX, Ixy, bayes, quad, ...
        mean(kappa_h, 'omitnan'), mean(rho_h, 'omitnan'), mean(eta_h, 'omitnan'), ...
        mean(acc_A_t), std(acc_A_t), mean(acc_R_t), std(acc_R_t), ...
        mean(acc_AB_t), std(acc_AB_t), ...
        mean(impr_t), std(impr_t)};
end

% =========================================================================
function write_summary(fpath, lines)
    fid = fopen(fpath, 'w');
    if fid < 0
        warning('Could not write summary file: %s', fpath);
        return
    end
    for i = 1:numel(lines)
        fprintf(fid, '%s\n', lines{i});
    end
    fclose(fid);
    fprintf('Wrote %s\n', fpath);
end

% =========================================================================
function make_idealised_figures(grid_tbl, scenario_tbl, outDir)
    qcol = containers.Map( ...
        {'Q1', 'Q2', 'Q3', 'Q4', 'boundary'}, ...
        {[0.20 0.63 0.17], [0.12 0.47 0.71], [0.89 0.47 0.07], ...
         [0.77 0.15 0.16], [0.5 0.5 0.5]});

    valid = ~isnan(grid_tbl.Ixy) & ~isnan(grid_tbl.acc_impr_pct_mean);

    % 1. I(X;Y) vs mean ML improvement
    fig1 = figure('Color', 'w', 'Position', [100 100 700 550], 'Visible', 'off');
    hold on;
    quads = ["Q1", "Q2", "Q3", "Q4"];
    for qi = 1:numel(quads)
        qm = valid & grid_tbl.quadrant == quads(qi);
        if ~any(qm), continue; end
        c = qcol(char(quads(qi)));
        scatter(grid_tbl.Ixy(qm), grid_tbl.acc_impr_pct_mean(qm), 36, ...
            'filled', 'MarkerFaceColor', c, 'DisplayName', char(quads(qi)));
    end
    xlabel('I(X;Y)  (bits, analytic)');
    ylabel('Mean ML improvement  (%, A vs A-B)');
    title('Information content vs relativisation gain');
    legend('Location', 'best');
    grid on; box on; hold off;
    exportgraphics(fig1, fullfile(outDir, 'idealised_probit_I_vs_dML.png'), 'Resolution', 200);
    close(fig1);

    % 2. eta vs mean ML improvement
    fig2 = figure('Color', 'w', 'Position', [100 100 700 550], 'Visible', 'off');
    hold on;
    for qi = 1:numel(quads)
        qm = valid & grid_tbl.quadrant == quads(qi);
        if ~any(qm), continue; end
        c = qcol(char(quads(qi)));
        scatter(grid_tbl.eta(qm), grid_tbl.acc_impr_pct_mean(qm), 36, ...
            'filled', 'MarkerFaceColor', c, 'DisplayName', char(quads(qi)));
    end
    xline(1, 'k--', 'LineWidth', 1);
    xlabel('\eta  (PEF)');
    ylabel('Mean ML improvement  (%, A vs A-B)');
    title('\eta vs ML improvement (efficiency--power tension)');
    legend('Location', 'best');
    grid on; box on; hold off;
    exportgraphics(fig2, fullfile(outDir, 'idealised_probit_eta_vs_dML.png'), 'Resolution', 200);
    close(fig2);

    % 3. Heatmap at delta/sigma_A = 1
    slice = abs(grid_tbl.delta_ratio - 1.0) < 1e-9;
    if any(slice)
        kappa_u = unique(grid_tbl.kappa(slice));
        rho_u   = unique(grid_tbl.rho(slice));
        kappa_u = sort(kappa_u);
        rho_u   = sort(rho_u);
        Z = nan(numel(kappa_u), numel(rho_u));
        for ik = 1:numel(kappa_u)
            for ir = 1:numel(rho_u)
                ix = slice & grid_tbl.kappa == kappa_u(ik) & grid_tbl.rho == rho_u(ir);
                if any(ix)
                    Z(ik, ir) = grid_tbl.acc_impr_pct_mean(find(ix, 1));
                end
            end
        end
        fig3 = figure('Color', 'w', 'Position', [100 100 750 550], 'Visible', 'off');
        imagesc(rho_u, kappa_u, Z);
        set(gca, 'YDir', 'normal');
        colorbar;
        xlabel('\rho');
        ylabel('\kappa');
        title('Mean ML improvement at \delta/\sigma_A = 1');
        set(gca, 'FontSize', 11);
        exportgraphics(fig3, fullfile(outDir, 'idealised_probit_heatmap_dML.png'), 'Resolution', 200);
        close(fig3);
    end

    % 4. Parameter recovery: target eta vs hat eta
    fig4 = figure('Color', 'w', 'Position', [100 100 650 550], 'Visible', 'off');
    hold on;
    scatter(grid_tbl.eta, grid_tbl.eta_hat_mean, 40, 'filled', ...
        'MarkerFaceColor', [0.2 0.45 0.7]);
    lims = [min([grid_tbl.eta; grid_tbl.eta_hat_mean], [], 'omitnan'), ...
            max([grid_tbl.eta; grid_tbl.eta_hat_mean], [], 'omitnan')];
    if all(isfinite(lims))
        plot(lims, lims, 'k--', 'LineWidth', 1);
    end
    xlabel('Target \eta', 'Interpreter', 'tex');
    ylabel('Mean recovered eta (sample)', 'Interpreter', 'none');
    title('PEF parameter recovery');
    grid on; box on; hold off;
    exportgraphics(fig4, fullfile(outDir, 'idealised_probit_recovery.png'), 'Resolution', 200);
    close(fig4);

    % 5. Named scenarios bar chart
    fig5 = figure('Color', 'w', 'Position', [100 100 900 500], 'Visible', 'off');
    nS = height(scenario_tbl);
    x = 1:nS;
    bar_data = [scenario_tbl.eta, scenario_tbl.Ixy, scenario_tbl.acc_impr_pct_mean / 100];
    bar(x, bar_data, 'grouped');
    set(gca, 'XTick', x, 'XTickLabel', scenario_tbl.scenario, 'XTickLabelRotation', 15);
    legend({'\eta', 'I(X;Y)  (bits)', 'ML impr.  (fraction)'}, 'Location', 'northwest');
    title('Named scenarios: efficiency, information, ML gain');
    grid on; box on;
    exportgraphics(fig5, fullfile(outDir, 'idealised_probit_scenarios_bar.png'), 'Resolution', 200);
    close(fig5);

    fprintf('Figures written to %s/idealised_probit_*.png\n', outDir);
end
