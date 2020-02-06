function [ gamma ] = gamma_alg( alpha,beta)
%GAMMA_ALG Summary calculate the gamma for HMM training
%   Input
%   @alpha: the forward parameters. (no. state * time)
%   @beta: the backward parameters. (no. state * time)
%   Output
%   @gamma: the gamma parameters. (no. state * time)

%     P = sum(alpha(:,end));% get the likelihood of the observed sequence;
%     gamma = alpha.*beta./P;
    gamma = alpha.*beta;
end

