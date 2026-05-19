function [paired, kpi_names] = load_rugby_paired(csv_path)
%LOAD_RUGBY_PAIRED  Read rugby URC 4-season CSV and pivot to wide paired form.
%
%   [paired, kpi_names] = LOAD_RUGBY_PAIRED(csv_path)
%
%   The raw rugby CSV is in long form (two rows per match: one home, one
%   away). This function returns a wide table where each KPI yields two
%   columns suffixed _home and _away, one row per match.
%
%   INPUTS
%       csv_path  Absolute path to the rugby CSV. Default columns expected:
%                 season, matchid, team, match_location, final_points_a,
%                 outcome, plus KPI columns ending in '_a'.
%
%   OUTPUTS
%       paired    Wide table with columns:
%                   season, matchid, home_team, away_team,
%                   {kpi}_home, {kpi}_away for each numeric KPI
%       kpi_names Cell array of base KPI names (suffixes stripped).
%
%   Notes
%       - Matches without exactly one home and one away row are dropped
%         (with a warning printed listing the offending match_ids).
%       - All KPI columns are coerced to double; non-numeric entries
%         become NaN.

    opts = detectImportOptions(csv_path, 'TextType', 'string');
    % Force matchid and string columns to be read robustly
    opts = setvartype(opts, {'season','team','match_location','outcome'}, 'string');
    raw  = readtable(csv_path, opts);

    % Normalise the match_location values
    raw.match_location = lower(strtrim(raw.match_location));

    % Identify KPI columns: anything ending with '_a' EXCEPT the outcome.
    vn = raw.Properties.VariableNames;
    is_kpi = endsWith(vn, '_a');
    % final_points_a is technically a margin but treat it as a KPI too -
    % it sits naturally alongside the others in PEF terms.
    kpi_cols = vn(is_kpi);

    % Strip the '_a' suffix to form base KPI names.
    kpi_names = regexprep(kpi_cols, '_a$', '');

    % Coerce KPI columns to double, replacing junk with NaN.
    for k = 1:numel(kpi_cols)
        col = raw.(kpi_cols{k});
        if ~isnumeric(col)
            col = str2double(string(col));
        end
        raw.(kpi_cols{k}) = double(col);
    end

    % Identify match_ids with exactly one home and one away row.
    matchids = unique(raw.matchid);
    n_match  = numel(matchids);

    % Pre-allocate the wide table.
    home_team  = strings(n_match,1);
    away_team  = strings(n_match,1);
    season_col = strings(n_match,1);
    keep       = true(n_match,1);

    home_vals = nan(n_match, numel(kpi_cols));
    away_vals = nan(n_match, numel(kpi_cols));

    for i = 1:n_match
        mid   = matchids(i);
        rows  = raw(raw.matchid == mid, :);
        home  = rows(rows.match_location == "home", :);
        away  = rows(rows.match_location == "away", :);
        if height(home) ~= 1 || height(away) ~= 1
            keep(i) = false;
            continue
        end
        season_col(i) = home.season(1);
        home_team(i)  = home.team(1);
        away_team(i)  = away.team(1);
        for k = 1:numel(kpi_cols)
            home_vals(i,k) = home.(kpi_cols{k})(1);
            away_vals(i,k) = away.(kpi_cols{k})(1);
        end
    end

    if any(~keep)
        warning('load_rugby_paired:dropped', ...
                'Dropped %d match_ids without exactly one home + one away row.', ...
                sum(~keep));
    end

    season_col = season_col(keep);
    home_team  = home_team(keep);
    away_team  = away_team(keep);
    matchids   = matchids(keep);
    home_vals  = home_vals(keep, :);
    away_vals  = away_vals(keep, :);

    % Assemble the wide table.
    paired = table(season_col, matchids, home_team, away_team, ...
                   'VariableNames', {'season','matchid','home_team','away_team'});
    for k = 1:numel(kpi_cols)
        paired.([kpi_names{k} '_home']) = home_vals(:,k);
        paired.([kpi_names{k} '_away']) = away_vals(:,k);
    end
end
