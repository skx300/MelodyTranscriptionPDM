%use the HMM note model

clf;
clear;

%for Octave server
% addpath(genpath(pwd)); %add all current subfolders to the search path
% folderPath = 'EvaluationFramework_ISMIR2014/DATASET/';    

%for macbook pro
folderPath = '../../Dataset/EvaluationFramework_ISMIR2014/DATASET/';

fileNames = readtable([folderPath,'fileNames.csv']);
accuracyHMMNote  = cell(size(fileNames,1),1);
editDHMMNoteModel = cell(size(fileNames,1),1);
fwHMMNote = cell(size(fileNames,1),1);

numTuning = zeros(size(fileNames,1),1); %indicates which tuning track is the best

%------note model self transition range-----
startSelfR = (0.1:0.1:0.9);
sustainSelfR = (0.1:0.1:0.9);
endSelfR = (0.1:0.1:0.9);
%-------------------------------------------

noteRefineThresh = 0.15;
metricMolina = zeros(size(fileNames,1),32,length(startSelfR),length(sustainSelfR),length(endSelfR));
% for istartR = 1:length(startSelfR)
for istartR = 1;
%     for isustainR = 1:length(sustainSelfR)
    for isustainR = 9
%         for iendR = 1:length(endSelfR)
        for iendR = 4
            for numFile = 1:size(fileNames,1)
                disp(['start:',num2str(startSelfR(istartR)),', sustain:',num2str(sustainSelfR(isustainR)),' end:',num2str(endSelfR(iendR))]);
%             for numFile = 4
            clearvars -except istartR isustainR iendR startSelfR sustainSelfR endSelfR numFile folderPath fileNames  editDHMMNoteModel...
                 fwHMMNote accuracyHMMNote metricMolina noteRefineThresh
                fileName = char(fileNames{numFile,1});
                disp([num2str(numFile),':',fileName]);

                data = csvread([folderPath,'f0_pyin/',fileName,'_f0_pyin.csv']); 
                time = data(:,1);
                pitchRaw = data(:,2);
                %let the pyin outputs engative frequencies as unvoiced, then make
                %the unvoiced as 0;
                pitchRaw(pitchRaw <= 0) = 0;


                pitchFs = 1/(time(2)-time(1));

                %-------------------------------------------------
                %get the power curve with the same sampling rate with the f0
                widowLengthf0 = 1024;
                stepf0 = round(44100/pitchFs); 
            %     [powerCurve, ZCRCurve, timePowerCurve] = GetPowerZCR([folderPath,fileName,'.wav'],widowLengthf0,stepf0);
            %     %do interpolation if the size of power curve is not same as the f0
            %     powerCurve = spline(timePowerCurve,powerCurve,time);
            %     ZCRCurve = spline(timePowerCurve,ZCRCurve,time);
                %-------------------------------------------------


                %-------START pitch pre-processing------------

                %get pitch deviation
                pitchDeviation = GetPitchDeviation(pitchRaw);
                pitchDevGround = pitchDeviation(1); %in semitone
                pitchDevCeil = pitchDeviation(2);   %in semitone

                midiPitchOriginal = freqToMidi(pitchRaw);
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
                stateRangeTransStructure = [0:384]'; %3*128+1, every midi note has 3 states: steady, transition-up, transiton-down

                %-------Power curve HMM-------
                %two states: voiced and unvoiced
            %     initialStateDistributionPowerCurve = [0.5,0.5];
            %     transPowerCurve = [0.7,0.3;...
            %                        0.3,0.7];
            % 
            %     [observationMatrixPower,observationMatrixPowerTemp] = GetObservsMatrixPower(powerCurve,stateRangeTransStructure);
            %     decodedPower =  ViterbiAlgHMM(transPowerCurve,observationMatrixPowerTemp,initialStateDistributionPowerCurve);
            % 
            %     decodedPower = 1./decodedPower;
            %     decodedPower(decodedPower == 0.5) = 0;
                %-------------------------------------------------------
                %%

                %-----START of the MM note level model------
                stateRangeMIDINote = [35:80]; %MIDI num [35:80]
                numStateRangeMIDI = length(stateRangeMIDINote);
                numStatesNoteModel = 3*length(stateRangeMIDINote); %every midi note has three states: start-sustain-end
                %-----initial distribution---------------------
                %only can go to attack states.
                initalDistributionNoteModel = 1/numStateRangeMIDI*ones(3,1);
                initalDistributionNoteModel(2:end) = 0;
                initalDistributionNoteModel = repmat(initalDistributionNoteModel,numStateRangeMIDI,1);

                %--------transition matrix----------------
        %         noteModelSelfTranPro = [0.3,0.8,0.2];   %the vector store note model self-transition probabilities. [startSelf,sustainSelf,endSelf]
                noteModelSelfTranPro = [startSelfR(istartR),sustainSelfR(isustainR),endSelfR(iendR)];
                noteTranSigma = 4; %the sigma (STD) for the note transition normal distribution
                transNoteModel = GetTransMatrixNoteModel(stateRangeMIDINote,noteModelSelfTranPro,noteTranSigma);

                %------observation matrix---------
                observationNoteModelOriginal = GetObservsMatrixNoteModel(midiPitchOriginal,deltaMidiPitch,stateRangeMIDINote,numStatesNoteModel);
                observationNoteModelGround = GetObservsMatrixNoteModel(midiPitchGround,deltaMidiPitch,stateRangeMIDINote,numStatesNoteModel);
                observationNoteModelCeil = GetObservsMatrixNoteModel(midiPitchCeil,deltaMidiPitch,stateRangeMIDINote,numStatesNoteModel);

                decodedHMMNote = zeros(length(midiPitchOriginal),3); 
                decodedHMMNote(:,1) = ViterbiAlgHMM(transNoteModel',observationNoteModelOriginal,initalDistributionNoteModel);
                decodedHMMNote(:,2) = ViterbiAlgHMM(transNoteModel',observationNoteModelGround,initalDistributionNoteModel);
                decodedHMMNote(:,3) = ViterbiAlgHMM(transNoteModel',observationNoteModelCeil,initalDistributionNoteModel);
                %make the resulte in MIDI scale
                decodedHMMNote = floor((decodedHMMNote)/3)+stateRangeMIDINote(1); 

                %-----END of the HMM note level model--------


                %%

                %get the voiced part directly from the pitch (assume non-zero values are voiced)
                voicedPitch = zeros(size(decodedHMMNote));
                voicedPitch(midiPitchOriginal > 0,1) = 1;
                voicedPitch(midiPitchGround > 0,2) = 1;
                voicedPitch(midiPitchCeil > 0,3) = 1;
                decodedHMMNote = decodedHMMNote.*voicedPitch;

            %     decodedHMMNote = decodedHMMNote.*repmat(decodedPower',1,3);

                %1. framewise accuracy
%                 accuracyHMMNote{numFile,1} = AccuracyEva(decodedHMMNote,stateGroundTruth);


                %------Note aggregation-----------------
                notesHMMNoteModel = NoteAggreBaseline(decodedHMMNote,pitchFs);
                %---------------------------------------


                %------Small duration pruning---------
        %         durationThresh = 0.1; %in seconds
            %     notesHMMNoteModel = NotePruning(notesHMMNoteModel, durationThresh);
                %-------------------------------------

                %transform my format into Molina2014 format [start(s):end(s):MIDI NN]
                notesHMMNoteModelNew = cell(size(notesHMMNoteModel));
                for i = 1:length(notesHMMNoteModel)
                    notesHMMNoteModelNew{1,i} = [notesHMMNoteModel{1,i}(:,1),notesHMMNoteModel{1,i}(:,1)+notesHMMNoteModel{1,i}(:,3),notesHMMNoteModel{1,i}(:,2)];   
                end

                %------spectral flux onset correction-----
                for i = 1:length(notesHMMNoteModelNew)
                    notesHMMNoteModelNew{1,i} = onsetCorrectFlux(notesHMMNoteModelNew{1,i},[folderPath,fileName,'.wav'],widowLengthf0,stepf0);
                end
                %-----------------------------------------   

                %------note refinement--------------
                for i = 1:length(notesHMMNoteModelNew)
                    notesHMMNoteModelNew{1,i} = noteRefinement(notesHMMNoteModelNew{1,i},noteRefineThresh);
                    csvwrite(['data/',fileName,'.notesHMMNoteModel',num2str(i),'.csv'],notesHMMNoteModelNew{1,i});
                end    

                %-----------------------------------

                %get Molina2014 metrics
                for i = 1:length(notesHMMNoteModel)
                    evaMolinaMetric(i,:) = evaluation(cellstr([folderPath,fileName,'.GroundTruth.txt']),cellstr(['data/',fileName,'.notesHMMNoteModel',num2str(i),'.csv']));
                end

                [~,numTuning(numFile)] = max(evaMolinaMetric(:,8));
                metricMolina(numFile,:,istartR,isustainR,iendR) = evaMolinaMetric(numTuning(numFile),:);
                folderNameNewEva = ['../../Dataset/EvaluationFramework_ISMIR2014/transcription/NoteModel_3/'];
%                 mkdir(folderNameNewEva);
%                 csvwrite([folderNameNewEva,fileName,'.notesHMMNoteModel.csv'],notesHMMNoteModelNew{1,numTuning(numFile)});
            end
            %save the variable for every loop
%             save(['metricMolina_3.mat'],'metricMolina');
        end
    end
end


% run('evaMolinaMetrics.m');

% fontSize = 20;
% figure(1)
% subplot(3,1,1)
% plot(time,midiPitchOriginal,'.');
% hold on
% plot(time,decodedHMMNote(:,1),'r');
% for i = 1:size(annotation,1)
%     plot([annotation(i,1),annotation(i,1)+annotation(i,3)],[annotation(i,2),annotation(i,2)],'g','LineWidth',2);
% end
% for i = 1:size(notesHMMNoteModelNew{1,1},1)
%     plot([notesHMMNoteModelNew{1,1}(i,1),notesHMMNoteModelNew{1,1}(i,2)],[notesHMMNoteModelNew{1,1}(i,3),notesHMMNoteModelNew{1,1}(i,3)],'r','LineWidth',2);
% end
% hold off
% xlabel('Time(s)','FontSize',fontSize);
% ylabel('Midi Note Number','FontSize',fontSize);
% title('F0, HMM Note Model','FontSize',fontSize);
% legend('f0','Raw','Ground Truth');
% set(gca, 'FontSize', fontSize);
% 
% subplot(3,1,2)
% plot(time,midiPitchGround,'.');
% hold on
% plot(time,decodedHMMNote(:,2),'r');
% for i = 1:size(annotation,1)
%     plot([annotation(i,1),annotation(i,1)+annotation(i,3)],[annotation(i,2),annotation(i,2)],'g','LineWidth',2);
% end
% for i = 1:size(notesHMMNoteModelNew{1,2},1)
%     plot([notesHMMNoteModelNew{1,2}(i,1),notesHMMNoteModelNew{1,2}(i,2)],[notesHMMNoteModelNew{1,2}(i,3),notesHMMNoteModelNew{1,2}(i,3)],'r','LineWidth',2);
% end
% hold off
% xlabel('Time(s)','FontSize',fontSize);
% ylabel('Midi Note Number','FontSize',fontSize);
% title('F0 with Ground Pitch Deviation Fixing, HMM Note Model','FontSize',fontSize);
% legend('f0','Raw','Ground Truth');
% set(gca, 'FontSize', fontSize);
% 
% subplot(3,1,3)
% plot(time,midiPitchCeil,'.');
% hold on
% plot(time,decodedHMMNote(:,3),'r');
% for i = 1:size(annotation,1)
%     plot([annotation(i,1),annotation(i,1)+annotation(i,3)],[annotation(i,2),annotation(i,2)],'g','LineWidth',2);
% end
% for i = 1:size(notesHMMNoteModelNew{1,3},1)
%     plot([notesHMMNoteModelNew{1,3}(i,1),notesHMMNoteModelNew{1,3}(i,2)],[notesHMMNoteModelNew{1,3}(i,3),notesHMMNoteModelNew{1,3}(i,3)],'r','LineWidth',2);
% end
% hold off
% xlabel('Time(s)','FontSize',fontSize);
% ylabel('Midi Note Number','FontSize',fontSize);
% title('F0 with Ceil Pitch Deviation Fixing, HMM Note Model','FontSize',fontSize);
% legend('f0','Raw','Ground Truth');
% set(gca, 'FontSize', fontSize);