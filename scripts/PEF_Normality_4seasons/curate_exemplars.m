function exemplars = curate_exemplars(pef_tbl, sport_kpi_role_map, top_n)
%CURATE_EXEMPLARS  Pick representative KPIs across the four PEF quadrants.
%
%   exemplars = CURATE_EXEMPLARS(pef_tbl, sport_kpi_role_map, top_n)
%
%   Selects up to `top_n` KPIs per (sport, quadrant) and per
%   (sport, role={'attacking','defensive','discipline'}). Ranking
%   criterion within a quadrant is the magnitude of |eta - 1|, which
%   emphasises KPIs that exhibit the strongest pairing effect (in either
%   direction) -- these are the most useful illustrative examples.
%
%   INPUTS
%       pef_tbl              Table from compute_pef (stacked across sports).
%       sport_kpi_role_map   containers.Map: keys = sport names,
%                            values = struct with .attacking, .defensive,
%                            .discipline cell arrays of KPI base names.
%       top_n                Maximum number of exemplars per category.
%
%   OUTPUTS
%       exemplars  Table with columns:
%                    sport, kpi, role, quadrant, kappa, rho, eta, n,
%                    abs_dev_eta_1, rank_in_group, criterion

    if nargin < 3 || isempty(top_n), top_n = 3; end

    t = pef_tbl;

    % --- Attach role labels.
    role = strings(height(t),1);
    role(:) = "unclassified";
    for s_idx = 1:length(sport_kpi_role_map.keys)
        keys_ = sport_kpi_role_map.keys;
        sname = keys_{s_idx};
        rs    = sport_kpi_role_map(sname);
        is_sport = t.sport == sname;
        % Attacking
        if isfield(rs, 'attacking')
            for kk = 1:numel(rs.attacking)
                role(is_sport & t.kpi == string(rs.attacking{kk})) = "attacking";
            end
        end
        % Defensive
        if isfield(rs, 'defensive')
            for kk = 1:numel(rs.defensive)
                role(is_sport & t.kpi == string(rs.defensive{kk})) = "defensive";
            end
        end
        % Discipline
        if isfield(rs, 'discipline')
            for kk = 1:numel(rs.discipline)
                role(is_sport & t.kpi == string(rs.discipline{kk})) = "discipline";
            end
        end
    end
    t.role = role;
    t.abs_dev_eta_1 = abs(t.eta - 1);

    % --- Per-quadrant exemplars (any role).
    quads = ["Q1","Q2","Q3","Q4"];
    out_quad = table();
    sports = unique(t.sport);
    for s = 1:numel(sports)
        for q = 1:numel(quads)
            sub = t(t.sport == sports(s) & t.quadrant == quads(q) & ~isnan(t.eta), :);
            if isempty(sub), continue; end
            sub = sortrows(sub, 'abs_dev_eta_1', 'descend');
            keep = min(top_n, height(sub));
            sub  = sub(1:keep, :);
            sub.rank_in_group = (1:keep)';
            sub.criterion = repmat("quadrant:" + quads(q), keep, 1);
            out_quad = [out_quad; sub]; %#ok<AGROW>
        end
    end

    % --- Per-role exemplars (best |eta-1| within each role and sport).
    roles = ["attacking","defensive","discipline"];
    out_role = table();
    for s = 1:numel(sports)
        for r = 1:numel(roles)
            sub = t(t.sport == sports(s) & t.role == roles(r) & ~isnan(t.eta), :);
            if isempty(sub), continue; end
            sub = sortrows(sub, 'abs_dev_eta_1', 'descend');
            keep = min(top_n, height(sub));
            sub  = sub(1:keep, :);
            sub.rank_in_group = (1:keep)';
            sub.criterion = repmat("role:" + roles(r), keep, 1);
            out_role = [out_role; sub]; %#ok<AGROW>
        end
    end

    exemplars = [out_quad; out_role];

    % Trim columns to a useful subset.
    keep_cols = {'sport','kpi','role','quadrant','kappa','rho','eta','n', ...
                 'abs_dev_eta_1','rank_in_group','criterion'};
    keep_cols = intersect(keep_cols, exemplars.Properties.VariableNames, 'stable');
    exemplars = exemplars(:, keep_cols);
end
