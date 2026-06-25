%REGEN_FIG1  Regenerate Figure 1 from existing pipeline CSVs (no full re-run).
THIS_DIR = fileparts(mfilename('fullpath'));
SCRIPTS  = fileparts(THIS_DIR);
REPO     = fileparts(SCRIPTS);
addpath(fullfile(THIS_DIR, 'lib'));
addpath(fullfile(SCRIPTS, 'PEF_Normality_4seasons'));

OUT_DIR = fullfile(THIS_DIR, 'outputs');
FIG_DIR = fullfile(REPO, 'figures');

pef_2s         = readtable(fullfile(OUT_DIR, 'pef_landscape_2season.csv'), 'TextType', 'string');
domain_summary = readtable(fullfile(OUT_DIR, 'domain_summary.csv'),        'TextType', 'string');

for c = {'rho_mean','kappa_mean','mean_eta','sd_eta','success_pct','n'}
    if ismember(c{1}, domain_summary.Properties.VariableNames)
        v = domain_summary.(c{1});
        if ~isnumeric(v)
            domain_summary.(c{1}) = cellfun(@str2double, cellstr(v));
        end
    end
end

figure_1_landscape(pef_2s, table(), domain_summary, fullfile(FIG_DIR, 'Figure_1.png'), table());
fprintf('Figure 1 saved to %s\n', fullfile(FIG_DIR, 'Figure_1.png'));
