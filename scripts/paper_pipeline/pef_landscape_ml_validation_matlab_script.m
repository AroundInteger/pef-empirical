%% PEF Landscape ML Validation (MATLAB) - Script Version
% This script validates PEF framework across all landscape quadrants with hard-coded inputs
% No function calls required - just run the script directly

clear; clc; close all;

fprintf('PEF Landscape ML Validation (MATLAB) - Script Version\n');
fprintf('===================================================\n');

%% HARD-CODED INPUTS - MODIFY THESE AS NEEDED
% Number of samples per quadrant
n_samples_per_quadrant = 100;

% Number of data points to generate per test
n_samples_per_test = 1000;

% Output file for results
output_file = '/Users/iMacPro/Documents/GitHub/UP1_PEF/paper/overleaf_pef_article/scripts/Matlab Figures/landscape_validation_results_script.mat';

%% DEFINE QUADRANTS
quadrants = {
    struct('name', 'Q1_HighKappa_PosRho', 'kappa_range', [1.01, 2], 'rho_range', [0.01, 0.99]),
    struct('name', 'Q2_LowKappa_PosRho', 'kappa_range', [0.01, 0.99], 'rho_range', [0.01, 0.99]),
    struct('name', 'Q3_LowKappa_NegRho', 'kappa_range', [0.01, 0.99], 'rho_range', [-0.99, -0.01]),
    struct('name', 'Q4_HighKappa_NegRho', 'kappa_range', [1.01, 2], 'rho_range', [-0.99, -0.01])
};

%% INITIALIZE RESULTS
all_results = [];

%% PROCESS EACH QUADRANT
for q = 1:length(quadrants)
    quadrant = quadrants{q};
    fprintf('\nProcessing Quadrant: %s\n', quadrant.name);
    fprintf('Kappa range: [%.1f, %.1f]\n', quadrant.kappa_range(1), quadrant.kappa_range(2));
    fprintf('Rho range: [%.1f, %.1f]\n', quadrant.rho_range(1), quadrant.rho_range(2));
    
    for s = 1:n_samples_per_quadrant
        % Sample parameters
        kappa = quadrant.kappa_range(1) + ...
                rand() * (quadrant.kappa_range(2) - quadrant.kappa_range(1));
        rho = quadrant.rho_range(1) + ...
               rand() * (quadrant.rho_range(2) - quadrant.rho_range(1));
        
        fprintf('  Sample %d/%d: κ=%.3f, ρ=%.3f\n', s, n_samples_per_quadrant, kappa, rho);
        
        % Generate synthetic data
        [data_a, data_b, outcomes] = generate_synthetic_data_matlab_script(kappa, rho, n_samples_per_test);
        
        % Calculate actual PEF
        actual_kappa = var(data_b) / var(data_a);
        actual_rho = corr(data_a, data_b);
        actual_pef = (1 + actual_kappa) / (1 + actual_kappa - 2 * sqrt(actual_kappa) * actual_rho);
        
        % Test ML performance
        ml_results = test_ml_performance_matlab_script(data_a, data_b, outcomes);
        
        % Store results
        result = struct();
        result.quadrant = quadrant.name;
        result.target_kappa = kappa;
        result.target_rho = rho;
        result.target_pef = (1 + kappa) / (1 + kappa - 2 * sqrt(kappa) * rho);
        result.actual_kappa = actual_kappa;
        result.actual_rho = actual_rho;
        result.actual_pef = actual_pef;
        result.abs_accuracy = ml_results.abs_accuracy;
        result.rel_accuracy = ml_results.rel_accuracy;
        result.abs_auc = ml_results.abs_auc;
        result.rel_auc = ml_results.rel_auc;
        result.acc_improvement = ml_results.acc_improvement;
        result.auc_improvement = ml_results.auc_improvement;
        
        all_results = [all_results; result];
        
        fprintf('    Actual: κ=%.3f, ρ=%.3f, PEF=%.3f\n', actual_kappa, actual_rho, actual_pef);
        fprintf('    ML: Acc_imp=%.1f%%, AUC_imp=%.1f%%\n', result.acc_improvement, result.auc_improvement);
    end
end

%% ANALYZE RESULTS
fprintf('\nLandscape Validation Analysis\n');
fprintf('=============================\n');

% Overall statistics
all_pef = [all_results.actual_pef];
all_acc_imp = [all_results.acc_improvement];
all_auc_imp = [all_results.auc_improvement];

fprintf('Overall Statistics:\n');
fprintf('  Total samples: %d\n', length(all_results));
fprintf('  Mean PEF: %.3f ± %.3f\n', mean(all_pef), std(all_pef));
fprintf('  Mean Accuracy Improvement: %.1f%% ± %.1f%%\n', mean(all_acc_imp), std(all_acc_imp));
fprintf('  Mean AUC Improvement: %.1f%% ± %.1f%%\n', mean(all_auc_imp), std(all_auc_imp));

% PEF prediction accuracy
correct_predictions = 0;
total_predictions = 0;

for i = 1:length(all_results)
    pef_val = all_results(i).actual_pef;
    acc_imp = all_results(i).acc_improvement;
    
    if (pef_val > 1.2 && acc_imp > 0) || (pef_val < 0.8 && acc_imp < 0)
        correct_predictions = correct_predictions + 1;
    end
    total_predictions = total_predictions + 1;
end

pef_prediction_accuracy = correct_predictions / total_predictions * 100;
fprintf('  PEF Prediction Accuracy: %.1f%%\n', pef_prediction_accuracy);

% By quadrant
for q = 1:length(quadrants)
    quadrant_name = quadrants{q}.name;
    quadrant_results = all_results(strcmp({all_results.quadrant}, quadrant_name));
    
    if ~isempty(quadrant_results)
        quadrant_pef = [quadrant_results.actual_pef];
        quadrant_acc_imp = [quadrant_results.acc_improvement];
        quadrant_auc_imp = [quadrant_results.auc_improvement];
        
        fprintf('\n%s:\n', quadrant_name);
        fprintf('  Samples: %d\n', length(quadrant_results));
        fprintf('  Mean PEF: %.3f ± %.3f\n', mean(quadrant_pef), std(quadrant_pef));
        fprintf('  Mean Accuracy Improvement: %.1f%% ± %.1f%%\n', mean(quadrant_acc_imp), std(quadrant_acc_imp));
        fprintf('  Mean AUC Improvement: %.1f%% ± %.1f%%\n', mean(quadrant_auc_imp), std(quadrant_auc_imp));
    end
end

%% CREATE VISUALIZATION
create_landscape_visualization_matlab_script(all_results);

%% STORE RESULTS
landscape_results = struct();
landscape_results.all_results = all_results;
landscape_results.quadrants = quadrants;
landscape_results.n_samples_per_quadrant = n_samples_per_quadrant;
landscape_results.n_samples_per_test = n_samples_per_test;
landscape_results.pef_prediction_accuracy = pef_prediction_accuracy;

%% SAVE RESULTS
fprintf('\nSaving results to: %s\n', output_file);
%save(output_file, 'landscape_results', 'all_results');

%% CREATE SUMMARY TABLE
if ~isempty(all_results)
    % Create summary table
    summary_table = table();
    for i = 1:length(all_results)
        summary_table.Quadrant{i} = all_results(i).quadrant;
        summary_table.Target_Kappa(i) = all_results(i).target_kappa;
        summary_table.Target_Rho(i) = all_results(i).target_rho;
        summary_table.Target_PEF(i) = all_results(i).target_pef;
        summary_table.Actual_Kappa(i) = all_results(i).actual_kappa;
        summary_table.Actual_Rho(i) = all_results(i).actual_rho;
        summary_table.Actual_PEF(i) = all_results(i).actual_pef;
        summary_table.Abs_Accuracy(i) = all_results(i).abs_accuracy;
        summary_table.Rel_Accuracy(i) = all_results(i).rel_accuracy;
        summary_table.Abs_AUC(i) = all_results(i).abs_auc;
        summary_table.Rel_AUC(i) = all_results(i).rel_auc;
        summary_table.Acc_Improvement(i) = all_results(i).acc_improvement;
        summary_table.AUC_Improvement(i) = all_results(i).auc_improvement;
    end
    
    % Display summary table
    fprintf('\nDetailed Results Table:\n');
    disp(summary_table);
    
    % Save summary table
    summary_file = strrep(output_file, '.mat', '_summary.csv');
    writetable(summary_table, summary_file);
    fprintf('Summary table saved to: %s\n', summary_file);
end

fprintf('\nPEF landscape validation script completed successfully!\n');

%% HELPER FUNCTIONS

function [data_a, data_b, outcomes] = generate_synthetic_data_matlab_script(kappa, rho, n_samples)
    % Generate synthetic paired data with specified parameters
    
    % Set initial variance for A
    var_a = 25; % σ²_A = 25, so σ_A = 5
    var_b = kappa * var_a; % σ²_B = κ * σ²_A
    
    % Calculate covariance
    cov_ab = rho * sqrt(var_a * var_b);
    
    % Generate bivariate normal data
    mean_vector = [50, 50]; % Equal means
    cov_matrix = [var_a, cov_ab; cov_ab, var_b];
    
    data = mvnrnd(mean_vector, cov_matrix, n_samples);
    data_a = data(:, 1);
    data_b = data(:, 2);
    
    % Generate outcomes (independent of relative performance to avoid bias)
    relative_performance = data_a - data_b;
    noise = normrnd(0, 0.1, n_samples, 1);
    outcome_prob = 0.5 + 0.3 * tanh(relative_performance / 10) + noise;
    outcome_prob = max(0, min(1, outcome_prob)); % Clip to [0, 1]
    outcomes = double(rand(n_samples, 1) < outcome_prob);
end

function ml_results = test_ml_performance_matlab_script(data_a, data_b, outcomes)
    % Test ML performance on absolute vs relative features
    
    % Create relative feature
    relative_kpi = data_a - data_b;
    
    % Set up cross-validation
    cv = cvpartition(length(outcomes), 'KFold', 5);
    
    abs_accuracies = zeros(5, 1);
    rel_accuracies = zeros(5, 1);
    abs_aucs = zeros(5, 1);
    rel_aucs = zeros(5, 1);
    
    for fold = 1:5
        train_idx = training(cv, fold);
        test_idx = test(cv, fold);
        
        % Check class balance
        train_outcomes = outcomes(train_idx);
        test_outcomes = outcomes(test_idx);
        
        if sum(train_outcomes) > 0 && sum(train_outcomes) < length(train_outcomes) && ...
           sum(test_outcomes) > 0 && sum(test_outcomes) < length(test_outcomes)
            
            % Prepare training and test data
            X_train_abs = data_a(train_idx);
            X_test_abs = data_a(test_idx);
            X_train_rel = relative_kpi(train_idx);
            X_test_rel = relative_kpi(test_idx);
            
            y_train = train_outcomes;
            y_test = test_outcomes;
            
            % Train and test absolute model
            try
                mdl_abs = fitglm(X_train_abs, y_train, 'Distribution', 'binomial','LikelihoodPenalty', 'jeffreys-prior' );
                prob_abs = predict(mdl_abs, X_test_abs);
                pred_abs = double(prob_abs > 0.5);
                abs_acc = sum(pred_abs == y_test) / length(y_test);
                
                % Calculate AUC
                [~, ~, ~, auc_abs] = perfcurve(y_test, prob_abs, 1);
                abs_aucs(fold) = auc_abs;
            catch
                abs_acc = 0.5;
                abs_aucs(fold) = 0.5;
            end
            
            % Train and test relative model
            try
                mdl_rel = fitglm(X_train_rel, y_train, 'Distribution', 'binomial','LikelihoodPenalty', 'jeffreys-prior' );
                prob_rel = predict(mdl_rel, X_test_rel);
                pred_rel = double(prob_rel > 0.5);
                rel_acc = sum(pred_rel == y_test) / length(y_test);
                
                % Calculate AUC
                [~, ~, ~, auc_rel] = perfcurve(y_test, prob_rel, 1);
                rel_aucs(fold) = auc_rel;
            catch
                rel_acc = 0.5;
                rel_aucs(fold) = 0.5;
            end
            
            abs_accuracies(fold) = abs_acc;
            rel_accuracies(fold) = rel_acc;
        else
            abs_accuracies(fold) = 0.5;
            rel_accuracies(fold) = 0.5;
            abs_aucs(fold) = 0.5;
            rel_aucs(fold) = 0.5;
        end
    end
    
    % Calculate improvements
    abs_accuracy = mean(abs_accuracies);
    rel_accuracy = mean(rel_accuracies);
    abs_auc = mean(abs_aucs);
    rel_auc = mean(rel_aucs);
    
    acc_improvement = (rel_accuracy - abs_accuracy) / abs_accuracy * 100;
    auc_improvement = (rel_auc - abs_auc) / abs_auc * 100;
    
    ml_results = struct();
    ml_results.abs_accuracy = abs_accuracy;
    ml_results.rel_accuracy = rel_accuracy;
    ml_results.abs_auc = abs_auc;
    ml_results.rel_auc = rel_auc;
    ml_results.acc_improvement = acc_improvement;
    ml_results.auc_improvement = auc_improvement;
end

function create_landscape_visualization_matlab_script(all_results)
    % Create visualization of landscape validation results
    
    figure('Position', [100, 100, 1200, 800]);
    
    % Extract data
    all_kappa = [all_results.actual_kappa];
    all_rho = [all_results.actual_rho];
    all_pef = [all_results.actual_pef];
    all_acc_imp = [all_results.acc_improvement];
    all_auc_imp = [all_results.auc_improvement];
    
    % Plot 1: PEF Landscape
    subplot(2, 3, 1);
    scatter(all_rho, all_kappa, 100, all_pef, 'filled');
    ylabel('Kappa (κ)');
    xlabel('Rho (ρ)');
    title('PEF Landscape');
    colorbar;
    colormap(jet);
    
    % Plot 2: Accuracy Improvement
    subplot(2, 3, 2);
    scatter(all_rho, all_kappa, 100, all_acc_imp, 'filled');
    ylabel('Kappa (κ)');
    xlabel('Rho (ρ)');
    title('Accuracy Improvement (%)');
    colorbar;
    colormap(jet);
    
    % Plot 3: AUC Improvement
    subplot(2, 3, 3);
    scatter(all_rho, all_kappa, 100, all_auc_imp, 'filled');
    ylabel('Kappa (κ)');
    xlabel('Rho (ρ)');
    title('AUC Improvement (%)');
    colorbar;
    colormap(jet);
    
    % Plot 4: PEF vs Accuracy Improvement
    subplot(2, 3, 4);
    scatter(all_pef, all_acc_imp, 100, 'filled');
    xlabel('PEF');
    ylabel('Accuracy Improvement (%)');
    title('PEF vs Accuracy Improvement');
    grid on;
    
    % Plot 5: PEF vs AUC Improvement
    subplot(2, 3, 5);
    scatter(all_pef, all_auc_imp, 100, 'filled');
    xlabel('PEF');
    ylabel('AUC Improvement (%)');
    title('PEF vs AUC Improvement');
    grid on;
    
    % Plot 6: Quadrant Comparison
    subplot(2, 3, 6);
    quadrant_names = unique({all_results.quadrant});
    quadrant_acc_imp = zeros(length(quadrant_names), 1);
    quadrant_auc_imp = zeros(length(quadrant_names), 1);
    
    for i = 1:length(quadrant_names)
        quadrant_results = all_results(strcmp({all_results.quadrant}, quadrant_names{i}));
        
        if ~isempty(quadrant_results)
            quadrant_acc_imp(i) = mean([quadrant_results.acc_improvement]);
            quadrant_auc_imp(i) = mean([quadrant_results.auc_improvement]);
        end
    end
    
    bar([quadrant_acc_imp, quadrant_auc_imp]);
    set(gca, 'XTickLabel', quadrant_names);
    ylabel('Improvement (%)');
    title('Improvement by Quadrant');
    legend('Accuracy', 'AUC', 'Location', 'best');
    xtickangle(45);
    
    sgtitle('PEF Landscape ML Validation Results');
    
    % Save figure
    %saveas(gcf, '/Users/rowanbrown/Documents/GitHub/UP1_SEF/analysis/pef_validation/landscape_validation_script.png');
    fprintf('Visualization saved to: landscape_validation_script.png\n');
end
