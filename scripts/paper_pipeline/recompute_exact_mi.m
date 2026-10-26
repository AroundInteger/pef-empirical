%RECOMPUTE_EXACT_MI  Replace analytic I(X;Y) on the saved probit grid.
%
%   Does not re-run the Monte Carlo. Accuracy columns are left as simulated.
%   Ixy and bayes_acc are recomputed from (kappa, rho, delta) under the
%   probit model (A1)--(A2). Writes the grid, the named-scenario table, and
%   a correlation summary including corr(eta, I) by delta/sigma_A slice.

script_dir = fileparts(mfilename('fullpath'));
addpath(fullfile(script_dir, 'lib'));
out_dir = fullfile(script_dir, 'outputs');
H = pef_theory_helpers();

grid_path = fullfile(out_dir, 'idealised_probit_grid.csv');
scen_path = fullfile(out_dir, 'idealised_probit_scenarios.csv');
grid = readtable(grid_path);

n = height(grid);
I_new = nan(n, 1);
B_new = nan(n, 1);
bound = nan(n, 1);
oldI = grid.Ixy;
for i = 1:n
    I_new(i) = H.mi_exact(grid.kappa(i), grid.rho(i), grid.delta(i), grid.sigma_a(i));
    B_new(i) = H.bayes_acc_x(grid.delta(i), grid.var_x(i));
    bound(i) = H.mi_bound(grid.kappa(i), grid.rho(i), grid.delta(i), grid.sigma_a(i));
end
grid.Ixy = I_new;
grid.bayes_acc = B_new;
writetable(grid, grid_path);

if exist(scen_path, 'file')
    scen = readtable(scen_path);
    for i = 1:height(scen)
        scen.Ixy(i) = H.mi_exact(scen.kappa(i), scen.rho(i), scen.delta(i), scen.sigma_a(i));
        scen.bayes_acc(i) = H.bayes_acc_x(scen.delta(i), scen.var_x(i));
    end
    writetable(scen, scen_path);
else
    scen = grid(strlength(string(grid.scenario)) > 0, :);
end

fprintf('\n=== Exact I versus former discriminant expression ===\n');
fprintf('max |I_exact - I_old| = %.4f\n', max(abs(I_new - oldI)));
fprintf('min (I_exact - Jensen bound) = %.6f\n', min(I_new - bound));

fprintf('\n=== Named scenarios ===\n');
for i = 1:height(scen)
    scen_name = string(scen.scenario(i));
    if strlength(scen_name) == 0
        continue
    end
    fprintf('%-32s eta=%.3f I=%.4f bound=%.4f bayes=%.3f impr=%.1f\n', ...
        scen_name, scen.eta(i), scen.Ixy(i), ...
        H.mi_bound(scen.kappa(i), scen.rho(i), scen.delta(i), scen.sigma_a(i)), ...
        scen.bayes_acc(i), scen.acc_impr_pct_mean(i));
end

fprintf('\n=== corr(eta, I) by slice ===\n');
dr_u = sort(unique(grid.delta_ratio));
lines = {};
lines{end+1} = '=== Idealised probit analytic refresh (exact I; MC accuracies unchanged) ==='; %#ok<AGROW>
lines{end+1} = sprintf('Date: %s', datestr(now)); %#ok<AGROW>
lines{end+1} = ''; %#ok<AGROW>
lines{end+1} = '--- corr(eta, I(X;Y)) by delta/sigma_A ---'; %#ok<AGROW>
for ii = 1:numel(dr_u)
    dr = dr_u(ii);
    sl = abs(grid.delta_ratio - dr) < 1e-9 & isfinite(grid.eta) & isfinite(grid.Ixy);
    r = corr(grid.eta(sl), grid.Ixy(sl));
    fprintf('  delta/sigma_A=%.1f  n=%d  corr(eta,I)=%.4f\n', dr, sum(sl), r);
    lines{end+1} = sprintf('  delta/sigma_A=%.1f  n=%d  corr(eta,I)=%.4f', dr, sum(sl), r); %#ok<AGROW>
end
sl = isfinite(grid.eta) & isfinite(grid.Ixy);
r_pool = corr(grid.eta(sl), grid.Ixy(sl));
fprintf('  pooled n=%d  corr(eta,I)=%.4f\n', sum(sl), r_pool);
lines{end+1} = sprintf('  pooled n=%d  corr(eta,I)=%.4f', sum(sl), r_pool); %#ok<AGROW>

valid = isfinite(grid.Ixy) & isfinite(grid.acc_impr_pct_mean);
r_IML = corr(grid.Ixy(valid), grid.acc_impr_pct_mean(valid));
r_eML = corr(grid.eta(valid), grid.acc_impr_pct_mean(valid));
fprintf('\ncorr(I, mean ML improvement) = %.4f\n', r_IML);
fprintf('corr(eta, mean ML improvement) = %.4f\n', r_eML);
lines{end+1} = ''; %#ok<AGROW>
lines{end+1} = '--- Correlations (full grid; MC accuracies) ---'; %#ok<AGROW>
lines{end+1} = sprintf('corr(I(X;Y), mean ML improvement) = %.4f', r_IML); %#ok<AGROW>
lines{end+1} = sprintf('corr(eta, mean ML improvement)     = %.4f', r_eML); %#ok<AGROW>

fprintf('\n=== Validation 1: parameter recovery ===\n');
lines{end+1} = ''; %#ok<AGROW>
lines{end+1} = '--- Validation 1: parameter recovery (mean |hat - target|) ---'; %#ok<AGROW>
dk = mean(abs(grid.kappa_hat_mean - grid.kappa), 'omitnan');
drho = mean(abs(grid.rho_hat_mean - grid.rho), 'omitnan');
de = mean(abs(grid.eta_hat_mean - grid.eta), 'omitnan');
fprintf('  mean |kappa_hat - kappa| = %.6f\n', dk);
fprintf('  mean |rho_hat - rho|     = %.6f\n', drho);
fprintf('  mean |eta_hat - eta|     = %.6f\n', de);
lines{end+1} = sprintf('  mean |kappa_hat - kappa| = %.6f', dk); %#ok<AGROW>
lines{end+1} = sprintf('  mean |rho_hat - rho|     = %.6f', drho); %#ok<AGROW>
lines{end+1} = sprintf('  mean |eta_hat - eta|     = %.6f', de); %#ok<AGROW>

% Landscape range at the nominal Figure 2 signal, for the colour scale.
d_nom = H.mi_exact_grid(linspace(0.05, 3, 40).', linspace(-0.9, 0.9, 40), 1, 1);
fprintf('\nFigure-2-like I range at delta/sigma_A=1: [%.4f, %.4f]\n', ...
    min(d_nom, [], 'all', 'omitnan'), max(d_nom, [], 'all', 'omitnan'));

fid = fopen(fullfile(out_dir, 'idealised_probit_summary.txt'), 'w');
for i = 1:numel(lines)
    fprintf(fid, '%s\n', lines{i});
end
fclose(fid);
fprintf('\nWrote %s\n', fullfile(out_dir, 'idealised_probit_summary.txt'));
