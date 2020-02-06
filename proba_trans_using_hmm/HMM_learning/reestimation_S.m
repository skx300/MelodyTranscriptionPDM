function [ pi_est,A_est,B_est ] = reestimation_S( observation,B,gamma,diGamma,c )
%REESTIMATION_S re-estimation the HMM parameters for scaled alpha and beta
%   Input
%   @observation: the observed sequence. (with length T)
%   @B: the observation likelihood prob matrix (no. state * no. emissions)
%   @gamma: the gamma parameters.
%   @diGamma: the diGamma parameters. (no. state * * no. state * time-1)
%   @c: the scaled factor. T length vector.
%   Output
%   @pi_est: estimated initial state distribution
%   @A_est: estimated state transition probbilities
%   @B_est: estimated observation likelihood matrix

    L = length(observation); %number of observation sequences

    %----Pi (initial state distribution)-----
    pi_est = zeros(1,size(B,1));
    for l = 1:L
        pi_est = pi_est + gamma{l}(:,1)'/sum(gamma{l}(:,1));
    end
    pi_est = pi_est/L;

    
    %----state transition probbilities-----
    
    N = size(B,1);
    A_est = zeros(size(B,1),size(B,1));
   
    for i = 1:N
       for j = 1:N
           numerA = 0;
           denoA = 0;
           for l = 1:L
               numerA = numerA + sum(diGamma{l}(i,j,1:end));
               denoA = denoA + sum(gamma{l}(i,1:end-1)./c{l}(1:end-1)); %Original            
%                 denoA = denoA + sum(gamma{l}(i,1:end-1));
           end
%           A_est(i,j) = sum(diGamma(i,j,1:end))/sum(gamma(i,1:end-1)./c(1:end-1));
            A_est(i,j) = numerA/denoA;
       end
    end
    
    %---or can be calcualted directly by the diGamma----
%     sumDiGamma = sum(diGamma,3);
%     for i = 1:size(sumDiGamma,1)
%        A_est(i,:) = sumDiGamma(i,:)/sum(sumDiGamma(i,:)) ;
%     end
    
    %----observation likelihood matrix-----
    B_est = zeros(size(B));
    M = size(B,2);
    for j = 1:N
       for k = 1:M
           numerB = 0;
           denoB = 0;
           for l = 1:L
                T = length(observation{l});
                for t = 1:T
                   if observation{l}(t) == k
                    numerB = numerB + gamma{l}(j,t)/c{l}(t);    %original
%                     numerB = numerB + gamma{l}(j,t);
                   end
                end
                denoB = denoB + sum(gamma{l}(j,1:end)./c{l});   %original
%                 denoB = denoB + sum(gamma{l}(j,1:end));
           end
           B_est(j,k) = numerB/denoB;
%            B_est(j,k) = numerB/sum(gamma(j,1:end)./c);
       end
    end

end

