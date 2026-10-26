function ex = select_confirmatory_exemplars(pef_tbl, margin)
%SELECT_CONFIRMATORY_EXEMPLARS  One KPI per quadrant, pre-specified rule.
%
%   Within each quadrant, keep KPIs with |log(kappa)| > margin (default
%   log(1.05), so kappa is outside [1/1.05, 1.05]). Among those, choose
%   the KPI whose |d_Y| is closest to the median |d_Y| of the eligible
%   set. Walk Q1 to Q4 and skip a candidate whose name contains, or is
%   contained in, an already chosen KPI name (long_balls versus
%   goalkeeper_long_balls). If a quadrant has no eligible KPI, relax the
%   margin to log(1.02), then to 0, and record the margin actually used.

    if nargin < 2 || isempty(margin)
        margin = log(1.05);
    end
    quads = ["Q1","Q2","Q3","Q4"];
    chosen = strings(0, 1);
    rows = cell(4, 1);
    for q = 1:numel(quads)
        [row, used] = pick_one(pef_tbl, quads(q), margin, chosen);
        if isempty(row)
            [row, used] = pick_one(pef_tbl, quads(q), log(1.02), chosen);
        end
        if isempty(row)
            [row, used] = pick_one(pef_tbl, quads(q), 0, chosen);
        end
        if isempty(row)
            error('select_confirmatory_exemplars:empty', ...
                'No KPI in %s.', quads(q));
        end
        row.margin_used = used;
        row.quadrant_target = quads(q);
        chosen(end+1, 1) = string(row.kpi); %#ok<AGROW>
        rows{q} = row;
    end
    ex = vertcat(rows{:});
end

function [row, used] = pick_one(t, quad, margin, chosen)
    row = table();
    used = margin;
    sub = t(t.quadrant == quad & isfinite(t.d_Y) & isfinite(t.kappa) & t.kappa > 0, :);
    if isempty(sub)
        return
    end
    sub = sub(abs(log(sub.kappa)) > margin, :);
    if isempty(sub)
        return
    end
    med = median(abs(sub.d_Y), 'omitnan');
    sub.dist_med = abs(abs(sub.d_Y) - med);
    sub = sortrows(sub, 'dist_med', 'ascend');
    for i = 1:height(sub)
        name = string(sub.kpi(i));
        if overlaps_chosen(name, chosen)
            continue
        end
        row = sub(i, :);
        return
    end
end

function tf = overlaps_chosen(name, chosen)
    tf = false;
    name = lower(string(name));
    for i = 1:numel(chosen)
        other = lower(string(chosen(i)));
        if contains(name, other) || contains(other, name)
            tf = true;
            return
        end
    end
end
