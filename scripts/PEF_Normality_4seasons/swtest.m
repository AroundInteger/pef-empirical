function [H, pValue, W] = swtest(x, alpha)
%SWTEST  Shapiro-Wilk parametric hypothesis test of composite normality.
%
%   [H, pValue, W] = SWTEST(x, alpha)
%
%   Tests H0: x is drawn from a normal distribution against H1: it is not.
%   Implements the Royston (1992, 1995) extension of the Shapiro-Wilk test,
%   valid for 4 <= n <= 5000.
%
%   INPUTS
%       x      Numeric vector. NaNs are removed before testing.
%       alpha  Significance level (default 0.05).
%
%   OUTPUTS
%       H       Logical -- true means H0 rejected (data not normal) at alpha.
%       pValue  Approximate p-value of the test.
%       W       The Shapiro-Wilk W statistic.
%
%   REFERENCES
%       Shapiro, S.S. & Wilk, M.B. (1965). An analysis of variance test
%           for normality (complete samples). Biometrika, 52, 591-611.
%       Royston, J.P. (1992). Approximating the Shapiro-Wilk W-test for
%           non-normality. Statistics and Computing, 2, 117-119.
%       Royston, J.P. (1995). A remark on Algorithm AS R94: The W-test
%           for normality. Applied Statistics, 44, 547-551.
%
%   This is a self-contained implementation -- no toolbox functions are
%   required beyond NORMCDF / NORMINV from Statistics and ML Toolbox.

    if nargin < 2 || isempty(alpha), alpha = 0.05; end
    if ~isvector(x)
        error('swtest:notVector', 'Input must be a vector.');
    end

    x = x(:);
    x = x(~isnan(x));
    n = numel(x);

    if n < 4
        error('swtest:tooFew', 'Sample size must be at least 4.');
    end
    if n > 5000
        warning('swtest:largeN', ...
            'Sample size > 5000; Royston approximation may be unreliable.');
    end
    if std(x) == 0
        % Degenerate constant series.
        H = true; pValue = 0; W = NaN; return
    end

    x = sort(x);

    % ----- Royston-corrected Shapiro-Wilk coefficients -------------------
    ii      = (1:n)';
    mtilde  = norminv((ii - 3/8) ./ (n + 1/4));   % Blom-type scores
    M       = sum(mtilde.^2);
    u       = 1/sqrt(n);

    an   = -2.706056*u^5 + 4.434685*u^4 - 2.071190*u^3 ...
            - 0.147981*u^2 + 0.221157*u + mtilde(n)/sqrt(M);
    anm1 = -3.582633*u^5 + 5.682633*u^4 - 1.752460*u^3 ...
            - 0.293762*u^2 + 0.042981*u + mtilde(n-1)/sqrt(M);

    a = zeros(n,1);
    if n > 5
        eps_n = (M - 2*mtilde(n)^2 - 2*mtilde(n-1)^2) / ...
                (1 - 2*an^2 - 2*anm1^2);
        a(n)   =  an;    a(1)   = -an;
        a(n-1) =  anm1;  a(2)   = -anm1;
        idx    = 3:(n-2);
        a(idx) = mtilde(idx) / sqrt(eps_n);
    else  % n == 4 or 5
        eps_n = (M - 2*mtilde(n)^2) / (1 - 2*an^2);
        a(n)   =  an;  a(1) = -an;
        idx    = 2:(n-1);
        a(idx) = mtilde(idx) / sqrt(eps_n);
    end

    % ----- W statistic ---------------------------------------------------
    xbar = mean(x);
    W = (sum(a .* x))^2 / sum((x - xbar).^2);

    % Guard against pathological numerical W >= 1.
    if W >= 1 - eps
        pValue = 1; H = false; return
    end

    % ----- Royston (1992) standardised log-transform ---------------------
    if n <= 11
        gamma_ = -log(0.459*n - 2.273);
        y      = -log(gamma_ - log(1 - W));
        mu_    =  0.5440 - 0.39978*n + 0.025054*n^2 - 0.0006714*n^3;
        sigma_ = exp(1.3822 - 0.77857*n + 0.062767*n^2 - 0.0020322*n^3);
    else
        ln_n   = log(n);
        y      = log(1 - W);
        mu_    = -1.5861 - 0.31082*ln_n - 0.083751*ln_n^2 + 0.0038915*ln_n^3;
        sigma_ = exp(-0.4803 - 0.082676*ln_n + 0.0030302*ln_n^2);
    end
    z      = (y - mu_) / sigma_;
    pValue = 1 - normcdf(z);
    H      = pValue < alpha;
end
