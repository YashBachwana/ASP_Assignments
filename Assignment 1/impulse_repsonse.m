% Load audio files
[y, Fs] = audioread('Audio.wav'); % y(n) - input signal
d = audioread('Recorded.wav'); % d(n) - desired signal

% Ensure same length and mono
minLen = min(length(y), length(d));
y = y(1:minLen, 1); 
d = d(1:minLen, 1);

% LMS filter parameters
filterLength = 32; % Length of h(n)
mu = 0.01; % Step size

% Initialize
h = zeros(filterLength, 1); % Impulse response h(n)
y_buffer = zeros(filterLength, 1); % Buffer for input

% LMS algorithm
for n = 1:minLen
    % Shift buffer and add new sample
    y_buffer = [y(n); y_buffer(1:end-1)];
    
    % Compute output
    y_hat = h' * y_buffer;
    
    % Compute error
    e = d(n) - y_hat;
    
    % Update filter coefficients
    h = h + mu * e * y_buffer;
end

% h is the impulse response h(n) (32x1)