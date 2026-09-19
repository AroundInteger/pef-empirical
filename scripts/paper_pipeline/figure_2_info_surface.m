function figure_2_info_surface(pef_2s, pef_per_season, domain_summary, fpath)
%FIGURE_2_INFO_SURFACE  I(X;Y) surface with Figure-1 layout.
%  Same four confirmatory exemplars and season drift as figure_1_landscape.
%  Nominal signal strength delta/sigma_A = 1 (eq:mi_closed).

    RHO_MIN = -0.999;
    RHO_MAX =  0.999;
    KAP_MIN =  0.001;
    KAP_MAX =  3.000;
    DELTA   =  1.0;
    SIGMA_A =  1.0;

    ST = pef_figure_style.config();
    FS_LABEL  = ST.fs_label;
    FS_TICK   = ST.fs_tick;
    FS_QUAD   = ST.fs_quad;
    FS_CONTOUR = ST.fs_contour;

    fig = figure('Color', 'w', 'Position', [100 100 1400 820]);
    ax  = axes('Parent', fig, 'Position', [0.09 0.13 0.44 0.81]);
    ax.Toolbar.Visible = 'off';
    hold(ax, 'on');

    % ---- I(X;Y) surface ----------------------------------------------------
    n_r = 500;
    n_k = 500;
    r_g = linspace(RHO_MIN, RHO_MAX, n_r);
    k_g = linspace(KAP_MIN, KAP_MAX, n_k);
    [R, K] = meshgrid(r_g, k_g);

    I_xy = compute_mi_grid(K, R, DELTA, SIGMA_A);

    h_img = imagesc(ax, r_g, k_g, I_xy);
    set(ax, 'YDir', 'normal');
    set(h_img, 'AlphaData', double(~isnan(I_xy)) * 0.55);

    colormap(ax, parula(256));
    caxis(ax, [0 0.30]);

    % ---- Iso-I contours ----------------------------------------------------
    I_levels = [0.01 0.02 0.05 0.08 0.10 0.15 0.20 0.25];
    [C, h] = contour(ax, R, K, I_xy, I_levels, 'k-', 'LineWidth', 0.7);
    clabel(C, h, 'FontSize', FS_CONTOUR, 'Color', [0.25 0.25 0.25]);
    h.HandleVisibility = 'off';

    % ---- Admissibility boundary --------------------------------------------
    k_bnd   = linspace(KAP_MIN, KAP_MAX, 300);
    rho_bnd = (1 + k_bnd) ./ (2 * sqrt(k_bnd));
    in_plot = rho_bnd >= RHO_MIN & rho_bnd <= RHO_MAX;
    plot(ax, rho_bnd(in_plot), k_bnd(in_plot), 'k:', 'LineWidth', 1.0, ...
        'HandleVisibility', 'off');

    % ---- Quadrant boundaries -----------------------------------------------
    plot(ax, [RHO_MIN RHO_MAX], [1 1], 'k--', 'LineWidth', 1.5, ...
        'HandleVisibility', 'off');
    plot(ax, [0 0], [KAP_MIN KAP_MAX], 'k--', 'LineWidth', 1.5, ...
        'HandleVisibility', 'off');

    % ---- Confirmatory exemplars (same four as Figure 1 / tab:exemplars) ----
    figure_quad_exemplars(ax, pef_2s, pef_per_season, 'I', DELTA, SIGMA_A);

    if ~isempty(domain_summary) && height(domain_summary) > 0 && ...
       all(ismember({'rho_mean', 'kappa_mean'}, domain_summary.Properties.VariableNames))
        dom_pal = lines(height(domain_summary));
        for di = 1:height(domain_summary)
            rd = domain_summary.rho_mean(di);
            kd = domain_summary.kappa_mean(di);
            if isnan(rd) || isnan(kd), continue; end
            scatter(ax, rd, kd, ST.ms_domain, dom_pal(di, :), '^', 'filled', ...
                'MarkerEdgeColor', 'k', 'LineWidth', 0.8, ...
                'DisplayName', domain_summary.domain{di});
        end
    end

    % ---- Quadrant labels ---------------------------------------------------
    text(ax,  0.90, 2.88, 'Q1', 'FontSize', FS_QUAD, 'FontWeight', 'bold', 'Color', [0.2 0.2 0.2]);
    text(ax,  0.88,  0.35, 'Q2', 'FontSize', FS_QUAD, 'FontWeight', 'bold', 'Color', [0.2 0.2 0.2]);
    text(ax, -0.92,  0.35, 'Q3', 'FontSize', FS_QUAD, 'FontWeight', 'bold', 'Color', [0.2 0.2 0.2]);
    text(ax, -0.92, 2.38, 'Q4', 'FontSize', FS_QUAD, 'FontWeight', 'bold', 'Color', [0.2 0.2 0.2]);

    xlim(ax, [RHO_MIN RHO_MAX]);
    ylim(ax, [KAP_MIN KAP_MAX]);
    xticks(ax, -0.8:0.2:0.8);
    yticks(ax, 0.5:0.5:3.0);
    set(ax, 'FontSize', FS_TICK, 'Box', 'on', ...
        'LabelFontSizeMultiplier', FS_LABEL / FS_TICK);
    xlabel(ax, 'Pairwise correlation \rho', 'FontSize', FS_LABEL);
    ylabel(ax, 'Variance ratio \kappa = \sigma_B^2/\sigma_A^2', 'FontSize', FS_LABEL);
    pef_figure_style.apply_decimal_ticks(ax, 1);
    grid(ax, 'on');

    % ---- Colorbar ------------------------------------------------------------
    cb = colorbar(ax, 'Location', 'east');
    I_ticks = 0:0.05:0.30;
    cb.Ticks = I_ticks;
    cb.TickLabels = pef_figure_style.decimal_labels(I_ticks, 2);
    cb.FontSize = FS_TICK;
    cb.Position = [0.545 0.13 0.022 0.81];
    cb.Label.String = '';
    cb_pos = cb.Position;
    % Horizontal label above the side legend (16 pt is too wide to sit
    % in the mid-bar gap used for the single-character \eta in Figure 1).
    annotation(fig, 'textbox', ...
        [cb_pos(1) + cb_pos(3) + 0.010, cb_pos(2) + cb_pos(4) - 0.09, 0.22, 0.08], ...
        'String', 'I(X;Y) (bits)', 'EdgeColor', 'none', 'FitBoxToText', 'on', ...
        'FontSize', FS_LABEL, 'HorizontalAlignment', 'left', ...
        'VerticalAlignment', 'middle', 'Interpreter', 'tex');

    % ---- Legend --------------------------------------------------------------
    pef_figure_style.apply_side_legend(ax, ST, [0.64, 0.28, 0.34, 0.40]);

    hold(ax, 'off');

    if nargin >= 4 && ~isempty(fpath)
        pef_figure_style.export_figure(fig, fpath);
    end
    close(fig);
end

% ---- Vectorised I(X;Y) on (kappa, rho) grid -------------------------------
function I_xy = compute_mi_grid(K, R, delta, sigmaA)
    den   = 1 + K - 2 * sqrt(K) .* R;
    eta_s = (1 + K) ./ den;
    bad   = ~isfinite(eta_s) | eta_s <= 0 | den <= 0;
    eta_s(bad) = NaN;

    sep = normcdf(delta ./ (2 * sigmaA * sqrt((1 + K) ./ eta_s)));
    sep = min(max(sep, 1e-12), 1 - 1e-12);
    H   = -sep .* log2(sep) - (1 - sep) .* log2(1 - sep);
    I_xy = 1 - H;
    I_xy(bad) = NaN;
end
