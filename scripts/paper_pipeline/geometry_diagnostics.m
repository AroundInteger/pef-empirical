function out = geometry_diagnostics(pef_in)
%GEOMETRY_DIAGNOSTICS  Augment a PEF table with geometry/IG coordinates.
%
%   out = GEOMETRY_DIAGNOSTICS(pef_in)
%
%   Appends the following columns to any table that already has
%   numeric ``kappa`` and ``rho`` columns (and optionally ``eta``):
%
%       tau           = (1/2) * log(kappa)                  -- half-log scale
%       abs_tau       = |tau|                               -- severity coord.
%       psi           = 2 * sign(rho) * atanh(sqrt(|rho * sech(tau)|))
%                                                            -- signed
%                       variance-stabilising Fisher--Rao coordinate.
%                       Real-valued provided |rho * sech(tau)| < 1, which
%                       holds throughout the physical domain except at the
%                       singular point (kappa, rho) = (1, 1).
%       cos_sigma     = 2 * sqrt(kappa) * rho / (1 + kappa) -- chord cosine
%                       to the marked pole P(1) on the Riemann sphere.
%       sigma         = acos(cos_sigma)                     -- angular dist.
%       sphere_x, sphere_y, sphere_z  -- inverse stereographic lift of
%                       z = sqrt(kappa) * exp(i * acos(rho)) to the unit
%                       sphere, normalised so that (kappa,rho) = (1,1)
%                       maps to the marked pole P(1) = (1, 0, 0).
%       eta_from_sigma = 1 / (1 - cos_sigma)
%                       -- eta reconstructed from the spherical coord.;
%                       agrees with the input ``eta`` column when present
%                       (consistency check for the sphere realisation).
%
%   The script is deliberately tolerant of NaN inputs: any row with NaN
%   kappa or rho yields NaN geometry columns.  No rows are dropped.
%
%   Mathematical references (all proven in the companion paper):
%
%     1. Canonical form
%           eta = cosh(tau) / (cosh(tau) - rho)
%        with tau = (1/2) log(kappa).
%     2. Sphere realisation
%           eta = 1 / (1 - cos sigma),
%           cos sigma = 2 * sqrt(kappa) * rho / (1 + kappa).
%     3. Partition-function reading
%           log eta = -log(1 - rho * sech(tau))
%        valid when rho * sech(tau) in (0, 1).
%     4. Fisher--Rao coordinate
%           psi = 2 * arctanh(sqrt(rho * sech(tau)))     (rho > 0),
%           |psi| analogous for rho < 0 with sign carried separately.
%
%   See also:  kappa_involution_audit, psi_scale_pooling, psi_ml_residuals.

    if ~istable(pef_in)
        error('geometry_diagnostics:badinput', ...
              'Input must be a table with kappa and rho columns.');
    end
    if ~ismember('kappa', pef_in.Properties.VariableNames) || ...
       ~ismember('rho',   pef_in.Properties.VariableNames)
        error('geometry_diagnostics:missingcols', ...
              'Input table must have ''kappa'' and ''rho'' columns.');
    end

    out = pef_in;
    kappa = out.kappa;
    rho   = out.rho;
    n     = numel(kappa);

    tau     = nan(n, 1);
    psi     = nan(n, 1);
    cos_sig = nan(n, 1);
    sigma   = nan(n, 1);
    sx      = nan(n, 1);
    sy      = nan(n, 1);
    sz      = nan(n, 1);

    for i = 1:n
        k = kappa(i);  r = rho(i);
        if ~isfinite(k) || ~isfinite(r) || k <= 0
            continue
        end
        if r < -1 || r > 1
            continue
        end

        tau(i) = 0.5 * log(k);

        s = r * sech(tau(i));     % rho * sech tau
        as = abs(s);
        if as < 1
            psi(i) = 2 * sign(s) * atanh(sqrt(as));
        elseif as == 1
            psi(i) = sign(s) * Inf;
        end

        cs = 2 * sqrt(k) * r / (1 + k);
        cs = max(min(cs, 1), -1);     % numerical safety
        cos_sig(i) = cs;
        sigma(i)   = acos(cs);

        theta   = acos(max(min(r, 1), -1));
        z_re    = sqrt(k) * cos(theta);
        z_im    = sqrt(k) * sin(theta);
        denom   = 1 + k;              % 1 + |z|^2 = 1 + kappa
        sx(i)   = 2 * z_re  / denom;
        sy(i)   = 2 * z_im  / denom;
        sz(i)   = (k - 1)   / denom;  % (|z|^2 - 1) / (|z|^2 + 1)
    end

    out.tau     = tau;
    out.abs_tau = abs(tau);
    out.psi     = psi;
    out.cos_sigma = cos_sig;
    out.sigma   = sigma;
    out.sphere_x = sx;
    out.sphere_y = sy;
    out.sphere_z = sz;
    out.eta_from_sigma = 1 ./ (1 - cos_sig);

    if ismember('eta', out.Properties.VariableNames)
        out.eta_sigma_residual = out.eta - out.eta_from_sigma;
    end
end
