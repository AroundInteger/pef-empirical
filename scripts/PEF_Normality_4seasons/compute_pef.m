function out = compute_pef(paired, kpi_names, sport_label, outcome_col)
%COMPUTE_PEF  Compute kappa, rho, eta (PEF) and quadrant per KPI.
%
%   out = COMPUTE_PEF(paired, kpi_names, sport_label)
%
%   For each KPI base name, finds the `_home` (A) and `_away` (B)
%   columns in `paired`, drops missing pairs, and computes:
%       kappa = var(B) / var(A)
%       rho   = corr(A, B)
%       eta   = (1 + kappa) / (1 + kappa - 2*sqrt(kappa)*rho)
%   along with quadrant labels per the paper's taxonomy:
%       Q1: kappa > 1, rho > 0   (high efficiency, high information)
%       Q2: kappa < 1, rho > 0   (high efficiency, moderate information)
%       Q3: kappa < 1, rho < 0   (low efficiency, low information)
%       Q4: kappa > 1, rho < 0   (low efficiency, variable information)
%
%   The signed quadrant is asymmetric in (A,B). The home team is taken
%   to be entity A throughout. Because kappa depends on the choice of
%   A vs B, `kappa_abs = max(varA,varB)/min(varA,varB)` is also reported
%   as a side-symmetric variance asymmetry summary.
%
%   INPUTS
%       paired       Wide table from load_*_paired.
%       kpi_names    Cell array of base KPI names.
%       sport_label  String tag stored on each row (e.g. "rugby").
%
%   OUTPUTS
%       out  Table with columns:
%              sport, kpi, n, var_home, var_away, mean_home, mean_away,
%              cohens_d_paired, kappa, rho, eta, kappa_abs,
%              quadrant, p_rho, sig_rho

    % Ensure shared PEF library (eta_pef, classify_quadrant, ...) is on path.
    persistent libAdded
    if isempty(libAdded)
        thisDir = fileparts(mfilename('fullpath'));
        addpath(fullfile(thisDir, '..', 'paper_pipeline', 'lib'));
        libAdded = true;
    end
    H = pef_theory_helpers();

    n_kpi = numel(kpi_names);

    sport = repmat(string(sport_label), n_kpi, 1);
    kpi   = string(kpi_names(:));
    n     = nan(n_kpi,1);

    var_home = nan(n_kpi,1); var_away = nan(n_kpi,1);
    mu_home  = nan(n_kpi,1); mu_away  = nan(n_kpi,1);
    cohens_d = nan(n_kpi,1);
    kappa    = nan(n_kpi,1);
    rho      = nan(n_kpi,1);
    eta      = nan(n_kpi,1);
    kappa_abs = nan(n_kpi,1);
    quadrant = strings(n_kpi,1);
    p_rho    = nan(n_kpi,1);

    for k = 1:n_kpi
        ch = [kpi_names{k} '_home'];
        ca = [kpi_names{k} '_away'];
        if ~ismember(ch, paired.Properties.VariableNames) || ...
           ~ismember(ca, paired.Properties.VariableNames)
            continue
        end
        A = paired.(ch);
        B = paired.(ca);
        ok = ~isnan(A) & ~isnan(B);
        A = A(ok); B = B(ok);
        n(k) = numel(A);
        if n(k) < 4
            continue
        end
        vA = var(A,0); vB = var(B,0);
        if vA <= 0 || vB <= 0
            quadrant(k) = "degenerate";
            continue
        end
        mA = mean(A); mB = mean(B);
        var_home(k) = vA; var_away(k) = vB;
        mu_home(k)  = mA; mu_away(k)  = mB;
        kappa(k)    = vB / vA;
        kappa_abs(k)= max(vA,vB) / min(vA,vB);
        [r, p]      = corrcoef(A, B);
        rho(k)      = r(1,2);
        p_rho(k)    = p(1,2);
        eta(k)      = H.eta_pef(kappa(k), rho(k));
        % Paired Cohen's d for the home-vs-away difference (using
        % variance of the difference as the standardising denominator).
        d = A - B;
        sd_d = std(d, 0);
        if sd_d > 0
            cohens_d(k) = mean(d) / sd_d;
        end
        quadrant(k) = H.classify_quadrant(kappa(k), rho(k));
    end

    sig_rho = p_rho < 0.05;

    % Descriptive home--away gap. Not the predictive signal.
    delta_home = mu_home - mu_away;
    sigma_home = sqrt(var_home);
    delta_ratio_home = delta_home ./ sigma_home;
    delta_ratio_home(~isfinite(sigma_home) | sigma_home <= 0) = NaN;

    % r_AX = Corr(X_A, X_A - X_B), algebraic in (kappa, rho).
    den = 1 + kappa - 2 .* sqrt(kappa) .* rho;
    r_ax = (1 - rho .* sqrt(kappa)) ./ sqrt(den);
    r_ax(~isfinite(den) | den <= 0) = NaN;

    % Class-conditional separation of the relative feature, if Y is present.
    d_Y = nan(n_kpi, 1);
    home_win_rate = nan(n_kpi, 1);
    use_y = nargin >= 4 && ~isempty(outcome_col) && ...
        ismember(outcome_col, paired.Properties.VariableNames);
    if use_y
        y_all = double(paired.(outcome_col));
        for k = 1:n_kpi
            ch = [kpi_names{k} '_home'];
            ca = [kpi_names{k} '_away'];
            if ~ismember(ch, paired.Properties.VariableNames)
                continue
            end
            A = paired.(ch);
            B = paired.(ca);
            ok = ~isnan(A) & ~isnan(B) & ~isnan(y_all);
            x = A(ok) - B(ok);
            y = y_all(ok);
            if numel(x) < 8 || std(x, 0) <= 0
                continue
            end
            y1 = y == 1;
            y0 = y == 0;
            if sum(y1) < 2 || sum(y0) < 2
                continue
            end
            d_Y(k) = (mean(x(y1)) - mean(x(y0))) / std(x, 0);
            home_win_rate(k) = mean(y == 1);
        end
    end

    out = table(sport, kpi, n, var_home, var_away, mu_home, mu_away, ...
                cohens_d, kappa, rho, eta, kappa_abs, quadrant, p_rho, sig_rho, ...
                delta_ratio_home, r_ax, d_Y, home_win_rate, ...
                'VariableNames', { ...
                    'sport','kpi','n','var_home','var_away','mean_home','mean_away', ...
                    'cohens_d_paired','kappa','rho','eta','kappa_abs','quadrant', ...
                    'p_rho','sig_rho','delta_ratio_home','r_ax','d_Y','home_win_rate'});
end
