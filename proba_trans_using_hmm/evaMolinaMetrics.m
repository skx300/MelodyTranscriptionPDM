%Report the evaluation metrics from Molina2014 and use the same dataset.

load('evaData.mat');

folderPath = '../../Dataset/EvaluationFramework_ISMIR2014/';
fileNames = readtable([folderPath,'/dataset/fileNames.csv']);

evaBaseTotal = zeros(size(fileNames,1),32);
evaMeloTotal = zeros(size(fileNames,1),32);
evaRyynanenTotal = zeros(size(fileNames,1),32);
evaSmstoolsTotal = zeros(size(fileNames,1),32);
evaSiPTHTotal = zeros(size(fileNames,1),32);
evaTonyTotal = zeros(size(fileNames,1),32);
evaCanteTotal = zeros(size(fileNames,1),32);
evaNoteModelTotal_1 = zeros(size(fileNames,1),32);
evaNoteModelTotal_2 = zeros(size(fileNames,1),32);
for i = 1:size(fileNames,1);
    groundTruthFileName = mat2cell([folderPath,'/dataset/',cell2mat(fileNames{i,1}),'.GroundTruth.txt'],1);
    
    %----for baseline-------
    %my baseline
% %     transFileNameBase = mat2cell(['data/forMolinaMetric/',cell2mat(fileNames{i,1}),'.notesBaseline.csv'],1);
%     %Molina's baseline
%     transFileNameBase = mat2cell([folderPath,'/transcription/baseline/',cell2mat(fileNames{i,1}),'.baseline.mid'],1);
%     evaBaseTotal(i,:) = evaluation(groundTruthFileName,transFileNameBase);  
%     
%     %----for Melotranscription---
%     transFileNameMelo = mat2cell([folderPath,'/transcription/melotranscript/',cell2mat(fileNames{i,1}),'.melotranscript.not'],1);
%     evaMeloTotal(i,:) = evaluation(groundTruthFileName,transFileNameMelo); 
%     
%     %----for Ryynanen-----------
%     transFileNameRyynanen = mat2cell([folderPath,'/transcription/ryynanen/',cell2mat(fileNames{i,1}),'.ryynanen.not'],1);
%     evaRyynanenTotal(i,:) = evaluation(groundTruthFileName,transFileNameRyynanen); 
%     
%     %----for smstools-------
%     transFileNameSmstools = mat2cell([folderPath,'/transcription/smstools/',cell2mat(fileNames{i,1}),'.smstools.not'],1); 
%     evaSmstoolsTotal(i,:) = evaluation(groundTruthFileName,transFileNameSmstools);
%     
%     %----for SiPTH----------
% %     transFileNameSiPTH = mat2cell([folderPath,'/dataset/',cell2mat(fileNames{i,1}),'.TransExample.mid'],1);
%     transFileNameSiPTH = mat2cell([folderPath,'/transcription/sipth/',cell2mat(fileNames{i,1}),'.sipth.csv'],1); 
%     evaSiPTHTotal(i,:) = evaluation(groundTruthFileName,transFileNameSiPTH);
%     
%     %----for tony-----------
%     transFileNameTony = mat2cell([folderPath,'/transcription/tony/',cell2mat(fileNames{i,1}),'.tony.csv'],1); 
%     evaTonyTotal(i,:) = evaluation(groundTruthFileName,transFileNameTony);
%     
%     %----for Cante----------
%     transFileNameCante = mat2cell([folderPath,'/transcription/cante/',cell2mat(fileNames{i,1}),'.mid'],1);  
%     evaCanteTotal(i,:) = evaluation(groundTruthFileName,transFileNameCante);
%     
%     %----for Note Model HMM----
%     transFileNameNoteModel_1 = mat2cell([folderPath,'/transcription/NoteModel_1/',cell2mat(fileNames{i,1}),'.notesHMMNoteModel.csv'],1);
%     evaNoteModelTotal_1(i,:) = evaluation(groundTruthFileName,transFileNameNoteModel_1);
    
    %----for current Note Model HMM------
    transFileNameNoteModel_2 = mat2cell([folderPath,'/transcription/NoteModel_3/',cell2mat(fileNames{i,1}),'.notesHMMNoteModel.csv'],1);
    evaNoteModelTotal_2(i,:) = evaluation(groundTruthFileName,transFileNameNoteModel_2);
    
end
load('data/otherMethodResults.mat');
%save other methods results
% save('otherMethodResults','evaBaseTotal','evaMeloTotal','evaRyynanenTotal',...
%     'evaSmstoolsTotal','evaSiPTHTotal','evaTonyTotal','evaCanteTotal','evaNoteModelTotal_1');

%calculate error bar
evaBaseTotalError = confidenceIntervalError(evaBaseTotal);
evaMeloTotalError = confidenceIntervalError(evaMeloTotal);
evaRyynanenTotalError = confidenceIntervalError(evaRyynanenTotal);
evaSmstoolsTotalError = confidenceIntervalError(evaSmstoolsTotal);
evaSiPTHTotalError = confidenceIntervalError(evaSiPTHTotal);
evaTonyTotalError = confidenceIntervalError(evaTonyTotal);
evaCanteTotalError = confidenceIntervalError(evaCanteTotal);
evaNoteModelTotal_1Error = confidenceIntervalError(evaNoteModelTotal_1);
evaNoteModelTotal_2Error = confidenceIntervalError(evaNoteModelTotal_2);

measureNum = [6,7,8,10,11,12,14,15,16,18,20,22,24,27,30,32];
measureNum_correct = [6,7,8,10,11,12,14,15,16];
measureNum_wrong = [18,20,22,24,27,30,32];

evaBaseTotalMean = mean(evaBaseTotal);
evaMeloTotalMean = mean(evaMeloTotal);
evaRyynanenTotalMean = mean(evaRyynanenTotal);
evaSmstoolsTotalMean = mean(evaSmstoolsTotal);
evaSiPTHTotalMean = mean(evaSiPTHTotal);
evaTonyTotalMean = mean(evaTonyTotal);
evaCanteTotalMean = mean(evaCanteTotal);
evaNoteModel_1TotalMean = mean(evaNoteModelTotal_1);
evaNoteModel_2TotalMean = mean(evaNoteModelTotal_2);

fontSize = 30;
figure(8)
bh1 = bar([evaBaseTotalMean(measureNum_correct);evaRyynanenTotalMean(measureNum_correct);evaSmstoolsTotalMean(measureNum_correct);evaSiPTHTotalMean(measureNum_correct);evaTonyTotalMean(measureNum_correct);evaNoteModel_2TotalMean(measureNum_correct)]');
% hold on
% %plot errorbars on the top of bar
% a = [evaBaseTotalMean(measureNum_correct);evaRyynanenTotalMean(measureNum_correct);evaSmstoolsTotalMean(measureNum_correct);evaSiPTHTotalMean(measureNum_correct);evaTonyTotalMean(measureNum_correct);evaNoteModel_2TotalMean(measureNum_correct)]';
% b = [evaBaseTotalError(measureNum_correct);evaRyynanenTotalError(measureNum_correct);evaSmstoolsTotalError(measureNum_correct);evaSiPTHTotalError(measureNum_correct);evaTonyTotalError(measureNum_correct);evaNoteModelTotal_2Error(measureNum_correct)]';
% for ib = 1:numel(bh1)
%     %XData property is the tick labels/group centers; XOffset is the offset
%     %of each distinct group
%     xData = bh1(ib).XData+bh1(ib).XOffset;
%     errorbar(xData,a(:,ib),b(:,ib),'k.','LineWidth',1);
% end
% hold off
% title('Precision, Recall and F-measure of Note-level Eavaluation');
str = {'P','R','F','P','R','F','P','R','F'};
str2 = {'COnPOff','COnP','COn'};
set(gca, 'XTickLabel',{}, 'XTick',1:numel(str),'FontSize',fontSize,'XTickLabelRotation',45);
%use the text create customised XTickLabel
for i = 1:length(str)
    text(i-0.1,-0.03,str(i),'FontSize',fontSize);
end
for i = 1:length(str2)
    if i == 1
        text((i-1)*3+1.3,-0.07,str2(i),'FontSize',fontSize);
    elseif i == 2
        text((i-1)*3+1.5,-0.07,str2(i),'FontSize',fontSize);
    elseif i == 3
        text((i-1)*3+1.7,-0.07,str2(i),'FontSize',fontSize);
    end
end
legend('Baseline',['Ryyn',char(228),'nen'],'G車mez & Bonada','SiPTH','Tony','Proposed','Location','NorthWest');
ylim([0 0.9]);
grid on;

figure(9)
bar([evaBaseTotalMean(measureNum_wrong);evaRyynanenTotalMean(measureNum_wrong);evaSmstoolsTotalMean(measureNum_wrong);evaSiPTHTotalMean(measureNum_wrong);evaTonyTotalMean(measureNum_wrong);evaNoteModel_2TotalMean(measureNum_wrong)]');
% title('Error Rate of Note-level Eavaluation');
str = {'OBOn','OBP','OBOff',...
    'S','M',...
    'PU','ND'};
set(gca, 'XTickLabel',str, 'XTick',1:numel(str),'FontSize',fontSize,'XTickLabelRotation',0);
% title('Note-level ');
legend('Baseline',['Ryyn',char(228),'nen'],'G車mez & Bonada','SiPTH','Tony','Proposed','Location','NorthEast');
grid on;

figure(10)
bar([evaRyynanenTotalMean(measureNum);evaSmstoolsTotalMean(measureNum);evaSiPTHTotalMean(measureNum);evaTonyTotalMean(measureNum);evaNoteModel_1TotalMean(measureNum);evaNoteModel_2TotalMean(measureNum)]');
title('Note-level Precion, Recall and F-measure for Note Model');
str2 = {'P-COnPOff','R-COnPOff','F-COnPOff','P-COnP','R-COnP','F-COnP'...
    ,'P-COn','R-COn','F-COn','Rate of OBOn','Rate of OBP','Rate of OBOff',...
    'Rate of Split','Rate of Merged',...
    'Rate of Spurious','Rate of Non-detected'};
set(gca, 'XTickLabel',str2, 'XTick',1:numel(str2),'FontSize',fontSize,'XTickLabelRotation',45);
legend(['Ryyn',char(228),'nen'],'G車mez & Bonada','SiPTH','Tony','Proposed','Proposed with Spectal flux');

figure(11)
bar([evaBaseTotalMean(measureNum);evaRyynanenTotalMean(measureNum);evaSmstoolsTotalMean(measureNum);evaSiPTHTotalMean(measureNum);evaTonyTotalMean(measureNum);evaNoteModel_1TotalMean(measureNum);evaNoteModel_2TotalMean(measureNum)]');
title('Note-level Precion, Recall and F-measure for Note Model');
str2 = {'P-COnPOff','R-COnPOff','F-COnPOff','P-COnP','R-COnP','F-COnP'...
    ,'P-COn','R-COn','F-COn','Rate of OBOn','Rate of OBP','Rate of OBOff',...
    'Rate of Split','Rate of Merged',...
    'Rate of Spurious','Rate of Non-detected'};
set(gca, 'XTickLabel',str2, 'XTick',1:numel(str2),'FontSize',fontSize,'XTickLabelRotation',45);
legend('Baseline',['Ryyn',char(228),'nen'],'G車mez & Bonada','SiPTH','Tony','Proposed','Proposed with Spectral Flux');