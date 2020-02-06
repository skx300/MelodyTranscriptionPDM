function [alphaS,c] = forward_alg( observation, A,B,pi)
%FORWARD_ALG HMM forward algoritm
%   Input
%   @observation: observation sequence in vector.
%   @A: the transition matrix (row sum to 1). (no. state * no. state)
%   @B: observation likelihood (row sum to 1). (no. state * no. symbols)
%   @pi: the initial distribution.(no.state * 1)
%   Output:
%   @alphaS: the scaled forward variable. (no. state * time)
%   @c: the scale variable. T length vector.

    T = length(observation);
    N = size(A,1);
    
    %-----calculate scaled alpha--------------
    alphaOriginal = zeros(N,T);
    alphaS = zeros(N,T);
    c = zeros(1,T); %scale factor
    for t = 1:T
        if t == 1
            %first step, initialisation
            alphaOriginal(:,t) = pi'.*B(:,observation(t));
        else
            %inducation step
            for i = 1:N
              alphaOriginal(i,t) = sum(alphaS(:,t-1).*A(:,i)*B(i,observation(t)));  
            end
        end
        c(t) = 1/sum(alphaOriginal(:,t)); 
        alphaS(:,t) = alphaOriginal(:,t)*c(t);        
    end
    %------------------------------------
    
end

