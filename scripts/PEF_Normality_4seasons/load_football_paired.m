function [paired, kpi_names] = load_football_paired(csv_dir, season_files)
%LOAD_FOOTBALL_PAIRED  Read 4 Championship CSVs and pivot to wide paired form.
%
%   [paired, kpi_names] = LOAD_FOOTBALL_PAIRED(csv_dir, season_files)
%
%   The football CSVs are in long form (two rows per match: one Home, one
%   Away). This function concatenates the 4 season files, drops obvious
%   metadata columns, identifies the numeric KPI columns automatically,
%   and returns a wide table where each KPI yields two columns suffixed
%   _home and _away, one row per match.
%
%   INPUTS
%       csv_dir       Directory containing the season CSVs.
%       season_files  Cell array of file names (in chronological order).
%
%   OUTPUTS
%       paired        Wide table with columns:
%                       season, match_id, home_team, away_team,
%                       {kpi}_home, {kpi}_away
%       kpi_names     Cell array of base KPI names.
%
%   Notes
%       - The function infers a uniform schema by taking the intersection
%         of numeric columns across all season files.
%       - Match-level identifier columns are stripped from the KPI set.

    metadata_cols = { ...
        'match_id','competition_country_name','competition_name', ...
        'season_name','home_team_id','away_team_id','match_date', ...
        'team_id','team_name','opposition_team_id','opposition_team_name', ...
        'home_away','result','wins','draws','losses','matches_played','points'};
    % `points` is removed because it is a league-table outcome, not a
    % match KPI -- it is a function of `result` (3/1/0).

    all_tables = cell(numel(season_files),1);
    numeric_cols_per_file = cell(numel(season_files),1);

    for s = 1:numel(season_files)
        fp = fullfile(csv_dir, season_files{s});
        opts = detectImportOptions(fp, 'TextType', 'string');
        % Force common identifier-like columns to string so they don't
        % accidentally get parsed as numeric.
        for v = {'season_name','team_name','opposition_team_name','home_away','result','match_date'}
            if ismember(v{1}, opts.VariableNames)
                opts = setvartype(opts, v{1}, 'string');
            end
        end
        tbl = readtable(fp, opts);

        % Normalise the home/away tag.
        if ismember('home_away', tbl.Properties.VariableNames)
            tbl.home_away = lower(strtrim(tbl.home_away));
        end

        all_tables{s} = tbl;

        % Identify numeric KPI columns in this file.
        vn = tbl.Properties.VariableNames;
        numeric_cols_per_file{s} = vn( varfun(@isnumeric, tbl, 'OutputFormat','uniform') );
    end

    % Intersection of numeric KPI columns across all seasons, minus
    % obvious metadata columns.
    common_numeric = numeric_cols_per_file{1};
    for s = 2:numel(numeric_cols_per_file)
        common_numeric = intersect(common_numeric, numeric_cols_per_file{s}, 'stable');
    end
    common_numeric = setdiff(common_numeric, metadata_cols, 'stable');

    kpi_cols  = common_numeric;
    kpi_names = kpi_cols;   % football column names already in base form

    % Concatenate all season tables, keeping only the columns we need.
    % Include 'result' so home_win can be derived during pairing.
    keep_cols = [{'season_name','match_id','team_name','opposition_team_name', ...
                  'home_away','result'} kpi_cols];

    parts = cell(numel(all_tables),1);
    for s = 1:numel(all_tables)
        tbl = all_tables{s};
        present = intersect(keep_cols, tbl.Properties.VariableNames, 'stable');
        parts{s} = tbl(:, present);
    end
    raw = vertcat(parts{:});

    % Pivot to wide.
    matchids = unique(raw.match_id);
    n_match  = numel(matchids);

    season_col    = strings(n_match,1);
    home_team     = strings(n_match,1);
    away_team     = strings(n_match,1);
    home_win_arr  = nan(n_match,1);
    keep          = true(n_match,1);

    has_result = ismember('result', raw.Properties.VariableNames);

    home_vals = nan(n_match, numel(kpi_cols));
    away_vals = nan(n_match, numel(kpi_cols));

    for i = 1:n_match
        mid  = matchids(i);
        rows = raw(raw.match_id == mid, :);
        home = rows(rows.home_away == "home", :);
        away = rows(rows.home_away == "away", :);
        if height(home) ~= 1 || height(away) ~= 1
            keep(i) = false;
            continue
        end
        season_col(i) = home.season_name(1);
        home_team(i)  = home.team_name(1);
        away_team(i)  = away.team_name(1);
        if has_result
            r = lower(strtrim(string(home.result(1))));
            % Accept both abbreviated ("w") and full word ("win") forms.
            home_win_arr(i) = double(r == "w" | r == "win");
        end
        for k = 1:numel(kpi_cols)
            home_vals(i,k) = home.(kpi_cols{k})(1);
            away_vals(i,k) = away.(kpi_cols{k})(1);
        end
    end

    if any(~keep)
        warning('load_football_paired:dropped', ...
                'Dropped %d match_ids without exactly one home + one away row.', ...
                sum(~keep));
    end

    season_col   = season_col(keep);
    home_team    = home_team(keep);
    away_team    = away_team(keep);
    home_win_arr = home_win_arr(keep);
    matchids     = matchids(keep);
    home_vals    = home_vals(keep, :);
    away_vals    = away_vals(keep, :);

    paired = table(season_col, matchids, home_team, away_team, home_win_arr, ...
                   'VariableNames', {'season','match_id','home_team','away_team','home_win'});
    for k = 1:numel(kpi_cols)
        paired.([kpi_names{k} '_home']) = home_vals(:,k);
        paired.([kpi_names{k} '_away']) = away_vals(:,k);
    end
end
