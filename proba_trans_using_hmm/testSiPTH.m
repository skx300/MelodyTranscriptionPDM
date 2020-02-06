%SiPTH Method

folderPath = '../../Dataset/EvaluationFramework_ISMIR2014/DATASET/';
fileNames = readtable([folderPath,'fileNames.csv']);
fwSIPTH = zeros(size(fileNames,1),3);
editDSIPTH = zeros(size(fileNames,1),1);
for t = 1:size(fileNames,1)
% for t = 1:1
    
    data = csvread([folderPath,'f0_pyin/',char(fileNames{t,1}),'_f0_pyin.csv']);
    time = data(:,1);
    pitchVibrato = data(:,2);

%     fid = fopen(['../../Dataset/EvaluationFramework_ISMIR2014/Results-SiPTH/',char(fileNames{t,1}),'_SiPTH.csv']);
    %the results from Molina
    fid = fopen(['../../Dataset/EvaluationFramework_ISMIR2014/sipth_transcription/',char(fileNames{t,1}),'.sipth.csv']);
    c = textscan(fid,'%f%f%f%f%s','delimiter',',');
    dataSIPTH = [c{1,1},c{1,2},c{1,3}];
    dataSIPTHNew = zeros(size(dataSIPTH));
    for i = 1:size(dataSIPTH,1)
       dataSIPTHNew(i,1) =  dataSIPTH(i,1);
       dataSIPTHNew(i,2) =  dataSIPTH(i,3);
       dataSIPTHNew(i,3) =  dataSIPTH(i,2) - dataSIPTH(i,1);
    end
    dataSIPTHNew(:,2) = round(dataSIPTHNew(:,2));
    dataSIPTH = dataSIPTHNew;
    
    %---------START of Ground-Truth---------  
    annotation = GT_Molina2OUR([folderPath,char(fileNames{t,1}),'.GroundTruth.txt']);
    annotation(:,2) = round(annotation(:,2));
    stateGroundTruth = zeros(size(pitchVibrato));
    for i = 1:size(annotation,1)
        startPoint = annotation(i,1);
        endPoint = startPoint+annotation(i,3); 
        stateGroundTruth(time>=startPoint & time <= endPoint) = annotation(i,2);
    end
    %---------END of Ground-Truth--------- 
    
    editDSIPTH(t) = EditDistance_2(dataSIPTH(:,2),annotation(:,2))/length(annotation(:,2));
    
    decodedSIPTH = zeros(size(stateGroundTruth));
    for i = 1:size(dataSIPTH,1)
        startPoint = dataSIPTH(i,1);
        endPoint = startPoint+dataSIPTH(i,3); 
        decodedSIPTH(time>=startPoint & time <= endPoint) = dataSIPTH(i,2);
    end

    fwSIPTH(t,:) = (frameFmeasure(decodedSIPTH,stateGroundTruth))';
end