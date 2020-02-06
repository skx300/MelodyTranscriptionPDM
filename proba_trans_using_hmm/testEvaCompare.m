%evaluation comparison

load('evaData.mat');

%------raw pitch accuracy---------



%---frame-wise precision, recall and f-measure
fwBaselineArray = zeros(size(fwBaseline,1),3);
for iii = 1:size(fwBaseline,1) 
    fwBaselineArray(iii,:) = fwBaseline{iii,1}'; 
end

[fwHMMStruArray,fwHMMStruArrayIndex] = evaGetArray(fwHMMStru);
[fwHMMNoteArray,fwHMMNoteArrayIndex] = evaGetArray(fwHMMNote);

fwBaselineArrayMean = mean(fwBaselineArray);
fwCanteMean = mean(fwCante);
fwSIPTHMean = mean(fwSIPTH);
fwHMMStruArrayMean = mean(fwHMMStruArray);
fwHMMNoteArrayMean = mean(fwHMMNoteArray);


fwTotal = [fwBaselineArrayMean;fwCanteMean;fwSIPTHMean;fwHMMNoteArrayMean]';

fontSize = 30;
figure(1)
bar(fwTotal);
title('Frame-level Precion, Recall and F-measure','FontSize',fontSize);
legend('Basline','Cante','SiPTH','Note Model HMM');
ylim([0.5 0.9]);
str = {'Precison','Recall','F-measure'};
set(gca, 'XTickLabel',str, 'XTick',1:numel(str),'FontSize',fontSize);