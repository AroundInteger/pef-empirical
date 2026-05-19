function res = psi_ml_residuals(varargin)
%PSI_ML_RESIDUALS  psi-stratified residual diagnostic for the PEF-to-ML map.
%
%   res = PSI_ML_RESIDUALS('ml_all', ML, 'fig_path', PATH)
%
%   Inputs
%       ml_all   Table with at minimum the columns
%                {kappa, rho, eta, acc_improvement} -- the output of the
%                run_paper_pipeline.m ML validation step joined onto the
%                per-KPI PEF parameters.
%       fig_path Output path for the two-panel Figure_3b diagnostic.
%
%   The PEF-to-ML polynomial mapping (eq:dml_poly in the manuscript) is
%
%        Delta_ML(eta) = 0.234 (eta - 1) + 0.089 (eta - 1)^2.
%
%   This script computes residuals
%        r_i = acc_improvement_i - Delta_ML(eta_i)
%   and asks: are residuals systematically organised along the Fisher--Rao
%   coordinate psi?  If yes, the polynomial mapping is mis-specified along
%   the psi direction -- which is paper-relevant because it disambiguates
%   three otherwise-confounded failure modes:
%
%     (a) Departure from bivariate normality (would show as a residual
%         pattern along |tau| more than psi).
%     (b) Suboptimal ML classifier (would show as a residual offset
%         independent of psi).
%     (c) Multivariate -> univariate projection (would show as a residual
%         trend along sign(rho), i.e. the regime change at psi = 0).
%
%   Outputs
%       res  Struct with fields:
%         .augmented      ml_all augmented with psi, residual columns.
%         .summary        Table: psi band -> mean residual, count.
%         .slope          Slope of residual ~ psi (OLS).
%         .slope_p        Two-sided p-value for the slope.
%         .corr_eta       Pearson r(eta, acc_improvement) -- as currently
%                         reported in tab:pef_ml.
%         .corr_psi       Pearson r(psi, acc_improvement) -- the
%                         psi-scale headline candidate.
%         .corr_abspsi    Pearson r(|psi|, acc_improvement) -- the
%                         severity-only candidate.
%         .signed_split   Struct .rho_pos and .rho_neg with corr_psi within
%                         each regime.  Tests the regime-change prediction
%                         at rho = 0.
%
%   See also:  geometry_diagnostics, psi_scale_pooling.

    %% ---- Argument parsing
    p = inputParser;
    addParameter(p, 'ml_all',     table(), @istable);
    addParameter(p, 'fig_path',   '',      @(x) ischar(x) || isstring(x));
    addParameter(p, 'n_bands',    5,       @isnumeric);
    parse(p, varargin{:});
    a = p.Results;

    ml = a.ml_all;
    required = {'kappa','rho','eta','acc_improvement'};
    if isempty(ml) || any(~ismember(required, ml.Properties.VariableNames))
        warning('psi_ml_residuals:missingcols', ...
            'ml_all is missing one of {kappa, rho, eta, acc_improvement}; returning empty.');
        res = empty_result();
        return
    end

    %% ---- Augment with geometry
    ml = geometry_diagnostics(ml);
    delta_ml_pred = 0.234 * (ml.eta - 1) + 0.089 * (ml.eta - 1).^2;
    ml.delta_ml_pred = delta_ml_pred;
    ml.residual = ml.acc_improvement - 100 * delta_ml_pred;
    % NOTE: acc_improvement is a percentage (100 * acc_rel-acc_abs) while
    % the polynomial coefficients in eq:dml_poly produce a proportion.
    % Multiplying the prediction by 100 puts both on the percentage scale,
    % consistent with how Figure 3 is currently rendered.

    valid = isfinite(ml.residual) & isfinite(ml.psi) & isfinite(ml.eta);

    %% ---- Band summary
    psi_v   = ml.psi(valid);
    res_v   = ml.residual(valid);
    rho_v   = ml.rho(valid);
    eta_v   = ml.eta(valid);
    impr_v  = ml.acc_improvement(valid);
    abspsi_v = abs(psi_v);

    if numel(psi_v) >= a.n_bands
        edges = quantile(psi_v, linspace(0, 1, a.n_bands + 1));
        edges(1) = -Inf;  edges(end) = Inf;
        band_id = discretize(psi_v, edges);
        band_rows = {};
        for b = 1:a.n_bands
            in_b = band_id == b;
            if any(in_b)
                band_rows(end+1,:) = {b, ...
                    sum(in_b), ...
                    median(psi_v(in_b)), ...
                    mean(res_v(in_b),  'omitnan'), ...
                    median(res_v(in_b),'omitnan'), ...
                    std(res_v(in_b),   'omitnan')}; %#ok<AGROW>
            end
        end
        summary = cell2table(band_rows, 'VariableNames', ...
            {'band','n','median_psi','mean_residual','median_residual','sd_residual'});
    else
        summary = table();
    end

    %% ---- OLS slope of residual on psi
    if sum(valid) >= 3
        X = [ones(sum(valid),1), psi_v];
        b_hat = X \ res_v;
        y_hat = X * b_hat;
        rss   = sum((res_v - y_hat).^2);
        sigma2 = rss / max(numel(res_v) - 2, 1);
        XtX_inv = inv(X' * X);
        se_slope = sqrt(sigma2 * XtX_inv(2, 2));
        t_stat = b_hat(2) / max(se_slope, 1e-12);
        % Two-sided p-value via normal approx (fine for n >= 30)
        slope_p = 2 * (1 - normcdf(abs(t_stat)));
        slope = b_hat(2);
    else
        slope = NaN; slope_p = NaN;
    end

    %% ---- Correlations on competing scales
    corr_eta    = safe_corr(eta_v,    impr_v);
    corr_psi    = safe_corr(psi_v,    impr_v);
    corr_abspsi = safe_corr(abspsi_v, impr_v);

    pos = rho_v > 0;
    neg = rho_v < 0;
    signed_split = struct( ...
        'rho_pos', struct('n', sum(pos), 'corr_psi', safe_corr(psi_v(pos), impr_v(pos)), ...
                          'corr_eta', safe_corr(eta_v(pos), impr_v(pos))), ...
        'rho_neg', struct('n', sum(neg), 'corr_psi', safe_corr(psi_v(neg), impr_v(neg)), ...
                          'corr_eta', safe_corr(eta_v(neg), impr_v(neg))));

    %% ---- Optional figure
    if ~isempty(a.fig_path)
        try
            render_figure_3b(ml(valid, :), slope, slope_p, a.fig_path);
        catch ME
            warning('psi_ml_residuals:figfail', ...
                'Figure 3b render failed: %s', ME.message);
        end
    end

    res = struct( ...
        'augmented',    ml, ...
        'summary',      summary, ...
        'slope',        slope, ...
        'slope_p',      slope_p, ...
        'corr_eta',     corr_eta, ...
        'corr_psi',     corr_psi, ...
        'corr_abspsi',  corr_abspsi, ...
        'signed_split', signed_split);
end

% =====================================================================

function r = safe_corr(x, y)
    ok = isfinite(x) & isfinite(y);
    if sum(ok) < 3 || std(x(ok)) == 0 || std(y(ok)) == 0
        r = NaN;
    else
        c = corrcoef(x(ok), y(ok));
        r = c(1, 2);
    end
end

function res = empty_result()
    res = struct( ...
        'augmented',    table(), ...
        'summary',      table(), ...
        'slope',        NaN, ...
        'slope_p',      NaN, ...
        'corr_eta',     NaN, ...
        'corr_psi',     NaN, ...
        'corr_abspsi',  NaN, ...
        'signed_split', struct('rho_pos', struct(), 'rho_neg', struct()));
end

function render_figure_3b(ml, slope, slope_p, fpath)
    fig = figure('Color','w','Position',[100 100 1100 480], 'Visible','off');

    % Panel A: residual vs eta (sanity overlay, the current figure scope)
    subplot(1, 2, 1);
    scatter(ml.eta, ml.residual, 40, ml.psi, 'filled'); hold on;
    yline(0, '--', 'Color', [0.4 0.4 0.4]);
    xlabel('\eta');
    ylabel('residual: observed - polynomial prediction (%)');
    title('(a) Residual on the \eta scale');
    cb = colorbar; cb.Label.String = '\psi';
    grid on; box on;

    % Panel B: residual vs psi (the diagnostic)
    subplot(1, 2, 2);
    scatter(ml.psi, ml.residual, 40, sign(ml.rho), 'filled'); hold on;
    psi_grid = linspace(min(ml.psi)-0.05, max(ml.psi)+0.05, 100);
    plot(psi_grid, slope * psi_grid + ...
         (mean(ml.residual) - slope * mean(ml.psi)), 'k-', 'LineWidth', 1.5);
    yline(0, '--', 'Color', [0.4 0.4 0.4]);
    xlabel('\psi   (Fisher--Rao coordinate)');
    ylabel('residual (%)');
    title(sprintf('(b) Residual on the \\psi scale (slope %.2f, p=%.3f)', slope, slope_p));
    grid on; box on;
    cb = colorbar; cb.Label.String = 'sign(\rho)'; caxis([-1 1]);

    sgtitle('Figure 3b: \psi-stratified residual diagnostic for the PEF-to-ML mapping');
    exportgraphics(fig, fpath, 'Resolution', 200);
    close(fig);
end
