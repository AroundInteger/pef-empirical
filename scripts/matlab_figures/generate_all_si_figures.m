%% generate_all_si_figures.m
% Regenerate supplementary figures. Printed SI order is S1--S5
% (theory surface, then probit pair, then empirical maps). Disk names
% retain generator tags. S3--S4 generators live here; the S1 overlay,
% iso-eta companion, and I_pred panel come from
% run_pef_finalize_diagnostics.m (requires pipeline outputs).
%
% Run from repo root or scripts/matlab_figures:
%   /Applications/MATLAB_R2025b.app/bin/matlab -batch ...
%     "cd('scripts/matlab_figures'); run('generate_all_si_figures.m')"

script_dir = fileparts(mfilename('fullpath'));
repo_root = fullfile(script_dir, '..', '..');
pipe_dir  = fullfile(repo_root, 'scripts', 'paper_pipeline');

fprintf('=== SI figure generation (pef_figure_style) ===\n\n');

fprintf('--- S3: information sensitivity ---\n');
run(fullfile(script_dir, 'generate_figure_S3_info_sensitivity.m'));

fprintf('\n--- S4: labelled KPI maps ---\n');
run(fullfile(script_dir, 'generate_figure_S4_labelled_kpis.m'));

repo_root = fullfile(script_dir, '..', '..');
pipe_dir  = fullfile(repo_root, 'scripts', 'paper_pipeline');
req = fullfile(pipe_dir, 'outputs', 'pef_landscape_2season.csv');
if isfile(req)
    fprintf('\n--- S2 overlay, S3, S5: finalize diagnostics ---\n');
    run(fullfile(pipe_dir, 'run_pef_finalize_diagnostics.m'));
else
    warning(['Skipping S2 overlay / S3 / S5: missing %s. Run run_paper_pipeline.m first.'], req);
end

fprintf('\n=== SI figures complete ===\n');
