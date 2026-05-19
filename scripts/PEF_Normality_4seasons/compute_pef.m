function out = compute_pef(paired, kpi_names, sport_label)
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
        eta(k)      = (1 + kappa(k)) / (1 + kappa(k) - 2*sqrt(kappa(k))*rho(k));
        % Paired Cohen's d for the home-vs-away difference (using
        % variance of the difference as the standardising denominator).
        d = A - B;
        sd_d = std(d, 0);
        if sd_d > 0
            cohens_d(k) = mean(d) / sd_d;
        end
        quadrant(k) = classify_quadrant(kappa(k), rho(k));
    end

    sig_rho = p_rho < 0.05;

    out = table(sport, kpi, n, var_home, var_away, mu_home, mu_away, ...
                cohens_d, kappa, rho, eta, kappa_abs, quadrant, p_rho, sig_rho, ...
                'VariableNames', { ...
                    'sport','kpi','n','var_home','var_away','mean_home','mean_away', ...
                    'cohens_d_paired','kappa','rho','eta','kappa_abs','quadrant', ...
                    'p_rho','sig_rho'});
end


function q = classify_quadrant(kappa, rho)
    if isnan(kappa) || isnan(rho)
        q = "NA"; return
    end
    if kappa > 1 && rho > 0,      q = "Q1";
    elseif kappa < 1 && rho > 0,  q = "Q2";
    elseif kappa < 1 && rho < 0,  q = "Q3";
    elseif kappa > 1 && rho < 0,  q = "Q4";
    else,                         q = "boundary";  % kappa==1 or rho==0
    end
end
