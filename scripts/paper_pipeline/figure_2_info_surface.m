function figure_2_info_surface(pef_2s, domain_summary, fpath)
%FIGURE_2_INFO_SURFACE  I(X;Y) surface with Figure-1 layout.
%  Same axes, exemplars, domain markers, and typography as figure_1_landscape.
%  Nominal signal strength delta/sigma_A = 1 (eq:mi_closed).

    RHO_MIN = -0.999;
    RHO_MAX =  0.999;
    KAP_MIN =  0.001;
    KAP_MAX =  3.000;
    DELTA   =  1.0;
    SIGMA_A =  1.0;

    FS_LABEL  = 16;
    FS_TICK   = 12;
    FS_QUAD   = 16;
    FS_MARKER = 12;

    fig = figure('Color', 'w', 'Position', [100 100 1400 820]);
    ax  = axes('Parent', fig, 'Position', [0.07 0.10 0.46 0.84]);
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
    clabel(C, h, 'FontSize', FS_TICK, 'Color', [0.25 0.25 0.25]);
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

    % ---- Curated exemplars (same as Figure 1) ------------------------------
    rugby_clr = [0.12 0.47 0.71];
    foot_clr  = [0.90 0.40 0.05];

    rugby_spec = { ...
        'Kick metres',    'kick_metres',        +0.649, 1.059, 'Q1'; ...
        'Rucks won',      'rucks_won',          +0.818, 0.820, 'Q2'; ...
        'Lineout throws', 'lineout_throws_won', -0.224, 0.918, 'Q3'; ...
        'Missed tackles', 'missed_tackles',     -0.043, 1.183, 'Q4'; ...
    };
    foot_spec = { ...
        'Yellow cards',  'yellow_cards',          +0.161, 1.098, 'Q1'; ...
        'Long balls',    'long_balls',            +0.233, 0.911, 'Q2'; ...
        'Passes',        'passes',                -0.649, 0.839, 'Q3'; ...
        'GK long balls', 'goalkeeper_long_balls', -0.241, 1.001, 'Q4'; ...
    };

    for i = 1:size(rugby_spec, 1)
        [xp, yp, Ip] = lookup_exemplar(pef_2s, "rugby", rugby_spec{i, 2}, ...
            rugby_spec{i, 3}, rugby_spec{i, 4}, DELTA, SIGMA_A);
        leg_str = sprintf('R%d  %s  (I=%.3f, %s)', i, rugby_spec{i, 1}, Ip, rugby_spec{i, 5});
        scatter(ax, xp, yp, 130, rugby_clr, 'o', 'filled', ...
            'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', leg_str);
        text(ax, xp, yp, sprintf('%d', i), ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
            'FontSize', FS_MARKER, 'FontWeight', 'bold', 'Color', 'w', ...
            'HandleVisibility', 'off');
    end

    for i = 1:size(foot_spec, 1)
        [xp, yp, Ip] = lookup_exemplar(pef_2s, "football", foot_spec{i, 2}, ...
            foot_spec{i, 3}, foot_spec{i, 4}, DELTA, SIGMA_A);
        leg_str = sprintf('F%d  %s  (I=%.3f, %s)', i, foot_spec{i, 1}, Ip, foot_spec{i, 5});
        scatter(ax, xp, yp, 130, foot_clr, 's', 'filled', ...
            'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', leg_str);
        text(ax, xp, yp, sprintf('%d', i), ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
            'FontSize', FS_MARKER, 'FontWeight', 'bold', 'Color', 'w', ...
            'HandleVisibility', 'off');
    end

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

    % ---- Quadrant labels ---------------------------------------------------
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

    % ---- Colorbar ------------------------------------------------------------
    cb = colorbar(ax, 'Location', 'east');
    cb.FontSize = FS_TICK;
    cb.Position = [0.545 0.10 0.022 0.84];
    cb.Label.String = '';
    cb_pos = cb.Position;
    % Wide label: place well right of tick numerals
    lbl_x = cb_pos(1) + cb_pos(3) + 0.042;
    lbl_y = cb_pos(2) + cb_pos(4) * 0.5 - 0.02;
    annotation(fig, 'textbox', [lbl_x, lbl_y, 0.08, 0.05], ...
        'String', 'I(X;Y) (bits)', 'EdgeColor', 'none', 'FitBoxToText', 'on', ...
        'FontSize', FS_LABEL, 'HorizontalAlignment', 'left', ...
        'VerticalAlignment', 'middle', 'Interpreter', 'tex');

    % ---- Legend --------------------------------------------------------------
    lgd = legend(ax, 'Location', 'none', 'Box', 'off', 'FontSize', FS_TICK, ...
        'Interpreter', 'tex');
    lgd.Position = [0.63 0.05 0.36 0.90];

    hold(ax, 'off');

    if nargin >= 3 && ~isempty(fpath)
        exportgraphics(fig, fpath, 'Resolution', 200);
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

% ---- Exemplar (rho, kappa) + I at nominal delta/sigma_A -------------------
function [rp, kp, Ip] = lookup_exemplar(pef_tbl, sport_str, kpi_str, fb_rho, fb_kap, delta, sigmaA)
    rp = fb_rho;
    kp = fb_kap;
    Ip = mi_at_point(fb_kap, fb_rho, delta, sigmaA);
    if isempty(pef_tbl) || height(pef_tbl) == 0, return; end
    m = pef_tbl.sport == sport_str & pef_tbl.kpi == kpi_str;
    if any(m)
        idx = find(m, 1);
        rp  = pef_tbl.rho(idx);
        kp  = pef_tbl.kappa(idx);
        Ip  = mi_at_point(kp, rp, delta, sigmaA);
    end
end

function Ixy = mi_at_point(kappa, rho, delta, sigmaA)
    den = 1 + kappa - 2 * sqrt(kappa) * rho;
    if den <= 0
        Ixy = NaN;
        return
    end
    eta = (1 + kappa) / den;
    sep = normcdf(delta / (2 * sigmaA * sqrt((1 + kappa) / eta)));
    sep = min(max(sep, 1e-12), 1 - 1e-12);
    Ixy = 1 - (-sep * log2(sep) - (1 - sep) * log2(1 - sep));
end
