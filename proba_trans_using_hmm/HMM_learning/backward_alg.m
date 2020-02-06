function [betaS] = backward_alg( observation, A,B,c)
%BACKWARD_ALG HMM backward algoritm
%   Input
%   @observation: observation sequence in vector.
%   @A: the transition matrix (row sum to 1). (no. state * no. state)
%   @B: observation likelihood (row sum to 1). (no. state * no. symbols)
%   @c: the scaled feactor from alpha. T length vector.
%   Output:
%   @betaS: the scaled backword parameter. (no. state * time)

    T = length(observation);
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
                betaOriginal(i,t) = sum(A(i,:)'.*B(:,observation(t+1)).*betaS(:,t+1));
            end
        end
        betaS(:,t) = betaOriginal(:,t)*c(t);
    end
    %--------------------------------------
end

