%RUN_PAPER_PIPELINE
%
%  Single entry-point script that generates every figure, table number, and
%  supplementary output needed for the PEF framework paper.
%
%  Data sources
%  ------------
%  Primary sports  (23/24 + 24/25):
%    Data/Rugby/Raw/4_seasons rugby abs.csv      (filtered to last 2 seasons)
%    Data/Football/Raw/team_summaries_4seasons/
%      championship_team_23_24.csv
%      championship_team_24_25.csv
%  SI normality (all 4 seasons):
%    Same rugby/football raw files, all seasons pooled
%  Non-sports (pre-computed by paper_data_and_analysis/python/ bundle):
%    paper_data_and_analysis/outputs/real_biology_pef_results.csv
%    paper_data_and_analysis/outputs/real_finance_pef_results.csv
%    paper_data_and_analysis/outputs/manufacturing_pef_results.csv
%    paper_data_and_analysis/outputs/tcga_brca_gene_pef.csv
%
%  Outputs
%  -------
%  figures/Figure_1.png  -- PEF landscape with KPI segments (23/24->24/25)
%                           + non-sports domain triangles + exemplar labels
%  figures/Figure_2.png  -- I(X;Y) information surface (theoretical)
%  figures/Figure_3.png  -- PEF-to-ML surface + empirical scatter overlay
%  figures/Figure_3b.png -- psi-stratified residual diagnostic (companion-paper
%                           bridge; two-panel: eta-scale + psi-scale)
%  outputs/normality_primary_2season.csv   -- normality at 2-season scope
%  outputs/normality_si_4season.csv        -- normality at 4-season scope (SI)
%  outputs/normality_commentary.csv        -- key % stats for paper text
%  outputs/ml_empirical_results.csv        -- per-KPI acc/AUC improvement
%  outputs/domain_summary.csv             -- non-sports domain summaries
%  outputs/pef_landscape_2season.csv
%  outputs/pef_landscape_per_season.csv
%  outputs/pef_landscape_4season.csv
%  outputs/pef_exemplars.csv              -- curated exemplar KPIs per quadrant+role
%  outputs/kappa_symmetry_audit.csv       -- per-KPI kappa<->1/kappa audit
%  outputs/psi_per_domain.csv             -- psi-scale meta-analysis table
%  outputs/psi_ml_residuals.csv           -- per-KPI ML residuals & psi
%  outputs/table_numbers.csv              -- all computed numbers for LaTeX
%  outputs/numbers.tex                    -- \newcommand macros for LaTeX \input{}
%  outputs/normality_summary_SI.png
%
%  Dependencies (resolved via addpath below)
%  ------------------------------------------
%    PEF_Normality_4seasons/: load_rugby_paired, load_football_paired,
%      compute_pef, normality_windows, swtest, plot_normality_summary,
%      curate_exemplars
%
%  MATLAB R2019b+ required (local functions in script, exportgraphics).
%  Run time: ~3-8 min depending on Lilliefors MCTol and ML fold count.

clear; clc; close all;
rng(20260511, 'twister');    % reproducible seed for CV folds + MC tests

% -----------------------------------------------------------------------
% 0. Paths
% -----------------------------------------------------------------------
THIS_DIR  = fileparts(mfilename('fullpath'));
SCRIPTS   = fileparts(THIS_DIR);                        % scripts/
REPO      = fileparts(SCRIPTS);                         % overleaf_pef_article/
addpath(fullfile(SCRIPTS, 'PEF_Normality_4seasons'));    % load_*_paired, compute_pef, normality_windows, swtest
addpath(THIS_DIR);                                         % figure_1_landscape.m
addpath(fullfile(THIS_DIR, 'lib'));                      % pef_theory_helpers (eta_pef, classify_quadrant, ...)

RUGBY_RAW   = fullfile(REPO, 'Data', 'Rugby', 'Raw', '4_seasons rugby abs.csv');
FOOT_DIR    = fullfile(REPO, 'Data', 'Football', 'Raw', 'team_summaries_4seasons');
FOOT_2S     = {'championship_team_23_24.csv', 'championship_team_24_25.csv'};
FOOT_4S     = {'championship_team_21_22.csv','championship_team_22_23.csv', ...
               'championship_team_23_24.csv','championship_team_24_25.csv'};
NS_DIR      = fullfile(REPO, 'paper_data_and_analysis', 'outputs');
OUT_DIR     = fullfile(THIS_DIR, 'outputs');
FIG_DIR     = fullfile(REPO, 'figures');
for d = {OUT_DIR, FIG_DIR}
    if ~exist(d{1}, 'dir'), mkdir(d{1}); end
end

ALPHA       = 0.05;
N_CV_FOLDS  = 5;
LILL_MCTOL  = 1e-2;       % Lilliefors MC tolerance (1e-3 = stricter but slower)
SEASONS_PRI = ["23/24","24/25"];   % primary paper seasons

fprintf('==========================================================\n');
fprintf(' PEF paper pipeline  (primary: 23/24 + 24/25)\n');
fprintf(' Outputs -> %s\n', OUT_DIR);
fprintf('==========================================================\n');

% -----------------------------------------------------------------------
% [1/9]  Load raw rugby data  (all 4 seasons; filter for primary)
% -----------------------------------------------------------------------
fprintf('\n[1/9] Loading raw rugby data...\n');
[rugby_all, rugby_kpis] = load_rugby_paired(RUGBY_RAW);
rugby_outcomes = attach_rugby_outcomes(RUGBY_RAW);   % matchid -> home_win

% Merge outcome onto paired table
rugby_all = outerjoin(rugby_all, rugby_outcomes, 'Keys','matchid', ...
    'MergeKeys',true,'Type','left');

% Primary 2-season subset
mask2r = ismember(string(rugby_all.season), SEASONS_PRI);
rugby_2s = rugby_all(mask2r, :);

fprintf('   4-season: %d matches  |  2-season (primary): %d matches  |  %d KPIs\n', ...
    height(rugby_all), height(rugby_2s), numel(rugby_kpis));

% -----------------------------------------------------------------------
% [2/9]  Load raw football data
% -----------------------------------------------------------------------
fprintf('\n[2/9] Loading raw football data...\n');
[foot_2s, foot_kpis]   = load_football_paired(FOOT_DIR, FOOT_2S);
[foot_all, ~]          = load_football_paired(FOOT_DIR, FOOT_4S);
% load_football_paired now embeds home_win directly; fall back to the
% attach_football_outcomes outerjoin only if the column is absent.
if ~ismember('home_win', foot_2s.Properties.VariableNames)
    foot_outcomes_2s = attach_football_outcomes(FOOT_DIR, FOOT_2S);
    foot_2s  = outerjoin(foot_2s, foot_outcomes_2s, 'Keys','match_id','MergeKeys',true,'Type','left');
end
if ~ismember('home_win', foot_all.Properties.VariableNames)
    foot_outcomes_4s = attach_football_outcomes(FOOT_DIR, FOOT_4S);
    foot_all = outerjoin(foot_all, foot_outcomes_4s, 'Keys','match_id','MergeKeys',true,'Type','left');
end

fprintf('   4-season: %d matches  |  2-season (primary): %d matches  |  %d KPIs\n', ...
    height(foot_all), height(foot_2s), numel(foot_kpis));

% -----------------------------------------------------------------------
% [3/9]  PEF landscape
% -----------------------------------------------------------------------
fprintf('\n[3/9] Computing PEF landscape...\n');

pef_rugby_2s = compute_pef(rugby_2s, rugby_kpis, "rugby");
pef_foot_2s  = compute_pef(foot_2s,  foot_kpis,  "football");
pef_2s       = [pef_rugby_2s; pef_foot_2s];

% Per-season (for Figure 1 KPI segments)
pef_per_season = table();
for sport_cell = {{'rugby', rugby_2s, rugby_kpis}, {'football', foot_2s, foot_kpis}}
    si = sport_cell{1};
    for s = unique(string(si{2}.season))'
        sub = si{2}(si{2}.season == s, :);
        pp  = compute_pef(sub, si{3}, si{1});
        pp.season = repmat(s, height(pp), 1);
        pef_per_season = [pef_per_season; pp]; %#ok<AGROW>
    end
end

% 4-season pooled (supplementary)
pef_rugby_4s = compute_pef(rugby_all, rugby_kpis, "rugby");
pef_foot_4s  = compute_pef(foot_all,  foot_kpis,  "football");
pef_4s       = [pef_rugby_4s; pef_foot_4s];

writetable(pef_2s,         fullfile(OUT_DIR, 'pef_landscape_2season.csv'));
writetable(pef_per_season, fullfile(OUT_DIR, 'pef_landscape_per_season.csv'));
writetable(pef_4s,         fullfile(OUT_DIR, 'pef_landscape_4season.csv'));
fprintf('   Rugby 2s : mean eta=%.3f  (n=%d KPIs)\n', mean(pef_rugby_2s.eta,'omitnan'), height(pef_rugby_2s));
fprintf('   Football 2s: mean eta=%.3f  (n=%d KPIs)\n', mean(pef_foot_2s.eta,'omitnan'), height(pef_foot_2s));

% -----------------------------------------------------------------------
% [3b/9] Exemplar KPI curation
% -----------------------------------------------------------------------
fprintf('\n[3b/9] Curating exemplar KPIs (per quadrant + role)...\n');

role_map = containers.Map();
role_map('rugby') = struct( ...
    'attacking',  {{'carries','metres_made','defenders_beaten','clean_breaks', ...
                    'offloads','passes','kicks_from_hand','kick_metres', ...
                    'rucks_won','scrums_won','lineout_throws_won','final_points'}}, ...
    'defensive',  {{'tackles','missed_tackles','turnovers_won', ...
                    'turnovers_conceded','lineout_throws_lost'}}, ...
    'discipline', {{'penalties_conceded','scrum_pens_conceded', ...
                    'lineout_pens_conceded','general_play_pens_conceded', ...
                    'free_kicks_conceded','ruck_maul_tackle_pen_con'}});

role_map('football') = struct( ...
    'attacking',  {{'goals','np_goals','xg','np_xg','shots','shots_on_target', ...
                    'big_chances','corners','passes','successful_passes', ...
                    'deep_completions','carries','progressive_carries', ...
                    'deep_progressions','box_entries','obv','on_ball_obv'}}, ...
    'defensive',  {{'tackles','successful_tackles','ball_recoveries', ...
                    'regains','blocks','pressures','counterpressures', ...
                    'defensive_obv'}}, ...
    'discipline', {{'yellow_cards','red_cards','fouls'}});

pef_exemplars = curate_exemplars(pef_2s, role_map, 3);
writetable(pef_exemplars, fullfile(OUT_DIR, 'pef_exemplars.csv'));
fprintf('   Exemplars curated: %d rows (rugby+football, quadrant+role).\n', height(pef_exemplars));

% -----------------------------------------------------------------------
% [4/9]  Normality analysis
% -----------------------------------------------------------------------
fprintf('\n[4/9] Normality analysis...\n');

% Primary: windows built on 23/24 + 24/25 data
win_r2 = build_windows(unique(string(rugby_2s.season)));
win_f2 = build_windows(unique(string(foot_2s.season)));
norm_rugby_2s = normality_windows(rugby_2s, rugby_kpis, 'season', win_r2, "rugby",    ALPHA, LILL_MCTOL);
norm_foot_2s  = normality_windows(foot_2s,  foot_kpis,  'season', win_f2, "football", ALPHA, LILL_MCTOL);
norm_primary  = [norm_rugby_2s; norm_foot_2s];
writetable(norm_primary, fullfile(OUT_DIR, 'normality_primary_2season.csv'));

% SI: all 4 seasons to show sample-size sensitivity
win_r4 = build_windows(unique(string(rugby_all.season)));
win_f4 = build_windows(unique(string(foot_all.season)));
norm_rugby_4s = normality_windows(rugby_all, rugby_kpis, 'season', win_r4, "rugby",    ALPHA, LILL_MCTOL);
norm_foot_4s  = normality_windows(foot_all,  foot_kpis,  'season', win_f4, "football", ALPHA, LILL_MCTOL);
norm_si       = [norm_rugby_4s; norm_foot_4s];
writetable(norm_si, fullfile(OUT_DIR, 'normality_si_4season.csv'));

% Commentary statistics
norm_commentary = compute_normality_commentary(norm_primary, norm_si);
writetable(norm_commentary, fullfile(OUT_DIR, 'normality_commentary.csv'));
print_normality_commentary(norm_commentary);

% -----------------------------------------------------------------------
% [5/9]  Non-sports domain summaries (pre-computed)
% -----------------------------------------------------------------------
fprintf('\n[5/9] Loading non-sports domain summaries...\n');
domain_summary = load_nonsports(NS_DIR);
writetable(domain_summary, fullfile(OUT_DIR, 'domain_summary.csv'));
for r = 1:height(domain_summary)
    fprintf('   %-20s  mean_eta=%.3f  success=%.1f%%\n', ...
        domain_summary.domain{r}, domain_summary.mean_eta(r), domain_summary.success_pct(r));
end

% -----------------------------------------------------------------------
% [6/9]  ML validation
% -----------------------------------------------------------------------
fprintf('\n[6/9] ML validation...\n');

fprintf('   Empirical: rugby 5-fold CV...\n');
ml_rugby = ml_empirical(rugby_2s, rugby_kpis, 'home_win', N_CV_FOLDS);
ml_rugby.sport = repmat("rugby", height(ml_rugby), 1);

fprintf('   Empirical: football 5-fold CV...\n');
ml_foot  = ml_empirical(foot_2s,  foot_kpis,  'home_win', N_CV_FOLDS);
ml_foot.sport = repmat("football", height(ml_foot), 1);

ml_all = [ml_rugby; ml_foot];
writetable(ml_all, fullfile(OUT_DIR, 'ml_empirical_results.csv'));
fprintf('   Rugby    mean acc impr: %+.1f%%\n', mean(ml_rugby.acc_improvement, 'omitnan'));
fprintf('   Football mean acc impr: %+.1f%%\n', mean(ml_foot.acc_improvement,  'omitnan'));

% Merge PEF params into ML table for Figure 3
ml_all = join_pef_to_ml(ml_all, pef_2s);

% Synthetic ML surface (for Figure 3 background)
ml_surface = build_ml_surface();

% -----------------------------------------------------------------------
% [7/9]  Geometry diagnostics + kappa <-> 1/kappa symmetry audit
% -----------------------------------------------------------------------
fprintf('\n[7/9] Geometry diagnostics + kappa<->1/kappa audit...\n');

pef_2s_geom = geometry_diagnostics(pef_2s);
writetable(pef_2s_geom, fullfile(OUT_DIR, 'pef_landscape_2season_geometry.csv'));

audit = kappa_involution_audit( ...
    'rugby_paired',    rugby_2s, ...
    'rugby_kpis',      rugby_kpis, ...
    'football_paired', foot_2s, ...
    'football_kpis',   foot_kpis, ...
    'nonsports_dir',   NS_DIR, ...
    'n_boot',          200);
writetable(audit.level2,                fullfile(OUT_DIR, 'kappa_symmetry_audit.csv'));
writetable(audit.nonsports_consistency, fullfile(OUT_DIR, 'kappa_symmetry_nonsports.csv'));
fprintf('%s\n', audit.summary);

% -----------------------------------------------------------------------
% [8/9]  psi-scale cross-domain pooling
% -----------------------------------------------------------------------
fprintf('\n[8/9] psi-scale cross-domain pooling...\n');

pool = psi_scale_pooling( ...
    'pef_sports',    pef_2s, ...
    'nonsports_dir', NS_DIR, ...
    'n_boot',        2000);
writetable(pool.per_domain,    fullfile(OUT_DIR, 'psi_per_domain.csv'));
writetable(pool.heterogeneity, fullfile(OUT_DIR, 'psi_heterogeneity.csv'));

fprintf('   psi-scale CV (cross-domain)  : %.4f\n', pool.heterogeneity.cv_psi);
fprintf('   eta-scale CV (cross-domain)  : %.4f\n', pool.heterogeneity.cv_eta);
fprintf('   heterogeneity ratio (psi/eta): %.4f\n', pool.heterogeneity.het_ratio);
fprintf('   Regime change (mean eta)     : rho>0 -> %.3f  |  rho<0 -> %.3f\n', ...
    pool.regime_change.mean_eta_pos, pool.regime_change.mean_eta_neg);

% -----------------------------------------------------------------------
% [9/9]  psi-stratified ML residuals + Figures + table_numbers.csv
% -----------------------------------------------------------------------
fprintf('\n[9/9] psi-stratified ML residuals + figures...\n');

psi_ml = psi_ml_residuals( ...
    'ml_all',   ml_all, ...
    'fig_path', fullfile(FIG_DIR, 'Figure_3b.png'));
writetable(psi_ml.augmented, fullfile(OUT_DIR, 'psi_ml_residuals.csv'));
fprintf('   corr(eta, ML)      : %.3f\n', psi_ml.corr_eta);
fprintf('   corr(psi, ML)      : %.3f\n', psi_ml.corr_psi);
fprintf('   corr(|psi|, ML)    : %.3f\n', psi_ml.corr_abspsi);
fprintf('   residual ~ psi slope: %+.3f  (p=%.3f)\n', psi_ml.slope, psi_ml.slope_p);

fprintf('\n   Generating figures...\n');

figure_1_landscape(pef_2s, pef_per_season, domain_summary, ...
                   fullfile(FIG_DIR, 'Figure_1.png'), pef_exemplars);
fprintf('   Figure 1 saved.\n');

figure_2_info_surface(pef_2s, pef_per_season, domain_summary, fullfile(FIG_DIR, 'Figure_2.png'));
fprintf('   Figure 2 saved.\n');

figure_3_ml_mapping(ml_all, ml_surface, fullfile(FIG_DIR, 'Figure_3.png'));
fprintf('   Figure 3 saved.\n');

figure_si_normality(norm_primary, norm_si, ...
                    fullfile(OUT_DIR, 'normality_summary_SI.png'));
fprintf('   SI normality figure saved.\n');

% All computed numbers for LaTeX \input{}
stats = collate_table_numbers(pef_2s, pef_per_season, norm_commentary, ...
                               domain_summary, ml_all, norm_primary, ...
                               height(rugby_2s), height(foot_2s), ...
                               audit, pool, psi_ml);
writetable(stats, fullfile(OUT_DIR, 'table_numbers.csv'));
fprintf('   table_numbers.csv written (%d rows).\n', height(stats));

write_numbers_tex(stats, fullfile(OUT_DIR, 'numbers.tex'));
fprintf('   numbers.tex written.\n');

fprintf('\n==========================================================\n');
fprintf(' Pipeline complete.\n');
fprintf(' Figures : %s\n', FIG_DIR);
fprintf(' Outputs : %s\n', OUT_DIR);
fprintf('==========================================================\n');
fprintf('\n');
fprintf(' To refresh the companion repo (pef-mathematics/validation_inputs/\n');
fprintf(' and scripts/lib/) with these outputs and a provenance manifest,\n');
fprintf(' run from the empirical repo root:\n');
fprintf('   bash scripts/paper_pipeline/sync_to_companion.sh\n');
fprintf('\n');

% ======================================================================
%  LOCAL FUNCTIONS  (MATLAB R2019b+)
% ======================================================================

% ---- Season-window builder -------------------------------------------
function windows = build_windows(season_list)
    season_list = sort(unique(string(season_list)));
    n = numel(season_list);
    windows = cell(1, n + 3);
    for s = 1:n
        windows{s} = {season_list(s)};
    end
    if n >= 4
        windows{n+1} = {season_list(1), season_list(2)};
        windows{n+2} = {season_list(3), season_list(4)};
        windows{n+3} = cellstr(season_list)';
    elseif n == 2
        windows{n+1} = cellstr(season_list)';
        windows = windows(1:n+1);
    else
        windows = windows(1:n);
    end
end

% ---- Extract home_win from raw rugby CSV ----------------------------
function tbl = attach_rugby_outcomes(csv_path)
    opts = detectImportOptions(csv_path, 'TextType', 'string');
    raw  = readtable(csv_path, opts);
    raw.match_location = lower(strtrim(raw.match_location));
    raw.outcome        = lower(strtrim(raw.outcome));
    home_rows = raw(raw.match_location == "home", {'matchid','outcome'});
    home_rows.home_win = double(home_rows.outcome == "win");
    tbl = home_rows(:, {'matchid','home_win'});
end

% ---- Extract home_win from raw football championship CSVs -----------
function tbl = attach_football_outcomes(csv_dir, season_files)
    rows = {};
    for s = 1:numel(season_files)
        fp = fullfile(csv_dir, season_files{s});
        if ~exist(fp, 'file'), continue; end
        opts = detectImportOptions(fp, 'TextType', 'string');
        t = readtable(fp, opts);
        if ~ismember('home_away', t.Properties.VariableNames) || ...
           ~ismember('result',    t.Properties.VariableNames) || ...
           ~ismember('match_id',  t.Properties.VariableNames)
            continue
        end
        t.home_away = lower(strtrim(t.home_away));
        t.result    = lower(strtrim(t.result));
        home_rows = t(t.home_away == "home", {'match_id','result'});
        % Accept both abbreviated ("w") and full word ("win") forms.
        home_rows.home_win = double(home_rows.result == "w" | home_rows.result == "win");
        rows{end+1} = home_rows(:, {'match_id','home_win'}); %#ok<AGROW>
    end
    if isempty(rows)
        tbl = table(string.empty(0,1), double.empty(0,1), ...
                    'VariableNames', {'match_id','home_win'});
    else
        tbl = vertcat(rows{:});
        tbl = unique(tbl, 'rows');
    end
end

% ---- Normality commentary statistics ---------------------------------
function nc = compute_normality_commentary(norm_prim, norm_si)
    sports = ["rugby","football"];
    sides  = ["home","away","diff"];
    rows   = {};
    for sp = sports
        for sd = sides
            % Single-season window (window_n_seasons == 1)
            m1 = norm_prim.sport == sp & norm_prim.side == sd & ...
                 norm_prim.window_n_seasons == 1;
            v1 = norm_prim.verdict(m1);
            pct_nc_1s = 100 * mean(v1 == "Normal" | v1 == "Close");
            pct_n_1s  = 100 * mean(v1 == "Normal");
            n_kpis_1s = sum(m1) / max(numel(unique(norm_prim.window_label(m1))), 1);

            % Pooled 2-season window (window_n_seasons == 2)
            m2 = norm_prim.sport == sp & norm_prim.side == sd & ...
                 norm_prim.window_n_seasons == 2;
            v2 = norm_prim.verdict(m2);
            pct_nc_2s = 100 * mean(v2 == "Normal" | v2 == "Close");

            % Pooled 4-season (from SI table)
            m4 = norm_si.sport == sp & norm_si.side == sd & ...
                 norm_si.window_n_seasons == 4;
            v4 = norm_si.verdict(m4);
            pct_nc_4s = 100 * mean(v4 == "Normal" | v4 == "Close");

            % Mean W statistic at single-season
            w_vals = norm_prim.sw_W(m1);
            mean_W = mean(w_vals(~isnan(w_vals)), 'omitnan');
            mean_sk = mean(norm_prim.skewness(m1), 'omitnan');
            mean_ku = mean(norm_prim.kurtosis(m1), 'omitnan');

            rows(end+1,:) = {sp, sd, n_kpis_1s, ...
                pct_nc_1s, pct_n_1s, pct_nc_2s, pct_nc_4s, ...
                mean_W, mean_sk, mean_ku}; %#ok<AGROW>
        end
    end
    nc = cell2table(rows, 'VariableNames', { ...
        'sport','side','n_kpis', ...
        'pct_normal_close_1season','pct_normal_1season','pct_normal_close_2season','pct_normal_close_4season', ...
        'mean_SW_W','mean_skewness','mean_kurtosis'});
end

% ---- Print normality commentary to console ---------------------------
function print_normality_commentary(nc)
    fprintf('\n--- Normality commentary ---\n');
    fprintf('%-10s %-5s  1-season  2-season  4-season  mean_W  skew   kurt\n', 'Sport','Side');
    fprintf('%s\n', repmat('-',1,70));
    for r = 1:height(nc)
        fprintf('%-10s %-5s  %5.1f%%    %5.1f%%    %5.1f%%   %.3f  %+.2f  %.2f\n', ...
            nc.sport{r}, nc.side{r}, ...
            nc.pct_normal_close_1season(r), ...
            nc.pct_normal_close_2season(r), ...
            nc.pct_normal_close_4season(r), ...
            nc.mean_SW_W(r), nc.mean_skewness(r), nc.mean_kurtosis(r));
    end
    % Key headline stats
    for sp = ["rugby","football"]
        row = nc(nc.sport == sp & nc.side == "diff", :);
        if ~isempty(row)
            fprintf('\n  %s diff series: %.0f%% pass Normal/Close at single-season n (W=%.3f, skew=%+.2f)\n', ...
                sp, row.pct_normal_close_1season, row.mean_SW_W, row.mean_skewness);
            fprintf('  Power effect  : pooling 4 seasons reduces pass rate to %.0f%%\n', ...
                row.pct_normal_close_4season);
        end
    end
    fprintf('\nNote: Rejection increase with pooling reflects test power (larger n detects\n');
    fprintf('minor deviations), NOT distributional change. W statistic and skewness\n');
    fprintf('remain stable, supporting assumption A1 (approximate normality of differences).\n\n');
end

% ---- Load non-sports pre-computed summaries --------------------------
function tbl = load_nonsports(ns_dir)
    specs = { ...
        'Healthcare',       'real_biology_pef_results.csv'; ...
        'Finance',          'real_finance_pef_results.csv'; ...
        'Manufacturing',    'manufacturing_pef_results.csv'; ...
        'Clinical Genomics','real_gene_expression_tcga_study.csv'; ...
    };
    rows = {};
    for i = 1:size(specs,1)
        dom   = specs{i,1};
        fpath = fullfile(ns_dir, specs{i,2});
        if ~exist(fpath, 'file')
            fprintf('   WARNING: %s not found, skipping.\n', specs{i,2});
            continue
        end
        t = readtable(fpath);
        ec = find_eta_col(t);
        rc = find_rho_col(t);
        kc = find_kappa_col(t);
        if isempty(ec), continue; end
        eta = t.(ec);
        eta = eta(isfinite(eta) & eta > 0);
        rho_mean   = NaN; kappa_mean = NaN;
        if ~isempty(rc), rho_mean   = mean(t.(rc),   'omitnan'); end
        if ~isempty(kc), kappa_mean = mean(t.(kc),   'omitnan'); end
        rows(end+1,:) = {dom, numel(eta), mean(eta), std(eta), ...
            100*mean(eta>1), rho_mean, kappa_mean}; %#ok<AGROW>
    end
    if isempty(rows)
        tbl = table();
    else
        tbl = cell2table(rows, 'VariableNames', ...
            {'domain','n','mean_eta','sd_eta','success_pct','rho_mean','kappa_mean'});
    end
end

function c = find_eta_col(t)
    c = first_match(t, {'eta','pef','PEF','ETA','eta_pooled','mean_eta'});
end
function c = find_rho_col(t)
    c = first_match(t, {'rho','correlation','pearson_r','rho_pooled','mean_rho'});
end
function c = find_kappa_col(t)
    c = first_match(t, {'kappa','variance_ratio','kappa_pooled','mean_kappa'});
end
function c = first_match(t, candidates)
    c = '';
    for i = 1:numel(candidates)
        if ismember(candidates{i}, t.Properties.VariableNames)
            c = candidates{i}; return
        end
    end
end

% ---- Empirical ML validation via 5-fold logistic CV -----------------
function ml_tbl = ml_empirical(paired, kpis, outcome_col, k)
    ML_VARS  = {'kpi','n','acc_abs','acc_rel','acc_improvement', ...
                'auc_abs','auc_rel','auc_improvement'};
    ML_TYPES = {'string','double','double','double','double', ...
                'double','double','double'};
    empty_ml = @() table('Size',[0 numel(ML_VARS)], ...
                         'VariableTypes', ML_TYPES, 'VariableNames', ML_VARS);

    if ~ismember(outcome_col, paired.Properties.VariableNames)
        warning('ml_empirical: outcome column "%s" not found. Skipping.', outcome_col);
        ml_tbl = empty_ml(); return
    end
    y_all = double(paired.(outcome_col));
    rows  = {};
    for ki = 1:numel(kpis)
        kpi = kpis{ki};
        ch  = [kpi '_home']; ca = [kpi '_away'];
        if ~ismember(ch, paired.Properties.VariableNames), continue; end
        A   = paired.(ch); B = paired.(ca);
        ok  = ~isnan(A) & ~isnan(B) & ~isnan(y_all);
        A   = A(ok); B = B(ok); y = y_all(ok);
        if numel(y) < 20 || numel(unique(y)) < 2, continue; end
        D   = A - B;   % relative (difference) feature
        [acc_a, auc_a] = cv_logistic(A, y, k);
        [acc_r, auc_r] = cv_logistic(D, y, k);
        acc_impr = 100 * (acc_r - acc_a) / max(acc_a, 0.01);
        auc_impr = 100 * (auc_r - auc_a) / max(auc_a, 0.01);
        rows(end+1,:) = {string(kpi), numel(y), ...
            acc_a, acc_r, acc_impr, auc_a, auc_r, auc_impr}; %#ok<AGROW>
    end
    if isempty(rows)
        ml_tbl = empty_ml();
    else
        ml_tbl = cell2table(rows, 'VariableNames', ML_VARS);
    end
end

function [acc, auc] = cv_logistic(X, y, k)
    n     = numel(X);
    idx   = mod(randperm(n)-1, k) + 1;
    preds = zeros(n,1);
    for f = 1:k
        tr = idx ~= f; te = idx == f;
        if sum(tr) < 10 || numel(unique(y(tr))) < 2
            preds(te) = mean(y(tr));
        else
            w1 = warning('off', 'stats:glmfit:PerfectSeparation');
            w2 = warning('off', 'stats:glmfit:IterationLimit');
            try
                b = glmfit(X(tr), y(tr), 'binomial', 'link', 'logit');
                preds(te) = glmval(b, X(te), 'logit');
            catch
                preds(te) = mean(y(tr));
            end
            warning(w1); warning(w2);
        end
    end
    acc = mean((preds >= 0.5) == y);
    % Trapezoidal AUC
    [~, ord] = sort(preds, 'descend');
    tp = cumsum( y(ord)) / sum(y);
    fp = cumsum(~y(ord)) / sum(~y);
    auc = trapz(fp, tp);
end

% ---- Merge PEF params into ML table ----------------------------------
function ml_out = join_pef_to_ml(ml_tbl, pef_tbl)
    ml_out = ml_tbl;
    ml_out.kappa    = NaN(height(ml_out),1);
    ml_out.rho      = NaN(height(ml_out),1);
    ml_out.eta      = NaN(height(ml_out),1);
    ml_out.quadrant = strings(height(ml_out),1);
    for r = 1:height(ml_out)
        match = pef_tbl.kpi == ml_out.kpi(r);
        if any(match)
            idx = find(match,1);
            ml_out.kappa(r)    = pef_tbl.kappa(idx);
            ml_out.rho(r)      = pef_tbl.rho(idx);
            ml_out.eta(r)      = pef_tbl.eta(idx);
            ml_out.quadrant(r) = pef_tbl.quadrant(idx);
        end
    end
end

% ---- Synthetic ML surface (polynomial mapping on eta grid) -----------
function surf = build_ml_surface()
    eta_g = linspace(0.3, 4, 200);
    % Empirical polynomial mapping coefficients (from pef_validation studies)
    ml_g  = 0.234*(eta_g-1) + 0.089*(eta_g-1).^2;
    surf  = struct('eta', eta_g, 'ml_improvement', ml_g);
end

% figure_1_landscape.m and figure_2_info_surface.m live in THIS_DIR

% ---- FIGURE 3: PEF-to-ML surface + empirical overlay ----------------
function figure_3_ml_mapping(ml_all, ~, fpath)
    % Figure 3: empirical eta vs DeltaML scatter with quadrant exemplar annotations.
    % x-axis [0,5.5]: retains rucks_won (eta~5.38), the Discussion counter-example.
    % y-axis [-5,10]: clips high-DeltaML outliers (noted in caption).
    % The polynomial surface (ml_surface) argument is accepted but not plotted.
    X_LIM = [0, 5.5];
    Y_LIM = [-5, 10];

    fig = figure('Color','w','Position',[100 100 950 650]);

    quads = ["Q1","Q2","Q3","Q4"];
    qcol  = [0.20 0.63 0.17; 0.12 0.47 0.71; 0.89 0.47 0.07; 0.77 0.15 0.16];
    valid = ~isnan(ml_all.eta) & ~isnan(ml_all.acc_improvement);

    % Count points that will be clipped (for caption note)
    n_clip_x = sum(valid & ml_all.eta > X_LIM(2));
    n_clip_y = sum(valid & (ml_all.acc_improvement < Y_LIM(1) | ...
                            ml_all.acc_improvement > Y_LIM(2)));

    % ---- Left panel: empirical scatter per quadrant ----------------------
    subplot(1,2,1); hold on;
    if any(valid)
        for qi = 1:4
            qm = valid & ml_all.quadrant == quads(qi);
            if ~any(qm), continue; end
            scatter(ml_all.eta(qm), ml_all.acc_improvement(qm), 45, qcol(qi,:), ...
                'filled','MarkerEdgeColor','k','LineWidth',0.3,'MarkerFaceAlpha',0.35, ...
                'DisplayName', char(quads(qi)));
        end
    end
    % Reference lines
    xline(1, 'k:', 'LineWidth',1.0, 'HandleVisibility','off');
    yline(0, 'k:', 'LineWidth',0.8, 'HandleVisibility','off');

    % Exemplar annotations (one per quadrant, verified against pipeline outputs)
    exemplar_sport = ["rugby",        "football",   "football", "football"];
    exemplar_kpi   = ["kick_metres",  "long_balls",  "passes",  "goalkeeper_long_balls"];
    exemplar_label = ["Q1: kick metres", "Q2: long balls", "Q3: passes", "Q4: gk long balls"];
    exemplar_xoff  = [ 0.12,  0.10,  0.10, 0.15];  % label x-offset (data units)
    exemplar_yoff  = [ 1.2,   1.8,  -2.0,  1.5];   % label y-offset (percentage points)
    for ei = 1:4
        emask = valid & ml_all.sport == exemplar_sport(ei) & ...
                        ml_all.kpi   == exemplar_kpi(ei);
        if ~any(emask), continue; end
        xe = ml_all.eta(emask);
        ye = ml_all.acc_improvement(emask);
        scatter(xe, ye, 160, 'k', 'o', 'LineWidth', 2.0, 'HandleVisibility','off');
        text(xe + exemplar_xoff(ei), ye + exemplar_yoff(ei), exemplar_label(ei), ...
            'FontSize', 8, 'FontWeight', 'bold', 'Color', [0.10 0.10 0.10], ...
            'HorizontalAlignment', 'left');
    end

    % Annotate the rucks_won counter-example (Discussion: high eta, zero DeltaML)
    rmask = valid & ml_all.sport == "rugby" & ml_all.kpi == "rucks_won";
    if any(rmask)
        scatter(ml_all.eta(rmask), ml_all.acc_improvement(rmask), 130, ...
            [0.5 0.5 0.5], 'd', 'LineWidth', 1.5, 'HandleVisibility','off');
        text(ml_all.eta(rmask) + 0.12, ml_all.acc_improvement(rmask) + 1.2, ...
            'rucks won', 'FontSize', 7.5, 'Color', [0.35 0.35 0.35], ...
            'HorizontalAlignment','left');
    end

    xlim(X_LIM); ylim(Y_LIM);
    xlabel('\eta (PEF)','FontSize',11);
    ylabel('\DeltaML accuracy (%)','FontSize',11);
    title('ML improvement vs \eta  (annotated exemplars)','FontSize',11);
    leg = legend('Location','northwest','Box','off','FontSize',8);
    % Clip note below legend if any points hidden
    if n_clip_x + n_clip_y > 0
        annotation('textbox',[0.09 0.04 0.36 0.04], ...
            'String', sprintf('%d pt(s) outside shown range', n_clip_x+n_clip_y), ...
            'EdgeColor','none','FontSize',7,'Color',[0.5 0.5 0.5]);
    end
    grid on; hold off;

    % ---- Right panel: mean ± SE by quadrant bar --------------------------
    subplot(1,2,2); hold on;
    q_means = zeros(4,1); q_se = zeros(4,1); q_n = zeros(4,1);
    for qi = 1:4
        qm  = valid & ml_all.quadrant == quads(qi);
        vals = ml_all.acc_improvement(qm);
        q_n(qi)     = sum(qm);
        q_means(qi) = mean(vals, 'omitnan');
        q_se(qi)    = std(vals, 'omitnan') / sqrt(max(q_n(qi), 1));
    end
    bh = bar(q_means, 'FaceColor','flat');
    for qi = 1:4, bh.CData(qi,:) = qcol(qi,:); end
    % ±1 SE error bars
    errorbar(1:4, q_means, q_se, 'k.', 'LineWidth', 1.2, 'CapSize', 6, ...
        'HandleVisibility','off');
    yline(0, 'k-', 'LineWidth', 0.8, 'HandleVisibility','off');
    xticklabels(cellstr(quads)); xlabel('Quadrant','FontSize',11);
    ylabel('Mean \DeltaML accuracy (%)','FontSize',11);
    title('Mean \pm 1 SE by quadrant','FontSize',11);
    % n-labels inside bars
    ax2 = gca; yl = ax2.YLim;
    for qi = 1:4
        ty = q_means(qi) * 0.5;
        ty = max(min(ty, yl(2)-0.2), yl(1)+0.1);
        text(qi, ty, sprintf('n=%d', q_n(qi)), ...
            'HorizontalAlignment','center','FontSize',9,'Color','w','FontWeight','bold');
    end
    grid on; hold off;

    sgtitle('PEF empirical ML improvement  (23/24 + 24/25 pooled)', ...
        'FontSize',12,'FontWeight','bold');
    if nargin >= 3 && ~isempty(fpath)
        exportgraphics(fig, fpath, 'Resolution',200);
    end
    close(fig);
end

% ---- SI FIGURE: Normality summary (2-season vs 4-season) ------------
function figure_si_normality(norm_prim, norm_si, fpath)
    cats   = ["Normal","Close","NotNormal"];
    colours = [0.20 0.62 0.18; 0.85 0.65 0.13; 0.75 0.13 0.13];
    sports = unique(norm_prim.sport);
    sides  = ["home","away","diff"];

    fig = figure('Color','w','Position',[100 100 1200 700]);
    n_sp = numel(sports);
    splot = 0;
    for si = 1:numel(sports)
        sp = sports(si);
        for sd = 1:3
            splot = splot+1;
            ax = subplot(n_sp*2, 3, splot);
            % Primary (2s) stacked bar
            wins_p = sort(unique(norm_prim.window_n_seasons));
            cube   = zeros(numel(wins_p),3);
            for wi=1:numel(wins_p)
                mask = norm_prim.sport==sp & norm_prim.side==sides(sd) & ...
                       norm_prim.window_n_seasons==wins_p(wi);
                v = norm_prim.verdict(mask);
                for ci=1:3, cube(wi,ci)=sum(v==cats(ci)); end
            end
            tot = sum(cube,2); tot(tot==0)=1;
            prop = 100*cube./tot;
            bh = bar(prop,'stacked','FaceColor','flat');
            for ci=1:3, bh(ci).FaceColor=colours(ci,:); end
            xticks(1:numel(wins_p));
            xticklabels(arrayfun(@(w)sprintf('%ds',w),wins_p,'UniformOutput',false));
            ylim([0 100]); ylabel('%'); grid on;
            if si==1, title(sprintf('%s',sides(sd)),'FontSize',10); end
            if sd==1, ax.YLabel.String = sprintf('%s\n%%',sp); end
        end
        % SI 4-season row
        for sd = 1:3
            splot = splot+1;
            subplot(n_sp*2, 3, splot);
            wins_s = sort(unique(norm_si.window_n_seasons));
            cube   = zeros(numel(wins_s),3);
            for wi=1:numel(wins_s)
                mask = norm_si.sport==sp & norm_si.side==sides(sd) & ...
                       norm_si.window_n_seasons==wins_s(wi);
                v = norm_si.verdict(mask);
                for ci=1:3, cube(wi,ci)=sum(v==cats(ci)); end
            end
            tot = sum(cube,2); tot(tot==0)=1;
            prop = 100*cube./tot;
            bh = bar(prop,'stacked','FaceColor','flat');
            for ci=1:3, bh(ci).FaceColor=colours(ci,:); end
            xticks(1:numel(wins_s));
            xticklabels(arrayfun(@(w)sprintf('%ds',w),wins_s,'UniformOutput',false));
            ylim([0 100]); grid on;
        end
    end
    % Legend
    hl = gobjects(3,1);
    for ci=1:3, hl(ci)=patch(NaN,NaN,colours(ci,:),'DisplayName',cats(ci)); end
    legend(hl,'Location','southoutside','Orientation','horizontal','Box','off');
    sgtitle('Normality verdict proportions — primary (top) vs 4-season SI (bottom)',...
            'FontSize',11,'FontWeight','bold');
    if nargin>=3 && ~isempty(fpath)
        exportgraphics(fig, fpath, 'Resolution',150);
    end
    close(fig);
end

% ---- Collate all table numbers for LaTeX ----------------------------
function stats = collate_table_numbers(pef_2s, ~, nc, domain_summary, ml_all, ~, n_rugby_games, n_foot_games, audit, pool, psi_ml)
    % Note: pef_per_season and norm_primary are accepted but unused here
    % (they are kept for API consistency).
    if nargin < 7,  n_rugby_games = NaN; end
    if nargin < 8,  n_foot_games  = NaN; end
    if nargin < 9,  audit  = struct(); end
    if nargin < 10, pool   = struct(); end
    if nargin < 11, psi_ml = struct(); end

    rows = {};  % grows via direct concatenation (avoids MATLAB closure-capture issue)

    % --- Table 1: per-domain validation summary ---
    n_rugby_kpis = 0; n_foot_kpis = 0;
    for sp = ["rugby","football"]
        sub = pef_2s(pef_2s.sport == sp & ~isnan(pef_2s.eta), :);
        mu  = mean(sub.eta, 'omitnan');
        sd  = std(sub.eta,  'omitnan');
        n   = height(sub);
        se  = sd / max(sqrt(n), 1);
        rows(end+1,:) = {'Table1', char(sp), 'mean_eta',    mu};         %#ok<AGROW>
        rows(end+1,:) = {'Table1', char(sp), 'sd_eta',      sd};
        rows(end+1,:) = {'Table1', char(sp), 'success_pct', 100*mean(sub.eta>1,'omitnan')};
        rows(end+1,:) = {'Table1', char(sp), 'n_kpis',      n};
        rows(end+1,:) = {'Table1', char(sp), 'ci_lo',       mu - 1.96*se};
        rows(end+1,:) = {'Table1', char(sp), 'ci_hi',       mu + 1.96*se};
        if sp == "rugby",    n_rugby_kpis = n; end
        if sp == "football", n_foot_kpis  = n; end
    end
    rows(end+1,:) = {'Table1', 'rugby',    'n_games',       n_rugby_games};
    rows(end+1,:) = {'Table1', 'football', 'n_games',       n_foot_games};
    rows(end+1,:) = {'Table1', 'sports',   'total_studies', n_rugby_kpis + n_foot_kpis};

    if ~isempty(domain_summary)
        for r = 1:height(domain_summary)
            dom = domain_summary.domain{r};
            mu  = domain_summary.mean_eta(r);
            sd  = domain_summary.sd_eta(r);
            n   = domain_summary.n(r);
            se  = sd / max(sqrt(n), 1);
            rows(end+1,:) = {'Table1', dom, 'mean_eta',    mu};
            rows(end+1,:) = {'Table1', dom, 'sd_eta',      sd};
            rows(end+1,:) = {'Table1', dom, 'success_pct', domain_summary.success_pct(r)};
            rows(end+1,:) = {'Table1', dom, 'n',           n};
            rows(end+1,:) = {'Table1', dom, 'ci_lo',       mu - 1.96*se};
            rows(end+1,:) = {'Table1', dom, 'ci_hi',       mu + 1.96*se};
        end
    end

    % --- Table 4: quadrant-level performance ---
    for q = ["Q1","Q2","Q3","Q4"]
        qm = pef_2s.quadrant == q & ~isnan(pef_2s.eta);
        mu  = mean(pef_2s.eta(qm), 'omitnan');
        sd  = std(pef_2s.eta(qm),  'omitnan');
        n   = sum(qm);
        se  = sd / max(sqrt(n), 1);
        rows(end+1,:) = {'Table4', char(q), 'mean_eta', mu};
        rows(end+1,:) = {'Table4', char(q), 'n_kpis',   n};
        rows(end+1,:) = {'Table4', char(q), 'ci_lo',    mu - 1.96*se};
        rows(end+1,:) = {'Table4', char(q), 'ci_hi',    mu + 1.96*se};
        if ~isempty(ml_all) && ismember('quadrant', ml_all.Properties.VariableNames)
            qml = ml_all.acc_improvement(ml_all.quadrant == q);
            rows(end+1,:) = {'Table4', char(q), 'mean_ml_impr', mean(qml,'omitnan')};
        end
    end

    % --- Table 5: ML mapping validation metrics ---
    if ~isempty(ml_all) && ismember('acc_improvement', ml_all.Properties.VariableNames) ...
                        && ismember('eta', ml_all.Properties.VariableNames)
        valid = ~isnan(ml_all.acc_improvement) & ~isnan(ml_all.eta);
        if sum(valid) > 3
            r_val = corr(ml_all.eta(valid), ml_all.acc_improvement(valid));
            resid = ml_all.acc_improvement(valid) - ...
                    (0.234*(ml_all.eta(valid)-1) + 0.089*(ml_all.eta(valid)-1).^2);
            rows(end+1,:) = {'Table5', 'mapping', 'r',    r_val};
            rows(end+1,:) = {'Table5', 'mapping', 'R2',   r_val^2};
            rows(end+1,:) = {'Table5', 'mapping', 'MAE',  mean(abs(resid))};
            rows(end+1,:) = {'Table5', 'mapping', 'RMSE', sqrt(mean(resid.^2))};
        end
    end

    % --- Normality headline numbers (for Results text) ---
    for r = 1:height(nc)
        lbl = sprintf('%s_%s', nc.sport{r}, nc.side{r});
        rows(end+1,:) = {'NormCommentary', lbl, 'pct_nc_1s', nc.pct_normal_close_1season(r)};
        rows(end+1,:) = {'NormCommentary', lbl, 'pct_nc_2s', nc.pct_normal_close_2season(r)};
        rows(end+1,:) = {'NormCommentary', lbl, 'pct_nc_4s', nc.pct_normal_close_4season(r)};
        rows(end+1,:) = {'NormCommentary', lbl, 'mean_W',    nc.mean_SW_W(r)};
    end

    % --- AppendixC: kappa <-> 1/kappa audit headline numbers ---
    if isfield(audit, 'grid_residual_max')
        rows(end+1,:) = {'AppendixC', 'audit', 'grid_residual', audit.grid_residual_max};
    end
    if isfield(audit, 'fail_rate_pct')
        rows(end+1,:) = {'AppendixC', 'audit', 'fail_rate_pct', audit.fail_rate_pct};
    end
    if isfield(audit, 'level2') && istable(audit.level2) && ~isempty(audit.level2)
        rows(end+1,:) = {'AppendixC', 'audit', 'n_l2_pass',     sum(audit.level2.level2_pass == 1)};
        rows(end+1,:) = {'AppendixC', 'audit', 'n_l2p5_pass',   sum(audit.level2.level2p5_pass == 1)};
        rows(end+1,:) = {'AppendixC', 'audit', 'n_units_total', height(audit.level2)};
    end

    % --- AppendixC: psi-scale per-domain pooling ---
    if isfield(pool, 'per_domain') && istable(pool.per_domain)
        for r = 1:height(pool.per_domain)
            dom = char(pool.per_domain.domain(r));
            rows(end+1,:) = {'AppendixC', dom, 'mean_psi',  pool.per_domain.mean_psi(r)};
            rows(end+1,:) = {'AppendixC', dom, 'psi_CI_lo', pool.per_domain.psi_CI_lo(r)};
            rows(end+1,:) = {'AppendixC', dom, 'psi_CI_hi', pool.per_domain.psi_CI_hi(r)};
            rows(end+1,:) = {'AppendixC', dom, 'mean_abs_tau', pool.per_domain.mean_abs_tau(r)};
        end
    end
    if isfield(pool, 'heterogeneity') && istable(pool.heterogeneity)
        rows(end+1,:) = {'AppendixC', 'heterogeneity', 'cv_psi',         pool.heterogeneity.cv_psi};
        rows(end+1,:) = {'AppendixC', 'heterogeneity', 'cv_eta',         pool.heterogeneity.cv_eta};
        rows(end+1,:) = {'AppendixC', 'heterogeneity', 'het_ratio',      pool.heterogeneity.het_ratio};
        rows(end+1,:) = {'AppendixC', 'heterogeneity', 'cv_psi_pos',     pool.heterogeneity.cv_psi_pos};
        rows(end+1,:) = {'AppendixC', 'heterogeneity', 'cv_eta_pos',     pool.heterogeneity.cv_eta_pos};
        rows(end+1,:) = {'AppendixC', 'heterogeneity', 'het_ratio_pos',  pool.heterogeneity.het_ratio_pos};
    end
    if isfield(pool, 'regime_change') && isstruct(pool.regime_change)
        rc = pool.regime_change;
        rows(end+1,:) = {'AppendixC', 'regime', 'n_pos',           rc.n_pos};
        rows(end+1,:) = {'AppendixC', 'regime', 'n_neg',           rc.n_neg};
        rows(end+1,:) = {'AppendixC', 'regime', 'mean_eta_pos',    rc.mean_eta_pos};
        rows(end+1,:) = {'AppendixC', 'regime', 'mean_eta_neg',    rc.mean_eta_neg};
        rows(end+1,:) = {'AppendixC', 'regime', 'mean_psi_pos',    rc.mean_psi_pos};
        rows(end+1,:) = {'AppendixC', 'regime', 'mean_abspsi_neg', rc.mean_abspsi_neg};
        rows(end+1,:) = {'AppendixC', 'regime', 'frac_eta_gt1_pos', rc.frac_eta_gt1_pos};
        rows(end+1,:) = {'AppendixC', 'regime', 'frac_eta_gt1_neg', rc.frac_eta_gt1_neg};
    end

    % --- AppendixC: psi-stratified ML residual diagnostic ---
    if isfield(psi_ml, 'slope')
        rows(end+1,:) = {'AppendixC', 'ml',    'corr_eta',       psi_ml.corr_eta};
        rows(end+1,:) = {'AppendixC', 'ml',    'corr_psi',       psi_ml.corr_psi};
        rows(end+1,:) = {'AppendixC', 'ml',    'corr_abspsi',    psi_ml.corr_abspsi};
        rows(end+1,:) = {'AppendixC', 'ml',    'residual_slope', psi_ml.slope};
        rows(end+1,:) = {'AppendixC', 'ml',    'residual_slope_p', psi_ml.slope_p};
        if isstruct(psi_ml.signed_split) && isfield(psi_ml.signed_split, 'rho_pos') ...
                && isfield(psi_ml.signed_split.rho_pos, 'corr_psi')
            rows(end+1,:) = {'AppendixC', 'ml', 'corr_psi_rho_pos', psi_ml.signed_split.rho_pos.corr_psi};
            rows(end+1,:) = {'AppendixC', 'ml', 'corr_psi_rho_neg', psi_ml.signed_split.rho_neg.corr_psi};
        end
    end

    % --- Table exemplars: four confirmatory KPIs (tab:exemplars) ---
    H = pef_theory_helpers();
    ex_spec = { ...
        'Qone',   "rugby",    "kick_metres"; ...
        'Qtwo',   "football", "long_balls"; ...
        'Qthree', "football", "passes"; ...
        'Qfour',  "football", "goalkeeper_long_balls"};
    dr_vals = [];
    for ei = 1:size(ex_spec, 1)
        row_lbl = ex_spec{ei, 1};
        sp      = ex_spec{ei, 2};
        kp      = ex_spec{ei, 3};
        m = pef_2s.sport == sp & pef_2s.kpi == kp;
        if ~any(m), continue; end
        idx = find(m, 1);
        rows(end+1,:) = {'TableExemplars', row_lbl, 'kappa', pef_2s.kappa(idx)}; %#ok<AGROW>
        rows(end+1,:) = {'TableExemplars', row_lbl, 'rho',   pef_2s.rho(idx)};
        rows(end+1,:) = {'TableExemplars', row_lbl, 'eta',   pef_2s.eta(idx)};
        [~, ~, dr] = H.delta_sigma_from_means( ...
            pef_2s.mean_home(idx), pef_2s.mean_away(idx), pef_2s.var_home(idx));
        dr_abs = abs(dr);
        dr_vals(end+1) = dr_abs; %#ok<AGROW>
        rows(end+1,:) = {'TableExemplars', row_lbl, 'delta_ratio', dr_abs};
        if ~isempty(ml_all) && ismember('sport', ml_all.Properties.VariableNames)
            mm = ml_all.sport == sp & ml_all.kpi == kp;
            if any(mm)
                rows(end+1,:) = {'TableExemplars', row_lbl, 'dml', ...
                    ml_all.acc_improvement(find(mm, 1))};
            end
        end
    end
    if ~isempty(dr_vals)
        rows(end+1,:) = {'TableExemplars', 'range', 'delta_ratio_lo', min(dr_vals)};
        rows(end+1,:) = {'TableExemplars', 'range', 'delta_ratio_hi', max(dr_vals)};
    end

    % --- Boundary illustration: rucks won (low delta despite high eta) ---
    m_rw = pef_2s.sport == "rugby" & pef_2s.kpi == "rucks_won";
    if any(m_rw)
        idx = find(m_rw, 1);
        rows(end+1,:) = {'TableExemplars', 'RucksWon', 'kappa', pef_2s.kappa(idx)};
        rows(end+1,:) = {'TableExemplars', 'RucksWon', 'rho',   pef_2s.rho(idx)};
        rows(end+1,:) = {'TableExemplars', 'RucksWon', 'eta',   pef_2s.eta(idx)};
        [~, ~, dr] = H.delta_sigma_from_means( ...
            pef_2s.mean_home(idx), pef_2s.mean_away(idx), pef_2s.var_home(idx));
        rows(end+1,:) = {'TableExemplars', 'RucksWon', 'delta_ratio', abs(dr)};
        if ~isempty(ml_all)
            mm = ml_all.sport == "rugby" & ml_all.kpi == "rucks_won";
            if any(mm)
                rows(end+1,:) = {'TableExemplars', 'RucksWon', 'dml', ...
                    ml_all.acc_improvement(find(mm, 1))};
            end
        end
    end

    % --- Landscape quadrant counts (Q3-heavy inventory) ---
    n_landscape = height(pef_2s);
    n_q3 = sum(pef_2s.quadrant == "Q3");
    if n_landscape > 0
        rows(end+1,:) = {'TableExemplars', 'landscape', 'n_qthree', n_q3};
        rows(end+1,:) = {'TableExemplars', 'landscape', 'pct_qthree', ...
            100 * n_q3 / n_landscape};
    end

    stats = cell2table(rows, 'VariableNames', {'table','row_label','metric','value'});
end

% ---- Write LaTeX \newcommand macros for manuscript auto-population ---
function write_numbers_tex(stats, fpath)
%WRITE_NUMBERS_TEX  Convert table_numbers rows to \newcommand macros.
%
%   Macro naming convention: \PEF<Domain><Stat>
%   Numeric values are formatted to a sensible precision (3 sig fig for
%   η / r values; 0 d.p. for integer counts; 1 d.p. for percentages).
%
%   The output file is safe to \InputIfFileExists in main.tex; it only
%   redefines macros so repeated compilation does not cause conflicts.

    % Lookup table: {table, row_label, metric} -> macro_name, format_spec
    % format_spec: 'pct'=%.1f, 'dp3'=%.3f, 'dp2'=%.2f, 'int'=%d, 'dp1'=%.1f
    lut = { ...
        'Table1','rugby',        'mean_eta',    'PEFrugbyMeanEta',     'dp3'; ...
        'Table1','rugby',        'sd_eta',       'PEFrugbySdEta',       'dp3'; ...
        'Table1','rugby',        'success_pct',  'PEFrugbySuccess',     'pct'; ...
        'Table1','rugby',        'n_kpis',       'PEFrugbyNkpis',       'int'; ...
        'Table1','rugby',        'n_games',      'PEFrugbyNgames',      'int'; ...
        'Table1','rugby',        'ci_lo',        'PEFrugbyCIlo',        'dp3'; ...
        'Table1','rugby',        'ci_hi',        'PEFrugbyCIhi',        'dp3'; ...
        'Table1','football',     'mean_eta',    'PEFfootMeanEta',      'dp3'; ...
        'Table1','football',     'sd_eta',       'PEFfootSdEta',        'dp3'; ...
        'Table1','football',     'success_pct',  'PEFfootSuccess',      'pct'; ...
        'Table1','football',     'n_kpis',       'PEFfootNkpis',        'int'; ...
        'Table1','football',     'n_games',      'PEFfootNgames',       'int'; ...
        'Table1','football',     'ci_lo',        'PEFfootCIlo',         'dp3'; ...
        'Table1','football',     'ci_hi',        'PEFfootCIhi',         'dp3'; ...
        'Table1','sports',       'total_studies','PEFtotalStudies',     'int'; ...
        'Table1','Healthcare',   'mean_eta',    'PEFhealthMeanEta',    'dp3'; ...
        'Table1','Healthcare',   'sd_eta',       'PEFhealthSdEta',      'dp3'; ...
        'Table1','Healthcare',   'success_pct',  'PEFhealthSuccess',    'pct'; ...
        'Table1','Healthcare',   'n',            'PEFhealthN',          'int'; ...
        'Table1','Finance',      'mean_eta',    'PEFfinanceMeanEta',   'dp3'; ...
        'Table1','Finance',      'sd_eta',       'PEFfinanceSdEta',     'dp3'; ...
        'Table1','Finance',      'success_pct',  'PEFfinanceSuccess',   'pct'; ...
        'Table1','Finance',      'n',            'PEFfinanceN',         'int'; ...
        'Table1','Manufacturing','mean_eta',    'PEFmfgMeanEta',       'dp3'; ...
        'Table1','Manufacturing','sd_eta',       'PEFmfgSdEta',         'dp3'; ...
        'Table1','Manufacturing','success_pct',  'PEFmfgSuccess',       'pct'; ...
        'Table1','Manufacturing','n',            'PEFmfgN',             'int'; ...
        'Table1','Clinical Genomics','mean_eta','PEFgenomicsMeanEta',  'dp3'; ...
        'Table1','Clinical Genomics','sd_eta',  'PEFgenomicsSdEta',    'dp3'; ...
        'Table1','Clinical Genomics','success_pct','PEFgenomicsSuccess','pct'; ...
        'Table1','Clinical Genomics','n',       'PEFgenomicsN',        'int'; ...
        'Table4','Q1',           'mean_eta',    'PEFqOneMeanEta',      'dp3'; ...
        'Table4','Q1',           'n_kpis',       'PEFqOneNkpis',        'int'; ...
        'Table4','Q1',           'mean_ml_impr', 'PEFqOneMLimpr',       'pct'; ...
        'Table4','Q1',           'ci_lo',        'PEFqOneCIlo',         'dp3'; ...
        'Table4','Q1',           'ci_hi',        'PEFqOneCIhi',         'dp3'; ...
        'Table4','Q2',           'mean_eta',    'PEFqTwoMeanEta',      'dp3'; ...
        'Table4','Q2',           'n_kpis',       'PEFqTwoNkpis',        'int'; ...
        'Table4','Q2',           'mean_ml_impr', 'PEFqTwoMLimpr',       'pct'; ...
        'Table4','Q3',           'mean_eta',    'PEFqThreeMeanEta',    'dp3'; ...
        'Table4','Q3',           'n_kpis',       'PEFqThreeNkpis',      'int'; ...
        'Table4','Q3',           'mean_ml_impr', 'PEFqThreeMLimpr',     'pct'; ...
        'Table4','Q4',           'mean_eta',    'PEFqFourMeanEta',     'dp3'; ...
        'Table4','Q4',           'n_kpis',       'PEFqFourNkpis',       'int'; ...
        'Table4','Q4',           'mean_ml_impr', 'PEFqFourMLimpr',      'pct'; ...
        'Table4','Q4',           'ci_lo',        'PEFqFourCIlo',        'dp3'; ...
        'Table4','Q4',           'ci_hi',        'PEFqFourCIhi',        'dp3'; ...
        'Table5','mapping',      'r',            'PEFmlCorr',           'dp3'; ...
        'Table5','mapping',      'R2',           'PEFmlRsq',            'dp3'; ...
        'Table5','mapping',      'MAE',          'PEFmlMAE',            'dp1'; ...
        'Table5','mapping',      'RMSE',         'PEFmlRMSE',           'dp1'; ...
        % --- AppendixC: kappa<->1/kappa audit ---
        'AppendixC','audit',     'grid_residual','PEFkappaGridResidual','exp'; ...
        'AppendixC','audit',     'fail_rate_pct','PEFkappaSymmetryFailRate','pct'; ...
        % n_l2_pass / n_l2p5_pass: exported to table_numbers.csv only (companion §7).
        % Do not emit LaTeX macros here: names like PEFkappaL2Pass are invalid in
        % LaTeX (control sequences stop at the digit after \PEFkappaL).
        'AppendixC','audit',     'n_units_total','PEFkappaAuditTotal',  'int'; ...
        % --- AppendixC: psi per domain ---
        'AppendixC','rugby',     'mean_psi',     'PEFpsiRugby',         'dp3'; ...
        'AppendixC','rugby',     'psi_CI_lo',    'PEFpsiRugbyCIlo',     'dp3'; ...
        'AppendixC','rugby',     'psi_CI_hi',    'PEFpsiRugbyCIhi',     'dp3'; ...
        'AppendixC','rugby',     'mean_abs_tau', 'PEFabsTauRugby',      'dp3'; ...
        'AppendixC','football',  'mean_psi',     'PEFpsiFoot',          'dp3'; ...
        'AppendixC','football',  'psi_CI_lo',    'PEFpsiFootCIlo',      'dp3'; ...
        'AppendixC','football',  'psi_CI_hi',    'PEFpsiFootCIhi',      'dp3'; ...
        'AppendixC','football',  'mean_abs_tau', 'PEFabsTauFoot',       'dp3'; ...
        'AppendixC','Healthcare','mean_psi',     'PEFpsiHealth',        'dp3'; ...
        'AppendixC','Healthcare','psi_CI_lo',    'PEFpsiHealthCIlo',    'dp3'; ...
        'AppendixC','Healthcare','psi_CI_hi',    'PEFpsiHealthCIhi',    'dp3'; ...
        'AppendixC','Finance',   'mean_psi',     'PEFpsiFinance',       'dp3'; ...
        'AppendixC','Finance',   'psi_CI_lo',    'PEFpsiFinanceCIlo',   'dp3'; ...
        'AppendixC','Finance',   'psi_CI_hi',    'PEFpsiFinanceCIhi',   'dp3'; ...
        'AppendixC','Manufacturing','mean_psi',  'PEFpsiMfg',           'dp3'; ...
        'AppendixC','Manufacturing','psi_CI_lo', 'PEFpsiMfgCIlo',       'dp3'; ...
        'AppendixC','Manufacturing','psi_CI_hi', 'PEFpsiMfgCIhi',       'dp3'; ...
        'AppendixC','ClinicalGenomics','mean_psi',  'PEFpsiGenomics',   'dp3'; ...
        'AppendixC','ClinicalGenomics','psi_CI_lo', 'PEFpsiGenomicsCIlo','dp3'; ...
        'AppendixC','ClinicalGenomics','psi_CI_hi', 'PEFpsiGenomicsCIhi','dp3'; ...
        % --- AppendixC: heterogeneity ---
        'AppendixC','heterogeneity','cv_psi',        'PEFpsiCV',          'dp3'; ...
        'AppendixC','heterogeneity','cv_eta',        'PEFetaCV',          'dp3'; ...
        'AppendixC','heterogeneity','het_ratio',     'PEFpsiHeterogeneityRatio','dp3'; ...
        'AppendixC','heterogeneity','cv_psi_pos',    'PEFpsiCVpos',       'dp3'; ...
        'AppendixC','heterogeneity','cv_eta_pos',    'PEFetaCVpos',       'dp3'; ...
        'AppendixC','heterogeneity','het_ratio_pos', 'PEFpsiHetRatioPos', 'dp3'; ...
        % --- AppendixC: regime change at rho = 0 ---
        'AppendixC','regime',    'n_pos',          'PEFregimeNpos',     'int'; ...
        'AppendixC','regime',    'n_neg',          'PEFregimeNneg',     'int'; ...
        'AppendixC','regime',    'mean_eta_pos',   'PEFregimeEtaPos',   'dp3'; ...
        'AppendixC','regime',    'mean_eta_neg',   'PEFregimeEtaNeg',   'dp3'; ...
        'AppendixC','regime',    'mean_psi_pos',   'PEFregimePsiPos',   'dp3'; ...
        'AppendixC','regime',    'mean_abspsi_neg','PEFregimeAbsPsiNeg','dp3'; ...
        'AppendixC','regime',    'frac_eta_gt1_pos','PEFregimeFracGtOnePos','pct'; ...
        'AppendixC','regime',    'frac_eta_gt1_neg','PEFregimeFracGtOneNeg','pct'; ...
        % --- AppendixC: psi-stratified ML residuals ---
        'AppendixC','ml',        'corr_eta',       'PEFmlCorrEta',      'dp3'; ...
        'AppendixC','ml',        'corr_psi',       'PEFmlCorrPsi',      'dp3'; ...
        'AppendixC','ml',        'corr_abspsi',    'PEFmlCorrAbsPsi',   'dp3'; ...
        'AppendixC','ml',        'residual_slope', 'PEFmlResidualPsiSlope','dp3'; ...
        'AppendixC','ml',        'residual_slope_p','PEFmlResidualPsiSlopeP','dp3'; ...
        'AppendixC','ml',        'corr_psi_rho_pos','PEFmlCorrPsiPos',  'dp3'; ...
        'AppendixC','ml',        'corr_psi_rho_neg','PEFmlCorrPsiNeg',  'dp3'; ...
        % --- Table exemplars (tab:exemplars) ---
        'TableExemplars','Qone',   'kappa',       'PEFexQoneKappa',       'dp2'; ...
        'TableExemplars','Qone',   'rho',         'PEFexQoneRho',         'rho'; ...
        'TableExemplars','Qone',   'eta',         'PEFexQoneEta',         'dp2'; ...
        'TableExemplars','Qone',   'delta_ratio', 'PEFexQoneDeltaRatio',  'dp2'; ...
        'TableExemplars','Qone',   'dml',         'PEFexQoneDml',         'dml'; ...
        'TableExemplars','Qtwo',   'kappa',       'PEFexQtwoKappa',       'dp2'; ...
        'TableExemplars','Qtwo',   'rho',         'PEFexQtwoRho',         'rho'; ...
        'TableExemplars','Qtwo',   'eta',         'PEFexQtwoEta',         'dp2'; ...
        'TableExemplars','Qtwo',   'delta_ratio', 'PEFexQtwoDeltaRatio',  'dp2'; ...
        'TableExemplars','Qtwo',   'dml',         'PEFexQtwoDml',         'dml'; ...
        'TableExemplars','Qthree', 'kappa',       'PEFexQthreeKappa',     'dp2'; ...
        'TableExemplars','Qthree', 'rho',         'PEFexQthreeRho',       'rho'; ...
        'TableExemplars','Qthree', 'eta',         'PEFexQthreeEta',       'dp2'; ...
        'TableExemplars','Qthree', 'delta_ratio', 'PEFexQthreeDeltaRatio','dp2'; ...
        'TableExemplars','Qthree', 'dml',         'PEFexQthreeDml',       'dml'; ...
        'TableExemplars','Qfour',  'kappa',       'PEFexQfourKappa',      'dp2'; ...
        'TableExemplars','Qfour',  'rho',         'PEFexQfourRho',        'rho'; ...
        'TableExemplars','Qfour',  'eta',         'PEFexQfourEta',        'dp2'; ...
        'TableExemplars','Qfour',  'delta_ratio', 'PEFexQfourDeltaRatio', 'dp2'; ...
        'TableExemplars','Qfour',  'dml',         'PEFexQfourDml',        'dml'; ...
        'TableExemplars','range',  'delta_ratio_lo','PEFexDeltaRatioLo',  'dp2'; ...
        'TableExemplars','range',  'delta_ratio_hi','PEFexDeltaRatioHi',  'dp2'; ...
        'TableExemplars','RucksWon','kappa',      'PEFexRucksKappa',      'dp2'; ...
        'TableExemplars','RucksWon','rho',        'PEFexRucksRho',        'rho'; ...
        'TableExemplars','RucksWon','eta',        'PEFexRucksEta',        'dp2'; ...
        'TableExemplars','RucksWon','delta_ratio','PEFexRucksDeltaRatio', 'dp2'; ...
        'TableExemplars','RucksWon','dml',        'PEFexRucksDml',        'dml'; ...
        'TableExemplars','landscape','n_qthree',  'PEFlandscapeQthreeN',  'int'; ...
        'TableExemplars','landscape','pct_qthree','PEFlandscapeQthreePct','pct'; ...
    };

    fid = fopen(fpath, 'w');
    if fid < 0
        warning('write_numbers_tex: could not open %s for writing.', fpath);
        return
    end
    fprintf(fid, '%% numbers.tex — auto-generated by run_paper_pipeline.m\n');
    fprintf(fid, '%% Do NOT edit by hand; re-run the pipeline to update.\n');
    fprintf(fid, '%% Generated: %s\n\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));

    n_written = 0;
    for li = 1:size(lut,1)
        tbl  = lut{li,1};
        row  = lut{li,2};
        met  = lut{li,3};
        mac  = lut{li,4};
        fmt  = lut{li,5};

        % LaTeX control sequence names are letter-only; digits terminate the name
        % (e.g. PEFkappaL2Pass -> \PEFkappaL + 2Pass). Skip invalid macro names.
        if ~isempty(regexp(mac, '[0-9]', 'once'))
            warning('write_numbers_tex: skipping macro %s (digits not allowed in LaTeX names).', mac);
            continue;
        end

        mask = strcmp(stats.table, tbl) & ...
               strcmp(stats.row_label, row) & ...
               strcmp(stats.metric, met);
        if ~any(mask), continue; end
        val = stats.value(find(mask,1));
        if isnan(val), continue; end

        switch fmt
            case 'pct', valstr = sprintf('%.1f', val);
            case 'dp3', valstr = sprintf('%.3f', val);
            case 'dp2', valstr = sprintf('%.2f', val);
            case 'dp1', valstr = sprintf('%.1f', val);
            case 'int', valstr = sprintf('%d',   round(val));
            case 'exp', valstr = sprintf('%.2e', val);
            case 'rho', valstr = sprintf('%+.2f', val);
            case 'dml', valstr = sprintf('%+.1f', val);
            otherwise,  valstr = sprintf('%.3f', val);
        end

        fprintf(fid, '\\providecommand{\\%s}{%s}\n', mac, valstr);
        fprintf(fid, '\\renewcommand{\\%s}{%s}\n',   mac, valstr);
        n_written = n_written + 1;
    end

    fprintf(fid, '\n%% %d macros written.\n', n_written);
    fclose(fid);
    fprintf('   numbers.tex: %d macros written to %s\n', n_written, fpath);
end
