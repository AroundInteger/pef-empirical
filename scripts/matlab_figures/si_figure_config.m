function cfg = si_figure_config()
%SI_FIGURE_CONFIG  Repo paths and season labels for supplementary figures.
    script_dir = fileparts(mfilename('fullpath'));
    % scripts/matlab_figures or scripts/Matlab Figures -> repo root is ../..
    cfg.repo_root = fullfile(script_dir, '..', '..');
    cfg.fig_dir   = fullfile(cfg.repo_root, 'figures');
    cfg.normality_dir = fullfile(cfg.repo_root, 'scripts', 'PEF_Normality_4seasons');

    cfg.rugby_raw = fullfile(cfg.repo_root, 'Data', 'Rugby', 'Raw', '4_seasons rugby abs.csv');
    cfg.foot_dir  = fullfile(cfg.repo_root, 'Data', 'Football', 'Raw', 'team_summaries_4seasons');
    cfg.foot_2s   = {'championship_team_23_24.csv', 'championship_team_24_25.csv'};

    cfg.rugby_seasons    = {'23/24', '24/25'};
    cfg.football_seasons = {'2023/2024', '2024/2025'};
end
