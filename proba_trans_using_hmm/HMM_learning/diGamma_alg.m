function [ diGamma ] = diGamma_alg( alpha,beta,A,B,observation)
%DIGAMMA_ALG calculate the di-Gamma for HMM training
%   Input
%   @alpha: the forward parameters. (no. state * time)
%   @beta: the backward parameters. (no. state * time)
%   @A: the transition prob matrix (no. state * no. state)
%   @B: the observation likelihood prob matrix (no. state * no. emissions)
%   @observation: the observed sequence. (with length T)
%   Output
%   @diGamma: the diGamma parameters. (no. state * * no. state * time-1)

    N = size(A,1);
    T = length(observation);
    
    diGamma = zeros(N,N,T-1);
    
%     P = sum(alpha(:,end));% get the likelihood of the observed sequence;
    for t = 1:T-1
       for i = 1:N
          for j = 1:N
%              diGamma(i,j,t) =  alpha(i,t)*A(i,j)*B(j,observation(t+1))*beta(j,t+1)/P;
             diGamma(i,j,t) = alpha(i,t)*A(i,j)*B(j,observation(t+1))*beta(j,t+1); %original
             
%             diGamma(i,j,t) =  c(t) *alpha(i,t)*A(i,j)*B(j,observation(t+1))*beta(j,t+1);
          end
       end
    end
end

