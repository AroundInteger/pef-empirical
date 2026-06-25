function figure_1_landscape(pef_2s, ~, domain_summary, fpath, ~)
%FIGURE_1_LANDSCAPE  Exemplar-based PEF landscape.
%  Surface grid: rho in [-0.999, 0.999], kappa in [0.001, 3].
%  Background colour uses log10(eta) to compress the admissibility blow-up
%  (eta diverges as rho -> (1+kappa)/(2*sqrt(kappa))); contour lines are raw eta.
%  Eight sports exemplars (numbered); KPI details in legend.

    RHO_MIN = -0.999;
    RHO_MAX =  0.999;
    KAP_MIN =  0.001;   % variance ratio > 0; axis starts near zero
    KAP_MAX =  3.000;

    ETA_COLOR_LO = 0.4;
    ETA_COLOR_HI = 10.0;   % saturate colour above this (eta still diverges beyond)

    FS_LABEL  = 16;   % axis / colorbar labels (print)
    FS_TICK   = 12;   % tick numerals, legend, contour labels
    FS_QUAD   = 16;   % Q1--Q4 annotations
    FS_MARKER = 12;   % numbered exemplar markers

    fig = figure('Color', 'w', 'Position', [100 100 1400 820]);
    ax  = axes('Parent', fig, 'Position', [0.07 0.10 0.46 0.84]);
    hold(ax, 'on');

    % ---- PEF surface -------------------------------------------------------
    n_r = 500;
    n_k = 500;
    r_g = linspace(RHO_MIN, RHO_MAX, n_r);
    k_g = linspace(KAP_MIN, KAP_MAX, n_k);
    [R, K] = meshgrid(r_g, k_g);

    den    = 1 + K - 2 * sqrt(K) .* R;
    eta_s  = (1 + K) ./ den;
    bad    = ~isfinite(eta_s) | eta_s <= 0 | den <= 0;
    eta_s(bad) = NaN;

    % log10(eta) colour field: compresses blow-up near admissibility boundary
    Z = log10(eta_s);
    Z(Z > log10(ETA_COLOR_HI)) = log10(ETA_COLOR_HI);

    h_img = imagesc(ax, r_g, k_g, Z);
    set(ax, 'YDir', 'normal');
    set(h_img, 'AlphaData', double(~isnan(Z)) * 0.55);

    colormap(ax, redblue_local(256));
    caxis(ax, [log10(ETA_COLOR_LO) log10(ETA_COLOR_HI)]);

    % ---- Iso-eta contours (raw eta, not log) -------------------------------
    eta_contour_levels = [0.5 0.75 1 1.25 1.5 2 3 5];
    [C, h] = contour(ax, R, K, eta_s, eta_contour_levels, ...
        'k-', 'LineWidth', 0.7);
    clabel(C, h, 'FontSize', FS_TICK, 'Color', [0.25 0.25 0.25]);
    h.HandleVisibility = 'off';

    % ---- Admissibility boundary (den = 0; eta diverges) -------------------
    k_bnd = linspace(KAP_MIN, KAP_MAX, 300);
    rho_bnd = (1 + k_bnd) ./ (2 * sqrt(k_bnd));
    in_plot = rho_bnd >= RHO_MIN & rho_bnd <= RHO_MAX;
    plot(ax, rho_bnd(in_plot), k_bnd(in_plot), 'k:', 'LineWidth', 1.0, ...
        'HandleVisibility', 'off');

    % ---- Quadrant boundaries -----------------------------------------------
    plot(ax, [RHO_MIN RHO_MAX], [1 1], 'k--', 'LineWidth', 1.5, ...
        'HandleVisibility', 'off');
    plot(ax, [0 0], [KAP_MIN KAP_MAX], 'k--', 'LineWidth', 1.5, ...
        'HandleVisibility', 'off');

    % ---- Curated exemplars ---------------------------------------------------
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
        [xp, yp, ep] = lookup_pef(pef_2s, "rugby", rugby_spec{i, 2}, ...
                                   rugby_spec{i, 3}, rugby_spec{i, 4});
        leg_str = sprintf('R%d  %s  (\\eta=%.2f, %s)', i, rugby_spec{i, 1}, ep, rugby_spec{i, 5});
        scatter(ax, xp, yp, 130, rugby_clr, 'o', 'filled', ...
            'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', leg_str);
        text(ax, xp, yp, sprintf('%d', i), ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
            'FontSize', FS_MARKER, 'FontWeight', 'bold', 'Color', 'w', ...
            'HandleVisibility', 'off');
    end

    for i = 1:size(foot_spec, 1)
        [xp, yp, ep] = lookup_pef(pef_2s, "football", foot_spec{i, 2}, ...
                                   foot_spec{i, 3}, foot_spec{i, 4});
        leg_str = sprintf('F%d  %s  (\\eta=%.2f, %s)', i, foot_spec{i, 1}, ep, foot_spec{i, 5});
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

    % ---- Colorbar: log-mapped field, eta tick labels -----------------------
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

    % ---- Legend ------------------------------------------------------------
    lgd = legend(ax, 'Location', 'none', 'Box', 'off', 'FontSize', FS_TICK, ...
        'Interpreter', 'tex');
    lgd.Position = [0.60 0.05 0.38 0.90];

    hold(ax, 'off');

    if nargin >= 4 && ~isempty(fpath)
        exportgraphics(fig, fpath, 'Resolution', 200);
    end
    close(fig);
end

% ---- Helper: look up (rho, kappa, eta) from pef table or use fallback ----
function [rp, kp, ep] = lookup_pef(pef_tbl, sport_str, kpi_str, fb_rho, fb_kap)
    rp = fb_rho;
    kp = fb_kap;
    ep = (1 + fb_kap) / (1 + fb_kap - 2 * sqrt(fb_kap) * fb_rho);
    if isempty(pef_tbl) || height(pef_tbl) == 0, return; end
    m = pef_tbl.sport == sport_str & pef_tbl.kpi == kpi_str;
    if any(m)
        idx = find(m, 1);
        rp  = pef_tbl.rho(idx);
        kp  = pef_tbl.kappa(idx);
        ep  = pef_tbl.eta(idx);
    end
end

% ---- Diverging red-blue colourmap (local) ----------------------------------
function map = redblue_local(n)
    if mod(n, 2) == 1, n = n + 1; end
    h = n / 2;
    map = [[linspace(0.05, 1, h)' linspace(0.30, 1, h)' linspace(0.55, 1, h)']; ...
           [linspace(1, 0.65, h)' linspace(1, 0.05, h)' linspace(1, 0.10, h)']];
end
