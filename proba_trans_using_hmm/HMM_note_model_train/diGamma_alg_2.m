function [ diGamma ] = diGamma_alg_2( alpha,beta,A,obserProb )
%DIGAMMA_ALG_2 Summary of this function goes here
%   Detailed explanation goes here
%   Input
%   @alpha: the forward parameters. (no. state * time)
%   @beta: the backward parameters. (no. state * time)
%   @A: the transition prob matrix (no. state * no. state)
%   @obserProb: the observation probabilities of the observations (no. state * time)
%   Output
%   @diGamma: the diGamma parameters. (no. state * * no. state * time-1)

    N = size(A,1);
    T = size(obserProb,2);
    
    diGamma = zeros(N,N,T-1);
    
%     P = sum(alpha(:,end));% get the likelihood of the observed sequence;
    for t = 1:T-1
       for i = 1:N
          for j = 1:N
%              diGamma(i,j,t) =  alpha(i,t)*A(i,j)*B(j,observation(t+1))*beta(j,t+1)/P;
             diGamma(i,j,t) = alpha(i,t)*A(i,j)*obserProb(j,t+1)*beta(j,t+1); %original
             
          end
       end
    end

end

