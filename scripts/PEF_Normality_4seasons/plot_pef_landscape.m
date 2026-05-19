function fig = plot_pef_landscape(pef_tbl, save_path)
%PLOT_PEF_LANDSCAPE  Scatter (rho, kappa) coloured by sport with iso-eta curves.
%                     Correlation rho on x-axis (read left-to-right as agreement).
%
%   fig = PLOT_PEF_LANDSCAPE(pef_tbl, save_path)

    t = pef_tbl(~isnan(pef_tbl.eta), :);

    fig = figure('Color','w','Position',[100 100 920 700]);
    hold on;

    % --- Background heatmap of eta over the (rho, kappa) plane (x=rho, y=kappa).
    k_grid = linspace(0.05, 5, 400);
    r_grid = linspace(-0.95, 0.95, 400);
    [R, K] = meshgrid(r_grid, k_grid);   % K(i,j)=kappa, R(i,j)=rho
    eta_surf = (1 + K) ./ (1 + K - 2.*sqrt(K).*R);
    eta_surf(eta_surf <= 0 | eta_surf > 10) = NaN;

    imagesc(r_grid, k_grid, log2(eta_surf), 'AlphaData', 0.45);
    set(gca,'YDir','normal');
    colormap(redblue_diverging(256));
    cb = colorbar; cb.Label.String = 'log_2(\eta)';
    caxis([-1.5 1.5]);

    % --- Iso-eta contours.
    [C, h] = contour(R, K, eta_surf, [0.5 0.75 1 1.25 1.5 2 3], ...
        'k-', 'LineWidth', 0.75);
    clabel(C, h, 'FontSize', 9, 'Color',[0.25 0.25 0.25]);

    % --- Quadrant boundaries (rho=0 vertical, kappa=1 horizontal).
    plot([-1 1], [1 1], 'k--', 'LineWidth', 1.5);
    plot([0 0], [0.05 5], 'k--', 'LineWidth', 1.5);

    % --- KPI scatter, coloured by sport.
    sports = unique(t.sport);
    palette = lines(numel(sports));
    handles = gobjects(numel(sports),1);
    for s = 1:numel(sports)
        sub = t(t.sport == sports(s), :);
        handles(s) = scatter(sub.rho, sub.kappa, 90, palette(s,:), 'filled', ...
            'MarkerEdgeColor','k','MarkerFaceAlpha',0.85,'DisplayName', sports(s));
    end

    % --- Quadrant labels (x=rho, y=kappa).
    text(0.85, 3.2, 'Q1 (high \kappa, +\rho)', 'FontSize', 11, 'FontWeight','bold');
    text(0.85, 0.22, 'Q2 (low \kappa, +\rho)',  'FontSize', 11, 'FontWeight','bold');
    text(-0.92, 0.22, 'Q3 (low \kappa, -\rho)',  'FontSize', 11, 'FontWeight','bold');
    text(-0.92, 3.2, 'Q4 (high \kappa, -\rho)', 'FontSize', 11, 'FontWeight','bold');

    xlim([-1 1]); ylim([0.05 5]);
    xlabel('Pairwise correlation \rho', 'FontSize', 12);
    ylabel('Variance ratio \kappa = \sigma_B^2 / \sigma_A^2', 'FontSize', 12);
    title('PEF landscape: KPIs from 4 seasons rugby (URC) + football (English Championship)', ...
          'FontSize', 13);
    legend(handles, 'Location','northeastoutside','Box','off');
    set(gca,'FontSize', 11);
    grid on; box on;
    hold off;

    if nargin >= 2 && ~isempty(save_path)
        exportgraphics(fig, save_path, 'Resolution', 200);
    end
end


function map = redblue_diverging(n)
% Simple diverging blue-white-red colormap (for log2-eta surface).
    if mod(n,2)==1, n = n+1; end
    half = n/2;
    blue = [linspace(0.05,1,half)', linspace(0.30,1,half)', linspace(0.55,1,half)'];
    red  = [linspace(1,0.65,half)', linspace(1,0.05,half)', linspace(1,0.10,half)'];
    map = [blue; red];
end
