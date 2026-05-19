function out = normality_windows(paired, kpi_names, season_col, windows, sport_label, alpha, lilliefors_mctol)
%NORMALITY_WINDOWS  Test KPI normality across user-specified season windows.
%
%   out = NORMALITY_WINDOWS(paired, kpi_names, season_col, windows, sport_label, alpha)
%   out = NORMALITY_WINDOWS(..., alpha, lilliefors_mctol)
%
%   For each KPI and each season window, runs Shapiro-Wilk (swtest) and
%   Lilliefors (lillietest) on the home margin, the away margin, and the
%   home-away difference. Returns one row per (kpi, side, window) triple
%   with the test statistics, p-values, reject flags at alpha, and the
%   skewness/kurtosis of the series.
%
%   INPUTS
%       paired       Wide paired table (output of load_*_paired).
%       kpi_names    Cell array of base KPI names.
%       season_col   Name of the season column in `paired` ('season').
%       windows      Cell array of cell arrays. Each entry is a list of
%                    season tag strings to pool together. E.g.
%                       { {"21/22"}, {"22/23"}, {"23/24"}, {"24/25"}, ...
%                         {"21/22","22/23"}, {"23/24","24/25"}, ...
%                         {"21/22","22/23","23/24","24/25"} }
%       sport_label  String tag stored on each row.
%       alpha        Significance level (default 0.05).
%       lilliefors_mctol  Optional. Monte Carlo tolerance for LILLIETEST p-values.
%                    Smaller values increase accuracy but cost far more CPU because
%                    each call simulates until SE(p) < tolerance. Across all
%                    (windows x KPIs x {home,away,diff}) tests, 1e-3 is often the
%                    dominant cost of [3/5]. Defaults to 1e-2; use NaN to omit
%                    MCTol (fastest, MATLAB table/interpolation only); use 1e-3
%                    only when you need stricter p-value MC control.
%
%   OUTPUTS
%       out  Table with columns:
%             sport, kpi, side, window_label, window_n_seasons, n,
%             skewness, kurtosis,
%             sw_W, sw_p, sw_reject,
%             lill_KS, lill_p, lill_reject,
%             verdict   - 'Normal' (both p>=alpha), 'Close' (both p>=0.01),
%                         'NotNormal' otherwise
%
%   Notes
%       Shapiro-Wilk uses the Royston (1992) extension valid for
%       4 <= n <= 5000. Lilliefors is MATLAB's built-in (KS variant with
%       estimated parameters).

    if nargin < 6 || isempty(alpha), alpha = 0.05; end
    if nargin < 7 || isempty(lilliefors_mctol), lilliefors_mctol = 1e-2; end

    rows = {};
    seasons_all = paired.(season_col);

    for w = 1:numel(windows)
        win = windows{w};
        win = string(win);
        mask = ismember(seasons_all, win);
        sub  = paired(mask, :);
        win_label = join(win, "+");
        for k = 1:numel(kpi_names)
            kpi = kpi_names{k};
            ch = [kpi '_home']; ca = [kpi '_away'];
            if ~ismember(ch, sub.Properties.VariableNames) || ...
               ~ismember(ca, sub.Properties.VariableNames)
                continue
            end
            A = sub.(ch); B = sub.(ca);
            ok = ~isnan(A) & ~isnan(B);
            A = A(ok); B = B(ok); D = A - B;

            for side_idx = 1:3
                switch side_idx
                    case 1, side = "home"; x = A;
                    case 2, side = "away"; x = B;
                    case 3, side = "diff"; x = D;
                end
                [sw_W, sw_p, sw_reject] = safe_swtest(x, alpha);
                [lill_KS, lill_p, lill_reject] = safe_lillietest(x, alpha, lilliefors_mctol);
                if numel(x) >= 4
                    sk = skewness(x);
                    ku = kurtosis(x);
                else
                    sk = NaN; ku = NaN;
                end
                v = verdict_from_pvalues(sw_p, lill_p, alpha);
                rows(end+1, :) = { ...
                    string(sport_label), string(kpi), side, win_label, ...
                    numel(win), numel(x), sk, ku, ...
                    sw_W, sw_p, sw_reject, lill_KS, lill_p, lill_reject, ...
                    v}; %#ok<AGROW>
            end
        end
    end

    out = cell2table(rows, 'VariableNames', { ...
        'sport','kpi','side','window_label','window_n_seasons','n', ...
        'skewness','kurtosis', ...
        'sw_W','sw_p','sw_reject', ...
        'lill_KS','lill_p','lill_reject', ...
        'verdict'});
end


function [W, p, h] = safe_swtest(x, alpha)
    W = NaN; p = NaN; h = NaN;
    x = x(~isnan(x));
    if numel(x) < 4 || numel(x) > 5000 || std(x) == 0
        return
    end
    try
        [h, p, W] = swtest(x, alpha);
    catch ME
        warning('safe_swtest:fail', 'swtest failed: %s', ME.message);
    end
end


function [KS, p, h] = safe_lillietest(x, alpha, lilliefors_mctol)
    KS = NaN; p = NaN; h = NaN;
    if nargin < 3 || isempty(lilliefors_mctol)
        lilliefors_mctol = 1e-2;
    end
    x = x(~isnan(x));
    if numel(x) < 4 || std(x) == 0
        return
    end
    try
        % MCTol drives run-time: many bootstrap draws until SE(p) < tolerance.
        % Pass NaN for lilliefors_mctol to skip MC and use tables (much faster).
        if isnumeric(lilliefors_mctol) && isscalar(lilliefors_mctol) && isnan(lilliefors_mctol)
            [h, p, KS] = lillietest(x, 'Alpha', alpha);
        else
            [h, p, KS] = lillietest(x, 'Alpha', alpha, 'MCTol', lilliefors_mctol);
        end
    catch
        try
            [h, p, KS] = lillietest(x, 'Alpha', alpha);
        catch ME
            warning('safe_lillietest:fail', 'lillietest failed: %s', ME.message);
        end
    end
end


function v = verdict_from_pvalues(p_sw, p_lill, alpha)
    % "Normal"     -- both tests fail to reject at alpha
    % "Close"      -- both p-values > 0.01 (i.e. not extremely far from normal)
    % "NotNormal"  -- otherwise
    if isnan(p_sw) && isnan(p_lill)
        v = "NA"; return
    end
    ps = [p_sw, p_lill];
    ps = ps(~isnan(ps));
    if all(ps >= alpha)
        v = "Normal";
    elseif all(ps >= 0.01)
        v = "Close";
    else
        v = "NotNormal";
    end
end
