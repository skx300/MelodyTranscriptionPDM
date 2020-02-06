%use the sturcture HMM 

clf;
clear;

% folderPath = '../../Dataset/singing-f0-eval-dataset/';
folderPath = '../../Dataset/EvaluationFramework_ISMIR2014/DATASET/';
fileNames = readtable([folderPath,'fileNames.csv']);
accuracyBaseline = cell(size(fileNames,1),1);
accuracyHMMBase = cell(size(fileNames,1),1);
accuracyHMMStru = cell(size(fileNames,1),1);
accuracyHMMStruSteady = cell(size(fileNames,1),1);
accuracyHMMNote  = cell(size(fileNames,1),1);
editDBaseline = cell(size(fileNames,1),1);
editDHMMBase = cell(size(fileNames,1),1);
editDHMMStruSteady = cell(size(fileNames,1),1);
editDHMMNoteModel = cell(size(fileNames,1),1);
fwBaseline = cell(size(fileNames,1),1);
fwHMMStru = cell(size(fileNames,1),1);
fwHMMNote = cell(size(fileNames,1),1);
fwHMMNoteGap= cell(size(fileNames,1),1);

% for numFile = 1:size(fileNames,1)
% numFile = 1;
for numFile = 1
clearvars -except numFile folderPath fileNames editDBaseline editDHMMBase editDHMMStruSteady editDHMMNoteModel...
    fwBaseline fwHMMStru fwHMMNote fwHMMNoteGap accuracyBaseline accuracyHMMBase accuracyHMMStru accuracyHMMStruSteady...
    accuracyHMMNote
    fileName = char(fileNames{numFile,1});
    disp([num2str(numFile),':',fileName]);
    % using my data
%     data = csvread('../../Dataset/Huangjiangqin/Huangjiangqin-2.csv');
%     data = csvread([folderPath,'f0_pyin/child2_f0_pyin.csv']);    
    data = csvread([folderPath,'f0_pyin/',fileName,'_f0_pyin.csv']); 
    time = data(:,1);
    pitchVibrato = data(:,2);

    %--------------------------
    % using YAMAHA data
%     data = csvread([folderPath,'clk_vt_me01.pitch']);
%     pitchVibrato = data(:,3); 
%     audioFs = 44100;
%     pitchWindow = 441;
%     time = (data(:,1)+pitchWindow/2)/audioFs;
%     time = time-time(1);
    %--------------------------

    % load('../../Dataset/Huangjiangqin/Huangjiangqin-2-VibratoFree.mat');
    % load('../../Laurel-Data/midiSpitchNoVibrato.mat');
    % pitchNoVibrato = midiSpitchNoVibrato;
    pitchFs = 1/(time(2)-time(1));

    %-------------------------------------------------
    %get the power curve with the same sampling rate with the f0
    widowLengthf0 = 1024;
    stepf0 = round(44100/pitchFs); 
    % [powerCurve, timePowerCurve] = GetPowerCurve('../../Dataset/Huangjiangqin/Huangjiangqin-2.wav',widowLengthf0,stepf0);
%     [powerCurve, ZCRCurve, timePowerCurve] = GetPowerZCR([folderPath,'clk_vt_me01.wav'],widowLengthf0,stepf0);
    [powerCurve, ZCRCurve, timePowerCurve] = GetPowerZCR([folderPath,fileName,'.wav'],widowLengthf0,stepf0);
    %do interpolation if the size of power curve is not same as the f0
    powerCurve = spline(timePowerCurve,powerCurve,time);
    ZCRCurve = spline(timePowerCurve,ZCRCurve,time);
    %-------------------------------------------------

    %---------START of Ground-Truth---------
    % annotation = csvread('../../Dataset/Huangjiangqin/Huangjiangqin-2-Note-Annotation-new.csv');
%     annotation = csvread([folderPath,'clk_vt_me01_Luwei.csv']);
    annotation = GT_Molina2OUR([folderPath,fileName,'.GroundTruth.txt']);
%     annotation(:,2) = round(annotation(:,2));
    stateGroundTruth = zeros(size(pitchVibrato));
    for i = 1:size(annotation,1)
        startPoint = annotation(i,1);
        endPoint = startPoint+annotation(i,3); 
        stateGroundTruth(time>=startPoint & time <= endPoint) = annotation(i,2);
    end
    %---------END of Ground-Truth---------

    %-------START pitch pre-processing------------

    %--Median filtering----
    % pitchVibrato = medf(pitchVibrato',3,length(pitchVibrato))';

    %get pitch deviation
    pitchDeviation = GetPitchDeviation(pitchVibrato);
    pitchDevGround = pitchDeviation(1);
    pitchDevCeil = pitchDeviation(2);

    midiPitchVibrato = freqToMidi(pitchVibrato);

    midiPitchOriginal = freqToMidi(pitchVibrato);
    %--Median filtering----
    midiPitchOriginal = medf(midiPitchOriginal,5,length(midiPitchOriginal));

    midiPitchGround = zeros(size(midiPitchOriginal));
    midiPitchCeil = zeros(size(midiPitchOriginal));
    midiPitchGround(midiPitchOriginal > 0) = midiPitchOriginal(midiPitchOriginal > 0)-pitchDevGround;
    midiPitchCeil(midiPitchOriginal > 0) = midiPitchOriginal(midiPitchOriginal > 0)+pitchDevCeil;

    %get delta f0
    deltaMidiPitch = [0;diff(smooth(midiPitchOriginal,10))];
    deltaMidiPitch(abs(deltaMidiPitch) > 3) = 0; %it is necessary
    %-------END pitch pre-processing------------

    %%

    stateRangeMIDI = [1:128]';
    stateRangeTransBaseline = [0:128]';  %128 midi notes "0" for silent state.
    stateRangeTransStructure = [0:384]'; %3*128+1, every midi note has 3 states: steady, transition-up, transiton-down
    stateRangeTransition = [-1,0,1]'; %the transition states: up, steady, down.

    %------------START of Baseline method----------------
    %Assign the f0 to the nearest MIDI NN
    decodedBaseline = round(midiPitchVibrato);
    %------------End of Baseline method------------------

    %---------Get initial state PDF, transiton matrix and observation matrix
    initialStateDistribution = 1/length(stateRangeTransStructure)*ones(1,length(stateRangeTransStructure));
    [transPitchBaseline,transPitchStructure] = ...
        GetTransMatrix(stateRangeTransBaseline,stateRangeTransition);

    observsBaselineOriginal = GetObservsMatrixBaseline(midiPitchOriginal,stateRangeTransBaseline);
    observsBaselineGround = GetObservsMatrixBaseline(midiPitchGround,stateRangeTransBaseline);
    observsBaselineCeil = GetObservsMatrixBaseline(midiPitchCeil,stateRangeTransBaseline);

    observsStructureOriginal = ...
        GetObservsMatrixStructure(midiPitchOriginal,deltaMidiPitch,stateRangeMIDI,stateRangeTransition);
    observsStructureGround = ...
        GetObservsMatrixStructure(midiPitchGround,deltaMidiPitch,stateRangeMIDI,stateRangeTransition);
    observsStructureCeil = ...
        GetObservsMatrixStructure(midiPitchCeil,deltaMidiPitch,stateRangeMIDI,stateRangeTransition);
    %------------------------------

    %-------Power curve HMM-------
    %two states: voiced and unvoiced
    initialStateDistributionPowerCurve = [0.5,0.5];
    transPowerCurve = [0.7,0.3;...
                       0.3,0.7];

    [observationMatrixPower,observationMatrixPowerTemp] = GetObservsMatrixPower(powerCurve,stateRangeTransStructure);
    decodedPower =  ViterbiAlgHMM(transPowerCurve,observationMatrixPowerTemp,initialStateDistributionPowerCurve);

    decodedPower = 1./decodedPower;
    decodedPower(decodedPower == 0.5) = 0;
    %-------------------------------------------------------
    %%

    %-------START of HMM Baseline-------------
    %[original, ground, ceil]
    decodedHMMBase = zeros(length(midiPitchOriginal),3); 
    midiTranscriptionCeilHMMBaseline = ViterbiAlgHMM(transPitchBaseline,observsBaselineCeil,initialStateDistribution);

    decodedHMMBase(:,1) = ViterbiAlgHMM(transPitchBaseline,observsBaselineOriginal,initialStateDistribution);
    decodedHMMBase(:,2) = ViterbiAlgHMM(transPitchBaseline,observsBaselineGround,initialStateDistribution);
    decodedHMMBase(:,3) = ViterbiAlgHMM(transPitchBaseline,observsBaselineCeil,initialStateDistribution);

    decodedHMMBase = decodedHMMBase-1;
    %-------END of HMM Baseline---------------

    %-------START of the HMM Sturcture------------
    %[original, ground, ceil]
    decodedHMMStru = zeros(length(midiPitchOriginal),3);    
    decodedHMMStru(:,1) = ViterbiAlgHMM(transPitchStructure,observsStructureOriginal,initialStateDistribution);
    decodedHMMStru(:,2) = ViterbiAlgHMM(transPitchStructure,observsStructureGround,initialStateDistribution);
    decodedHMMStru(:,3) = ViterbiAlgHMM(transPitchStructure,observsStructureCeil,initialStateDistribution);

    decodedHMMStru = decodedHMMStru/3;
    decodedHMMStru(decodedHMMStru == (1/3)) = 0;

    decodedHMMStruSteady = zeros(size(decodedHMMStru));
    for i = 1:size(decodedHMMStru,2)
        decodedHMMStruSteady(decodedHMMStru(:,i)-floor(decodedHMMStru(:,i)) == 0,i) = decodedHMMStru(decodedHMMStru(:,i)-floor(decodedHMMStru(:,i)) == 0,i);
    end
    %-------END of the HMM Sturcture------------

    %-----START of the HMM note level model------
    stateRangeMIDINote = [0:128]; %MIDI num 1:128, 0 for silent
    numStateRangeMIDI = length(stateRangeMIDINote);
    numStatesNoteModel = 3*length(stateRangeMIDINote); %every midi note has three states: start-sustain-end
    %-----initial distribution---------------------
    %only can go to attack states.
    initalDistributionNoteModel = 1/numStateRangeMIDI*ones(3,1);
    initalDistributionNoteModel(2:end) = 0;
    initalDistributionNoteModel = repmat(initalDistributionNoteModel,numStateRangeMIDI,1);

    %--------transition matrix----------------
    transNoteModel = GetTransMatrixNoteModel(stateRangeMIDINote);

    %------observation matrix---------
    observationNoteModelOriginal = GetObservsMatrixNoteModel(midiPitchOriginal,deltaMidiPitch,numStatesNoteModel);
    observationNoteModelGround = GetObservsMatrixNoteModel(midiPitchGround,deltaMidiPitch,numStatesNoteModel);
    observationNoteModelCeil = GetObservsMatrixNoteModel(midiPitchCeil,deltaMidiPitch,numStatesNoteModel);

    decodedHMMNote = zeros(length(midiPitchOriginal),3); 
    decodedHMMNote(:,1) = ViterbiAlgHMM(transNoteModel',observationNoteModelOriginal,initalDistributionNoteModel);
    decodedHMMNote(:,2) = ViterbiAlgHMM(transNoteModel',observationNoteModelGround,initalDistributionNoteModel);
    decodedHMMNote(:,3) = ViterbiAlgHMM(transNoteModel',observationNoteModelCeil,initalDistributionNoteModel);
    decodedHMMNote = floor((decodedHMMNote-1)/3);

    %-----END of the HMM note level model--------


    %%
    %----START of evaluation-------------------
    decodedHMMStru = decodedHMMStru.*repmat(decodedPower',1,3);
    decodedHMMStruMerge = TransPartToSteady(decodedHMMStru);
    % decodedHMMStruFollow = decodedHMMStruMerge;
    decodedHMMStruFollow = TransPartToFollow(decodedHMMStruMerge);

    decodedHMMNote = decodedHMMNote.*repmat(decodedPower',1,3);

    %1. framewise accuracy
    accuracyBaseline{numFile,1} = AccuracyEva(decodedBaseline,stateGroundTruth);
    accuracyHMMBase{numFile,1} = AccuracyEva(decodedHMMBase,stateGroundTruth);
    accuracyHMMStru{numFile,1} = AccuracyEva(round(decodedHMMStru),stateGroundTruth);

    stateGroundTruthSteady = stateGroundTruth;
    stateGroundTruthSteady((decodedHMMStru(:,3)-floor(decodedHMMStru(:,3))~=0)) = 0; 
    accuracyHMMStruSteady{numFile,1} = AccuracyEva(decodedHMMStruSteady,stateGroundTruth);

    accuracyHMMNote{numFile,1} = AccuracyEva(decodedHMMNote,stateGroundTruth);


    %------Note aggregation-----------------
    notesBaseline = NoteAggreBaseline(decodedBaseline,pitchFs); 
    notesHMMBase = NoteAggreBaseline(decodedHMMBase,pitchFs);
    notesHMMStruSteady = NoteAggreBaseline(decodedHMMStruFollow,pitchFs);
    notesHMMNoteModel = NoteAggreBaseline(decodedHMMNote,pitchFs);
    %---------------------------------------

    %---------START OF fill gap------------------
    decodedHMMNoteGap(:,1) = FillGap(decodedHMMNote(:,1),decodedHMMStru(:,1),notesHMMNoteModel{1,1},pitchFs);
    decodedHMMNoteGap(:,2) = FillGap(decodedHMMNote(:,2),decodedHMMStru(:,2),notesHMMNoteModel{1,2},pitchFs);
    decodedHMMNoteGap(:,3) = FillGap(decodedHMMNote(:,3),decodedHMMStru(:,3),notesHMMNoteModel{1,3},pitchFs);
    %---------END OF fill gap------------------

    %------Small duration pruning---------
    durationThresh = 0.1; %in seconds
    notesBaseline = NotePruning(notesBaseline, durationThresh);
    notesHMMBase = NotePruning(notesHMMBase, durationThresh);
    notesHMMStruSteady = NotePruning(notesHMMStruSteady, durationThresh);
    notesHMMNoteModel = NotePruning(notesHMMNoteModel, durationThresh);
    %-------------------------------------

    %2. edit distance
%     editDBaseline{numFile,1} = EditDistance_2(notesBaseline{1,1}(:,2),annotation(:,2))/length(annotation(:,2));
% 
%     editDHMMBase{numFile,1} = zeros(1,size(notesHMMBase,2));
%     for i = 1:size(notesHMMBase,2)
%         editDHMMBase{numFile,1}(1,i) = EditDistance_2(notesHMMBase{1,i}(:,2),annotation(:,2))/length(annotation(:,2));
%     end
% 
%     editDHMMStruSteady{numFile,1} = zeros(1,size(notesHMMStruSteady,2));
%     for i = 1:size(notesHMMStruSteady,2)
%         editDHMMStruSteady{numFile,1}(1,i) = EditDistance_2(notesHMMStruSteady{1,i}(:,2),annotation(:,2))/length(annotation(:,2));
%     end

    editDHMMNoteModel{numFile,1} = zeros(1,size(notesHMMNoteModel,2));
    for i = 1:size(editDHMMNoteModel,2)
        editDHMMNoteModel{numFile,1}(1,i) = EditDistance_2(notesHMMNoteModel{1,i}(:,2),annotation(:,2))/length(annotation(:,2));
    end

    %3. frame-wise f-measure, precison and recall
    fwBaseline{numFile,1} = frameFmeasure(decodedBaseline,stateGroundTruth);
    fwHMMStru{numFile,1} = frameFmeasure(round(decodedHMMStru),stateGroundTruth);
    fwHMMNote{numFile,1} = frameFmeasure(decodedHMMNote,stateGroundTruth);
    fwHMMNoteGap{numFile,1} = frameFmeasure(decodedHMMNoteGap,stateGroundTruth);
    %-------END of evaluation---------------------------
    
%     csvwrite(['data/',fileName,'.notesBaseline.csv'],notesBaseline{1,1});
%     csvwrite(['data/',fileName,'.notesHMMBase3.csv'],notesHMMBase{1,3});
%     csvwrite(['data/',fileName,'.notesHMMStruSteady1.csv'],notesHMMStruSteady{1,1});
%     csvwrite(['data/',fileName,'.notesHMMStruSteady2.csv'],notesHMMStruSteady{1,2});
%     csvwrite(['data/',fileName,'.notesHMMStruSteady3.csv'],notesHMMStruSteady{1,3});
    
    
    csvwrite(['data/',fileName,'.notesHMMNoteModel1.csv'],notesHMMNoteModel{1,1});
    csvwrite(['data/',fileName,'.notesHMMNoteModel2.csv'],notesHMMNoteModel{1,2});
    csvwrite(['data/',fileName,'.notesHMMNoteModel3.csv'],notesHMMNoteModel{1,3});
    
    %get Molina2014 metrics
    for i = 1:length(notesHMMNoteModel)
        evaMolinaMetric(i,:) = evaluation(cellstr([folderPath,fileName,'.GroundTruth.txt']),cellstr(['data/',fileName,'.notesHMMNoteModel',num2str(i),'.csv']));
    end
end

% save evaData editDBaseline editDHMMBase editDHMMStruSteady editDHMMNoteModel...
%     fwBaseline fwHMMStru fwHMMNote fwHMMNoteGap accuracyBaseline accuracyHMMBase accuracyHMMStru accuracyHMMStruSteady...
%     accuracyHMMNote;