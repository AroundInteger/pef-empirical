%EXPORT_MATCHES  Paired primary-season matches for the PEF numerics Phase 6.
%
% Uses the existing loaders. Does not reimplement pairing. Seasons are
% 23/24 and 24/25. Outcome-adjacent KPIs are dropped inside the loaders.
% Draws are coded as not a home win.

this_dir = fileparts(mfilename('fullpath'));
repo = fileparts(fileparts(fileparts(this_dir)));
addpath(fullfile(repo, 'scripts', 'PEF_Normality_4seasons'));

out_dir = fullfile(this_dir, '..', 'data');
if ~exist(out_dir, 'dir'), mkdir(out_dir); end

rugby_csv = fullfile(repo, 'Data', 'Rugby', 'Raw', '4_seasons rugby abs.csv');
foot_dir = fullfile(repo, 'Data', 'Football', 'Raw', 'team_summaries_4seasons');
foot_files = {'championship_team_23_24.csv', 'championship_team_24_25.csv'};

[rugby, rugby_kpis] = load_rugby_paired(rugby_csv);
keep = ismember(string(rugby.season), ["23/24", "24/25"]);
rugby = rugby(keep, :);
opts = detectImportOptions(rugby_csv, 'TextType', 'string');
raw = readtable(rugby_csv, opts);
raw.match_location = lower(strtrim(raw.match_location));
raw.outcome = lower(strtrim(string(raw.outcome)));
home_rows = raw(raw.match_location == "home", {'matchid', 'outcome'});
home_rows.home_win = double(home_rows.outcome == "win");
outcomes = home_rows(:, {'matchid', 'home_win'});
rugby = outerjoin(rugby, outcomes, 'Keys', 'matchid', 'MergeKeys', true, 'Type', 'left');

[foot, foot_kpis] = load_football_paired(foot_dir, foot_files);

rugby_long = to_long(rugby, rugby_kpis, "rugby", 'matchid');
foot_long = to_long(foot, foot_kpis, "football", 'match_id');
long = [rugby_long; foot_long];
out_file = fullfile(out_dir, 'matches_long.csv');
writetable(long, out_file);
fprintf('Wrote %d rows to %s\n', height(long), out_file);

function long = to_long(paired, kpi_names, sport, id_col)
    n = height(paired);
    k = numel(kpi_names);
    sport_c = repmat(sport, n * k, 1);
    season = repelem(string(paired.season), k, 1);
    match_id = repelem(paired.(id_col), k, 1);
    home_team = repelem(string(paired.home_team), k, 1);
    away_team = repelem(string(paired.away_team), k, 1);
    home_win = repelem(paired.home_win, k, 1);
    kpi = strings(n * k, 1);
    home_value = nan(n * k, 1);
    away_value = nan(n * k, 1);
    for j = 1:k
        name = string(kpi_names{j});
        rows = j:k:(n * k);
        kpi(rows) = name;
        home_value(rows) = paired.(char(name + "_home"));
        away_value(rows) = paired.(char(name + "_away"));
    end
    long = table(sport_c, season, match_id, home_team, away_team, kpi, ...
        home_value, away_value, home_win, ...
        'VariableNames', {'sport', 'season', 'match_id', 'home_team', 'away_team', ...
        'kpi', 'home_value', 'away_value', 'home_win'});
end
