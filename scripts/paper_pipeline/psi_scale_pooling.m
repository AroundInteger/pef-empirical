function pool = psi_scale_pooling(varargin)
%PSI_SCALE_POOLING  Cross-domain meta-analysis on the psi (Fisher--Rao) scale.
%
%   pool = PSI_SCALE_POOLING('pef_sports', PEF_2S, ...
%                            'nonsports_dir', NS_DIR, ...
%                            'n_boot', 2000)
%
%   For each of the six paper domains (rugby, football, healthcare,
%   clinical genomics, finance, manufacturing), this script:
%
%     1. Loads per-unit (kappa, rho, eta) values.
%     2. Computes per-unit psi via geometry_diagnostics.
%     3. Bootstraps the mean of psi (and the mean of eta) across units,
%        producing 95% bootstrap percentile intervals on both scales.
%     4. Compares psi-scale vs eta-scale cross-domain heterogeneity using
%        a coefficient-of-variation ratio
%
%             het_ratio = CV(mean_psi across domains) / CV(mean_eta across domains).
%
%        The companion paper predicts het_ratio < 1: psi-scale pooling
%        reduces the apparent heterogeneity that the eta-scale exhibits.
%
%   OUTPUT
%       pool  Struct with fields:
%         .per_domain   Table: domain, n_units, mean_psi, psi_CI_lo,
%                       psi_CI_hi, mean_eta, eta_CI_lo, eta_CI_hi,
%                       mean_abs_tau, share_rho_pos, share_rho_neg.
%         .heterogeneity Table:
%                       cv_psi, cv_eta, het_ratio, cv_psi_pos,
%                       cv_eta_pos (positive-rho subset only -- the regime
%                       where the partition-function reading is valid).
%         .regime_change Struct with summary stats by sign(rho) regime,
%                       used to motivate the 2-regime collapse claim.
%
%   See also:  geometry_diagnostics, kappa_involution_audit, psi_ml_residuals.

    %% ---- Argument parsing
    p = inputParser;
    addParameter(p, 'pef_sports',    table(), @istable);
    addParameter(p, 'nonsports_dir', '',      @(x) ischar(x) || isstring(x));
    addParameter(p, 'n_boot',        2000,    @(x) isnumeric(x) && x >= 50);
    addParameter(p, 'seed',          20260518, @isnumeric);
    parse(p, varargin{:});
    a = p.Results;

    rng(a.seed, 'twister');

    %% ---- Build the per-domain (kappa, rho, eta) tables
    %    Sports come from pef_2s (already in long format).  Non-sports are
    %    re-loaded from the original CSVs at unit granularity rather than
    %    aggregate granularity, so that bootstrap CIs are meaningful.

    domain_tables = struct();
    if ~isempty(a.pef_sports)
        for sp = ["rugby", "football"]
            sub = a.pef_sports(a.pef_sports.sport == sp, :);
            sub = sub(~isnan(sub.kappa) & ~isnan(sub.rho) & sub.kappa > 0 & abs(sub.rho) <= 1, :);
            domain_tables.(char(sp)) = sub(:, {'kappa','rho','eta'});
        end
    end
    if ~isempty(a.nonsports_dir)
        ns = load_nonsports_unit_level(a.nonsports_dir);
        f = fieldnames(ns);
        for i = 1:numel(f)
            domain_tables.(f{i}) = ns.(f{i});
        end
    end

    %% ---- Per-domain bootstrap on the psi scale
    domain_names = fieldnames(domain_tables);
    rows = {};
    for di = 1:numel(domain_names)
        dom = domain_names{di};
        T   = domain_tables.(dom);
        T   = geometry_diagnostics(T);
        valid = isfinite(T.psi) & isfinite(T.eta);
        T = T(valid, :);
        n = height(T);
        if n < 4
            rows(end+1,:) = {string(dom), n, ...
                NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN}; %#ok<AGROW>
            continue
        end
        psi_mean = mean(T.psi, 'omitnan');
        eta_mean = mean(T.eta, 'omitnan');

        % Bootstrap percentile CIs
        psi_boot = zeros(a.n_boot, 1);
        eta_boot = zeros(a.n_boot, 1);
        for b = 1:a.n_boot
            idx = randi(n, n, 1);
            psi_boot(b) = mean(T.psi(idx), 'omitnan');
            eta_boot(b) = mean(T.eta(idx), 'omitnan');
        end
        psi_lo = prctile(psi_boot, 2.5);
        psi_hi = prctile(psi_boot, 97.5);
        eta_lo = prctile(eta_boot, 2.5);
        eta_hi = prctile(eta_boot, 97.5);

        mean_abs_tau = mean(T.abs_tau, 'omitnan');
        share_pos    = mean(T.rho > 0);
        share_neg    = mean(T.rho < 0);

        rows(end+1,:) = {string(dom), n, ...
            psi_mean, psi_lo, psi_hi, ...
            eta_mean, eta_lo, eta_hi, ...
            mean_abs_tau, share_pos, share_neg}; %#ok<AGROW>
    end

    per_domain = cell2table(rows, 'VariableNames', { ...
        'domain','n_units', ...
        'mean_psi','psi_CI_lo','psi_CI_hi', ...
        'mean_eta','eta_CI_lo','eta_CI_hi', ...
        'mean_abs_tau','share_rho_pos','share_rho_neg'});

    %% ---- Cross-domain heterogeneity
    valid_rows = ~isnan(per_domain.mean_psi);
    mp_psi  = per_domain.mean_psi(valid_rows);
    mp_eta  = per_domain.mean_eta(valid_rows);

    cv_psi = std(mp_psi, 'omitnan') / max(abs(mean(mp_psi, 'omitnan')), 1e-9);
    cv_eta = std(mp_eta, 'omitnan') / max(abs(mean(mp_eta, 'omitnan')), 1e-9);
    if cv_eta > 0
        het_ratio = cv_psi / cv_eta;
    else
        het_ratio = NaN;
    end

    % Positive-rho subset: the regime where the partition-function reading
    % is mathematically valid.  We compute heterogeneity using only the
    % positive-rho units within each domain (re-bootstrapping for CIs is
    % overkill at this stage; just report the point estimate).
    rows_pos = {};
    for di = 1:numel(domain_names)
        dom = domain_names{di};
        T   = geometry_diagnostics(domain_tables.(dom));
        T   = T(T.rho > 0 & isfinite(T.psi) & isfinite(T.eta), :);
        if isempty(T), continue; end
        rows_pos(end+1,:) = {string(dom), height(T), ...
            mean(T.psi,'omitnan'), mean(T.eta,'omitnan')}; %#ok<AGROW>
    end
    if isempty(rows_pos)
        cv_psi_pos = NaN; cv_eta_pos = NaN; het_ratio_pos = NaN;
    else
        pos_tbl = cell2table(rows_pos, 'VariableNames', {'domain','n','psi','eta'});
        cv_psi_pos = std(pos_tbl.psi,'omitnan') / max(abs(mean(pos_tbl.psi,'omitnan')), 1e-9);
        cv_eta_pos = std(pos_tbl.eta,'omitnan') / max(abs(mean(pos_tbl.eta,'omitnan')), 1e-9);
        if cv_eta_pos > 0
            het_ratio_pos = cv_psi_pos / cv_eta_pos;
        else
            het_ratio_pos = NaN;
        end
    end

    heterogeneity = table(cv_psi, cv_eta, het_ratio, ...
                          cv_psi_pos, cv_eta_pos, het_ratio_pos, ...
        'VariableNames', {'cv_psi','cv_eta','het_ratio', ...
                          'cv_psi_pos','cv_eta_pos','het_ratio_pos'});

    %% ---- Regime change at rho = 0: pooled summary
    %    Pool all units across all domains and compute mean eta and mean
    %    |psi| separately for rho > 0 and rho < 0.  This is descriptive --
    %    the formal regime-change LRT is companion-paper scope.
    pooled = table();
    for di = 1:numel(domain_names)
        T = geometry_diagnostics(domain_tables.(domain_names{di}));
        T.domain = repmat(string(domain_names{di}), height(T), 1);
        pooled = [pooled; T(:, {'domain','kappa','rho','eta','psi','abs_tau'})];%#ok<AGROW>
    end
    pooled = pooled(isfinite(pooled.eta) & isfinite(pooled.psi), :);

    pos_mask = pooled.rho > 0;
    neg_mask = pooled.rho < 0;
    regime_change = struct( ...
        'n_pos',         sum(pos_mask), ...
        'n_neg',         sum(neg_mask), ...
        'mean_eta_pos',  mean(pooled.eta(pos_mask), 'omitnan'), ...
        'mean_eta_neg',  mean(pooled.eta(neg_mask), 'omitnan'), ...
        'mean_psi_pos',  mean(pooled.psi(pos_mask), 'omitnan'), ...
        'mean_abspsi_neg', mean(abs(pooled.psi(neg_mask)), 'omitnan'), ...
        'frac_eta_gt1_pos', mean(pooled.eta(pos_mask) > 1, 'omitnan'), ...
        'frac_eta_gt1_neg', mean(pooled.eta(neg_mask) > 1, 'omitnan'));

    pool = struct( ...
        'per_domain',    per_domain, ...
        'heterogeneity', heterogeneity, ...
        'regime_change', regime_change, ...
        'pooled_units',  pooled);
end

% =====================================================================
%  Local helpers
% =====================================================================

function ns = load_nonsports_unit_level(ns_dir)
    %LOAD_NONSPORTS_UNIT_LEVEL  Returns per-unit (kappa, rho, eta) tables.
    %
    %   Mirrors the column-detection logic of load_nonsports inside
    %   run_paper_pipeline.m but keeps unit granularity rather than
    %   aggregating.

    ns = struct();
    if ~exist(ns_dir, 'dir')
        return
    end
    specs = { ...
        'Healthcare',       'real_biology_pef_results.csv'; ...
        'Finance',          'real_finance_pef_results.csv'; ...
        'Manufacturing',    'manufacturing_pef_results.csv'; ...
        'ClinicalGenomics', 'real_gene_expression_tcga_study.csv'; ...
    };
    for i = 1:size(specs, 1)
        dom = specs{i, 1};
        fp  = fullfile(ns_dir, specs{i, 2});
        if ~exist(fp, 'file'), continue; end
        t   = readtable(fp);
        ec = first_match(t, {'eta','pef','PEF','ETA','eta_pooled','mean_eta'});
        rc = first_match(t, {'rho','correlation','pearson_r','rho_pooled','mean_rho'});
        kc = first_match(t, {'kappa','variance_ratio','kappa_pooled','mean_kappa'});
        if isempty(ec) || isempty(rc) || isempty(kc), continue; end
        eta   = t.(ec);
        rho   = t.(rc);
        kappa = t.(kc);
        good  = isfinite(eta) & isfinite(rho) & isfinite(kappa) & kappa > 0 & abs(rho) <= 1;
        ns.(dom) = table(kappa(good), rho(good), eta(good), ...
            'VariableNames', {'kappa','rho','eta'});
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
