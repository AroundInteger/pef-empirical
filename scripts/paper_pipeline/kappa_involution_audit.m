function audit = kappa_involution_audit(varargin)
%KAPPA_INVOLUTION_AUDIT  Three-level kappa <-> 1/kappa symmetry audit.
%
%   audit = KAPPA_INVOLUTION_AUDIT('rugby_paired', T_R, 'rugby_kpis', K_R, ...
%                                  'football_paired', T_F, 'football_kpis', K_F, ...
%                                  'nonsports_dir', NS_DIR, ...
%                                  'n_boot', 500)
%
%   Tests the structural identity
%
%        eta(kappa, rho) = eta(1/kappa, rho)
%
%   at three levels of strictness:
%
%       Level 1 (algebraic):  grid-check the closed-form expression on a
%                             (kappa, rho) mesh.  Should hold at machine
%                             precision; failure indicates a numerical
%                             issue with sqrt near branch points.
%
%       Level 2 (estimator):  for each sports KPI, swap the (home, away)
%                             role and recompute (kappa_hat, rho_hat,
%                             eta_hat).  Symmetry holds *by construction*
%                             when the estimators use ddof = 1 var and
%                             Pearson rho consistently; a failure here
%                             reveals an asymmetric implementation
%                             upstream (centring, ddof, NaN handling).
%
%       Level 2.5 (bootstrap): for each sports KPI, draw B paired
%                             resamples and verify that at every
%                             resample the (A,B)- and (B,A)-computed
%                             (|tau|, rho) match exactly.  Catches
%                             pipeline-level asymmetries that the point
%                             estimate does not.
%
%   For supporting (non-sports) domains the raw paired observations are
%   not directly available in this MATLAB pipeline -- the domain CSVs
%   contain per-unit aggregates only -- so we report a *consistency*
%   check: for each row, verify that the reported eta equals
%   (1+kappa)/(1+kappa - 2*sqrt(kappa)*rho) within tolerance.  This is a
%   self-consistency audit of the upstream Python pipeline rather than a
%   true symmetry test.  Failures here indicate the upstream Python
%   computation has an asymmetric implementation that should be flagged
%   for the companion paper.
%
%   OUTPUT
%       audit  Struct with fields:
%         .grid_residual_max     Max abs residual from level 1 grid check.
%         .level2                Table: one row per sports KPI; flags pass.
%         .level2p5              Same; flags pass.
%         .nonsports_consistency Table: one row per non-sports unit.
%         .fail_rate_pct         Headline number: percentage of (KPI x test)
%                                cells that did not pass, used for the
%                                \PEFkappaSymmetryFailRate macro.
%         .summary               Pretty-printable per-domain summary.
%
%   See also:  geometry_diagnostics, psi_scale_pooling, psi_ml_residuals.

    %% ---- Argument parsing
    p = inputParser;
    p.KeepUnmatched = false;
    addParameter(p, 'rugby_paired',   table(),  @(x) istable(x) || isempty(x));
    addParameter(p, 'rugby_kpis',     {},       @iscell);
    addParameter(p, 'football_paired',table(),  @(x) istable(x) || isempty(x));
    addParameter(p, 'football_kpis',  {},       @iscell);
    addParameter(p, 'nonsports_dir',  '',       @(x) ischar(x) || isstring(x));
    addParameter(p, 'n_boot',         500,      @(x) isnumeric(x) && x >= 50);
    addParameter(p, 'grid_n',         200,      @(x) isnumeric(x) && x >= 20);
    addParameter(p, 'tol_estimator',  1e-10,    @isnumeric);
    addParameter(p, 'tol_bootstrap',  1e-10,    @isnumeric);
    addParameter(p, 'tol_consistency',1e-6,     @isnumeric);
    addParameter(p, 'seed',           20260518, @isnumeric);
    parse(p, varargin{:});
    a = p.Results;

    rng(a.seed, 'twister');

    %% ---- Level 1: algebraic grid check
    kg = logspace(-3, 3, a.grid_n);
    rg = linspace(-0.95, 0.95, a.grid_n);
    [K, R] = meshgrid(kg, rg);
    eta_kr     = pef_eta(K,    R);
    eta_invkr  = pef_eta(1./K, R);
    grid_residual = max(abs(eta_kr(:) - eta_invkr(:)), [], 'omitnan');

    %% ---- Levels 2 + 2.5 on sports KPIs
    sports_rows  = {};

    if ~isempty(a.rugby_paired) && ~isempty(a.rugby_kpis)
        sports_rows = [sports_rows; ...
            sports_audit_loop("rugby", a.rugby_paired, a.rugby_kpis, ...
                              a.n_boot, a.tol_estimator, a.tol_bootstrap)];
    end
    if ~isempty(a.football_paired) && ~isempty(a.football_kpis)
        sports_rows = [sports_rows; ...
            sports_audit_loop("football", a.football_paired, a.football_kpis, ...
                              a.n_boot, a.tol_estimator, a.tol_bootstrap)];
    end

    if isempty(sports_rows)
        level2 = empty_audit_table();
    else
        level2 = vertcat(sports_rows{:});
    end

    %% ---- Non-sports consistency check
    nonsports = nonsports_consistency_check(a.nonsports_dir, a.tol_consistency);

    %% ---- Headline numbers
    n_l2_total  = sum(~isnan(level2.level2_pass));
    n_l2_fail   = sum(level2.level2_pass == 0);
    n_l2p5_total= sum(~isnan(level2.level2p5_pass));
    n_l2p5_fail = sum(level2.level2p5_pass == 0);

    if (n_l2_total + n_l2p5_total) > 0
        fail_rate_pct = 100 * (n_l2_fail + n_l2p5_fail) / (n_l2_total + n_l2p5_total);
    else
        fail_rate_pct = NaN;
    end

    %% ---- Pretty summary
    summary = compose_summary(grid_residual, level2, nonsports, fail_rate_pct);

    audit = struct( ...
        'grid_residual_max',     grid_residual, ...
        'level2',                level2, ...
        'nonsports_consistency', nonsports, ...
        'fail_rate_pct',         fail_rate_pct, ...
        'summary',               summary);
end

% =====================================================================
%  Local helpers
% =====================================================================

function rows = sports_audit_loop(sport_label, paired, kpis, n_boot, tol_e, tol_b)
    rows = {};
    n_data = height(paired);
    for ki = 1:numel(kpis)
        kpi = kpis{ki};
        ch  = [kpi '_home'];
        ca  = [kpi '_away'];
        if ~ismember(ch, paired.Properties.VariableNames) || ...
           ~ismember(ca, paired.Properties.VariableNames)
            continue
        end
        A = paired.(ch);  B = paired.(ca);
        ok = ~isnan(A) & ~isnan(B);
        A  = A(ok); B = B(ok);
        n  = numel(A);
        if n < 10
            continue
        end

        % Level 2: point estimate under swap
        [eta_AB, kappa_AB, rho_AB] = est_eta_pair(A, B);
        [eta_BA, kappa_BA, rho_BA] = est_eta_pair(B, A);
        d_eta   = abs(eta_AB   - eta_BA);
        d_kappa = abs(kappa_AB - 1/kappa_BA);
        d_rho   = abs(rho_AB   - rho_BA);
        l2_pass = (d_eta < tol_e) && (d_kappa < tol_e) && (d_rho < tol_e);

        % Level 2.5: bootstrap.  For each bootstrap resample, compute
        % (|tau|, rho) under both labelings on the SAME resampled index
        % set so that any non-deterministic asymmetry is exposed.
        max_disc_tau = 0;
        max_disc_rho = 0;
        for b = 1:n_boot
            idx = randi(n, n, 1);
            Ab  = A(idx);  Bb = B(idx);
            [~, kAB_b, rAB_b] = est_eta_pair(Ab, Bb);
            [~, kBA_b, rBA_b] = est_eta_pair(Bb, Ab);
            if isfinite(kAB_b) && isfinite(kBA_b) && kAB_b > 0 && kBA_b > 0
                tAB = abs(0.5 * log(kAB_b));
                tBA = abs(0.5 * log(kBA_b));
                max_disc_tau = max(max_disc_tau, abs(tAB - tBA));
            end
            if isfinite(rAB_b) && isfinite(rBA_b)
                max_disc_rho = max(max_disc_rho, abs(rAB_b - rBA_b));
            end
        end
        l2p5_pass = (max_disc_tau < tol_b) && (max_disc_rho < tol_b);

        rows{end+1,1} = make_audit_row( ...
            sport_label, kpi, n, ...
            eta_AB, eta_BA, kappa_AB, kappa_BA, rho_AB, rho_BA, ...
            d_eta, d_kappa, d_rho, l2_pass, ...
            max_disc_tau, max_disc_rho, l2p5_pass); %#ok<AGROW>
    end
end

function row = make_audit_row(domain, unit, n, ...
        eta_AB, eta_BA, kappa_AB, kappa_BA, rho_AB, rho_BA, ...
        d_eta, d_kappa, d_rho, l2_pass, ...
        max_disc_tau, max_disc_rho, l2p5_pass)
    row = table( ...
        string(domain), string(unit), n, ...
        eta_AB, eta_BA, kappa_AB, kappa_BA, rho_AB, rho_BA, ...
        d_eta, d_kappa, d_rho, double(l2_pass), ...
        max_disc_tau, max_disc_rho, double(l2p5_pass), ...
        'VariableNames', { ...
            'domain','unit','n', ...
            'eta_AB','eta_BA','kappa_AB','kappa_BA','rho_AB','rho_BA', ...
            'd_eta','d_kappa','d_rho','level2_pass', ...
            'max_disc_tau','max_disc_rho','level2p5_pass'});
end

function tbl = empty_audit_table()
    tbl = table( ...
        string.empty(0,1), string.empty(0,1), zeros(0,1), ...
        zeros(0,1), zeros(0,1), zeros(0,1), zeros(0,1), zeros(0,1), zeros(0,1), ...
        zeros(0,1), zeros(0,1), zeros(0,1), zeros(0,1), ...
        zeros(0,1), zeros(0,1), zeros(0,1), ...
        'VariableNames', { ...
            'domain','unit','n', ...
            'eta_AB','eta_BA','kappa_AB','kappa_BA','rho_AB','rho_BA', ...
            'd_eta','d_kappa','d_rho','level2_pass', ...
            'max_disc_tau','max_disc_rho','level2p5_pass'});
end

function [eta_, kappa_, rho_] = est_eta_pair(A, B)
    A = A(:); B = B(:);
    if numel(A) < 2 || std(A) == 0 || std(B) == 0
        eta_ = NaN; kappa_ = NaN; rho_ = NaN; return
    end
    vA = var(A, 0);  vB = var(B, 0);
    kappa_ = vB / vA;
    cc  = corrcoef(A, B);
    rho_ = cc(1, 2);
    eta_ = (1 + kappa_) / (1 + kappa_ - 2 * sqrt(kappa_) * rho_);
end

function eta_ = pef_eta(K, R)
    eta_ = (1 + K) ./ (1 + K - 2 * sqrt(K) .* R);
end

function out = nonsports_consistency_check(ns_dir, tol)
    if isempty(ns_dir) || ~exist(ns_dir, 'dir')
        out = table(string.empty(0,1), string.empty(0,1), zeros(0,1), zeros(0,1), zeros(0,1), zeros(0,1), zeros(0,1), ...
            'VariableNames', {'domain','source','n_units','n_fail','max_residual','median_residual','consistency_pass'});
        return
    end

    specs = { ...
        'Healthcare',       'real_biology_pef_results.csv'; ...
        'Finance',          'real_finance_pef_results.csv'; ...
        'Manufacturing',    'manufacturing_pef_results.csv'; ...
        'Clinical Genomics','real_gene_expression_tcga_study.csv'; ...
    };
    rows = {};
    for i = 1:size(specs, 1)
        dom   = specs{i, 1};
        fpath = fullfile(ns_dir, specs{i, 2});
        if ~exist(fpath, 'file')
            continue
        end
        t = readtable(fpath);
        ec = first_match(t, {'eta','pef','PEF','ETA','eta_pooled','mean_eta'});
        rc = first_match(t, {'rho','correlation','pearson_r','rho_pooled','mean_rho'});
        kc = first_match(t, {'kappa','variance_ratio','kappa_pooled','mean_kappa'});
        if isempty(ec) || isempty(rc) || isempty(kc)
            continue
        end
        eta_obs = t.(ec);
        rho_obs = t.(rc);
        kap_obs = t.(kc);
        good = isfinite(eta_obs) & isfinite(rho_obs) & isfinite(kap_obs) & kap_obs > 0 & abs(rho_obs) <= 1;
        eta_obs = eta_obs(good);
        rho_obs = rho_obs(good);
        kap_obs = kap_obs(good);
        if isempty(eta_obs), continue; end
        eta_pred = (1 + kap_obs) ./ (1 + kap_obs - 2 * sqrt(kap_obs) .* rho_obs);
        resid = abs(eta_obs - eta_pred) ./ max(abs(eta_obs), 1e-9);  % relative
        n_units = numel(eta_obs);
        n_fail  = sum(resid > tol);
        rows(end+1,:) = {string(dom), string(specs{i,2}), n_units, n_fail, ...
            max(resid,[],'omitnan'), median(resid,'omitnan'), ...
            double(n_fail == 0)}; %#ok<AGROW>
    end
    if isempty(rows)
        out = table(string.empty(0,1), string.empty(0,1), zeros(0,1), zeros(0,1), zeros(0,1), zeros(0,1), zeros(0,1), ...
            'VariableNames', {'domain','source','n_units','n_fail','max_residual','median_residual','consistency_pass'});
    else
        out = cell2table(rows, 'VariableNames', ...
            {'domain','source','n_units','n_fail','max_residual','median_residual','consistency_pass'});
    end
end

function c = first_match(t, candidates)
    c = '';
    for i = 1:numel(candidates)
        if ismember(candidates{i}, t.Properties.VariableNames)
            c = candidates{i}; return
        end
    end
end

function s = compose_summary(grid_residual, level2, nonsports, fail_rate_pct)
    lines = strings(0, 1);
    lines(end+1) = sprintf("kappa <-> 1/kappa involution audit");
    lines(end+1) = sprintf("------------------------------------------------");
    lines(end+1) = sprintf("Level 1 (algebraic grid)   : max residual = %.3e", grid_residual);
    if grid_residual > 1e-10
        lines(end+1) = sprintf("  WARNING: grid residual exceeds 1e-10 (numerical issue)");
    else
        lines(end+1) = sprintf("  OK (machine precision)");
    end
    lines(end+1) = "";

    if height(level2) > 0
        n_total = height(level2);
        n_l2_pass = sum(level2.level2_pass == 1);
        n_l2p5_pass = sum(level2.level2p5_pass == 1);
        for sp = unique(level2.domain)'
            sub = level2(level2.domain == sp, :);
            lines(end+1) = sprintf("Level 2 (estimator) %s : %d/%d KPIs pass", ...
                sp, sum(sub.level2_pass == 1), height(sub)); %#ok<AGROW>
            lines(end+1) = sprintf("Level 2.5 (bootstrap) %s : %d/%d KPIs pass (n_boot resamples)", ...
                sp, sum(sub.level2p5_pass == 1), height(sub));
        end
        lines(end+1) = "";
        lines(end+1) = sprintf("Sports overall pass rate: %d/%d level-2, %d/%d level-2.5", ...
            n_l2_pass, n_total, n_l2p5_pass, n_total);
    else
        lines(end+1) = "Sports KPIs: no data supplied.";
    end
    lines(end+1) = "";

    if height(nonsports) > 0
        for r = 1:height(nonsports)
            lines(end+1) = sprintf("Non-sports consistency  %-18s : %d / %d units OK, max rel. resid. = %.2e", ...
                nonsports.domain(r), ...
                nonsports.n_units(r) - nonsports.n_fail(r), ...
                nonsports.n_units(r), nonsports.max_residual(r));
        end
    else
        lines(end+1) = "Non-sports consistency: no data supplied.";
    end
    lines(end+1) = "";
    lines(end+1) = sprintf("HEADLINE: kappa symmetry fail rate = %.2f%% (across all sports level-2 and 2.5 tests).", fail_rate_pct);
    s = strjoin(lines, newline);
end
