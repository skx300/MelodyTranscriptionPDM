function [ betaS ] = backward_alg_2(A,obserProb,c)
%BACKWARD_ALG_2 backward algoritm with pre-computed observation
%probabilities on the observations
%   Input
%   @A: the transition matrix (row sum to 1). (no. state * no. state)
%   @obserProb: the observation probabilities of the observations (no. state * time)
%   @c: the scaled feactor from alpha. T length vector.
%   Output:
%   @betaS: the scaled backword parameter. (no. state * time)

    T = size(obserProb,2);
    N = size(A,1);
   
    
    %--------calculate scaled beta-----------------
    betaOriginal = zeros(N,T);
    betaS = zeros(N,T);
    for t = T:-1:1
        if t == T
            %first step, initialisation
            betaOriginal(:,t) = 1;           
        else
            %inducation step
            for i = 1:N
                betaOriginal(i,t) = sum(A(i,:)'.*obserProb(:,t+1).*betaS(:,t+1));
            end
        end
        betaS(:,t) = betaOriginal(:,t)*c(t);
    end
    %--------------------------------------

end

