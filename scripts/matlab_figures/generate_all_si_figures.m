%% generate_all_si_figures.m
% Regenerate supplementary figures S1--S2 (matlab_figures) and S3--S8
% (run_pef_finalize_diagnostics.m).  Requires pipeline outputs for S3--S8.
%
% Run from repo root or scripts/matlab_figures:
%   /Applications/MATLAB_R2025b.app/bin/matlab -batch ...
%     "cd('scripts/matlab_figures'); run('generate_all_si_figures.m')"

script_dir = fileparts(mfilename('fullpath'));
repo_root = fullfile(script_dir, '..', '..');
pipe_dir  = fullfile(repo_root, 'scripts', 'paper_pipeline');

fprintf('=== SI figure generation (pef_figure_style) ===\n\n');

fprintf('--- S1: information sensitivity ---\n');
run(fullfile(script_dir, 'generate_figure_S1_info_sensitivity.m'));

fprintf('\n--- S2: labelled KPI maps ---\n');
run(fullfile(script_dir, 'generate_figure_S2_labelled_kpis.m'));

repo_root = fullfile(script_dir, '..', '..');
pipe_dir  = fullfile(repo_root, 'scripts', 'paper_pipeline');
req = fullfile(pipe_dir, 'outputs', 'pef_landscape_2season.csv');
if isfile(req)
    fprintf('\n--- S3--S8: finalize diagnostics ---\n');
    run(fullfile(pipe_dir, 'run_pef_finalize_diagnostics.m'));
else
    warning(['Skipping S3--S8: missing %s. Run run_paper_pipeline.m first.'], req);
end

fprintf('\n=== SI figures complete ===\n');
