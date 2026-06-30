function run_pef_diagnostic(inputCsv, outputCsv)
%RUN_PEF_DIAGNOSTIC  Per-feature PEF quadrant diagnostic from paired data.
%
%   run_pef_diagnostic()
%   run_pef_diagnostic(inputCsv)
%   run_pef_diagnostic(inputCsv, outputCsv)
%
%   Implements the six-step procedure in Discussion §Practical Guidance:
%   estimate (kappa, rho), compute eta, classify quadrant, and (for all
%   quadrants) report delta/sigma_A and I(X;Y) under (A1)–(A2).
%
%   INPUT FORMATS (CSV)
%   -------------------
%   Long (preferred): one row per paired observation.
%     Required columns: feature_id, x_a, x_b
%     Optional: unit_id (ignored by estimator; for traceability only)
%
%   Wide: one row per observation; paired columns per feature.
%     Suffix pairs: *_a / *_b  OR  *_home / *_away
%     Example: passes_home, passes_away, tackles_home, tackles_away
%
%   Entity A is the reference for kappa = Var(B)/Var(A). Document which
%   entity is A when interpreting kappa (e.g. home team, patient, test arm).
%
%   OUTPUT
%   ------
%   CSV with one row per feature: n, kappa, rho, eta, quadrant,
%   delta, sigma_a, delta_sigma_a, I_bits, recommendation, admissible
%
%   Requires Statistics and Machine Learning Toolbox (readtable/writetable).
%   Theory helpers: ../paper_pipeline/lib/pef_theory_helpers.m
%
%   Example:
%     cd scripts/practitioner
%     run_pef_diagnostic('examples/pef_diagnostic_long.csv')

    THIS_DIR = fileparts(mfilename('fullpath'));
    HELPERS  = fullfile(THIS_DIR, '..', 'paper_pipeline', 'lib');
    addpath(HELPERS);
    H = pef_theory_helpers();

    if nargin < 1 || isempty(inputCsv)
        inputCsv = fullfile(THIS_DIR, 'examples', 'pef_diagnostic_long.csv');
    end
    if nargin < 2 || isempty(outputCsv)
        [p, n, e] = fileparts(inputCsv);
        outputCsv = fullfile(p, [n, '_pef_diagnostic', e]);
    end

    if ~isfile(inputCsv)
        error('run_pef_diagnostic:missingInput', 'Input file not found: %s', inputCsv);
    end

    T = readtable(inputCsv, 'VariableNamingRule', 'preserve');
    features = extract_feature_pairs(T);

    nFeat = numel(features);
    out = table( ...
        strings(nFeat, 1), zeros(nFeat, 1), zeros(nFeat, 1), zeros(nFeat, 1), ...
        zeros(nFeat, 1), strings(nFeat, 1), zeros(nFeat, 1), zeros(nFeat, 1), ...
        zeros(nFeat, 1), zeros(nFeat, 1), strings(nFeat, 1), false(nFeat, 1), ...
        'VariableNames', { ...
        'feature_id', 'n', 'kappa', 'rho', 'eta', 'quadrant', ...
        'delta', 'sigma_a', 'delta_sigma_a', 'I_bits', ...
        'recommendation', 'admissible'});

    for k = 1:nFeat
        A = features(k).a;
        B = features(k).b;
        ok = isfinite(A) & isfinite(B);
        A = A(ok);
        B = B(ok);
        nObs = numel(A);

        out.feature_id(k) = string(features(k).name);
        out.n(k) = nObs;

        if nObs < 8
            out.recommendation(k) = "Insufficient observations (n < 8)";
            continue
        end

        vA = var(A, 0);
        vB = var(B, 0);
        if vA <= 0 || vB <= 0
            out.recommendation(k) = "Zero variance in A or B";
            continue
        end

        mA = mean(A);
        mB = mean(B);
        kappa = vB / vA;
        rmat = corrcoef(A, B);
        rho = rmat(1, 2);

        adm = H.is_admissible(kappa, rho);
        eta = H.eta_pef(kappa, rho);
        q   = H.classify_quadrant(kappa, rho);
        [delta, sigmaA, deltaRatio] = H.delta_sigma_from_means(mA, mB, vA);
        Ixy = H.mi_closed(kappa, rho, delta, sigmaA);

        out.kappa(k) = kappa;
        out.rho(k) = rho;
        out.eta(k) = eta;
        out.quadrant(k) = q;
        out.delta(k) = delta;
        out.sigma_a(k) = sigmaA;
        out.delta_sigma_a(k) = deltaRatio;
        out.I_bits(k) = Ixy;
        out.admissible(k) = adm;
        out.recommendation(k) = recommendation_for_quadrant(q, eta, Ixy, adm);
    end

    writetable(out, outputCsv);
    fprintf('PEF diagnostic: %d feature(s) from %s\n', nFeat, inputCsv);
    fprintf('Wrote %s\n', outputCsv);
    disp(out);
end

% -------------------------------------------------------------------------
function features = extract_feature_pairs(T)
    vn = T.Properties.VariableNames;
    lowerVn = lower(vn);

    if ismember('feature_id', lowerVn) && ...
            (any(strcmp(lowerVn, 'x_a')) || any(strcmp(lowerVn, 'xa')))
        features = extract_long_format(T, vn, lowerVn);
        return
    end

    if ismember('feature_id', vn) && ismember('x_a', vn) && ismember('x_b', vn)
        features = extract_long_format(T, vn, lowerVn);
        return
    end

    features = extract_wide_format(T, vn);
    if isempty(features)
        error('run_pef_diagnostic:badFormat', ...
            ['Unrecognised CSV layout. Use long format (feature_id, x_a, x_b) ', ...
             'or wide format (*_a/*_b or *_home/*_away pairs).']);
    end
end

% -------------------------------------------------------------------------
function features = extract_long_format(T, vn, lowerVn)
    fidCol = vn{find(strcmp(lowerVn, 'feature_id'), 1)};
    aCol = vn{find(ismember(lowerVn, {'x_a', 'xa'}), 1, 'first')};
    bCol = vn{find(ismember(lowerVn, {'x_b', 'xb'}), 1, 'first')};

    fids = unique(string(T.(fidCol)));
    features = struct('name', {}, 'a', {}, 'b', {});
    for i = 1:numel(fids)
        mask = string(T.(fidCol)) == fids(i);
        features(end + 1) = struct( ... %#ok<AGROW>
            'name', char(fids(i)), ...
            'a', T.(aCol)(mask), ...
            'b', T.(bCol)(mask));
    end
end

% -------------------------------------------------------------------------
function features = extract_wide_format(T, vn)
    features = struct('name', {}, 'a', {}, 'b', {});
    used = false(size(vn));

    for i = 1:numel(vn)
        if used(i)
            continue
        end
        [base, side] = split_pair_suffix(vn{i});
        if isempty(side)
            continue
        end
        other = pair_column_name(base, side, vn);
        if isempty(other)
            continue
        end
        j = find(strcmp(vn, other), 1);
        if side == "a"
            aCol = vn{i};
            bCol = vn{j};
        else
            aCol = vn{j};
            bCol = vn{i};
        end
        features(end + 1) = struct( ... %#ok<AGROW>
            'name', char(base), ...
            'a', T.(aCol), ...
            'b', T.(bCol));
        used(i) = true;
        used(j) = true;
    end
end

% -------------------------------------------------------------------------
function [base, side] = split_pair_suffix(col)
    base = "";
    side = "";
    col = char(col);
    for suf = {'_home', '_away', '_a', '_b'}
        s = suf{1};
        if endsWith(col, s)
            base = string(col(1:end - numel(s)));
            if any(strcmp(s, {'_home', '_a'}))
                side = "a";
            else
                side = "b";
            end
            return
        end
    end
end

% -------------------------------------------------------------------------
function other = pair_column_name(base, side, vn)
    if side == "a"
        candidates = [char(base) + "_b", char(base) + "_away"];
    else
        candidates = [char(base) + "_a", char(base) + "_home"];
    end
    other = '';
    for c = 1:numel(candidates)
        if any(strcmp(vn, candidates(c)))
            other = candidates(c);
            return
        end
    end
end

% -------------------------------------------------------------------------
function msg = recommendation_for_quadrant(q, eta, Ixy, adm)
    if ~adm
        msg = "Inadmissible (1 + kappa - 2*sqrt(kappa)*rho <= 0); check data or scaling";
        return
    end
    switch char(q)
        case 'Q1'
            msg = "Quadrant 1: prefer relative features (eta > 1, kappa > 1, rho > 0)";
        case 'Q2'
            msg = "Quadrant 2: prefer relative features (eta > 1, kappa < 1, rho > 0)";
        case 'Q3'
            msg = "Quadrant 3: prefer absolute features (eta <= 1, kappa < 1, rho < 0)";
        case 'Q4'
            msg = sprintf( ...
                "Quadrant 4: eta = %.3f < 1; assess I(X;Y) = %.3f bits before relativising", ...
                eta, Ixy);
        case 'boundary'
            msg = "On quadrant boundary (rho = 0 or kappa = 1); inspect eta and I(X;Y)";
        otherwise
            msg = "Could not classify quadrant";
    end
end
