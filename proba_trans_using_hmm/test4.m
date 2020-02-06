%show the evaluation results for different state self probabilities
clear;

load('metricMolina_2.mat');

%------note model self transition range-----
startSelfR = (0.1:0.1:0.9);
sustainSelfR = (0.1:0.1:0.9);
endSelfR = (0.1:0.1:0.9);
%-------------------------------------------

meanMetricMolina = mean(metricMolina);

max(meanMetricMolina(:,:,:,:,1));

FCOnPOff = meanMetricMolina(1,8,:,:,:);
FCOnPOff = permute(FCOnPOff,[3 4 5 1 2]);

figure(1)
surf(sustainSelfR,startSelfR,FCOnPOff(:,:,4));
title(['FConPOff, End Self Probability = ',num2str(endSelfR(1))]);
ylabel('Start Self Probability');
xlabel('Sustain Self Probability');
view(2);

figure(2)
surf(sustainSelfR,startSelfR,FCOnPOff(:,:,5));
title(['FConPOff, End Self Probability = ',num2str(endSelfR(2))]);
ylabel('Start Self Probability');
xlabel('Sustain Self Probability');
view(2);

figure(3)
surf(sustainSelfR,startSelfR,FCOnPOff(:,:,6));
title(['FConPOff, End Self Probability = ',num2str(endSelfR(3))]);
ylabel('Start Self Probability');
xlabel('Sustain Self Probability');
view(2);