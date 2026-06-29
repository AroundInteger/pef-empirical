function figure_1_landscape(pef_2s, pef_per_season, domain_summary, fpath, ~)
%FIGURE_1_LANDSCAPE  PEF landscape with four confirmatory exemplars (tab:exemplars).
%  Surface grid: rho in [-0.999, 0.999], kappa in [0.001, 3].
%  Four quadrant exemplars with 23/24 -> 24/25 drift segments.

    RHO_MIN = -0.999;
    RHO_MAX =  0.999;
    KAP_MIN =  0.001;
    KAP_MAX =  3.000;

    ETA_COLOR_LO = 0.4;
    ETA_COLOR_HI = 10.0;

    FS_LABEL  = 16;
    FS_TICK   = 12;
    FS_QUAD   = 16;

    fig = figure('Color', 'w', 'Position', [100 100 1400 820]);
    ax  = axes('Parent', fig, 'Position', [0.07 0.10 0.46 0.84]);
    hold(ax, 'on');

    n_r = 500;
    n_k = 500;
    r_g = linspace(RHO_MIN, RHO_MAX, n_r);
    k_g = linspace(KAP_MIN, KAP_MAX, n_k);
    [R, K] = meshgrid(r_g, k_g);

    den    = 1 + K - 2 * sqrt(K) .* R;
    eta_s  = (1 + K) ./ den;
    bad    = ~isfinite(eta_s) | eta_s <= 0 | den <= 0;
    eta_s(bad) = NaN;

    Z = log10(eta_s);
    Z(Z > log10(ETA_COLOR_HI)) = log10(ETA_COLOR_HI);

    h_img = imagesc(ax, r_g, k_g, Z);
    set(ax, 'YDir', 'normal');
    set(h_img, 'AlphaData', double(~isnan(Z)) * 0.55);

    colormap(ax, redblue_local(256));
    caxis(ax, [log10(ETA_COLOR_LO) log10(ETA_COLOR_HI)]);

    eta_contour_levels = [0.5 0.75 1 1.25 1.5 2 3 5];
    [C, h] = contour(ax, R, K, eta_s, eta_contour_levels, ...
        'k-', 'LineWidth', 0.7);
    clabel(C, h, 'FontSize', FS_TICK, 'Color', [0.25 0.25 0.25]);
    h.HandleVisibility = 'off';

    k_bnd = linspace(KAP_MIN, KAP_MAX, 300);
    rho_bnd = (1 + k_bnd) ./ (2 * sqrt(k_bnd));
    in_plot = rho_bnd >= RHO_MIN & rho_bnd <= RHO_MAX;
    plot(ax, rho_bnd(in_plot), k_bnd(in_plot), 'k:', 'LineWidth', 1.0, ...
        'HandleVisibility', 'off');

    plot(ax, [RHO_MIN RHO_MAX], [1 1], 'k--', 'LineWidth', 1.5, ...
        'HandleVisibility', 'off');
    plot(ax, [0 0], [KAP_MIN KAP_MAX], 'k--', 'LineWidth', 1.5, ...
        'HandleVisibility', 'off');

    figure_quad_exemplars(ax, pef_2s, pef_per_season, 'eta');

    if ~isempty(domain_summary) && height(domain_summary) > 0 && ...
       all(ismember({'rho_mean', 'kappa_mean'}, domain_summary.Properties.VariableNames))
        dom_pal = lines(height(domain_summary));
        for di = 1:height(domain_summary)
            rd = domain_summary.rho_mean(di);
            kd = domain_summary.kappa_mean(di);
            if isnan(rd) || isnan(kd), continue; end
            scatter(ax, rd, kd, 110, dom_pal(di, :), '^', 'filled', ...
                'MarkerEdgeColor', 'k', 'LineWidth', 0.8, ...
                'DisplayName', domain_summary.domain{di});
        end
    end

    text(ax,  0.88, 2.65, 'Q1', 'FontSize', FS_QUAD, 'FontWeight', 'bold', 'Color', [0.2 0.2 0.2]);
    text(ax,  0.88,  0.35, 'Q2', 'FontSize', FS_QUAD, 'FontWeight', 'bold', 'Color', [0.2 0.2 0.2]);
    text(ax, -0.92,  0.35, 'Q3', 'FontSize', FS_QUAD, 'FontWeight', 'bold', 'Color', [0.2 0.2 0.2]);
    text(ax, -0.92, 2.65, 'Q4', 'FontSize', FS_QUAD, 'FontWeight', 'bold', 'Color', [0.2 0.2 0.2]);

    xlim(ax, [RHO_MIN RHO_MAX]);
    ylim(ax, [KAP_MIN KAP_MAX]);
    xlabel(ax, 'Pairwise correlation \rho', 'FontSize', FS_LABEL);
    ylabel(ax, 'Variance ratio \kappa = \sigma_B^2/\sigma_A^2', 'FontSize', FS_LABEL);
    set(ax, 'FontSize', FS_TICK);
    grid(ax, 'on');
    box(ax, 'on');

    cb = colorbar(ax, 'Location', 'east');
    eta_ticks = [0.5 1 2 3 5 10];
    cb.Ticks      = log10(eta_ticks);
    cb.TickLabels = arrayfun(@(v) sprintf('%.0g', v), eta_ticks, 'UniformOutput', false);
    cb.FontSize   = FS_TICK;
    cb.Position   = [0.545 0.10 0.022 0.84];
    cb.Label.String = '';
    cb_pos = cb.Position;
    eta_lbl_x = cb_pos(1) + cb_pos(3) + 0.008;
    eta_lbl_y = cb_pos(2) + cb_pos(4) * 0.5 - 0.02;
    annotation(fig, 'textbox', [eta_lbl_x, eta_lbl_y, 0.04, 0.04], ...
        'String', '\eta', 'EdgeColor', 'none', 'FitBoxToText', 'on', ...
        'FontSize', FS_LABEL, 'HorizontalAlignment', 'left', ...
        'VerticalAlignment', 'middle', 'Interpreter', 'tex');

    lgd = legend(ax, 'Location', 'none', 'Box', 'off', 'FontSize', FS_TICK, ...
        'Interpreter', 'tex');
    lgd.Position = [0.60 0.05 0.38 0.90];

    hold(ax, 'off');

    if nargin >= 4 && ~isempty(fpath)
        exportgraphics(fig, fpath, 'Resolution', 200);
    end
    close(fig);
end

function map = redblue_local(n)
    if mod(n, 2) == 1, n = n + 1; end
    h = n / 2;
    map = [[linspace(0.05, 1, h)' linspace(0.30, 1, h)' linspace(0.55, 1, h)']; ...
           [linspace(1, 0.65, h)' linspace(1, 0.05, h)' linspace(1, 0.10, h)']];
end
