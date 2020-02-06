function [ alphaS,c ] = forward_alg_2(A,obserProb,pi )
%FORWARD_ALG_2 HMM forward algoritm with pre-computed observation
%probabilities on the observations
%   Input
%   @A: the transition matrix (row sum to 1). (no. state * no. state)
%   @obserProb: the observation probabilities of the observations (no. state * time)
%   @pi: the initial distribution.(no.state * 1)
%   Output:
%   @alphaS: the scaled forward variable. (no. state * time)
%   @c: the scale variable. T length vector.

    T = size(obserProb,2);
    N = size(A,1);
    
    %-----calculate scaled alpha--------------
    alphaOriginal = zeros(N,T);
    alphaS = zeros(N,T);
    c = zeros(1,T); %scale factor
    for t = 1:T
        if t == 1
            %first step, initialisation
            alphaOriginal(:,t) = pi'.*obserProb(:,t);
        else
            %inducation step
            for i = 1:N 
                alphaOriginal(i,t) = sum(alphaS(:,t-1).*A(:,i)*obserProb(i,t)); 
            end
        end
        c(t) = 1/sum(alphaOriginal(:,t)); 
        alphaS(:,t) = alphaOriginal(:,t)*c(t);        
    end
    %------------------------------------

end

