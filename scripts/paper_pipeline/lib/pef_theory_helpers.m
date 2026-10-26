function H = pef_theory_helpers()
%PEF_THEORY_HELPERS  Function handles for idealised probit simulation.
%
%   H = pef_theory_helpers() returns handles to theory-aligned helpers:
%     eta_pef, var_diff, mi_exact, mi_bound, mi_closed, corr_ax,
%     bayes_acc_x, bayes_acc_A, classify_quadrant,
%     sample_bvn_ab, sample_y_a2, cv_logistic_sim, is_admissible
%
%   mi_exact is I(X;Y) under the probit model (A1)--(A2).
%   mi_bound is the Jensen lower bound H(Y) - h(P_e) under that model.
%   mi_closed is the former equal-prior discriminant expression. It is not
%   I(X;Y) under (A1)--(A2) and is retained only for comparison.
%
%   Used by run_pef_idealised_probit_sim.m and run_pef_finalize_diagnostics.m.

    H = struct( ...
        'eta_pef',                @eta_pef, ...
        'eta_pef_vec',            @eta_pef_vec, ...
        'var_diff',               @var_diff, ...
        'mi_exact',               @mi_exact, ...
        'mi_exact_grid',          @mi_exact_grid, ...
        'mi_bound',               @mi_bound, ...
        'mi_closed',              @mi_closed, ...
        'corr_ax',                @corr_ax, ...
        'd_rel',                  @d_rel, ...
        'bayes_acc_x',            @bayes_acc_x, ...
        'bayes_acc_A',            @bayes_acc_A, ...
        'classify_quadrant',      @classify_quadrant, ...
        'delta_sigma_from_means', @delta_sigma_from_means, ...
        'grad_I',                 @grad_I, ...
        'grad_eta',               @grad_eta, ...
        'bootstrap_pef_table',    @bootstrap_pef_table, ...
        'sample_bvn_ab',          @sample_bvn_ab, ...
        'sample_y_a2',            @sample_y_a2, ...
        'cv_logistic_sim',        @cv_logistic_sim, ...
        'is_admissible',          @is_admissible);
end

% -------------------------------------------------------------------------
function adm = is_admissible(kappa, rho)
    adm = (1 + kappa - 2 * sqrt(kappa) * rho) > 0;
end

% -------------------------------------------------------------------------
function eta = eta_pef(kappa, rho)
    denom = 1 + kappa - 2 * sqrt(kappa) * rho;
    if denom <= 0
        eta = NaN;
    else
        eta = (1 + kappa) / denom;
    end
end

% -------------------------------------------------------------------------
% Vectorised companion to eta_pef. Operates element-wise on arrays/columns;
% callers handle admissibility/NaN propagation (no scalar guard).
function eta = eta_pef_vec(K, R)
    eta = (1 + K) ./ (1 + K - 2 * sqrt(K) .* R);
end

% -------------------------------------------------------------------------
function v = var_diff(kappa, rho, sigmaA)
    if nargin < 3 || isempty(sigmaA)
        sigmaA = 1;
    end
    v = sigmaA^2 * (1 + kappa - 2 * sqrt(kappa) * rho);
end

% -------------------------------------------------------------------------
function d = d_rel(kappa, rho, delta, sigmaA)
    % Standardised mean of X under (A1): |E[X]| / sqrt(Var(X)).
    if nargin < 4 || isempty(sigmaA)
        sigmaA = 1;
    end
    v = var_diff(kappa, rho, sigmaA);
    if ~is_admissible(kappa, rho) || ~(v > 0) || ~isfinite(delta)
        d = NaN;
    else
        d = abs(delta) / sqrt(v);
    end
end

% -------------------------------------------------------------------------
function r = corr_ax(kappa, rho)
    % r_AX = Corr(X_A, X_A - X_B) under (A1). Algebraic in (kappa, rho).
    den = 1 + kappa - 2 * sqrt(kappa) * rho;
    if ~(den > 0) || ~isfinite(kappa) || ~isfinite(rho) || kappa <= 0
        r = NaN;
        return
    end
    r = (1 - rho * sqrt(kappa)) / sqrt(den);
    r = max(min(r, 1), -1);
end

% -------------------------------------------------------------------------
function Ixy = mi_exact(kappa, rho, delta, sigmaA)
    % Mutual information I(X;Y) in bits under the probit model (A1)--(A2).
    % X ~ N(delta, Var(X)), Y|X=x ~ Bernoulli(Phi(x/sqrt(Var(X)))).
    % Depends on the parameters only through d_rel.
    if nargin < 4 || isempty(sigmaA)
        sigmaA = 1;
    end
    d = d_rel(kappa, rho, delta, sigmaA);
    if ~isfinite(d)
        Ixy = NaN;
        return
    end
    Ixy = mi_from_drel_scalar(d);
end

% -------------------------------------------------------------------------
function I_xy = mi_exact_grid(K, R, delta, sigmaA)
    % Vectorised I(X;Y) on a (kappa, rho) mesh at fixed delta, sigmaA.
    % Uses a cached quadrature table in d_rel (the information depends on
    % nothing else). Inadmissible cells are NaN.
    if nargin < 4 || isempty(sigmaA)
        sigmaA = 1;
    end
    den = 1 + K - 2 .* sqrt(K) .* R;
    bad = ~isfinite(den) | den <= 0 | ~isfinite(K) | K <= 0 | ~isfinite(R);
    d = abs(delta) ./ (sigmaA .* sqrt(den));
    d(bad) = NaN;
    I_xy = mi_lookup(d);
    I_xy(bad) = NaN;
end

% -------------------------------------------------------------------------
function Ilo = mi_bound(kappa, rho, delta, sigmaA)
    % Jensen lower bound under (A1)--(A2): I(X;Y) >= H(Y) - h(P_e).
    % Binary entropy is concave on [0, 1/2], and H(Y|X) = E[h(min(p,1-p))].
    if nargin < 4 || isempty(sigmaA)
        sigmaA = 1;
    end
    d = d_rel(kappa, rho, delta, sigmaA);
    if ~isfinite(d)
        Ilo = NaN;
        return
    end
    pY = min(max(normcdf(d / sqrt(2)), 1e-12), 1 - 1e-12);
    HY = binary_entropy_bits(pY);
    accR = integral(@(u) normcdf(abs(d + u)) .* normpdf(u), -10, 10, ...
        'AbsTol', 1e-8, 'RelTol', 1e-6);
    Pe = min(max(1 - accR, 1e-12), 0.5);
    Ilo = max(HY - binary_entropy_bits(Pe), 0);
end

% -------------------------------------------------------------------------
function Ixy = mi_closed(kappa, rho, delta, sigmaA)
    % Former discriminant expression 1 - h(Phi(|d_rel|/2)).
    % Not I(X;Y) under the probit model (A1)--(A2). Retained for comparison
    % with earlier drafts. Reported information uses mi_exact.
    if nargin < 4 || isempty(sigmaA)
        sigmaA = 1;
    end
    d = d_rel(kappa, rho, delta, sigmaA);
    if ~isfinite(d)
        Ixy = NaN;
        return
    end
    sep = normcdf(d / 2);
    sep = min(max(sep, 1e-12), 1 - 1e-12);
    Ixy = 1 - binary_entropy_bits(sep);
end

% -------------------------------------------------------------------------
function Ixy = mi_from_drel_scalar(d)
    d = abs(d);
    pY = min(max(normcdf(d / sqrt(2)), 1e-12), 1 - 1e-12);
    HY = binary_entropy_bits(pY);
    HYX = integral(@(u) binary_entropy_bits(normcdf(d + u)) .* normpdf(u), ...
        -10, 10, 'AbsTol', 1e-8, 'RelTol', 1e-6);
    Ixy = max(HY - HYX, 0);
end

% -------------------------------------------------------------------------
function I = mi_lookup(d)
    persistent dGrid IGrid
    if isempty(dGrid)
        dGrid = linspace(0, 8, 401).';
        IGrid = zeros(size(dGrid));
        for i = 1:numel(dGrid)
            IGrid(i) = mi_from_drel_scalar(dGrid(i));
        end
    end
    I = nan(size(d));
    ok = isfinite(d);
    I(ok) = interp1(dGrid, IGrid, min(max(abs(d(ok)), 0), dGrid(end)), 'pchip');
end

% -------------------------------------------------------------------------
function acc = bayes_acc_x(delta, varX)
    % Bayes accuracy of the sign rule for X under the probit model (A2).
    % acc_R = E[Phi(|d_rel + U|)], U ~ N(0,1). Matches SI Validation 4.
    if ~(varX > 0) || ~isfinite(delta)
        acc = NaN;
        return
    end
    d = abs(delta) / sqrt(varX);
    acc = integral(@(u) normcdf(abs(d + u)) .* normpdf(u), -10, 10, ...
        'AbsTol', 1e-8, 'RelTol', 1e-6);
end

% -------------------------------------------------------------------------
function acc = bayes_acc_A(delta, kappa, rho, sigmaA)
    % Equal-prior Bayes accuracy of the absolute feature X_A under (A1)--(A2).
    % Matches SI Validation 4: acc_A(d_rel, r) with d_rel = |delta|/sqrt(Var(X)).
    if nargin < 4 || isempty(sigmaA)
        sigmaA = 1;
    end
    if ~is_admissible(kappa, rho) || ~(sigmaA > 0) || ~isfinite(delta)
        acc = NaN;
        return
    end
    vX = var_diff(kappa, rho, sigmaA);
    if ~(vX > 0)
        acc = NaN;
        return
    end
    d_rel = abs(delta) / sqrt(vX);
    r = (1 - rho * sqrt(kappa)) / sqrt(1 + kappa - 2 * sqrt(kappa) * rho);
    r = max(min(r, 1 - 1e-12), -1 + 1e-12);
    denom = sqrt(max(2 - r^2, 1e-12));
    phi = @(w) exp(-0.5 * w.^2) / sqrt(2 * pi);
    Phi = @(z) 0.5 * erfc(-z / sqrt(2));
    acc = integral(@(w) phi(w) .* Phi(abs(d_rel + r .* w) ./ denom), ...
        -8, 8, 'AbsTol', 1e-8);
end

% -------------------------------------------------------------------------
function q = classify_quadrant(kappa, rho)
    if isnan(kappa) || isnan(rho)
        q = "NA";
    elseif kappa > 1 && rho > 0
        q = "Q1";
    elseif kappa < 1 && rho > 0
        q = "Q2";
    elseif kappa < 1 && rho < 0
        q = "Q3";
    elseif kappa > 1 && rho < 0
        q = "Q4";
    else
        q = "boundary";
    end
end

% -------------------------------------------------------------------------
function [delta, sigmaA, deltaRatio] = delta_sigma_from_means(muH, muA, varH)
    delta = muH - muA;
    if varH > 0
        sigmaA = sqrt(varH);
    else
        sigmaA = NaN;
    end
    if sigmaA > 0 && isfinite(sigmaA)
        deltaRatio = delta / sigmaA;
    else
        deltaRatio = NaN;
    end
end

% -------------------------------------------------------------------------
function g = grad_I(kappa, rho, delta, sigmaA, epsStep)
    if nargin < 5 || isempty(epsStep)
        epsStep = 1e-4;
    end
    if nargin < 4 || isempty(sigmaA)
        sigmaA = 1;
    end
    I0 = mi_exact(kappa, rho, delta, sigmaA);
    Ir = mi_exact(kappa, rho + epsStep, delta, sigmaA);
    Ik = mi_exact(kappa + epsStep, rho, delta, sigmaA);
    g = [(Ir - I0) / epsStep; (Ik - I0) / epsStep];
end

% -------------------------------------------------------------------------
function g = grad_eta(kappa, rho, epsStep)
    if nargin < 3 || isempty(epsStep)
        epsStep = 1e-4;
    end
    e0 = eta_pef(kappa, rho);
    er = eta_pef(kappa, rho + epsStep);
    ek = eta_pef(kappa + epsStep, rho);
    g = [(er - e0) / epsStep; (ek - e0) / epsStep];
end

% -------------------------------------------------------------------------
function boot = bootstrap_pef_table(paired, kpiName, nBoot)
    kpiName = char(string(kpiName));
    ch = [kpiName '_home'];
    ca = [kpiName '_away'];
    if ~ismember(ch, paired.Properties.VariableNames)
        error('bootstrap_pef_table:missingcol', 'Column %s not found.', ch);
    end
    A = paired.(ch);
    B = paired.(ca);
    ok = ~isnan(A) & ~isnan(B);
    A = A(ok);
    B = B(ok);
    n = numel(A);
    if n < 8
        boot = struct('n', n, 'eta_ci', [NaN NaN NaN], 'I_ci', [NaN NaN NaN], ...
            'kappa_ci', [NaN NaN NaN], 'rho_ci', [NaN NaN NaN]);
        return
    end

    use_team_boot = ismember('home_team', paired.Properties.VariableNames);
    if use_team_boot
        ht = string(paired.home_team(ok));
        teams = unique(ht, 'stable');
        n_teams = numel(teams);
    end

    eta_s = nan(nBoot, 1);
    I_s   = nan(nBoot, 1);
    k_s   = nan(nBoot, 1);
    r_s   = nan(nBoot, 1);

    for b = 1:nBoot
        if use_team_boot
            draw = teams(randi(n_teams, n_teams, 1));
            idx = [];
            for t = 1:n_teams
                idx = [idx; find(ht == draw(t))]; %#ok<AGROW>
            end
            if numel(idx) < 8
                continue
            end
            Ab = A(idx);
            Bb = B(idx);
        else
            idx = randi(n, n, 1);
            Ab = A(idx);
            Bb = B(idx);
        end
        vA = var(Ab, 0);
        vB = var(Bb, 0);
        if vA <= 0 || vB <= 0
            continue
        end
        mA = mean(Ab);
        mB = mean(Bb);
        kappa = vB / vA;
        rmat = corrcoef(Ab, Bb);
        rho = rmat(1, 2);
        [delta, sigmaA, ~] = delta_sigma_from_means(mA, mB, vA);
        eta_s(b) = eta_pef(kappa, rho);
        % Do not plug the home--away gap into I(X;Y). That gap is not
        % the predictive separation. Reported information is the probit
        % integral at a stated d_rel, not a bootstrap of this mean.
        I_s(b)   = NaN;
        k_s(b)   = kappa;
        r_s(b)   = rho;
    end

    pct = @(x) [prctile(x, 2.5), prctile(x, 50), prctile(x, 97.5)];
    boot = struct( ...
        'n', n, ...
        'eta_ci', pct(eta_s), ...
        'I_ci', pct(I_s), ...
        'kappa_ci', pct(k_s), ...
        'rho_ci', pct(r_s));
end

% -------------------------------------------------------------------------
function [A, B] = sample_bvn_ab(kappa, rho, delta, sigmaA, n)
    if nargin < 4 || isempty(sigmaA)
        sigmaA = 1;
    end
    mu    = [delta / 2; -delta / 2];
    Sigma = [sigmaA^2, sigmaA^2 * rho * sqrt(kappa); ...
             sigmaA^2 * rho * sqrt(kappa), sigmaA^2 * kappa];
    AB = mvnrnd(mu, Sigma, n);
    A  = AB(:, 1);
    B  = AB(:, 2);
end

% -------------------------------------------------------------------------
function Y = sample_y_a2(X, varX)
    p = normcdf(X ./ sqrt(varX));
    p = min(max(p, 1e-12), 1 - 1e-12);
    Y = double(rand(size(X)) < p);
end

% -------------------------------------------------------------------------
function [acc, auc] = cv_logistic_sim(X, y, k)
    n = size(X, 1);
    if size(X, 2) == 1
        X = X(:);
    end
    idx   = mod(randperm(n) - 1, k) + 1;
    preds = zeros(n, 1);
    for f = 1:k
        tr = idx ~= f;
        te = idx == f;
        if sum(tr) < 10 || numel(unique(y(tr))) < 2
            preds(te) = mean(y(tr));
        else
            w1 = warning('off', 'stats:glmfit:PerfectSeparation');
            w2 = warning('off', 'stats:glmfit:IterationLimit');
            try
                b = glmfit(X(tr, :), y(tr), 'binomial', 'link', 'logit');
                preds(te) = glmval(b, X(te, :), 'logit');
            catch
                preds(te) = mean(y(tr));
            end
            warning(w1);
            warning(w2);
        end
    end
    acc = mean((preds >= 0.5) == y);
    [~, ord] = sort(preds, 'descend');
    tp = cumsum(y(ord)) / sum(y);
    fp = cumsum(~y(ord)) / sum(~y);
    if numel(unique(fp)) < 2
        auc = 0.5;
    else
        auc = trapz(fp, tp);
    end
end

% -------------------------------------------------------------------------
function Hbits = binary_entropy_bits(p)
    p = min(max(p, 0), 1);
    Hbits = zeros(size(p));
    mid = p > 0 & p < 1;
    pm = p(mid);
    Hbits(mid) = -(pm .* log2(pm) + (1 - pm) .* log2(1 - pm));
end
