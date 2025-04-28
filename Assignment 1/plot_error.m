M = 8;
T = length(out.nlms_error) / M;

% Reshape to [T x M]
E_nlms = reshape(out.nlms_error, M, T)';
E_apa = reshape(out.apa_error, M, T)';

% Compute squared norm ||e(n)||^2 at each timestep
e_sq_nlms = sum(E_nlms.^2, 2);
e_sq_apa = sum(E_apa.^2, 2);

% Plot in two subplots
figure;

subplot(2,1,1);
plot(e_sq_nlms, 'b');
xlabel('Time step');
ylabel('||e(n)||^2');
title('NLMS: Squared Error Norm vs Time');
grid on;

subplot(2,1,2);
plot(e_sq_apa, 'r');
xlabel('Time step');
ylabel('||e(n)||^2');
title('APA: Squared Error Norm vs Time');
grid on;
