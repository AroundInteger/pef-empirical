function H = pef_theory_helpers()
%PEF_THEORY_HELPERS  Function handles for idealised probit simulation.
%
%   H = pef_theory_helpers() returns handles to theory-aligned helpers:
%     eta_pef, var_diff, mi_closed, bayes_acc_x, classify_quadrant,
%     sample_bvn_ab, sample_y_a2, cv_logistic_sim, is_admissible
%
%   Used by run_pef_idealised_probit_sim.m and run_pef_finalize_diagnostics.m.

    H = struct( ...
        'eta_pef',                @eta_pef, ...
        'eta_pef_vec',            @eta_pef_vec, ...
        'var_diff',               @var_diff, ...
        'mi_closed',              @mi_closed, ...
        'bayes_acc_x',            @bayes_acc_x, ...
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
function Ixy = mi_closed(kappa, rho, delta, sigmaA)
    if nargin < 4 || isempty(sigmaA)
        sigmaA = 1;
    end
    eta  = eta_pef(kappa, rho);
    if isnan(eta) || eta <= 0
        Ixy = NaN;
        return
    end
    sep = normcdf(delta ./ (2 * sigmaA * sqrt((1 + kappa) ./ eta)));
    sep = min(max(sep, 1e-12), 1 - 1e-12);
    Ixy = 1 - binary_entropy_bits(sep);
end

% -------------------------------------------------------------------------
function acc = bayes_acc_x(delta, varX)
    acc = 1 - normcdf(-delta ./ (2 * sqrt(varX)));
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
    I0 = mi_closed(kappa, rho, delta, sigmaA);
    Ir = mi_closed(kappa, rho + epsStep, delta, sigmaA);
    Ik = mi_closed(kappa + epsStep, rho, delta, sigmaA);
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

    eta_s = nan(nBoot, 1);
    I_s   = nan(nBoot, 1);
    k_s   = nan(nBoot, 1);
    r_s   = nan(nBoot, 1);

    for b = 1:nBoot
        idx = randi(n, n, 1);
        Ab = A(idx);
        Bb = B(idx);
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
        I_s(b)   = mi_closed(kappa, rho, delta, sigmaA);
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
    Hbits = -(p .* log2(p) + (1 - p) .* log2(1 - p));
end
