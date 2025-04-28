clc;
clear all;

no_of_independent_trials = 1;

for itr=1:no_of_independent_trials
    
    
    clc;
    disp(['Independent Trial No: ',num2str(itr)])
    
    no_of_inputs = 6e6;
    % random signal uniformly distributed in the range [−0.5, 0.5]
    input=rand(1,no_of_inputs) - 0.5;
    
    
    
    
    N=15;
    %FLN order
    
    fln_order =2;
    
    % input buffer with initial condition
    
    x_buffer=zeros(1,N);
    
    %length of inputs after trigonometric functional expansion
    
    M = (2*fln_order+1)*N + 1;
    
    % FLN_weights
    
    fln_weights=zeros(1,M);
    
    %mu value
    
    mu=0.01;
    
    %setting a 30 dB noise floor
    
    noise = awgn(input,30)-input;
    % FLN Begins!!!
    
    for i=1:length(input)
    
    % tap value generation with each input
    
        x_buffer=[input(i) x_buffer(1:end-1)];
    
        q = 1.5 * input(i) - 0.3*input(i)^2 ;
        if q>0
            rho = 4;
        else
            rho=0.5;
        end
        
        desired_output(i) = 2 * ((1/(1+exp(-rho*q)))-0.5) + noise(i);    
        
    
    
        FEB=[];
        for k =1:fln_order
            FEB=[FEB, sin(pi*k*x_buffer), cos(pi*k*x_buffer)];
        end
        
        % Final Contents of FEB
        fln_input= [1,x_buffer,FEB];
    
    
    
        fln_output= fln_weights * fln_input';
    
        %finding the error
    
        error(i)= desired_output(i) - fln_output;
    
        %FLN weight-update rule
    
        fln_weights=fln_weights + 2 * mu * error(i) * fln_input;
    end
    err(itr,:)=error.^2;
end

err_smooth = err ;

length_of_smoothing_filter = 200;
% Coefficients of Smoothing Filter
smoothing_filter_coeff = (1/length_of_smoothing_filter)*ones(1,length_of_smoothing_filter);
for i=1:itr
    err_smooth(i,:) = filter(smoothing_filter_coeff,1,err(i,:));
end

figure;
plot(10*log10((err_smooth))); xlabel('Iterations');ylabel('MSE (dB)'); grid on;

fln_mse=10*log10(((err(end-1000:end))));
fprintf('Average MSE Value over the last 1000 iterations is %f', fln_mse);
