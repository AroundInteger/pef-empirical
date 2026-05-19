%% PEF-Information Content Boundary Analysis
% Investigate I(X;Y) behavior in Fisher regime and at κ,ρ extremities
% Explore theoretical boundaries and special cases

clear; close all; clc;

fprintf('=== PEF-INFORMATION CONTENT BOUNDARY ANALYSIS ===\n');
fprintf('Investigating I(X;Y) behavior at boundaries\n\n');

%% 1. THEORETICAL FRAMEWORK
fprintf('1. THEORETICAL FRAMEWORK\n');
fprintf('=======================\n');

fprintf('PEF Formula: PEF = (1 + κ) / (1 + κ - 2√κ × ρ)\n');
fprintf('Information Content: I(X;Y) = 1 - H(Φ(δ / (2σ_A√((1 + κ) / PEF))))\n\n');

fprintf('Where:\n');
fprintf('- κ = σ²_B/σ²_A (variance ratio)\n');
fprintf('- ρ = correlation between A and B\n');
fprintf('- δ = mean difference between teams\n');
fprintf('- σ_A = standard deviation of team A\n');
fprintf('- H = entropy function\n');
fprintf('- Φ = normal CDF\n\n');

%% 2. FISHER REGIME ANALYSIS
fprintf('2. FISHER REGIME ANALYSIS\n');
fprintf('========================\n');

fprintf('Fisher regime: κ = 1, ρ = 0 (equal variances, no correlation)\n');
fprintf('This represents the classical paired t-test scenario\n\n');

% Fisher regime
kappa_fisher = 1.0;
rho_fisher = 0.0;
pef_fisher = (1 + kappa_fisher) / (1 + kappa_fisher - 2 * sqrt(kappa_fisher) * rho_fisher);

fprintf('Fisher Regime Parameters:\n');
fprintf('κ = %.1f, ρ = %.1f\n', kappa_fisher, rho_fisher);
fprintf('PEF = %.3f\n', pef_fisher);

% Calculate information content for different δ values
delta_values = [0.1, 0.5, 1.0, 2.0, 5.0];
sigma_a = 1.0;

fprintf('\nInformation Content in Fisher Regime:\n');
fprintf('δ\tI(X;Y)\tInterpretation\n');
fprintf('---\t------\t-------------\n');

for i = 1:length(delta_values)
    delta = delta_values(i);
    
    % Calculate information content
    separability = normcdf(delta / (2 * sigma_a * sqrt((1 + kappa_fisher) / pef_fisher)));
    if separability > 0 && separability < 1
        i_xy = 1 - (-separability * log2(separability) - (1 - separability) * log2(1 - separability));
    else
        i_xy = 0;
    end
    
    if delta < 0.5
        interpretation = 'Very low signal';
    elseif delta < 1.0
        interpretation = 'Low signal';
    elseif delta < 2.0
        interpretation = 'Moderate signal';
    elseif delta < 5.0
        interpretation = 'High signal';
    else
        interpretation = 'Very high signal';
    end
    
    fprintf('%.1f\t%.3f\t%s\n', delta, i_xy, interpretation);
end

%% 3. KAPPA EXTREMITIES
fprintf('\n3. KAPPA EXTREMITIES\n');
fprintf('===================\n');

fprintf('κ → 0: Team B has much lower variance than Team A\n');
fprintf('κ → ∞: Team B has much higher variance than Team A\n\n');

% Test kappa extremities
kappa_values = [0.01, 0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 100.0];
rho_test = 0.0;  % No correlation for simplicity
delta_test = 1.0;
sigma_a = 1.0;

fprintf('Kappa Extremity Analysis (ρ = 0, δ = 1):\n');
fprintf('κ\tPEF\tI(X;Y)\tInterpretation\n');
fprintf('---\t-----\t------\t-------------\n');

for i = 1:length(kappa_values)
    kappa = kappa_values(i);
    
    % Calculate PEF
    pef = (1 + kappa) / (1 + kappa - 2 * sqrt(kappa) * rho_test);
    
    % Calculate information content
    separability = normcdf(delta_test / (2 * sigma_a * sqrt((1 + kappa) / pef)));
    if separability > 0 && separability < 1
        i_xy = 1 - (-separability * log2(separability) - (1 - separability) * log2(1 - separability));
    else
        i_xy = 0;
    end
    
    if kappa < 0.1
        interpretation = 'Very low B variance';
    elseif kappa < 0.5
        interpretation = 'Low B variance';
    elseif kappa < 2.0
        interpretation = 'Moderate variance ratio';
    elseif kappa < 10.0
        interpretation = 'High B variance';
    else
        interpretation = 'Very high B variance';
    end
    
    fprintf('%.2f\t%.3f\t%.3f\t%s\n', kappa, pef, i_xy, interpretation);
end

%% 4. RHO EXTREMITIES
fprintf('\n4. RHO EXTREMITIES\n');
fprintf('=================\n');

fprintf('ρ → -1: Perfect negative correlation\n');
fprintf('ρ → +1: Perfect positive correlation\n');
fprintf('ρ = 0: No correlation (Fisher regime)\n\n');

% Test rho extremities
rho_values = [-0.99, -0.8, -0.5, -0.2, 0.0, 0.2, 0.5, 0.8, 0.99];
kappa_test = 1.0;  % Equal variances for simplicity
delta_test = 1.0;
sigma_a = 1.0;

fprintf('Rho Extremity Analysis (κ = 1, δ = 1):\n');
fprintf('ρ\tPEF\tI(X;Y)\tInterpretation\n');
fprintf('---\t-----\t------\t-------------\n');

for i = 1:length(rho_values)
    rho = rho_values(i);
    
    % Calculate PEF
    pef = (1 + kappa_test) / (1 + kappa_test - 2 * sqrt(kappa_test) * rho);
    
    % Calculate information content
    separability = normcdf(delta_test / (2 * sigma_a * sqrt((1 + kappa_test) / pef)));
    if separability > 0 && separability < 1
        i_xy = 1 - (-separability * log2(separability) - (1 - separability) * log2(1 - separability));
    else
        i_xy = 0;
    end
    
    if rho < -0.8
        interpretation = 'Very strong negative correlation';
    elseif rho < -0.5
        interpretation = 'Strong negative correlation';
    elseif rho < -0.2
        interpretation = 'Moderate negative correlation';
    elseif rho < 0.2
        interpretation = 'Weak correlation';
    elseif rho < 0.5
        interpretation = 'Moderate positive correlation';
    elseif rho < 0.8
        interpretation = 'Strong positive correlation';
    else
        interpretation = 'Very strong positive correlation';
    end
    
    fprintf('%.2f\t%.3f\t%.3f\t%s\n', rho, pef, i_xy, interpretation);
end

%% 5. SPECIAL CASES
fprintf('\n5. SPECIAL CASES\n');
fprintf('===============\n');

% Case 1: Perfect negative correlation
fprintf('Case 1: Perfect Negative Correlation (ρ = -1)\n');
kappa_case1 = 1.0;
rho_case1 = -1.0;
pef_case1 = (1 + kappa_case1) / (1 + kappa_case1 - 2 * sqrt(kappa_case1) * rho_case1);
fprintf('PEF = %.3f (undefined - division by zero)\n', pef_case1);
fprintf('This represents perfect anti-correlation - teams are mirror images\n\n');

% Case 2: Perfect positive correlation
fprintf('Case 2: Perfect Positive Correlation (ρ = +1)\n');
kappa_case2 = 1.0;
rho_case2 = 1.0;
pef_case2 = (1 + kappa_case2) / (1 + kappa_case2 - 2 * sqrt(kappa_case2) * rho_case2);
fprintf('PEF = %.3f\n', pef_case2);
fprintf('This represents perfect correlation - teams move together\n\n');

% Case 3: Zero variance ratio
fprintf('Case 3: Zero Variance Ratio (κ = 0)\n');
kappa_case3 = 0.0;
rho_case3 = 0.0;
pef_case3 = (1 + kappa_case3) / (1 + kappa_case3 - 2 * sqrt(kappa_case3) * rho_case3);
fprintf('PEF = %.3f\n', pef_case3);
fprintf('This represents Team B having zero variance\n\n');

% Case 4: Infinite variance ratio
fprintf('Case 4: Infinite Variance Ratio (κ → ∞)\n');
kappa_case4 = 1000.0;  % Approximate infinity
rho_case4 = 0.0;
pef_case4 = (1 + kappa_case4) / (1 + kappa_case4 - 2 * sqrt(kappa_case4) * rho_case4);
fprintf('PEF ≈ %.3f (approaches 1)\n', pef_case4);
fprintf('This represents Team B having infinite variance\n\n');

%% 6. ASYMPTOTIC BEHAVIOR
fprintf('6. ASYMPTOTIC BEHAVIOR\n');
fprintf('=====================\n');

fprintf('As κ → 0:\n');
fprintf('- PEF → 1\n');
fprintf('- Var(A-B) → σ²_A\n');
fprintf('- I(X;Y) → 1 - H(Φ(δ/(2σ_A)))\n');
fprintf('- Information content depends only on δ/σ_A ratio\n\n');

fprintf('As κ → ∞:\n');
fprintf('- PEF → 1\n');
fprintf('- Var(A-B) → σ²_A(1 + κ) ≈ κσ²_A\n');
fprintf('- I(X;Y) → 1 - H(Φ(δ/(2σ_A√κ)))\n');
fprintf('- Information content decreases as κ increases\n\n');

fprintf('As ρ → -1:\n');
fprintf('- PEF → ∞ (undefined)\n');
fprintf('- Var(A-B) → σ²_A(1 + κ + 2√κ) = (√κ + 1)²σ²_A\n');
fprintf('- Perfect anti-correlation maximizes variance\n\n');

fprintf('As ρ → +1:\n');
fprintf('- PEF → (1 + κ)/(1 + κ - 2√κ) = (√κ + 1)/(√κ - 1)\n');
fprintf('- Var(A-B) → σ²_A(1 + κ - 2√κ) = (√κ - 1)²σ²_A\n');
fprintf('- Perfect correlation minimizes variance\n\n');

%% 7. FISHER REGIME DEEP DIVE
fprintf('7. FISHER REGIME DEEP DIVE\n');
fprintf('=========================\n');

fprintf('In the Fisher regime (κ = 1, ρ = 0):\n');
fprintf('- PEF = 1 (no efficiency gain or loss)\n');
fprintf('- Var(A-B) = 2σ²_A\n');
fprintf('- I(X;Y) = 1 - H(Φ(δ/(2σ_A√2)))\n');
fprintf('- This is the baseline case for comparison\n\n');

% Calculate Fisher regime information content for different signal levels
delta_fisher = [0.1, 0.5, 1.0, 2.0, 5.0];
sigma_a = 1.0;

fprintf('Fisher Regime Information Content:\n');
fprintf('δ/σ_A\tI(X;Y)\tSNR\tInterpretation\n');
fprintf('------\t------\t---\t-------------\n');

for i = 1:length(delta_fisher)
    delta = delta_fisher(i);
    
    % Calculate SNR
    snr = delta^2 / (2 * sigma_a^2);
    
    % Calculate information content
    separability = normcdf(delta / (2 * sigma_a * sqrt(2)));
    if separability > 0 && separability < 1
        i_xy = 1 - (-separability * log2(separability) - (1 - separability) * log2(1 - separability));
    else
        i_xy = 0;
    end
    
    if delta < 0.5
        interpretation = 'Very weak signal';
    elseif delta < 1.0
        interpretation = 'Weak signal';
    elseif delta < 2.0
        interpretation = 'Moderate signal';
    elseif delta < 5.0
        interpretation = 'Strong signal';
    else
        interpretation = 'Very strong signal';
    end
    
    fprintf('%.1f\t%.3f\t%.3f\t%s\n', delta, snr, i_xy, interpretation);
end

%% 8. COMPETITIVE DYNAMICS REGIME
fprintf('\n8. COMPETITIVE DYNAMICS REGIME\n');
fprintf('=============================\n');

fprintf('Competitive dynamics: κ > 1, ρ < 0\n');
fprintf('This is where PEF < 1 but ML improvement is observed\n\n');

% Test competitive dynamics scenarios
kappa_comp = [1.2, 1.5, 2.0, 3.0, 5.0];
rho_comp = [-0.1, -0.2, -0.3, -0.5, -0.8];
delta_comp = 1.0;
sigma_a = 1.0;

fprintf('Competitive Dynamics Analysis (δ = 1):\n');
fprintf('κ\tρ\tPEF\tI(X;Y)\tInterpretation\n');
fprintf('---\t---\t-----\t------\t-------------\n');

for i = 1:length(kappa_comp)
    for j = 1:length(rho_comp)
        kappa = kappa_comp(i);
        rho = rho_comp(j);
        
        % Calculate PEF
        pef = (1 + kappa) / (1 + kappa - 2 * sqrt(kappa) * rho);
        
        % Calculate information content
        separability = normcdf(delta_comp / (2 * sigma_a * sqrt((1 + kappa) / pef)));
        if separability > 0 && separability < 1
            i_xy = 1 - (-separability * log2(separability) - (1 - separability) * log2(1 - separability));
        else
            i_xy = 0;
        end
        
        if pef < 0.8
            interpretation = 'Strong competitive dynamics';
        elseif pef < 1.0
            interpretation = 'Moderate competitive dynamics';
        else
            interpretation = 'Weak competitive dynamics';
        end
        
        fprintf('%.1f\t%.1f\t%.3f\t%.3f\t%s\n', kappa, rho, pef, i_xy, interpretation);
    end
end

%% 9. VISUALIZATION
fprintf('\n9. CREATING VISUALIZATION\n');
fprintf('=========================\n');

create_boundary_visualization(kappa_values, rho_values, delta_values, delta_fisher);

fprintf('Boundary analysis complete!\n');

%% HELPER FUNCTIONS

function create_boundary_visualization(kappa_values, rho_values, delta_values, delta_fisher)
    % Create comprehensive boundary visualization
    
    figure('Position', [100, 100, 1400, 1000]);
    
    % Subplot 1: Kappa vs Information Content
    subplot(2, 4, 1);
    pef_kappa = (1 + kappa_values) ./ (1 + kappa_values - 2 * sqrt(kappa_values) * 0);
    i_kappa = zeros(size(kappa_values));
    for i = 1:length(kappa_values)
        separability = normcdf(1 / (2 * 1 * sqrt((1 + kappa_values(i)) / pef_kappa(i))));
        if separability > 0 && separability < 1
            i_kappa(i) = 1 - (-separability * log2(separability) - (1 - separability) * log2(1 - separability));
        end
    end
    semilogx(kappa_values, i_kappa, 'b-o', 'LineWidth', 2, 'MarkerSize', 6);
    xlabel('κ (Variance Ratio)');
    ylabel('I(X;Y)');
    title('Information Content vs Kappa');
    grid on;
    
    % Subplot 2: Rho vs Information Content
    subplot(2, 4, 2);
    pef_rho = (1 + 1) ./ (1 + 1 - 2 * sqrt(1) * rho_values);
    i_rho = zeros(size(rho_values));
    for i = 1:length(rho_values)
        separability = normcdf(1 / (2 * 1 * sqrt((1 + 1) / pef_rho(i))));
        if separability > 0 && separability < 1
            i_rho(i) = 1 - (-separability * log2(separability) - (1 - separability) * log2(1 - separability));
        end
    end
    plot(rho_values, i_rho, 'r-o', 'LineWidth', 2, 'MarkerSize', 6);
    xlabel('ρ (Correlation)');
    ylabel('I(X;Y)');
    title('Information Content vs Rho');
    grid on;
    
    % Subplot 3: Delta vs Information Content (Fisher regime)
    subplot(2, 4, 3);
    i_delta = zeros(size(delta_fisher));
    for i = 1:length(delta_fisher)
        separability = normcdf(delta_fisher(i) / (2 * 1 * sqrt(2)));
        if separability > 0 && separability < 1
            i_delta(i) = 1 - (-separability * log2(separability) - (1 - separability) * log2(1 - separability));
        end
    end
    plot(delta_fisher, i_delta, 'g-o', 'LineWidth', 2, 'MarkerSize', 6);
    xlabel('δ (Mean Difference)');
    ylabel('I(X;Y)');
    title('Fisher Regime: I(X;Y) vs Delta');
    grid on;
    
    % Subplot 4: PEF vs Information Content
    subplot(2, 4, 4);
    pef_range = linspace(0.5, 3, 100);
    i_pef = zeros(size(pef_range));
    for i = 1:length(pef_range)
        separability = normcdf(1 / (2 * 1 * sqrt(2 / pef_range(i))));
        if separability > 0 && separability < 1
            i_pef(i) = 1 - (-separability * log2(separability) - (1 - separability) * log2(1 - separability));
        end
    end
    plot(pef_range, i_pef, 'm-o', 'LineWidth', 2, 'MarkerSize', 6);
    xlabel('PEF');
    ylabel('I(X;Y)');
    title('PEF vs Information Content');
    grid on;
    
    % Subplot 5: Kappa-Rho heatmap
    subplot(2, 4, 5);

    yvals = linspace(0.01,2,200);   % κ
    xvals = linspace(-0.99,0.99,200);% ρ


    [R, K] = meshgrid(xvals, yvals);
    PEF = (1 + K) ./ (1 + K - 2 * sqrt(K) .* R);
    I_XY = zeros(size(K));
    for i = 1:size(K, 1)
        for j = 1:size(K, 2)
            separability = normcdf(1 / (2 * 1 * sqrt((1 + K(i,j)) / PEF(i,j))));
            if separability > 0 && separability < 1
                I_XY(i,j) = 1 - (-separability * log2(separability) - (1 - separability) * log2(1 - separability));
            end
        end
    end
    imagesc(xvals, yvals, I_XY);
    colorbar;
    ylabel('κ');
    xlabel('ρ');
    title('Information Content Heatmap');
    
    % Subplot 6: Asymptotic behavior
    subplot(2, 4, 6);
    kappa_asymp = logspace(-2, 2, 100);
    pef_asymp = (1 + kappa_asymp) ./ (1 + kappa_asymp);
    i_asymp = zeros(size(kappa_asymp));
    for i = 1:length(kappa_asymp)
        separability = normcdf(1 / (2 * 1 * sqrt((1 + kappa_asymp(i)) / pef_asymp(i))));
        if separability > 0 && separability < 1
            i_asymp(i) = 1 - (-separability * log2(separability) - (1 - separability) * log2(1 - separability));
        end
    end
    loglog(kappa_asymp, i_asymp, 'k-', 'LineWidth', 2);
    xlabel('κ');
    ylabel('I(X;Y)');
    title('Asymptotic Behavior');
    grid on;
    
    % Subplot 7: Special cases
    subplot(2, 4, 7);
    axis off;
    text(0.1, 0.9, 'SPECIAL CASES', 'FontSize', 16, 'FontWeight', 'bold');
    text(0.1, 0.8, 'Fisher Regime (κ=1, ρ=0):', 'FontSize', 12, 'FontWeight', 'bold');
    text(0.1, 0.7, '• PEF = 1 (baseline)', 'FontSize', 10);
    text(0.1, 0.6, '• I(X;Y) = 1 - H(Φ(δ/(2σ√2)))', 'FontSize', 10);
    text(0.1, 0.5, 'Perfect Correlation (ρ=1):', 'FontSize', 12, 'FontWeight', 'bold');
    text(0.1, 0.4, '• PEF = (√κ+1)/(√κ-1)', 'FontSize', 10);
    text(0.1, 0.3, '• Minimum variance', 'FontSize', 10);
    text(0.1, 0.2, 'Perfect Anti-Correlation (ρ=-1):', 'FontSize', 12, 'FontWeight', 'bold');
    text(0.1, 0.1, '• PEF → ∞ (undefined)', 'FontSize', 10);
    text(0.1, 0.0, '• Maximum variance', 'FontSize', 10);
    
    % Subplot 8: Summary
    subplot(2, 4, 8);
    axis off;
    text(0.1, 0.9, 'BOUNDARY SUMMARY', 'FontSize', 16, 'FontWeight', 'bold');
    text(0.1, 0.8, 'κ → 0: I(X;Y) → 1 - H(Φ(δ/(2σ)))', 'FontSize', 10);
    text(0.1, 0.7, 'κ → ∞: I(X;Y) → 1 - H(Φ(δ/(2σ√κ)))', 'FontSize', 10);
    text(0.1, 0.6, 'ρ → -1: PEF → ∞, Max variance', 'FontSize', 10);
    text(0.1, 0.5, 'ρ → +1: PEF → (√κ+1)/(√κ-1)', 'FontSize', 10);
    text(0.1, 0.4, 'Fisher: PEF = 1, Baseline case', 'FontSize', 10);
    text(0.1, 0.3, 'Competitive: PEF < 1, High I(X;Y)', 'FontSize', 10);
    
    sgtitle('PEF-Information Content Boundary Analysis', 'FontSize', 16, 'FontWeight', 'bold');
    
    % Save figure
    fig_file = fullfile(pwd, '..', 'pef_information_content_boundaries_visualization.png');
    saveas(gcf, fig_file);
    fprintf('Visualization saved to: %s\n', fig_file);
end
