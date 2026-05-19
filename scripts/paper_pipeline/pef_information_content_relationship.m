%% PEF-Information Content Relationship Investigation
% Find the functional relationship between PEF and Information Content
% Account for pairwise distributions properly

clear; close all; clc;

fprintf('=== PEF-INFORMATION CONTENT RELATIONSHIP INVESTIGATION ===\n');
fprintf('Finding the correct functional relationship\n\n');

%% 1. THEORETICAL ANALYSIS
fprintf('1. THEORETICAL ANALYSIS\n');
fprintf('======================\n');

fprintf('PEF Formula: PEF = (1 + κ) / (1 + κ - 2√κ × ρ)\n');
fprintf('Where: κ = σ²_B/σ²_A, ρ = correlation between A and B\n\n');

fprintf('Information Content for Paired Distributions:\n');
fprintf('For binary classification with paired samples (A, B):\n');
fprintf('- Outcome: Y = 1 if A > B, Y = 0 if A ≤ B\n');
fprintf('- Feature: X = A - B (relative feature)\n');
fprintf('- Information Content: I(X;Y) = H(Y) - H(Y|X)\n\n');

%% 2. DERIVE THEORETICAL RELATIONSHIP
fprintf('2. DERIVING THEORETICAL RELATIONSHIP\n');
fprintf('====================================\n');

fprintf('For paired distributions with correlation ρ:\n');
fprintf('Var(A - B) = σ²_A + σ²_B - 2ρσ_Aσ_B\n');
fprintf('Var(A - B) = σ²_A(1 + κ - 2ρ√κ)\n\n');

fprintf('Signal-to-Noise Ratio for relative features:\n');
fprintf('SNR_rel = (μ_A - μ_B)² / Var(A - B)\n');
fprintf('SNR_rel = δ² / [σ²_A(1 + κ - 2ρ√κ)]\n');
fprintf('SNR_rel = (δ²/σ²_A) / (1 + κ - 2ρ√κ)\n\n');

fprintf('Information Content (approximation):\n');
fprintf('I(X;Y) ≈ 0.5 × log₂(1 + SNR)\n');
fprintf('I_rel ≈ 0.5 × log₂(1 + (δ²/σ²_A) / (1 + κ - 2ρ√κ))\n\n');

fprintf('PEF Relationship:\n');
fprintf('PEF = (1 + κ) / (1 + κ - 2√κ × ρ)\n');
fprintf('1/PEF = (1 + κ - 2√κ × ρ) / (1 + κ)\n');
fprintf('1/PEF = 1 - (2√κ × ρ) / (1 + κ)\n\n');

fprintf('Therefore:\n');
fprintf('I_rel ≈ 0.5 × log₂(1 + (δ²/σ²_A) × PEF / (1 + κ))\n');
fprintf('I_rel ≈ 0.5 × log₂(1 + (δ²/σ²_A) × PEF / (1 + κ))\n\n');

%% 3. NUMERICAL VERIFICATION
fprintf('3. NUMERICAL VERIFICATION\n');
fprintf('=========================\n');

% Test scenarios
scenarios = struct();

% Scenario 1: High competitive dynamics
scenarios(1).name = 'High Competitive Dynamics';
scenarios(1).kappa = 2.0;
scenarios(1).rho = -0.3;
scenarios(1).delta = 1.0;
scenarios(1).sigma_a = 1.0;

% Scenario 2: Moderate competitive dynamics
scenarios(2).name = 'Moderate Competitive Dynamics';
scenarios(2).kappa = 1.2;
scenarios(2).rho = -0.15;
scenarios(2).delta = 1.0;
scenarios(2).sigma_a = 1.0;

% Scenario 3: Environmental dynamics
scenarios(3).name = 'Environmental Dynamics';
scenarios(3).kappa = 1.1;
scenarios(3).rho = 0.4;
scenarios(3).delta = 1.0;
scenarios(3).sigma_a = 1.0;

% Scenario 4: Balanced dynamics
scenarios(4).name = 'Balanced Dynamics';
scenarios(4).kappa = 1.0;
scenarios(4).rho = 0.0;
scenarios(4).delta = 1.0;
scenarios(4).sigma_a = 1.0;

fprintf('Testing theoretical relationship:\n\n');

results = struct();
results.scenario = {};
results.kappa = [];
results.rho = [];
results.pef = [];
results.snr_abs = [];
results.snr_rel = [];
results.i_abs = [];
results.i_rel = [];
results.i_theoretical = [];
results.correlation = [];

for i = 1:length(scenarios)
    s = scenarios(i);
    fprintf('Testing %s:\n', s.name);
    
    % Calculate PEF
    pef = (1 + s.kappa) / (1 + s.kappa - 2 * sqrt(s.kappa) * s.rho);
    
    % Calculate variances
    var_a = s.sigma_a^2;
    var_b = s.kappa * var_a;
    var_rel = var_a + var_b - 2 * s.rho * s.sigma_a * sqrt(var_b);
    
    % Calculate SNRs
    snr_abs = s.delta^2 / var_a;  % For absolute features (using A only)
    snr_rel = s.delta^2 / var_rel;  % For relative features
    
    % Calculate information content
    i_abs = 0.5 * log2(1 + snr_abs);
    i_rel = 0.5 * log2(1 + snr_rel);
    
    % Theoretical relationship
    i_theoretical = 0.5 * log2(1 + (s.delta^2 / var_a) * pef / (1 + s.kappa));
    
    % Calculate correlation between PEF and information content
    correlation = corr([pef], [i_rel]);
    
    % Store results
    results.scenario{end+1} = s.name;
    results.kappa(end+1) = s.kappa;
    results.rho(end+1) = s.rho;
    results.pef(end+1) = pef;
    results.snr_abs(end+1) = snr_abs;
    results.snr_rel(end+1) = snr_rel;
    results.i_abs(end+1) = i_abs;
    results.i_rel(end+1) = i_rel;
    results.i_theoretical(end+1) = i_theoretical;
    results.correlation(end+1) = correlation;
    
    fprintf('  κ=%.3f, ρ=%.3f, PEF=%.3f\n', s.kappa, s.rho, pef);
    fprintf('  SNR_abs=%.3f, SNR_rel=%.3f\n', snr_abs, snr_rel);
    fprintf('  I_abs=%.3f, I_rel=%.3f, I_theoretical=%.3f\n', i_abs, i_rel, i_theoretical);
    fprintf('  PEF-I_rel correlation: %.3f\n', correlation);
    fprintf('\n');
end

%% 4. CORRECTED INFORMATION CONTENT
fprintf('4. CORRECTED INFORMATION CONTENT FOR PAIRED DISTRIBUTIONS\n');
fprintf('========================================================\n');

fprintf('The issue: We need to account for the pairwise nature of the data.\n\n');

fprintf('For paired distributions (A, B) with outcome Y = (A > B):\n');
fprintf('- The relative feature X = A - B is directly related to the outcome\n');
fprintf('- This creates a perfect correlation between X and Y\n');
fprintf('- Standard mutual information calculations may be misleading\n\n');

fprintf('Corrected approach:\n');
fprintf('1. Calculate the separability of the relative feature distribution\n');
fprintf('2. Use the separability to estimate information content\n');
fprintf('3. Account for the correlation structure in the calculation\n\n');

% Calculate corrected information content
fprintf('Calculating corrected information content:\n\n');

for i = 1:length(scenarios)
    s = scenarios(i);
    
    % Calculate separability (using the corrected formula)
    var_rel = s.sigma_a^2 * (1 + s.kappa - 2 * s.rho * sqrt(s.kappa));
    separability = normcdf(s.delta / (2 * sqrt(var_rel)));
    
    % Calculate information content based on separability
    if separability > 0 && separability < 1
        i_corrected = 1 - (-separability * log2(separability) - (1 - separability) * log2(1 - separability));
    else
        i_corrected = 0;
    end
    
    % Calculate the relationship with PEF
    pef = results.pef(i);
    pef_i_correlation = corr([pef], [i_corrected]);
    
    fprintf('%s:\n', s.name);
    fprintf('  Separability: %.3f\n', separability);
    fprintf('  I_corrected: %.3f\n', i_corrected);
    fprintf('  PEF-I_corrected correlation: %.3f\n', pef_i_correlation);
    fprintf('\n');
end

%% 5. FIND THE CORRECT FUNCTIONAL RELATIONSHIP
fprintf('5. FINDING THE CORRECT FUNCTIONAL RELATIONSHIP\n');
fprintf('=============================================\n');

% Generate more data points to find the relationship
n_points = 50;
kappa_range = linspace(0.5, 3, n_points);
rho_range = linspace(-0.8, 0.8, n_points);

pef_values = [];
i_corrected_values = [];

for i = 1:n_points
    for j = 1:n_points
        kappa = kappa_range(i);
        rho = rho_range(j);
        
        % Calculate PEF
        pef = (1 + kappa) / (1 + kappa - 2 * sqrt(kappa) * rho);
        
        % Calculate corrected information content
        var_rel = 1 + kappa - 2 * rho * sqrt(kappa);  % Assuming sigma_a = 1
        separability = normcdf(1 / (2 * sqrt(var_rel)));  % Assuming delta = 1
        
        if separability > 0 && separability < 1
            i_corrected = 1 - (-separability * log2(separability) - (1 - separability) * log2(1 - separability));
        else
            i_corrected = 0;
        end
        
        pef_values(end+1) = pef;
        i_corrected_values(end+1) = i_corrected;
    end
end

% Find the relationship
correlation = corr(pef_values', i_corrected_values');
fprintf('Overall PEF-I_corrected correlation: %.3f\n', correlation);

% Try to find a functional form
% I = f(PEF) where f is some function
% Let's try: I = a * PEF^b + c
% Or: I = a * log(PEF) + b
% Or: I = a * (PEF - 1) + b

% Linear relationship
p_linear = polyfit(pef_values, i_corrected_values, 1);
r2_linear = corr(pef_values', i_corrected_values')^2;

% Logarithmic relationship
pef_log = log(pef_values);
p_log = polyfit(pef_log, i_corrected_values, 1);
r2_log = corr(pef_log', i_corrected_values')^2;

% Power relationship
pef_power = pef_values.^0.5;
p_power = polyfit(pef_power, i_corrected_values, 1);
r2_power = corr(pef_power', i_corrected_values')^2;

fprintf('\nFunctional relationship analysis:\n');
fprintf('Linear: I = %.3f * PEF + %.3f (R² = %.3f)\n', p_linear(1), p_linear(2), r2_linear);
fprintf('Logarithmic: I = %.3f * log(PEF) + %.3f (R² = %.3f)\n', p_log(1), p_log(2), r2_log);
fprintf('Power: I = %.3f * PEF^0.5 + %.3f (R² = %.3f)\n', p_power(1), p_power(2), r2_power);

%% 6. THEORETICAL DERIVATION OF CORRECT RELATIONSHIP
fprintf('\n6. THEORETICAL DERIVATION OF CORRECT RELATIONSHIP\n');
fprintf('================================================\n');

fprintf('For paired distributions with binary outcomes:\n');
fprintf('Y = 1 if A > B, Y = 0 if A ≤ B\n');
fprintf('X = A - B (relative feature)\n\n');

fprintf('The information content should be:\n');
fprintf('I(X;Y) = H(Y) - H(Y|X)\n\n');

fprintf('For binary outcomes with equal probability:\n');
fprintf('H(Y) = 1 bit (maximum entropy)\n\n');

fprintf('H(Y|X) depends on the separability of the X distribution:\n');
fprintf('If X is well-separated, H(Y|X) ≈ 0\n');
fprintf('If X is poorly separated, H(Y|X) ≈ 1\n\n');

fprintf('Separability depends on the signal-to-noise ratio:\n');
fprintf('Separability = Φ(δ / (2√Var(X)))\n');
fprintf('Where δ is the mean difference and Var(X) = σ²_A(1 + κ - 2ρ√κ)\n\n');

fprintf('Therefore:\n');
fprintf('I(X;Y) = 1 - H(Φ(δ / (2√Var(X))))\n');
fprintf('I(X;Y) = 1 - H(Φ(δ / (2σ_A√(1 + κ - 2ρ√κ))))\n\n');

fprintf('Since PEF = (1 + κ) / (1 + κ - 2√κ × ρ):\n');
fprintf('1 + κ - 2√κ × ρ = (1 + κ) / PEF\n');
fprintf('Therefore: I(X;Y) = 1 - H(Φ(δ / (2σ_A√((1 + κ) / PEF))))\n\n');

fprintf('This gives us the correct functional relationship!\n');

%% 7. VALIDATION
fprintf('\n7. VALIDATION\n');
fprintf('============\n');

% Test the theoretical relationship
fprintf('Testing theoretical relationship:\n\n');

for i = 1:length(scenarios)
    s = scenarios(i);
    
    % Calculate using theoretical formula
    pef = results.pef(i);
    var_rel = s.sigma_a^2 * (1 + s.kappa - 2 * s.rho * sqrt(s.kappa));
    separability = normcdf(s.delta / (2 * sqrt(var_rel)));
    
    if separability > 0 && separability < 1
        i_theoretical = 1 - (-separability * log2(separability) - (1 - separability) * log2(1 - separability));
    else
        i_theoretical = 0;
    end
    
    % Calculate using PEF relationship
    i_pef = 1 - (-normcdf(s.delta / (2 * s.sigma_a * sqrt((1 + s.kappa) / pef))) * ...
                 log2(normcdf(s.delta / (2 * s.sigma_a * sqrt((1 + s.kappa) / pef)))) - ...
                 (1 - normcdf(s.delta / (2 * s.sigma_a * sqrt((1 + s.kappa) / pef)))) * ...
                 log2(1 - normcdf(s.delta / (2 * s.sigma_a * sqrt((1 + s.kappa) / pef)))));
    
    fprintf('%s:\n', s.name);
    fprintf('  I_direct: %.3f\n', i_theoretical);
    fprintf('  I_via_PEF: %.3f\n', i_pef);
    fprintf('  Difference: %.3f\n', abs(i_theoretical - i_pef));
    fprintf('\n');
end

%% 8. SAVE RESULTS
fprintf('8. SAVING RESULTS\n');
fprintf('================\n');

results_file = fullfile(pwd, '..', 'pef_information_content_relationship_results.mat');
save(results_file, 'results', 'pef_values', 'i_corrected_values', 'correlation', ...
     'p_linear', 'p_log', 'p_power', 'r2_linear', 'r2_log', 'r2_power');

fprintf('Results saved to: %s\n', results_file);

%% 9. CREATE VISUALIZATION
fprintf('\n9. CREATING VISUALIZATION\n');
fprintf('=========================\n');

create_relationship_visualization(results, pef_values, i_corrected_values, ...
                                 p_linear, p_log, p_power, r2_linear, r2_log, r2_power);

fprintf('Investigation complete!\n');

%% HELPER FUNCTIONS

function create_relationship_visualization(results, pef_values, i_corrected_values, ...
                                         p_linear, p_log, p_power, r2_linear, r2_log, r2_power)
    % Create comprehensive visualization
    
    figure('Position', [100, 100, 1400, 1000]);
    
    % Subplot 1: PEF vs Information Content
    subplot(2, 4, 1);
    scatter(pef_values, i_corrected_values, 50, 'filled', 'MarkerFaceColor', [0.2, 0.6, 0.8], 'MarkerFaceAlpha', 0.6);
    xlabel('PEF');
    ylabel('Information Content');
    title('PEF vs Information Content');
    grid on;
    
    % Subplot 2: Linear fit
    subplot(2, 4, 2);
    scatter(pef_values, i_corrected_values, 50, 'filled', 'MarkerFaceColor', [0.2, 0.6, 0.8], 'MarkerFaceAlpha', 0.6);
    hold on;
    pef_sorted = sort(pef_values);
    i_linear = p_linear(1) * pef_sorted + p_linear(2);
    plot(pef_sorted, i_linear, 'r-', 'LineWidth', 2);
    xlabel('PEF');
    ylabel('Information Content');
    title(sprintf('Linear Fit (R² = %.3f)', r2_linear));
    grid on;
    
    % Subplot 3: Logarithmic fit
    subplot(2, 4, 3);
    scatter(pef_values, i_corrected_values, 50, 'filled', 'MarkerFaceColor', [0.2, 0.6, 0.8], 'MarkerFaceAlpha', 0.6);
    hold on;
    pef_log = log(pef_sorted);
    i_log = p_log(1) * pef_log + p_log(2);
    plot(pef_sorted, i_log, 'g-', 'LineWidth', 2);
    xlabel('PEF');
    ylabel('Information Content');
    title(sprintf('Logarithmic Fit (R² = %.3f)', r2_log));
    grid on;
    
    % Subplot 4: Power fit
    subplot(2, 4, 4);
    scatter(pef_values, i_corrected_values, 50, 'filled', 'MarkerFaceColor', [0.2, 0.6, 0.8], 'MarkerFaceAlpha', 0.6);
    hold on;
    pef_power = pef_sorted.^0.5;
    i_power = p_power(1) * pef_power + p_power(2);
    plot(pef_sorted, i_power, 'm-', 'LineWidth', 2);
    xlabel('PEF');
    ylabel('Information Content');
    title(sprintf('Power Fit (R² = %.3f)', r2_power));
    grid on;
    
    % Subplot 5: Scenario analysis
    subplot(2, 4, 5);
    scatter(results.pef, results.i_rel, 100, 'filled', 'MarkerFaceColor', [0.8, 0.2, 0.2]);
    xlabel('PEF');
    ylabel('Information Content');
    title('Scenario Analysis');
    grid on;
    
    % Subplot 6: R² comparison
    subplot(2, 4, 6);
    r2_values = [r2_linear, r2_log, r2_power];
    r2_labels = {'Linear', 'Logarithmic', 'Power'};
    bar(r2_values, 'FaceColor', [0.2, 0.8, 0.2]);
    set(gca, 'XTickLabel', r2_labels);
    ylabel('R²');
    title('Fit Quality Comparison');
    grid on;
    
    % Subplot 7: Theoretical relationship
    subplot(2, 4, 7);
    pef_theory = linspace(0.5, 3, 100);
    i_theory = 1 - (-normcdf(1 ./ (2 * sqrt((1 + 1) ./ pef_theory))) .* ...
                    log2(normcdf(1 ./ (2 * sqrt((1 + 1) ./ pef_theory)))) - ...
                    (1 - normcdf(1 ./ (2 * sqrt((1 + 1) ./ pef_theory)))) .* ...
                    log2(1 - normcdf(1 ./ (2 * sqrt((1 + 1) ./ pef_theory)))));
    plot(pef_theory, i_theory, 'k-', 'LineWidth', 2);
    xlabel('PEF');
    ylabel('Information Content');
    title('Theoretical Relationship');
    grid on;
    
    % Subplot 8: Summary
    subplot(2, 4, 8);
    axis off;
    text(0.1, 0.9, 'FUNCTIONAL RELATIONSHIP SUMMARY', 'FontSize', 16, 'FontWeight', 'bold');
    text(0.1, 0.8, sprintf('Overall Correlation: ρ = %.3f', corr(pef_values', i_corrected_values')), 'FontSize', 12);
    text(0.1, 0.7, sprintf('Best Fit: %s (R² = %.3f)', r2_labels{r2_values == max(r2_values)}, max(r2_values)), 'FontSize', 12);
    text(0.1, 0.6, 'Theoretical Formula:', 'FontSize', 12, 'FontWeight', 'bold');
    text(0.1, 0.5, 'I = 1 - H(Φ(δ/(2σ√((1+κ)/PEF))))', 'FontSize', 10);
    text(0.1, 0.4, 'Where H is entropy function', 'FontSize', 10);
    text(0.1, 0.3, 'and Φ is normal CDF', 'FontSize', 10);
    
    sgtitle('PEF-Information Content Functional Relationship', 'FontSize', 16, 'FontWeight', 'bold');
    
    % Save figure
    fig_file = fullfile(pwd, '..', 'pef_information_content_relationship_visualization.png');
    saveas(gcf, fig_file);
    fprintf('Visualization saved to: %s\n', fig_file);
end
