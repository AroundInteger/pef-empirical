%% RUN_PEF_FINALIZE_DIAGNOSTICS
% Pre-submission surface diagnostics (standalone; run after pipeline + idealised sim).
%
% Prerequisites:
%   run_paper_pipeline.m  -> outputs/pef_landscape_*.csv, ml_empirical_results.csv
%   run_pef_idealised_probit_sim.m -> outputs/idealised_probit_grid.csv
%
% Outputs:
%   outputs/finalize_kpi_information.csv
%   outputs/finalize_correlations.txt
%   outputs/finalize_idealised_stratified.csv
%   outputs/finalize_iso_delta_ratio.txt
%   outputs/finalize_bootstrap_pef.csv
%   outputs/finalize_q4_bayes_gap.csv
%   outputs/finalize_season_drift.csv
%   figures/Figure_S3_Ipred_vs_dML.png
%   figures/Figure_S4_idealised_I_vs_dML_stratified.png
%   figures/Figure_S5_iso_eta_I_tension.png
%   figures/Figure_finalize_bootstrap_exemplars.png
%   figures/Figure_S6_q4_bayes_gap.png
%   figures/Figure_S7_season_drift_alignment.png
%
% Run:
%   cd scripts/paper_pipeline
%   /Applications/MATLAB_R2025b.app/bin/matlab -batch "run('run_pef_finalize_diagnostics.m')"

clear; clc; close all;
rng(20260521, 'twister');

THIS_DIR  = fileparts(mfilename('fullpath'));
SCRIPTS   = fileparts(THIS_DIR);
REPO      = fileparts(SCRIPTS);
OUT_DIR   = fullfile(THIS_DIR, 'outputs');
FIG_DIR   = fullfile(REPO, 'figures');
addpath(fullfile(SCRIPTS, 'PEF_Normality_4seasons'));
addpath(fullfile(THIS_DIR, 'lib'));

N_BOOT    = 300;
QUICK_MODE = false;   % set true for smoke test (N_BOOT=50)
if QUICK_MODE
    N_BOOT = 50;
end

for d = {OUT_DIR, FIG_DIR}
    if ~exist(d{1}, 'dir'), mkdir(d{1}); end
end

H = pef_theory_helpers();

req = {'pef_landscape_2season.csv', 'ml_empirical_results.csv', ...
       'pef_landscape_per_season.csv', 'pef_exemplars.csv', ...
       'idealised_probit_grid.csv'};
for i = 1:numel(req)
    if ~isfile(fullfile(OUT_DIR, req{i}))
        error('Missing %s. Run run_paper_pipeline.m and run_pef_idealised_probit_sim.m first.', req{i});
    end
end

pef2  = readtable(fullfile(OUT_DIR, 'pef_landscape_2season.csv'));
ml    = readtable(fullfile(OUT_DIR, 'ml_empirical_results.csv'));
pef_ps = readtable(fullfile(OUT_DIR, 'pef_landscape_per_season.csv'));
exem  = readtable(fullfile(OUT_DIR, 'pef_exemplars.csv'));
ideal = readtable(fullfile(OUT_DIR, 'idealised_probit_grid.csv'));

fprintf('=== PEF finalize diagnostics ===\n\n');

%% ---- Item 1: Per-KPI I_pred + correlations --------------------------------
kpi_tbl = build_kpi_information_table(pef2, ml, H);
writetable(kpi_tbl, fullfile(OUT_DIR, 'finalize_kpi_information.csv'));
fprintf('Wrote finalize_kpi_information.csv (%d rows)\n', height(kpi_tbl));

valid = isfinite(kpi_tbl.I_pred) & isfinite(kpi_tbl.acc_improvement);
corr_lines = write_correlation_summary(kpi_tbl, valid, fullfile(OUT_DIR, 'finalize_correlations.txt'));

fig_s3 = fullfile(FIG_DIR, 'Figure_S3_Ipred_vs_dML.png');
plot_Ipred_vs_dML(kpi_tbl, valid, fig_s3);
fprintf('Wrote %s\n', fig_s3);

median_dr = median(kpi_tbl.delta_ratio, 'omitnan');
fprintf('Median empirical delta/sigma_A = %.3f\n\n', median_dr);

%% ---- Item 2: Stratified idealised sim -------------------------------------
[strat_tbl, pooled_r] = stratify_idealised_grid(ideal);
writetable(strat_tbl, fullfile(OUT_DIR, 'finalize_idealised_stratified.csv'));
fig_s4 = fullfile(FIG_DIR, 'Figure_S4_idealised_I_vs_dML_stratified.png');
plot_idealised_stratified(ideal, fig_s4);
fprintf('Wrote finalize_idealised_stratified.csv and %s\n', fig_s4);
fprintf('Pooled corr(I, dML) = %.3f; stratified slices in CSV\n\n', pooled_r);

%% ---- Item 3: Iso-eta / iso-I overlay ------------------------------------
if ~isfinite(median_dr) || median_dr <= 0
    iso_dr = 0.5;
else
    iso_dr = median_dr;
end
write_iso_delta_sidecar(fullfile(OUT_DIR, 'finalize_iso_delta_ratio.txt'), iso_dr, median_dr);
fig_s5 = fullfile(FIG_DIR, 'Figure_S5_iso_eta_I_tension.png');
plot_iso_eta_I_tension(kpi_tbl, iso_dr, H, fig_s5);
fprintf('Wrote %s (delta/sigma_A = %.3f)\n\n', fig_s5, iso_dr);

%% ---- Items 4-5: Bootstrap + Q4 Bayes gap ----------------------------------
[boot_tbl, paired_all] = run_bootstrap_all_kpis(REPO, kpi_tbl, H, N_BOOT);
writetable(boot_tbl, fullfile(OUT_DIR, 'finalize_bootstrap_pef.csv'));
fprintf('Wrote finalize_bootstrap_pef.csv\n');

ex_top = exemplars_unique_rank1(exem);
fig_boot = fullfile(FIG_DIR, 'Figure_finalize_bootstrap_exemplars.png');
plot_bootstrap_exemplars(boot_tbl, ex_top, fig_boot);
fprintf('Wrote %s\n', fig_boot);

q4_tbl = build_q4_bayes_gap(kpi_tbl, exem);
writetable(q4_tbl, fullfile(OUT_DIR, 'finalize_q4_bayes_gap.csv'));
fig_s6 = fullfile(FIG_DIR, 'Figure_S6_q4_bayes_gap.png');
plot_q4_bayes_gap(q4_tbl, fig_s6);
fprintf('Wrote finalize_q4_bayes_gap.csv and %s\n\n', fig_s6);

%% ---- Item 6: Season drift vs grad I ---------------------------------------
drift_tbl = build_season_drift_table(pef_ps, kpi_tbl, H);
writetable(drift_tbl, fullfile(OUT_DIR, 'finalize_season_drift.csv'));
fig_s7 = fullfile(FIG_DIR, 'Figure_S7_season_drift_alignment.png');
plot_season_drift(drift_tbl, fig_s7);
fprintf('Wrote finalize_season_drift.csv and %s\n', fig_s7);
fprintf('Quadrant-crossing KPIs: %d\n', sum(drift_tbl.quadrant_crossed));

fprintf('\nFinalize diagnostics complete.\n');

% =========================================================================
function tbl = build_kpi_information_table(pef2, ml, H)
    pef2.sport = string(pef2.sport);
    pef2.kpi = string(pef2.kpi);
    pef2.quadrant = string(pef2.quadrant);
    ml.kpi = string(ml.kpi);
    if ismember('sport', ml.Properties.VariableNames)
        ml.sport = string(ml.sport);
    end
    n = height(pef2);
    cols = {'sport','kpi','n','kappa','rho','eta','quadrant', ...
            'mean_home','mean_away','var_home','delta','sigma_a','delta_ratio', ...
            'I_pred','bayes_acc','bayes_gap_pp', ...
            'acc_abs','acc_rel','acc_improvement'};
    M = cell(n, numel(cols));

    for i = 1:n
        sp = string(pef2.sport(i));
        kp = string(pef2.kpi(i));
        mi = ml_sport_kpi_match(ml, sp, kp);

        [delta, sigmaA, dr] = H.delta_sigma_from_means( ...
            pef2.mean_home(i), pef2.mean_away(i), pef2.var_home(i));
        varX = H.var_diff(pef2.kappa(i), pef2.rho(i), sigmaA);
        Ipr = H.mi_closed(pef2.kappa(i), pef2.rho(i), delta, sigmaA);
        bay = H.bayes_acc_x(delta, varX);
        if mi.found
            gap = 100 * (mi.acc_rel - bay);
            acc_a = mi.acc_abs;
            acc_r = mi.acc_rel;
            acc_i = mi.acc_improvement;
        else
            gap = NaN; acc_a = NaN; acc_r = NaN; acc_i = NaN;
        end

        M(i, :) = {sp, kp, pef2.n(i), pef2.kappa(i), pef2.rho(i), pef2.eta(i), ...
            string(pef2.quadrant(i)), pef2.mean_home(i), pef2.mean_away(i), ...
            pef2.var_home(i), delta, sigmaA, dr, Ipr, bay, gap, ...
            acc_a, acc_r, acc_i};
    end
    tbl = cell2table(M, 'VariableNames', cols);
end

% =========================================================================
function out = ml_sport_kpi_match(ml, sport, kpi)
    out = struct('found', false, 'acc_abs', NaN, 'acc_rel', NaN, 'acc_improvement', NaN);
    if ~ismember('sport', ml.Properties.VariableNames)
        ml.sport = repmat("", height(ml), 1);
    end
    m = ml.sport == sport & ml.kpi == kpi;
    if any(m)
        idx = find(m, 1);
        out.found = true;
        out.acc_abs = ml.acc_abs(idx);
        out.acc_rel = ml.acc_rel(idx);
        out.acc_improvement = ml.acc_improvement(idx);
    end
end

% =========================================================================
function lines = write_correlation_summary(tbl, valid, fpath)
    lines = {};
    lines{end+1} = '=== Finalize diagnostics: correlation summary ===';
    lines{end+1} = sprintf('Date: %s', datestr(now));
    lines{end+1} = sprintf('N valid KPIs: %d', sum(valid));
    lines{end+1} = '';

    rI = NaN; rEta = NaN; rEtaI = NaN; rDr = NaN;
    if sum(valid) >= 3
        rI   = corr(tbl.I_pred(valid), tbl.acc_improvement(valid));
        rEta = corr(tbl.eta(valid), tbl.acc_improvement(valid));
        rDr  = corr(tbl.delta_ratio(valid), tbl.acc_improvement(valid));
        rEtaI = corr(tbl.eta(valid), tbl.I_pred(valid));
        lines{end+1} = sprintf('corr(I_pred, acc_improvement)   = %.4f', rI);
        lines{end+1} = sprintf('corr(eta, acc_improvement)      = %.4f', rEta);
        lines{end+1} = sprintf('corr(eta, I_pred)               = %.4f', rEtaI);
        lines{end+1} = sprintf('corr(delta_ratio, acc_improvement) = %.4f', rDr);
        lines{end+1} = '';
        if abs(rI) > abs(rEta)
            lines{end+1} = 'I_pred correlates more strongly with ML improvement than eta (ranking only; not deterministic).';
        else
            lines{end+1} = 'Neither I_pred nor eta shows strong linear correlation with ML improvement.';
        end
    end
    lines{end+1} = '';
    lines{end+1} = sprintf('Median delta/sigma_A = %.4f', median(tbl.delta_ratio, 'omitnan'));

    fid = fopen(fpath, 'w');
    for i = 1:numel(lines)
        fprintf(fid, '%s\n', lines{i});
        fprintf('%s\n', lines{i});
    end
    fclose(fid);

    tex_path = fullfile(fileparts(fpath), 'finalize_correlations.tex');
    write_finalize_correlations_tex(tex_path, sum(valid), rI, rEta, rEtaI, rDr, ...
        median(tbl.delta_ratio, 'omitnan'));
end

% =========================================================================
function write_finalize_correlations_tex(fpath, nValid, rI, rEta, rEtaI, rDr, medianDr)
    fid = fopen(fpath, 'w');
    fprintf(fid, '%% finalize_correlations.tex — auto-generated by run_pef_finalize_diagnostics.m\n');
    fprintf(fid, '%% Do NOT edit by hand; re-run finalize diagnostics to update.\n');
    fprintf(fid, '%% Generated: %s\n\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
    if nValid >= 3 && all(isfinite([rI, rEta, rEtaI, rDr]))
        macros = {
            'PEFcorrIpredML',  rI,    3;
            'PEFcorrEtaML',     rEta,  3;
            'PEFcorrEtaIpred',  rEtaI, 3;
            'PEFmedianDeltaRatio', medianDr, 4;
            };
        for i = 1:size(macros, 1)
            name = macros{i, 1};
            val  = macros{i, 2};
            dp   = macros{i, 3};
            fprintf(fid, '\\providecommand{\\%s}{???}\n', name);
            fprintf(fid, '\\renewcommand{\\%s}{%.*f}\n', name, dp, val);
        end
    end
    fclose(fid);
    fprintf('Wrote %s\n', fpath);
end

% =========================================================================
function plot_Ipred_vs_dML(tbl, valid, fpath)
    qcol = quadrant_colours();
    fig = figure('Color', 'w', 'Position', [100 100 700 550], 'Visible', 'off');
    hold on;
    quads = ["Q1","Q2","Q3","Q4"];
    for qi = 1:numel(quads)
        qm = valid & tbl.quadrant == quads(qi);
        if ~any(qm), continue; end
        c = qcol(char(quads(qi)));
        scatter(tbl.I_pred(qm), tbl.acc_improvement(qm), 40, 'filled', ...
            'MarkerFaceColor', c, 'DisplayName', char(quads(qi)));
    end
    xlabel('I_{pred}(X;Y)  (bits, eq. mi\_closed)');
    ylabel('ML improvement  (%, A vs A-B)');
    title('Predicted information vs relativisation gain');
    legend('Location', 'best');
    grid on; box on; hold off;
    exportgraphics(fig, fpath, 'Resolution', 200);
    close(fig);
end

% =========================================================================
function [strat_tbl, pooled_r] = stratify_idealised_grid(ideal)
    dr_u = unique(ideal.delta_ratio);
    dr_u = sort(dr_u);
    rows = {};
    vall = isfinite(ideal.Ixy) & isfinite(ideal.acc_impr_pct_mean);
    if sum(vall) >= 3
        pooled_r = corr(ideal.Ixy(vall), ideal.acc_impr_pct_mean(vall));
    else
        pooled_r = NaN;
    end
    for i = 1:numel(dr_u)
        dr = dr_u(i);
        sl = abs(ideal.delta_ratio - dr) < 1e-9 & vall;
        n = sum(sl);
        if n >= 3
            r = corr(ideal.Ixy(sl), ideal.acc_impr_pct_mean(sl));
        else
            r = NaN;
        end
        rows(end+1, :) = {dr, n, r}; %#ok<AGROW>
    end
    strat_tbl = cell2table(rows, 'VariableNames', ...
        {'delta_ratio', 'n_cells', 'corr_I_dML'});
end

% =========================================================================
function plot_idealised_stratified(ideal, fpath)
    dr_u = unique(ideal.delta_ratio);
    dr_u = sort(dr_u);
    nP = numel(dr_u);
    fig = figure('Color', 'w', 'Position', [50 50  350*nP 400], 'Visible', 'off');
    qcol = quadrant_colours();
    for pi = 1:nP
        dr = dr_u(pi);
        sl = abs(ideal.delta_ratio - dr) < 1e-9;
        sub = ideal(sl, :);
        ax = subplot(1, nP, pi);
        hold(ax, 'on');
        quads = ["Q1","Q2","Q3","Q4"];
        for qi = 1:numel(quads)
            qm = sub.quadrant == quads(qi);
            if ~any(qm), continue; end
            c = qcol(char(quads(qi)));
            scatter(ax, sub.Ixy(qm), sub.acc_impr_pct_mean(qm), 36, 'filled', ...
                'MarkerFaceColor', c, 'DisplayName', char(quads(qi)));
        end
        xlabel(ax, 'I(X;Y)');
        ylabel(ax, 'Mean ML impr. (%)');
        title(ax, sprintf('\\delta/\\sigma_A = %.1f', dr));
        grid(ax, 'on');
        if pi == 1
            legend(ax, 'Location', 'best');
        end
    end
    sgtitle('Idealised probit: I vs ML gain by fixed \delta/\sigma_A');
    exportgraphics(fig, fpath, 'Resolution', 200);
    close(fig);
end

% =========================================================================
function write_iso_delta_sidecar(fpath, iso_dr, median_dr)
    fid = fopen(fpath, 'w');
    fprintf(fid, 'iso_eta_I_panel_delta_ratio = %.6f\n', iso_dr);
    fprintf(fid, 'median_empirical_delta_ratio = %.6f\n', median_dr);
    fclose(fid);
end

% =========================================================================
function plot_iso_eta_I_tension(kpi_tbl, deltaRatio, H, fpath)
    r_g = linspace(-0.95, 0.95, 300);
    k_g = linspace(0.05, 5, 300);
    [R, K] = meshgrid(r_g, k_g);
    eta_s = (1 + K) ./ (1 + K - 2 * sqrt(K) .* R);
    eta_s(eta_s <= 0 | eta_s > 20) = NaN;

    sep = normcdf(deltaRatio ./ (2 * sqrt((1 + K) ./ max(eta_s, 1e-6))));
    sep = min(max(sep, 1e-12), 1 - 1e-12);
    Ixy = 1 - (-sep .* log2(sep) - (1 - sep) .* log2(1 - sep));

    fig = figure('Color', 'w', 'Position', [100 100 900 700], 'Visible', 'off');
    imagesc(r_g, k_g, Ixy, 'AlphaData', 0.55);
    set(gca, 'YDir', 'normal');
    hold on;
    colormap(parula);
    colorbar;
    [Ce, he] = contour(R, K, eta_s, [0.5 0.75 1 1.25 1.5 2], 'Color', [0.3 0.3 0.3], 'LineWidth', 1.2);
    clabel(Ce, he, 'FontSize', 8, 'Color', [0.2 0.2 0.2]);
    [Ci, hi] = contour(R, K, Ixy, [0.02 0.05 0.1 0.15 0.2], 'w--', 'LineWidth', 0.9);
    clabel(Ci, hi, 'FontSize', 8, 'Color', 'w');
    plot([-1 1], [1 1], 'k--', 'LineWidth', 1.2, 'HandleVisibility', 'off');
    plot([0 0], [0.05 5], 'k--', 'LineWidth', 1.2, 'HandleVisibility', 'off');
    scatter(kpi_tbl.rho, kpi_tbl.kappa, 24, 'w', 'filled', 'MarkerFaceAlpha', 0.5);
    xlim([-1 1]); ylim([0.05 5]);
    xlabel('\rho'); ylabel('\kappa');
    title(sprintf('Iso-\\eta (solid) vs iso-I (dashed) at \\delta/\\sigma_A = %.2f', deltaRatio));
    hold off;
    exportgraphics(fig, fpath, 'Resolution', 200);
    close(fig);
end

% =========================================================================
function [boot_tbl, paired_all] = run_bootstrap_all_kpis(REPO, kpi_tbl, H, nBoot)
    SEASONS = ["23/24", "24/25"];
    rugby_raw = fullfile(REPO, 'Data', 'Rugby', 'Raw', '4_seasons rugby abs.csv');
    foot_dir  = fullfile(REPO, 'Data', 'Football', 'Raw', 'team_summaries_4seasons');
    foot_files = {'championship_team_23_24.csv', 'championship_team_24_25.csv'};

    paired_all = struct('rugby', table(), 'football', table());
    if isfile(rugby_raw)
        [pr, ~] = load_rugby_paired(rugby_raw);
        paired_all.rugby = pr(ismember(string(pr.season), SEASONS), :);
    end
    if isfolder(foot_dir)
        [pf, ~] = load_football_paired(foot_dir, foot_files);
        paired_all.football = pf(ismember(string(pf.season), SEASONS), :);
    end

    cols = {'sport','kpi','n','eta_lo','eta_med','eta_hi','I_lo','I_med','I_hi', ...
            'kappa_lo','kappa_med','kappa_hi','rho_lo','rho_med','rho_hi'};
    M = cell(height(kpi_tbl), numel(cols));

    for i = 1:height(kpi_tbl)
        sp = char(kpi_tbl.sport(i));
        kp = char(kpi_tbl.kpi(i));
        paired = paired_all.(sp);
        try
            b = H.bootstrap_pef_table(paired, kp, nBoot);
            M(i, :) = {string(sp), string(kp), b.n, ...
                b.eta_ci(1), b.eta_ci(2), b.eta_ci(3), ...
                b.I_ci(1), b.I_ci(2), b.I_ci(3), ...
                b.kappa_ci(1), b.kappa_ci(2), b.kappa_ci(3), ...
                b.rho_ci(1), b.rho_ci(2), b.rho_ci(3)};
        catch
            M(i, :) = {string(sp), string(kp), NaN, ...
                NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN};
        end
        if mod(i, 20) == 0
            fprintf('   Bootstrap %d / %d KPIs\n', i, height(kpi_tbl));
        end
    end
    boot_tbl = cell2table(M, 'VariableNames', cols);
end

% =========================================================================
function ex = exemplars_unique_rank1(exem)
    top = exem(exem.rank_in_group == 1, :);
    [~, ia] = unique(top.kpi, 'stable');
    ex = top(ia, :);
end

% =========================================================================
function plot_bootstrap_exemplars(boot_tbl, ex_top, fpath)
    fig = figure('Color', 'w', 'Position', [100 100 900 500], 'Visible', 'off');
    tiledlayout(2, 1);

    nexttile;
    hold on;
    for i = 1:height(ex_top)
        m = boot_tbl.sport == string(ex_top.sport(i)) & boot_tbl.kpi == string(ex_top.kpi(i));
        if ~any(m), continue; end
        row = boot_tbl(find(m, 1), :);
        errorbar(i, row.eta_med, row.eta_med - row.eta_lo, row.eta_hi - row.eta_med, 'o');
    end
    yline(1, 'k--');
    xlabel('Exemplar index');
    ylabel('\eta');
    title('Bootstrap 95% CI on \eta (exemplars)');
    grid on;

    nexttile;
    hold on;
    for i = 1:height(ex_top)
        m = boot_tbl.sport == string(ex_top.sport(i)) & boot_tbl.kpi == string(ex_top.kpi(i));
        if ~any(m), continue; end
        row = boot_tbl(find(m, 1), :);
        errorbar(i, row.I_med, row.I_med - row.I_lo, row.I_hi - row.I_med, 'o');
    end
    xlabel('Exemplar index');
    ylabel('I_{pred}  (bits)');
    title('Bootstrap 95% CI on I_{pred} (exemplars)');
    grid on;

    exportgraphics(fig, fpath, 'Resolution', 200);
    close(fig);
end

% =========================================================================
function q4 = build_q4_bayes_gap(kpi_tbl, exem)
    q4ex = exem(exem.quadrant == "Q4" & exem.rank_in_group == 1, :);
    [~, ia] = unique(q4ex.kpi, 'stable');
    q4ex = q4ex(ia, :);
    rows = {};
    for i = 1:height(q4ex)
        m = kpi_tbl.sport == string(q4ex.sport(i)) & kpi_tbl.kpi == string(q4ex.kpi(i));
        if ~any(m), continue; end
        r = kpi_tbl(find(m, 1), :);
        rows(end+1, :) = {r.sport, r.kpi, r.eta, r.I_pred, r.delta_ratio, ...
            r.acc_abs, r.acc_rel, r.acc_improvement, r.bayes_acc, r.bayes_gap_pp}; %#ok<AGROW>
    end
    q4 = cell2table(rows, 'VariableNames', ...
        {'sport','kpi','eta','I_pred','delta_ratio','acc_abs','acc_rel', ...
         'acc_improvement','bayes_acc','bayes_gap_pp'});
end

% =========================================================================
function plot_q4_bayes_gap(q4, fpath)
    if isempty(q4) || height(q4) == 0
        return
    end
    fig = figure('Color', 'w', 'Position', [100 100 900 450], 'Visible', 'off');
    labels = strcat(string(q4.sport), ': ', string(q4.kpi));
    labels = cellstr(labels);
    for i = 1:numel(labels)
        labels{i} = strrep(labels{i}, '_', ' ');
    end
    Y = [100 * q4.acc_abs, 100 * q4.acc_rel, 100 * q4.bayes_acc];
    bar(Y, 'grouped');
    set(gca, 'XTickLabel', labels, 'XTickLabelRotation', 25);
    legend({'acc A (%)', 'acc A-B (%)', 'Bayes on X (%)'}, 'Location', 'northwest');
    title('Q4 exemplars: absolute vs relative vs Bayes bound');
    ylabel('Accuracy (%)');
    grid on;
    exportgraphics(fig, fpath, 'Resolution', 200);
    close(fig);
end

% =========================================================================
function drift = build_season_drift_table(pef_ps, kpi_tbl, H)
    seasons_u = sort(unique(string(pef_ps.season)));
    if numel(seasons_u) < 2
        drift = table();
        return
    end
    s1 = seasons_u(end-1);
    s2 = seasons_u(end);

    keys = unique(strcat(string(kpi_tbl.sport), "|", string(kpi_tbl.kpi)));
    rows = {};

    for i = 1:numel(keys)
        parts = split(keys(i), "|");
        sp = parts(1);
        kp = parts(2);

        sub1 = pef_ps(pef_ps.sport == sp & pef_ps.season == s1 & pef_ps.kpi == kp, :);
        sub2 = pef_ps(pef_ps.sport == sp & pef_ps.season == s2 & pef_ps.kpi == kp, :);
        if height(sub1) ~= 1 || height(sub2) ~= 1
            continue
        end

        r1 = sub1.rho(1); k1 = sub1.kappa(1);
        r2 = sub2.rho(1); k2 = sub2.kappa(1);
        q1 = string(sub1.quadrant(1));
        q2 = string(sub2.quadrant(1));

        mk = kpi_tbl.sport == sp & kpi_tbl.kpi == kp;
        if ~any(mk), continue; end
        kr = kpi_tbl(find(mk, 1), :);
        delta = kr.delta;
        sigmaA = kr.sigma_a;

        d_rho = r2 - r1;
        d_logk = log(k2) - log(k1);
        disp_len = sqrt(d_rho^2 + d_logk^2);

        gI = H.grad_I(kr.kappa, kr.rho, delta, sigmaA);
        gnorm = norm(gI);
        if disp_len > 1e-9 && gnorm > 1e-12
            align = (d_rho * gI(1) + d_logk * gI(2)) / (disp_len * gnorm);
        else
            align = NaN;
        end

        rows(end+1, :) = {sp, kp, s1, s2, r1, k1, r2, k2, q1, q2, ...
            d_rho, d_logk, disp_len, gI(1), gI(2), gnorm, align, ...
            q1 ~= q2}; %#ok<AGROW>
    end

    drift = cell2table(rows, 'VariableNames', ...
        {'sport','kpi','season1','season2','rho1','kappa1','rho2','kappa2', ...
         'quadrant1','quadrant2','d_rho','d_logkappa','drift_length', ...
         'gradI_rho','gradI_kappa','gradI_norm','alignment','quadrant_crossed'});
end

% =========================================================================
function plot_season_drift(drift, fpath)
    if isempty(drift) || height(drift) == 0
        return
    end
    fig = figure('Color', 'w', 'Position', [100 100 700 450], 'Visible', 'off');
    hold on;
    al = drift.alignment;
    ok = isfinite(al);
    histogram(al(ok), 20, 'FaceColor', [0.3 0.5 0.75]);
    xc = drift.alignment(drift.quadrant_crossed & isfinite(drift.alignment));
    if ~isempty(xc)
        for j = 1:numel(xc)
            xline(xc(j), 'Color', [0.85 0.2 0.15], 'LineWidth', 1.5, ...
                'HandleVisibility', 'off');
        end
        plot(nan, nan, 'Color', [0.85 0.2 0.15], 'LineWidth', 2, ...
            'DisplayName', 'Quadrant-crossing KPIs');
    end
    xlabel('Alignment: season drift \cdot \nabla I / (|\Delta| |\nabla I|)');
    ylabel('Count');
    title('Season-to-season drift vs local information gradient');
    legend('Location', 'best');
    grid on;
    exportgraphics(fig, fpath, 'Resolution', 200);
    close(fig);
end

% =========================================================================
function qcol = quadrant_colours()
    qcol = containers.Map( ...
        {'Q1', 'Q2', 'Q3', 'Q4'}, ...
        {[0.20 0.63 0.17], [0.12 0.47 0.71], [0.89 0.47 0.07], [0.77 0.15 0.16]});
end
