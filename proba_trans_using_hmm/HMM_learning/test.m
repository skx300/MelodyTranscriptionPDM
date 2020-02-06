%this is the implementation of HMM forward algorithm

clear;

%row stochastic(row sum to 1)
% A = [0.6,0.4;...
%  0.3,0.7];
%row stochastic(row sum to 1)
% A = [0.3,0.7;...
%  0.1,0.9];
A = [1/3-0.1,1/3+0.1,1/3;...
 1/3+0.1,1/3-0.1,1/3;...
 1/3+0.1,1/3-0.1,1/3];

%row stochastic
% B = [0.3,0.4,0.3;...
%  0.4,0.3,0.3];
% B = [0.4,0.6;...
%  0.5,0.5];
B = [1/4+0.1,1/4-0.1,1/4+0.1,1/4-0.1;...
 1/4-0.1,1/4+0.1,1/4-0.1,1/4+0.1;...
 1/4+0.1,1/4-0.1,1/4+0.1,1/4-0.1;];

%initial distirbution
% pi = [0.8,0.2];
% pi = [0.85,0.15];
pi = [1/3+0.05,1/3-0.05,1/3];

%     observation = [1,2,3,3];
%     observation = [1,2,2,1];

dataObser{1} = [1 1 1 4 1 1 1 2 2 2 2 2 2 1 2 2 2 2 3 3 3 3 3 1 3 3 3];
dataObser{2} = [1 1 2 1 1 1 1 1 2 2 2 3 2 2 2 2 2 3 3 3 3 3 4 3 3 3 ];

obserProb{1} = zeros(3,length(dataObser{1}));
obserProb{2} = zeros(3,length(dataObser{2}));
for nObser = 1:length(obserProb)
    for i = 1:length(obserProb{nObser})
        for iState = 1:size(B,1)
            obserProb{nObser}(iState,i) = B(iState,dataObser{nObser}(i));
        end
    end
end

for nIte = 1:100
    alpha_S = cell(size(dataObser));
    beta_S = cell(size(dataObser));
    c = cell(size(dataObser));
    c_new = cell(size(dataObser));
    gamma_S = cell(size(dataObser));
    diGamma_S = cell(size(dataObser));
    PO_S_log = zeros(length(dataObser),1);
    PO_S_log_est = zeros(length(dataObser),1);
    for nObser = 1:length(dataObser)
    
        [alpha_S{nObser},c{nObser}] = forward_alg(dataObser{nObser},A,B,pi);
%         [alpha_S_2{nObser},c_2{nObser}] = forward_alg_2(A,obserProb{nObser},pi);
        beta_S{nObser} = backward_alg(dataObser{nObser},A,B,c{nObser});
%         beta_S_2{nObser} = backward_alg_2(A,obserProb{nObser},c{nObser});

        PO_S_log(nObser) = -1*sum(log(c{nObser}));
        PO_S_log_sum = sum(PO_S_log);

        %-----Gamma and diGamma-----------
        gamma_S{nObser} = gamma_alg(alpha_S{nObser},beta_S{nObser});
%         gamma_S_2{nObser} = gamma_alg(alpha_S_2{nObser},beta_S_2{nObser});
      
        diGamma_S{nObser} = diGamma_alg(alpha_S{nObser},beta_S{nObser},A,B,dataObser{nObser});
%         diGamma_S_2{nObser} = diGamma_alg_2(alpha_S{nObser},beta_S{nObser},A,obserProb{nObser});
    end

    %-----Estimation-----------
    [pi_est_S,A_est_S,B_est_S] = reestimation_S(dataObser,B,gamma_S,diGamma_S,c);
    
    for nObser = 1:length(dataObser)
        [~,c_new{nObser}] = forward_alg(dataObser{nObser},A_est_S,B_est_S,pi_est_S);
        PO_S_log_est(nObser) = -1*sum(log(c_new{nObser}));
    end
    PO_S_log_est_sum = sum(PO_S_log_est);
    %criterion for iteration
    %the whole mean log-likelihood will be used
    if mean(abs(PO_S_log_est_sum-PO_S_log_sum))/mean(abs(PO_S_log_sum)) < 0.0001
        break;
    else
        pi = pi_est_S;
        A = A_est_S;
        B = B_est_S; 
    end
end












