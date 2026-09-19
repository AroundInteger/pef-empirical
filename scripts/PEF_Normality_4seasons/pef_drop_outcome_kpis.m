function [paired, kpi_names] = pef_drop_outcome_kpis(paired, kpi_names)
%PEF_DROP_OUTCOME_KPIS  Remove score, cards, xG, shots on target, and OBV.
%
%   These quantities are circular with Y = home_win (the score or a scoring
%   event), disciplinary sanctions, or models whose target is scoring or
%   winning. Action KPIs (passes, carries, shot volume, tackles, \ldots)
%   are retained.

    omit = outcome_adjacent_names();
    names = string(kpi_names(:));
    keep = ~ismember(lower(names), lower(string(omit)));
    dropped = names(~keep);
    kpi_names = kpi_names(keep);

    for i = 1:numel(dropped)
        stem = char(dropped(i));
        for sfx = {'_home', '_away'}
            col = [stem sfx{1}];
            if ismember(col, paired.Properties.VariableNames)
                paired.(col) = [];
            end
        end
    end

    if ~isempty(dropped)
        fprintf('pef_drop_outcome_kpis: omitted %d KPI(s): %s\n', ...
            numel(dropped), strjoin(cellstr(dropped), ', '));
    end
end

function omit = outcome_adjacent_names()
    omit = { ...
        'final_points', ...
        'goals', 'np_goals', 'op_goals', 'sp_goals', ...
        'penalty_goals', 'own_goals', 'goals_from_counters', ...
        'red_cards', 'yellow_cards', 'second_yellow_cards', ...
        'xg', 'np_xg', 'op_xg', 'sp_xg', 'penalty_xg', 'xg_from_counters', ...
        'shots_on_target', 'np_shots_on_target', ...
        'obv', 'on_ball_obv', 'defensive_obv', ...
        'obv_from_passes', 'obv_from_carries', ...
        'obv_from_dribbles', 'obv_from_dribble_carry'};
end
