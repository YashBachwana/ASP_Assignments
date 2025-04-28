clc; clear all; close all;

% Parameters
num_trials = 500;
no_of_inputs = 1.2e4;            % Adjust for faster testing if needed
N = 15;                        % Input buffer length
fln_order = 2;                 % Functional expansion order
M = (2*fln_order + 1)*N + 1;   % Total number of FLANN inputs

mu1 = 0.001;       % Learning rate for FLANN 1 (slow)
mu2 = 0.02;        % Learning rate for FLANN 2 (fast)
mu_alpha = 0.05;   % Learning rate for alpha (for lambda adaptation)

% For storing across trials
err1_all = zeros(num_trials, no_of_inputs);
err2_all = zeros(num_trials, no_of_inputs);
err_comb_all = zeros(num_trials, no_of_inputs);
lambda_all = zeros(num_trials, no_of_inputs);

for trial = 1:num_trials
    fprintf('Trial %d / %d\n', trial, num_trials);

    % Generate random input in [-0.5, 0.5] and noise
    input = rand(1, no_of_inputs) - 0.5;
    noise = awgn(input, 30) - input;

    % Initialization
    x_buffer = zeros(1, N);
    fln_w1 = zeros(1, M);
    fln_w2 = zeros(1, M);
    alpha = 0;  % Internal parameter for lambda

    for i = 1:no_of_inputs
        % Update input buffer
        x_buffer = [input(i), x_buffer(1:end-1)];

        % Desired system output
        if i < 6000
            q = 1.5 * input(i) - 0.3 * input(i)^2;
            rho = (q > 0) * 4 + (q <= 0) * 0.5;
            desired = 2 * ((1 / (1 + exp(-rho * q))) - 0.5) + noise(i);
        else
            q = 0.3 * input(i) - 1.5 * input(i)^2;
            rho = (q > 0) * 4 + (q <= 0) * 0.5;
            desired = 2 * ((1 / (1 + exp(-rho * q))) - 0.5) + noise(i);
        end

        % Functional expansion
        FEB = [];
        for k = 1:fln_order
            FEB = [FEB, sin(pi * k * x_buffer), cos(pi * k * x_buffer)];
        end
        fln_input = [1, x_buffer, FEB];

        % Outputs from individual FLANNs
        y1 = fln_w1 * fln_input';
        y2 = fln_w2 * fln_input';

        % Lambda from sigmoid(alpha)
        lambda = 1 / (1 + exp(-alpha));

        % Combined output
        y_comb = lambda * y1 + (1 - lambda) * y2;

        % Errors
        e1 = desired - y1;
        e2 = desired - y2;
        e_comb = desired - y_comb;

        % Weight updates
        fln_w1 = fln_w1 + 2 * mu1 * e1 * fln_input;
        fln_w2 = fln_w2 + 2 * mu2 * e2 * fln_input;

        % Alpha update (gradient descent on lambda)
        alpha = alpha + mu_alpha * e_comb * (y1 - y2) * lambda * (1 - lambda);

        % Store errors and lambda
        err1_all(trial, i) = e1^2;
        err2_all(trial, i) = e2^2;
        err_comb_all(trial, i) = e_comb^2;
        lambda_all(trial, i) = lambda;
    end
end

% Ensemble Average
mean_err1 = mean(err1_all, 1);
mean_err2 = mean(err2_all, 1);
mean_err_comb = mean(err_comb_all, 1);
mean_lambda = mean(lambda_all, 1);

% Plot Learning Curves
figure;
plot(10*log10(mean_err1), 'r'); hold on;
plot(10*log10(mean_err2), 'b');
plot(10*log10(mean_err_comb), 'k');
legend('FLANN 1','FLANN 2','Combined');
xlabel('Iterations'); ylabel('MSE (dB)'); grid on;
title('Ensemble Averaged Learning Curves');

% Plot Lambda Evolution
figure;
plot(mean_lambda, 'm');
xlabel('Iterations'); ylabel('\lambda'); grid on;
title('Ensemble Averaged Combination Ratio (\lambda)');
