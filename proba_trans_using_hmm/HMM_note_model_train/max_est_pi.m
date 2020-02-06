function [ output_args ] = max_est_pi( A,gamma_S,diGamma_S )
%MAX_EST_PI Baum-Welch algorithm, Maximization step, Estimate pi (state initial distribution)
%   Detailed explanation goes here

    pi_est = pi_est + gamma_S(:,1)'/sum(gamma_S(:,1));

end

