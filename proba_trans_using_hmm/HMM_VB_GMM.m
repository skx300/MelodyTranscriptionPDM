%HMM method that take the output, gammaHat, from VB_GMM

clear;

load('../VB-GMM/gammaHat.mat');
load('../VB-GMM/T.mat');
load('../VB-GMM/K.mat');
kStart = 5000;

%----get pitch---------
data = csvread('../Huangjiangqin/Huangjiangqin-1.csv');
time = data(:,1);
pitch = data(:,2);
midiPitchOriginal = freqToMidi(pitch);

%-----get annotation-------
annotation = csvread('../Huangjiangqin/Huangjiangqin-1-Note-Annotation-new.csv');
% annotation = csvread('../SingingVoiceCorpus_toLuwei/GroundTruth/amateur/clk_ak03.lab');
% stateGroundTruth = zeros(size(pitch))';
% for i = 1:size(annotation,1)
%     startPoint = annotation(i,1);
%     endPoint = startPoint+annotation(i,3);
%     stateGroundTruth(time>=startPoint & time <= endPoint) = annotation(i,2);
% end

%------get power curve------------------
windowLength = 1024;
step = windowLength/2;
[powerCurve, timePowerCurve] = GetPowerCurve('../Huangjiangqin/Huangjiangqin-1.wav',windowLength,step);

%do interpolation if the size of power curve is not same as the f0
powerCurve = spline(timePowerCurve,powerCurve,T);
%---------------------------------------

stateRangeTrans = [1:K];  
octaNum = floor(K/12/4);

%-------create confusion matrix-----------
confusionK = zeros(K,K);
for i = 1:K
   if mod(i,12*4) == 1
       %harmonic part
       if i == 1
            confusionK(i,1) = (1-K*0.001)/(octaNum)+0.1;
       else
            confusionK(i,1) = (1-K*0.001)/(octaNum);
       end
   else
       %in harmonic part
       confusionK(i,1) = 0.001; 
   end
end

for i = 2:K
    confusionK(:,i) = circshift(confusionK(:,1),i-1);
end
%------------------------------------
observationMatrix = confusionK*gammaHat;

stateRangePower = [1,2];    %voiced and unvoiced
observationMatrixPower = zeros(size(gammaHat));
observationMatrixPowerTemp = zeros(2,length(T));
%-------create observation matrix for power curve-------
for i = 1:length(stateRangePower)
    if i == 1
        %voiced
        observationMatrixPowerTemp(i,:) = pdf('Gamma',powerCurve,1.5,4)*0.01;
    elseif i == 2
        %unvoiced
        observationMatrixPowerTemp(i,:) = normpdf(powerCurve,0,0.05)*0.01;
    end
end
%-------------------------------------------------------
decodedSeqPower = ViterbiAlgHMM([0.8,0.2;0.5,0.5],observationMatrixPowerTemp,[0.5 0.5]);

%------get transition matrix----------
transMatrix = zeros(length(stateRangeTrans));
for i = 1:size(transMatrix,1)
    if (i == 1)
        %for "slient" part
        paraTransPitch = [i-1,4];
    else
        paraTransPitch = [i-1,4];
    end
    transMatrix(i,:) = normpdf(stateRangeTrans,paraTransPitch(1),paraTransPitch(2))*1;
end
%-------------------------------------    

initialStateDistribution = 1/length(stateRangeTrans)*ones(1,length(stateRangeTrans));

decodedSeq = ViterbiAlgHMM(transMatrix,observationMatrix,initialStateDistribution);
decodedSeq = (decodedSeq - 1)/4+kStart/100;


%-----------Evaluation of decoded sequence and f0----------- 
midiPitchOriginalInter = spline(time,midiPitchOriginal,T);
evalf0 = sqrt(sum((decodedSeq - midiPitchOriginalInter).^2));
%-----------------------------------------------------------

% VB_DATA = [T',decodedSeq'];
% save VB_DATA;

fontSize = 20;
figure(1)
subplot(3,1,1)
plot(T,decodedSeq);
hold on
plot(time,midiPitchOriginal);
plot(T,midiPitchOriginalInter,'k');
for i = 1:size(annotation,1)
    plot([annotation(i,1),annotation(i,1)+annotation(i,3)],[annotation(i,2),annotation(i,2)],'g','LineWidth',2);
end
hold off
legend('VB-GMM-HMM','f0','Interpolated f0','Annotation');
set(gca, 'FontSize', fontSize);
xlim([T(1),T(end)]);
ylim([50 85]);
title('Decoded Sequence');

subplot(3,1,2)
surf(T,kStart+([1:K(end)]-1)*25,10*log10(gammaHat),'EdgeColor','none');
axis xy; axis tight; colormap(jet); view(0,90);
title('gammaHat');
ylabel('Basis','fontSize',fontSize);
xlabel('Time(s)','fontSize',fontSize);

subplot(3,1,3)
plot(T,powerCurve);
xlabel('Time(s)','fontSize',fontSize);
ylabel('Power','fontSize',fontSize);
xlim([T(1),T(end)]);
title('Power Curve');

figure(4)
subplot(2,1,1);
surf(T,kStart+([1:K(end)]-1)*25,10*log10(gammaHat),'EdgeColor','none');
axis xy; axis tight; colormap(jet); view(0,90);
title('gammaHat');
ylabel('Basis','fontSize',fontSize);
xlabel('Time(s)','fontSize',fontSize);

subplot(2,1,2)
surf(T,kStart+([1:K(end)]-1)*25,10*log10(observationMatrix),'EdgeColor','none');
axis xy; axis tight; colormap(jet); view(0,90);
title('Observation matrix');
ylabel('Basis','fontSize',fontSize);
xlabel('Time(s)','fontSize',fontSize);

figure(5)
plot(T,1./decodedSeqPower);
xlim([T(1),T(end)]);
ylim([0 1.5]);
title('Voice and unvoiced detection');

figure(6)
surf(50+[0:K-1]/4,50+[0:K-1]/4,10*log10(confusionK),'EdgeColor','none');
axis xy; axis tight; colormap(jet); view(0,90);
title('Confusion matrix');
ylabel('Midi Note','fontSize',fontSize);
xlabel('Midi Note','fontSize',fontSize);