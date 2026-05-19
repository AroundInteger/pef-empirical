%RUN_PEF_NORMALITY_ANALYSIS
%
%  End-to-end PEF + normality analysis for the rugby union (URC) and
%  football (English Championship) datasets, across 4 seasons each.
%
%  Pipeline
%  --------
%  1. Load paired (home, away) match-level KPI data.
%  2. Compute kappa, rho, eta (PEF) and four-quadrant label per KPI,
%     for each sport separately and (a) per season, (b) pooled 4 seasons.
%  3. Run Shapiro-Wilk + Lilliefors normality tests on each KPI for the
%     home, away, and home-away difference series, across:
%        - each season alone (4 windows)
%        - two 2-season pools (first half, second half)
%        - the full 4-season pool
%  4. Curate exemplar KPIs in each PEF quadrant and split by
%     attacking / defensive / discipline role.
%  5. Write all results to CSV and produce two summary figures.
%
%  All outputs land in `outputs/` next to this script.
%
%  Reproducibility
%  ---------------
%  No randomness in the core PEF computations or normality tests. The
%  only stochastic element is MATLAB's lillietest Monte-Carlo p-value
%  refinement; we seed the global RNG below so repeated runs match.

clear; clc; close all;
rng(20260511, 'twister');   % paper-stable seed

% --------------------------------------------------------------------- %
% Paths
% --------------------------------------------------------------------- %
this_dir  = fileparts(mfilename('fullpath'));
addpath(this_dir);
repo_root = fileparts(fileparts(this_dir));   % .../overleaf_pef_article

rugby_csv = fullfile(repo_root, 'Data', 'Rugby', 'Raw', '4_seasons rugby abs.csv');
foot_dir  = fullfile(repo_root, 'Data', 'Football', 'Raw', 'team_summaries_4seasons');
foot_files = { ...
    'championship_team_21_22.csv', ...
    'championship_team_22_23.csv', ...
    'championship_team_23_24.csv', ...
    'championship_team_24_25.csv'};

out_dir = fullfile(this_dir, 'outputs');
if ~exist(out_dir, 'dir'), mkdir(out_dir); end

fprintf('=========================================================\n');
fprintf(' PEF + Normality analysis (rugby URC, football Championship)\n');
fprintf(' Outputs -> %s\n', out_dir);
fprintf('=========================================================\n');

% --------------------------------------------------------------------- %
% 1. Load paired data
% --------------------------------------------------------------------- %
fprintf('\n[1/5] Loading paired data...\n');
[rugby_paired, rugby_kpis] = load_rugby_paired(rugby_csv);
fprintf('   rugby: %d matches across seasons {%s}, %d KPIs\n', ...
    height(rugby_paired), join(unique(rugby_paired.season),', '), numel(rugby_kpis));

[foot_paired, foot_kpis] = load_football_paired(foot_dir, foot_files);
fprintf('   football: %d matches across seasons {%s}, %d KPIs\n', ...
    height(foot_paired), join(unique(foot_paired.season),', '), numel(foot_kpis));

% --------------------------------------------------------------------- %
% 2. PEF computation - per-sport, pooled across all 4 seasons
% --------------------------------------------------------------------- %
fprintf('\n[2/5] Computing PEF landscape (4-season pooled)...\n');
pef_rugby = compute_pef(rugby_paired, rugby_kpis, "rugby");
pef_foot  = compute_pef(foot_paired,  foot_kpis,  "football");

% Quadrant counts
fprintf('   Quadrant counts (pooled):\n');
disp(varfun(@(x) {sum(pef_rugby.quadrant == x)}, ...
            cell2table({"Q1","Q2","Q3","Q4"})));
fprintf('   Rugby quadrant distribution:\n');
disp(tabulate_quadrants(pef_rugby));
fprintf('   Football quadrant distribution:\n');
disp(tabulate_quadrants(pef_foot));

pef_landscape = [pef_rugby; pef_foot];
writetable(pef_landscape, fullfile(out_dir, 'pef_landscape_pooled4.csv'));

% Per-season PEF (useful for the year-on-year stability segments the
% paper references in fig:pef_landscape).
fprintf('\n   Computing per-season PEF...\n');
season_pef = table();
seasons_rugby = unique(rugby_paired.season);
for s = 1:numel(seasons_rugby)
    sub = rugby_paired(rugby_paired.season == seasons_rugby(s), :);
    pp  = compute_pef(sub, rugby_kpis, "rugby");
    pp.season = repmat(seasons_rugby(s), height(pp), 1);
    season_pef = [season_pef; pp]; %#ok<AGROW>
end
seasons_foot = unique(foot_paired.season);
for s = 1:numel(seasons_foot)
    sub = foot_paired(foot_paired.season == seasons_foot(s), :);
    pp  = compute_pef(sub, foot_kpis, "football");
    pp.season = repmat(seasons_foot(s), height(pp), 1);
    season_pef = [season_pef; pp]; %#ok<AGROW>
end
writetable(season_pef, fullfile(out_dir, 'pef_landscape_per_season.csv'));

% --------------------------------------------------------------------- %
% 3. Normality testing across 1-, 2-, 4-season windows
% --------------------------------------------------------------------- %
%  normality_windows(..., alpha, lilliefors_mctol) — Seventh arg is optional.
%  Default Lilliefors MC tolerance is 1e-2 (see normality_windows.m). Use NaN
%  for no Monte Carlo (fastest) or 1e-3 if you need stricter p-value control.
fprintf('\n[3/5] Normality testing across season windows...\n');

% Rugby windows
rugby_windows = build_windows(seasons_rugby);
norm_rugby = normality_windows(rugby_paired, rugby_kpis, 'season', ...
                               rugby_windows, "rugby", 0.05);

% Football windows
foot_windows = build_windows(seasons_foot);
norm_foot  = normality_windows(foot_paired, foot_kpis, 'season', ...
                               foot_windows, "football", 0.05);

normality_all = [norm_rugby; norm_foot];
writetable(normality_all, fullfile(out_dir, 'normality_results.csv'));

% Compact rollup: % normal/close/not-normal by sport-window-side
roll = rollup_normality(normality_all);
writetable(roll, fullfile(out_dir, 'normality_rollup.csv'));

% --------------------------------------------------------------------- %
% 4. Curate exemplar KPIs per quadrant + role
% --------------------------------------------------------------------- %
fprintf('\n[4/5] Curating exemplar KPIs...\n');

role_map = containers.Map();
role_map('rugby') = struct( ...
    'attacking',  {{'carries','metres_made','defenders_beaten','clean_breaks', ...
                    'offloads','passes','kicks_from_hand','kick_metres', ...
                    'rucks_won','scrums_won','lineout_throws_won','final_points'}}, ...
    'defensive',  {{'tackles','missed_tackles','turnovers_won', ...
                    'turnovers_conceded','lineout_throws_lost'}}, ...
    'discipline', {{'penalties_conceded','scrum_pens_conceded', ...
                    'lineout_pens_conceded','general_play_pens_conceded', ...
                    'free_kicks_conceded','ruck_maul_tackle_pen_con','red_cards'}});

role_map('football') = struct( ...
    'attacking',  {{'goals','np_goals','xg','np_xg','penalty_xg','shots', ...
                    'shots_inside_box','shots_outside_box','big_chances', ...
                    'corners','sp_goals','sp_xg','sp_shots','shots_on_target', ...
                    'np_shots_on_target','op_goals','op_xg','op_shots', ...
                    'goals_from_counters','xg_from_counters','passes', ...
                    'successful_passes','op_passes','successful_op_passes', ...
                    'passes_inside_box','passes_into_box','op_passes_into_box', ...
                    'passes_into_final_third','op_passes_into_final_third', ...
                    'passes_in_final_third','deep_completions','long_balls', ...
                    'crosses','dribbles','carries','carries_into_final_third', ...
                    'carries_into_box','progressive_carries', ...
                    'deep_progressions','box_entries','obv','on_ball_obv', ...
                    'obv_from_passes','obv_from_carries', ...
                    'obv_from_dribbles','obv_from_dribble_carry'}}, ...
    'defensive',  {{'tackles','successful_tackles','ball_recoveries', ...
                    'regains','regains_opposition_half', ...
                    'tackle_interceptions_opposition_half','blocks', ...
                    'pressures','pressures_opposition_half','counterpressures', ...
                    'counterpressures_opposition_half','defensive_obv'}}, ...
    'discipline', {{'yellow_cards','second_yellow_cards','red_cards','fouls'}});

exemplars = curate_exemplars(pef_landscape, role_map, 3);
writetable(exemplars, fullfile(out_dir, 'pef_exemplars.csv'));

% --------------------------------------------------------------------- %
% 5. Figures
% --------------------------------------------------------------------- %
fprintf('\n[5/5] Generating figures...\n');
fig1 = plot_pef_landscape(pef_landscape, fullfile(out_dir, 'pef_landscape.png'));
fig2 = plot_normality_summary(normality_all, fullfile(out_dir, 'normality_summary.png'));

% --------------------------------------------------------------------- %
% Console summary
% --------------------------------------------------------------------- %
fprintf('\n--- Summary ---------------------------------------------\n');
print_summary(pef_landscape, normality_all, exemplars);
fprintf('---------------------------------------------------------\n');
fprintf('Done. CSVs and figures saved in:\n   %s\n', out_dir);


% --------------------------------------------------------------------- %
% Local helpers
% --------------------------------------------------------------------- %
function windows = build_windows(season_list)
    % Returns the cell-of-cells of season tags representing:
    %   - each season alone   (4 windows)
    %   - the first half pool  (seasons 1+2)
    %   - the second half pool (seasons 3+4)
    %   - the full 4-season pool
    season_list = sort(unique(string(season_list)));
    windows = cell(1, numel(season_list) + 3);
    for s = 1:numel(season_list)
        windows{s} = {season_list(s)};
    end
    if numel(season_list) >= 4
        windows{numel(season_list)+1} = {season_list(1), season_list(2)};
        windows{numel(season_list)+2} = {season_list(3), season_list(4)};
        windows{numel(season_list)+3} = cellstr(season_list)';
    else
        windows = windows(1:numel(season_list));
    end
end


function t = tabulate_quadrants(pef_tbl)
    quads = ["Q1","Q2","Q3","Q4","boundary","degenerate"];
    counts = zeros(numel(quads),1);
    mean_eta = nan(numel(quads),1);
    for q = 1:numel(quads)
        mask = pef_tbl.quadrant == quads(q);
        counts(q)   = sum(mask);
        if counts(q) > 0
            mean_eta(q) = mean(pef_tbl.eta(mask), 'omitnan');
        end
    end
    t = table(quads(:), counts, mean_eta, ...
              'VariableNames', {'Quadrant','N_KPIs','Mean_eta'});
end


function r = rollup_normality(norm_tbl)
    G = findgroups(norm_tbl.sport, norm_tbl.side, norm_tbl.window_n_seasons);
    rows = {};
    [keys_s, keys_sd, keys_w] = deal( ...
        splitapply(@(x) x(1), norm_tbl.sport, G), ...
        splitapply(@(x) x(1), norm_tbl.side,  G), ...
        splitapply(@(x) x(1), norm_tbl.window_n_seasons, G));
    for g = 1:max(G)
        v = norm_tbl.verdict(G == g);
        n = numel(v);
        n_norm  = sum(v == "Normal");
        n_close = sum(v == "Close");
        n_not   = sum(v == "NotNormal");
        rows(end+1, :) = { ...
            keys_s(g), keys_sd(g), keys_w(g), n, ...
            n_norm,  100*n_norm/n,  ...
            n_close, 100*n_close/n, ...
            n_not,   100*n_not/n}; %#ok<AGROW>
    end
    r = cell2table(rows, 'VariableNames', { ...
        'sport','side','window_n_seasons','n_tests', ...
        'n_normal','pct_normal','n_close','pct_close','n_notnormal','pct_notnormal'});
    r = sortrows(r, {'sport','side','window_n_seasons'});
end


function print_summary(pef_tbl, norm_tbl, exemplars)
    sports = unique(pef_tbl.sport);
    fprintf('\nPEF landscape (4-season pooled):\n');
    for s = 1:numel(sports)
        sub = pef_tbl(pef_tbl.sport == sports(s) & ~isnan(pef_tbl.eta), :);
        fprintf('  %s : N_KPIs=%d | mean(eta)=%.3f | %% with eta>1 = %.1f%%\n', ...
            sports(s), height(sub), mean(sub.eta), 100*mean(sub.eta>1));
        for q = ["Q1","Q2","Q3","Q4"]
            n_q = sum(sub.quadrant == q);
            if n_q == 0, continue; end
            mu_eta = mean(sub.eta(sub.quadrant == q));
            fprintf('     %s: n=%2d, mean(eta)=%.3f\n', q, n_q, mu_eta);
        end
    end

    fprintf('\nNormality verdict by sport / side / window size (%% normal):\n');
    sides = ["home","away","diff"];
    wins  = sort(unique(norm_tbl.window_n_seasons));
    for s = 1:numel(sports)
        for sd = 1:numel(sides)
            row_str = sprintf('  %-8s %-4s ', sports(s), sides(sd));
            for w = 1:numel(wins)
                mask = norm_tbl.sport == sports(s) & ...
                       norm_tbl.side  == sides(sd) & ...
                       norm_tbl.window_n_seasons == wins(w);
                v = norm_tbl.verdict(mask);
                if isempty(v)
                    row_str = [row_str sprintf(' n=0     ')]; %#ok<AGROW>
                else
                    pct = 100 * mean(v == "Normal" | v == "Close");
                    row_str = [row_str sprintf(' w=%d:%4.1f%% ', wins(w), pct)]; %#ok<AGROW>
                end
            end
            fprintf('%s\n', row_str);
        end
    end

    fprintf('\nTop quadrant exemplars (best |eta-1| per sport, quadrant):\n');
    for s = 1:numel(sports)
        sub = exemplars(exemplars.sport == sports(s) & ...
                        startsWith(exemplars.criterion,'quadrant:') & ...
                        exemplars.rank_in_group == 1, :);
        for r = 1:height(sub)
            fprintf('  %s %s: %-30s  kappa=%.2f rho=%+.2f eta=%.3f (n=%d)\n', ...
                sub.sport(r), sub.quadrant(r), sub.kpi(r), ...
                sub.kappa(r), sub.rho(r), sub.eta(r), sub.n(r));
        end
    end
end
