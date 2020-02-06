clear;
clf;

folderPath = '../../../Dataset/EvaluationFramework_ISMIR2014/';
fileNames = readtable([folderPath,'/dataset/fileNames.csv']);

%------Baum-Welch algorithm----------

%-----Initialization of parameters-----
pi = [1,0,0];
A = [1/3-0.1,1/3+0.1,1/3;...
 1/3+0.1,1/3-0.1,1/3;...
 1/3+0.1,1/3-0.1,1/3];
%para for Yang-Maezawa distribution
%start, sustain and end state
kappa = [0.5,0,0.5];
a = [0.4,0.1,0.2];
b = [1,1,1];
mu = [3/4*pi,0,1/4*pi];
%--------------------------------------

% bRan = (0.1:0.05:10); %evenly spaced
bRan = (0.1:1:10);
% kappaRan = logspace(-2,1,99); %logarithmically spaced between 0.01 and 10
kappaRan = logspace(-2,2,20); %logarithmically spaced between 0.01 and 10

% for i = 1:size(fileNames,1)
for i = 1
    
    groundTruthFileName = [folderPath,'/dataset/',cell2mat(fileNames{i,1}),'.GroundTruth.txt']; 

    gtData = csvread(groundTruthFileName);
    gtData(:,3) = round(gtData(:,3));
   
    data = csvread([folderPath,'DATASET/f0_pyin/',cell2mat(fileNames{i,1}),'_f0_pyin.csv']); 
    time = data(:,1);
    pitchRaw = data(:,2);
    %let the pyin outputs negative frequencies as unvoiced, then make
    %the unvoiced as 0;
    pitchRaw(pitchRaw <= 0) = 0;
    pitchFs = 1/(time(2)-time(1));
    midiPitchOriginal = freqToMidi(pitchRaw);
    
    %get delta f0 (Here no post processing for delta-f0)
    deltaMidiPitch = [0;diff(smooth(midiPitchOriginal,1))];
%     deltaMidiPitch(abs(deltaMidiPitch) > 3) = 0; %it is necessary

    %get each note's f0 and delta-f0
%     for numNote = 1:size(gtData,1)
    for numNote = 1
       startTime = gtData(numNote,1);
       endTime = gtData(numNote,2);
       M = gtData(numNote,3); % para of Yang-Maezawa distribution
       [~,startPoint] = min(abs(time-startTime));
       [~,endPoint] = min(abs(time-endTime));
       
       tempMidiPitch = midiPitchOriginal(startPoint:endPoint);
       tempDeltaPitch = deltaMidiPitch(startPoint:endPoint);
       
       %pre-compute the observation probabilities for all observations
        T = length(tempMidiPitch);
        N = size(A,1); 
        obserProb = zeros(N,T);
        for iObser = 1:N
            obserProb(iObser,:) = (VonMisesPDF_2(tempMidiPitch,tempDeltaPitch,M,kappa(iObser),a(iObser),b(iObser),mu(iObser)))';
        end      
       
       
       %----START of EXPECTATION---------
       %----------alpha----------    
        [alphaS,c] = forward_alg_2(A,obserProb,pi);
       
        %--------beta-----------------
        betaS = backward_alg_2(A,obserProb,c);
        
        PO_S_log = -1*sum(log(c));
        
        %-----Gamma-------------- 
        gamma_S = gamma_alg(alphaS,betaS);
        
        %-----diGamma-----------
        diGamma_S = diGamma_alg_2(alphaS,betaS,A,obserProb);
        %----END of EXPECTATION---------
        
        %----START of MAXIMIZATION---------
        %----Pi-----
        pi_est = zeros(size(pi));
        pi_est = pi_est + gamma_S(:,1)'/sum(gamma_S(:,1));
        
        
        %----START of state transition probbilities-----
        A_est = zeros(size(A));

        for iState = 1:N
           for j = 1:N
               numerA = 0;
               denoA = 0;
               numerA = numerA + sum(diGamma_S(iState,j,1:end));
               denoA = denoA + sum(gamma_S(iState,1:end-1)./c(1:end-1));
    %           A_est(i,j) = sum(diGamma(i,j,1:end))/sum(gamma(i,1:end-1)./c(1:end-1));
                A_est(iState,j) = numerA/denoA;
           end
        end
        %-----------------------------     
        %----END of state transition probbilities-----
        
        
        %------START of observation distribution estimation------
        %----estimate kappa-------------
%         PO_S_log_est_K = zeros(length(kappaRan),length(kappaRan),length(kappaRan));
%         max_log_likelihood_k = 0; 
%         max_log_likelihood_k_pos = [0;0;0];
%         for iKappa1 = 1:length(kappaRan)
%             for iKappa2 = 1:length(kappaRan)
%                 for iKappa3 = 1:length(kappaRan)
%                     obserProb_est = zeros(N,T);
%                     for iObser = 1:N
%                         if iObser == 1
%                             obserProb_est(iObser,:) = (VonMisesPDF_2(tempMidiPitch,tempDeltaPitch,M,kappaRan(iKappa1),a(iObser),b(iObser),mu(iObser)))';
%                         elseif iObser == 2
%                             obserProb_est(iObser,:) = (VonMisesPDF_2(tempMidiPitch,tempDeltaPitch,M,kappaRan(iKappa2),a(iObser),b(iObser),mu(iObser)))';
%                         elseif iObser == 3
%                             obserProb_est(iObser,:) = (VonMisesPDF_2(tempMidiPitch,tempDeltaPitch,M,kappaRan(iKappa3),a(iObser),b(iObser),mu(iObser)))';
%                         end
%                         [alphaS_est,c_est] = forward_alg_2(A_est,obserProb_est,pi_est);
%                         log_likelihhod_temp = -1*sum(log(c_est));
%                         if log_likelihhod_temp > max_log_likelihood_k
%                             max_log_likelihood_k = log_likelihhod_temp;
%                             max_log_likelihood_k_pos = [iKappa1;iKappa2;iKappa3];
%                         end
%                         PO_S_log_est_K(iKappa1,iKappa2,iKappa3) = -1*sum(log(c_est));
%                     end  
%                 end
%             end
%         end 
%         [maxValue,maxIndex] = max(PO_S_log_est_K(:));
%         [X,Y,Z] = ind2sub(size(PO_S_log_est_K),maxIndex);
%         kappa_est = [kappaRan(X),kappaRan(Y),kappaRan(Z)];
        
        
        %----estimate b-------------
        PO_S_log_est_b = zeros(length(bRan),length(bRan),length(bRan));
        max_log_likelihood_b = 0; 
        max_log_likelihood_b_pos = [0;0;0];
        for iB1 = 1:length(bRan)
            for iB2 = 1:length(bRan)
                for iB3 = 1:length(bRan)
                    obserProb_est = zeros(N,T);
                    for iObser = 1:N
                        if iObser == 1
                            obserProb_est(iObser,:) = (VonMisesPDF_2(tempMidiPitch,tempDeltaPitch,M,kappa(iObser),a(iObser),bRan(iB1),mu(iObser)))';
                        elseif iObser == 2
                            obserProb_est(iObser,:) = (VonMisesPDF_2(tempMidiPitch,tempDeltaPitch,M,kappa(iObser),a(iObser),bRan(iB2),mu(iObser)))';
                        elseif iObser == 3
                            obserProb_est(iObser,:) = (VonMisesPDF_2(tempMidiPitch,tempDeltaPitch,M,kappa(iObser),a(iObser),bRan(iB3),mu(iObser)))';
                        end
                        [alphaS_est,c_est] = forward_alg_2(A_est,obserProb_est,pi_est);
                        log_likelihhod_temp = -1*sum(log(c_est));
                        if log_likelihhod_temp > max_log_likelihood_b
                            max_log_likelihood_b = log_likelihhod_temp;
                            max_log_likelihood_b_pos = [iB1;iB2;iB3];
                        end
                        PO_S_log_est_b(iB1,iB2,iB3) = -1*sum(log(c_est));
                    end  
                end
            end
        end 
        [maxValue,maxIndex] = max(PO_S_log_est_b(:));
        [X,Y,Z] = ind2sub(size(PO_S_log_est_b),maxIndex);
        b_est = [bRan(X),bRan(Y),bRan(Z)];      
        
        
        
        %------END of observation distribution estimation------
        
        %----END of MAXIMIZATION---------
    end
end
%------------------------------------