classdef pef_figure_style
%PEF_FIGURE_STYLE  Shared layout, colours, and drawing helpers for PEF figures.
%
%  Used by main-text figures (Figures 1--3), supplementary figures (S1--S8),
%  and finalize diagnostics.  Call static methods directly, e.g.:
%    cfg = pef_figure_style.config();
%    fig = pef_figure_style.new_figure(1400, 820);
%    pef_figure_style.draw_eta_surface(ax);
%    pef_figure_style.export_figure(fig, fpath);

    methods (Static)

        function cfg = config()
            cfg.rho_min = -0.999;
            cfg.rho_max =  0.999;
            cfg.kap_min =  0.001;
            cfg.kap_max =  3.000;
            cfg.fs_label  = 16;
            cfg.fs_tick   = 12;
            cfg.fs_quad   = 16;
            cfg.fs_title  = 13;
            cfg.fs_panel  = 11;
            cfg.eta_color_lo = 0.4;
            cfg.eta_color_hi = 10.0;
            cfg.I_caxis = [0, 0.30];
            cfg.I_panel_caxis = [0, 1.0];
            cfg.surface_alpha = 0.55;
            cfg.quad_line_width = 1.5;
            cfg.dpi = 300;
            cfg.rugby = [0, 119, 187] / 255;
            cfg.football = [230, 159, 0] / 255;
            cfg.migrate = [213, 94, 0] / 255;
            cfg.quad_text = [0.2, 0.2, 0.2];
            cfg.quad_positions = [ ...
                0.88,  2.65; ...
                0.88,  0.35; ...
               -0.92,  0.35; ...
               -0.92,  2.65];
            cfg.quad_keys = {'Q1', 'Q2', 'Q3', 'Q4'};
            cfg.bar_series = [ ...
                0.12, 0.47, 0.71; ...
                0.89, 0.47, 0.07; ...
                0.55, 0.55, 0.20];
        end

        function c = quadrant_color(q)
            qmap = pef_figure_style.quadrant_map();
            key = char(string(q));
            if isKey(qmap, key)
                c = qmap(key);
            else
                c = [0.4, 0.4, 0.4];
            end
        end

        function qmap = quadrant_map()
            qmap = containers.Map( ...
                {'Q1', 'Q2', 'Q3', 'Q4'}, ...
                {[0.20 0.63 0.17], [0.12 0.47 0.71], [0.89 0.47 0.07], [0.77 0.15 0.16]});
        end

        function fig = new_figure(width, height)
            if nargin < 1, width = 900; end
            if nargin < 2, height = 650; end
            fig = figure('Color', 'w', 'Position', [100, 100, width, height], ...
                'Visible', 'off');
        end

        function export_figure(fig, fpath)
            cfg = pef_figure_style.config();
            exportgraphics(fig, fpath, 'Resolution', cfg.dpi);
        end

        function [r_g, k_g, R, K] = landscape_grid(n_r, n_k)
            if nargin < 1, n_r = 500; end
            if nargin < 2, n_k = 500; end
            cfg = pef_figure_style.config();
            r_g = linspace(cfg.rho_min, cfg.rho_max, n_r);
            k_g = linspace(cfg.kap_min, cfg.kap_max, n_k);
            [R, K] = meshgrid(r_g, k_g);
        end

        function eta_s = compute_eta(R, K)
            den = 1 + K - 2 * sqrt(K) .* R;
            eta_s = (1 + K) ./ den;
            bad = ~isfinite(eta_s) | eta_s <= 0 | den <= 0;
            eta_s(bad) = NaN;
        end

        function I_xy = compute_mi_grid(K, R, delta, sigmaA)
            eta_s = pef_figure_style.compute_eta(R, K);
            bad = isnan(eta_s);
            sep = normcdf(delta ./ (2 * sigmaA * sqrt((1 + K) ./ eta_s)));
            sep = min(max(sep, 1e-12), 1 - 1e-12);
            H = -sep .* log2(sep) - (1 - sep) .* log2(1 - sep);
            I_xy = 1 - H;
            I_xy(bad) = NaN;
        end

        function draw_admissibility_boundary(ax, cfg)
            if nargin < 2, cfg = pef_figure_style.config(); end
            k_bnd = linspace(cfg.kap_min, cfg.kap_max, 300);
            rho_bnd = (1 + k_bnd) ./ (2 * sqrt(k_bnd));
            in_plot = rho_bnd >= cfg.rho_min & rho_bnd <= cfg.rho_max;
            plot(ax, rho_bnd(in_plot), k_bnd(in_plot), 'k:', 'LineWidth', 1.0, ...
                'HandleVisibility', 'off');
        end

        function draw_quadrant_boundaries(ax, cfg)
            if nargin < 2, cfg = pef_figure_style.config(); end
            plot(ax, [cfg.rho_min, cfg.rho_max], [1, 1], 'k--', ...
                'LineWidth', cfg.quad_line_width, 'HandleVisibility', 'off');
            plot(ax, [0, 0], [cfg.kap_min, cfg.kap_max], 'k--', ...
                'LineWidth', cfg.quad_line_width, 'HandleVisibility', 'off');
        end

        function draw_quadrant_labels(ax, cfg, text_color)
            if nargin < 2, cfg = pef_figure_style.config(); end
            if nargin < 3, text_color = cfg.quad_text; end
            for qi = 1:4
                text(ax, cfg.quad_positions(qi, 1), cfg.quad_positions(qi, 2), ...
                    cfg.quad_keys{qi}, 'FontSize', cfg.fs_quad, ...
                    'FontWeight', 'bold', 'Color', text_color);
            end
        end

        function style_landscape_axes(ax, cfg, xlabel_str, ylabel_str)
            if nargin < 2, cfg = pef_figure_style.config(); end
            if nargin < 3
                xlabel_str = 'Pairwise correlation \rho';
            end
            if nargin < 4
                ylabel_str = 'Variance ratio \kappa = \sigma_B^2/\sigma_A^2';
            end
            xlim(ax, [cfg.rho_min, cfg.rho_max]);
            ylim(ax, [cfg.kap_min, cfg.kap_max]);
            xlabel(ax, xlabel_str, 'FontSize', cfg.fs_label);
            ylabel(ax, ylabel_str, 'FontSize', cfg.fs_label);
            set(ax, 'FontSize', cfg.fs_tick, 'Box', 'on');
            grid(ax, 'on');
        end

        function style_scatter_axes(ax, cfg)
            if nargin < 2, cfg = pef_figure_style.config(); end
            set(ax, 'FontSize', cfg.fs_tick, 'Box', 'on', 'GridAlpha', 0.2);
            grid(ax, 'on');
        end

        function cb = add_eta_colorbar(ax, cfg)
            if nargin < 2, cfg = pef_figure_style.config(); end
            cb = colorbar(ax);
            eta_ticks = [0.5, 1, 2, 3, 5, 10];
            cb.Ticks = log10(eta_ticks);
            cb.TickLabels = arrayfun(@(v) sprintf('%.0g', v), eta_ticks, ...
                'UniformOutput', false);
            cb.FontSize = cfg.fs_tick;
            cb.Label.String = '\eta';
            cb.Label.FontSize = cfg.fs_label;
        end

        function cb = add_I_colorbar(ax, cfg, caxis_range)
            if nargin < 2, cfg = pef_figure_style.config(); end
            if nargin < 3, caxis_range = cfg.I_caxis; end
            cb = colorbar(ax);
            cb.FontSize = cfg.fs_tick;
            cb.Label.String = 'I(X;Y)  [bits]';
            cb.Label.FontSize = cfg.fs_label;
            caxis(ax, caxis_range);
        end

        function h_img = draw_eta_surface(ax, cfg, show_contours)
            if nargin < 2, cfg = pef_figure_style.config(); end
            if nargin < 3, show_contours = true; end
            [r_g, k_g, R, K] = pef_figure_style.landscape_grid();
            eta_s = pef_figure_style.compute_eta(R, K);
            Z = log10(eta_s);
            Z(Z > log10(cfg.eta_color_hi)) = log10(cfg.eta_color_hi);
            h_img = imagesc(ax, r_g, k_g, Z);
            set(ax, 'YDir', 'normal');
            set(h_img, 'AlphaData', double(~isnan(Z)) * cfg.surface_alpha);
            colormap(ax, pef_figure_style.redblue_map(256));
            caxis(ax, [log10(cfg.eta_color_lo), log10(cfg.eta_color_hi)]);
            hold(ax, 'on');
            if show_contours
                levels = [0.5, 0.75, 1, 1.25, 1.5, 2, 3, 5];
                [C, h] = contour(ax, R, K, eta_s, levels, 'k-', 'LineWidth', 0.7);
                clabel(C, h, 'FontSize', cfg.fs_tick, 'Color', [0.25, 0.25, 0.25]);
                h.HandleVisibility = 'off';
            end
            pef_figure_style.draw_admissibility_boundary(ax, cfg);
            pef_figure_style.draw_quadrant_boundaries(ax, cfg);
            pef_figure_style.draw_quadrant_labels(ax, cfg);
            pef_figure_style.style_landscape_axes(ax, cfg);
        end

        function h_img = draw_I_surface(ax, delta, sigmaA, cfg, caxis_range, show_contours)
            if nargin < 4, cfg = pef_figure_style.config(); end
            if nargin < 5, caxis_range = cfg.I_caxis; end
            if nargin < 6, show_contours = true; end
            if nargin < 3, sigmaA = 1.0; end
            if nargin < 2, delta = 1.0; end
            [r_g, k_g, R, K] = pef_figure_style.landscape_grid();
            I_xy = pef_figure_style.compute_mi_grid(K, R, delta, sigmaA);
            h_img = imagesc(ax, r_g, k_g, I_xy);
            set(ax, 'YDir', 'normal');
            set(h_img, 'AlphaData', double(~isnan(I_xy)) * cfg.surface_alpha);
            colormap(ax, parula(256));
            caxis(ax, caxis_range);
            hold(ax, 'on');
            if show_contours
                if max(caxis_range) <= 0.35
                    I_levels = [0.01, 0.02, 0.05, 0.08, 0.10, 0.15, 0.20, 0.25];
                else
                    I_levels = 0:0.1:1;
                end
                [C, h] = contour(ax, R, K, I_xy, I_levels, 'k-', 'LineWidth', 0.7);
                clabel(C, h, 'FontSize', cfg.fs_tick, 'Color', [0.25, 0.25, 0.25]);
                h.HandleVisibility = 'off';
            end
            pef_figure_style.draw_admissibility_boundary(ax, cfg);
            pef_figure_style.draw_quadrant_boundaries(ax, cfg);
            pef_figure_style.draw_quadrant_labels(ax, cfg);
            pef_figure_style.style_landscape_axes(ax, cfg);
        end

        function scatter_by_quadrant(ax, x, y, quadrant, cfg, marker_size)
            if nargin < 5, cfg = pef_figure_style.config(); end
            if nargin < 6, marker_size = 45; end
            hold(ax, 'on');
            quads = cfg.quad_keys;
            for qi = 1:numel(quads)
                qm = quadrant == string(quads{qi});
                if ~any(qm), continue; end
                scatter(ax, x(qm), y(qm), marker_size, 'filled', ...
                    'MarkerFaceColor', pef_figure_style.quadrant_color(quads{qi}), ...
                    'MarkerEdgeColor', [0.15, 0.15, 0.15], 'LineWidth', 0.4, ...
                    'MarkerFaceAlpha', 0.85, 'DisplayName', quads{qi});
            end
        end

        function map = redblue_map(n)
            if mod(n, 2) == 1, n = n + 1; end
            h = n / 2;
            map = [ ...
                [linspace(0.05, 1, h)', linspace(0.30, 1, h)', linspace(0.55, 1, h)']; ...
                [linspace(1, 0.65, h)', linspace(1, 0.05, h)', linspace(1, 0.10, h)']];
        end

        function lbl = exemplar_label(sport, kpi, quadrant)
            kp = strrep(char(kpi), '_', ' ');
            if nargin >= 3 && ~isempty(quadrant)
                lbl = sprintf('%s: %s', char(quadrant), kp);
            else
                lbl = sprintf('%s: %s', char(sport), kp);
            end
        end

    end
end
