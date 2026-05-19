function fig = plot_normality_summary(norm_tbl, save_path)
%PLOT_NORMALITY_SUMMARY  Bar chart: % KPI series normal/close/not-normal
%   across season-window sizes, split by sport and series side.
%
%   fig = PLOT_NORMALITY_SUMMARY(norm_tbl, save_path)
%
%   Verdict counts are computed per (sport, side, window_n_seasons),
%   and shown as stacked bars where each colour = one verdict category.

    t = norm_tbl;

    sports = unique(t.sport);
    sides  = ["home","away","diff"];
    wins   = sort(unique(t.window_n_seasons));

    verdict_cats = ["Normal","Close","NotNormal"];
    colours = [0.20 0.55 0.20;  % Normal -- green
               0.85 0.65 0.13;  % Close  -- amber
               0.75 0.20 0.20]; % NotNormal -- red

    fig = figure('Color','w','Position',[100 100 1100 700]);
    n_rows = numel(sports);
    n_cols = numel(sides);
    plot_idx = 0;
    for sp = 1:n_rows
        for sd = 1:n_cols
            plot_idx = plot_idx + 1;
            subplot(n_rows, n_cols, plot_idx);
            counts = zeros(numel(wins), numel(verdict_cats));
            for wi = 1:numel(wins)
                mask = t.sport == sports(sp) & t.side == sides(sd) & ...
                       t.window_n_seasons == wins(wi);
                vsub = t.verdict(mask);
                for vc = 1:numel(verdict_cats)
                    counts(wi,vc) = sum(vsub == verdict_cats(vc));
                end
            end
            % Convert to per-window proportions so windows are comparable
            % even though they contain different numbers of (kpi,window) cells.
            row_totals = sum(counts,2);
            row_totals(row_totals==0) = 1;
            props = 100 * counts ./ row_totals;
            hb = bar(props, 'stacked');
            for vc = 1:numel(verdict_cats)
                hb(vc).FaceColor = colours(vc,:);
                hb(vc).EdgeColor = 'none';
            end
            set(gca, 'XTick', 1:numel(wins), 'XTickLabel', ...
                arrayfun(@(w) sprintf('%d seas.',w), wins, 'UniformOutput', false));
            ylim([0 100]);
            if sd == 1
                ylabel(sprintf('%s\n%% of KPI series', sports(sp)), 'FontSize', 11);
            end
            if sp == 1
                title(sprintf('side: %s', sides(sd)), 'FontSize', 12);
            end
            if sp == n_rows && sd == n_cols
                legend(verdict_cats, 'Location','southoutside','Orientation','horizontal','Box','off');
            end
            set(gca, 'FontSize', 10);
            box on; grid on;
        end
    end
    sgtitle('Shapiro-Wilk + Lilliefors normality verdicts vs. season-window size', ...
            'FontSize', 13, 'FontWeight','bold');

    if nargin >= 2 && ~isempty(save_path)
        exportgraphics(fig, save_path, 'Resolution', 200);
    end
end
