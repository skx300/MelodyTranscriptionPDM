%test for note model HMM training
clear;
clf;

folderPath = '../../../Dataset/EvaluationFramework_ISMIR2014/';
fileNames = readtable([folderPath,'/dataset/fileNames.csv']);

%----Train probabilityies of note transition--------------
%Assume the initial prob from silent to each MIDI NN is uniform
%distribution
stateRangeMIDINote = (34:80)'; %MIDI num [35:80], 34: silent
%column stochastic (each column is summed to 1)
countNoteTran = zeros(length(stateRangeMIDINote),length(stateRangeMIDINote));
probNoteTran = zeros(size(countNoteTran));
% probNoteTran(:,1) = 1/length(probNoteTran(:,1));

for i = 1:size(fileNames,1)
   groundTruthFileName = [folderPath,'/dataset/',cell2mat(fileNames{i,1}),'.GroundTruth.txt']; 
   
   gtData = csvread(groundTruthFileName);
   %round the midi number
   midiSeq = round(gtData(:,3));
   
   for n = 1:length(midiSeq)
%     for n = 1:3
        currentNumInStateRange = midiSeq(n)-stateRangeMIDINote(1)+1;
       if n == 1
           %the first note
           countNoteTran(currentNumInStateRange,n) = countNoteTran(currentNumInStateRange,n) + 1;
       elseif n == length(midiSeq)
           %the last note
           countNoteTran(1,currentNumInStateRange) = countNoteTran(1,currentNumInStateRange) + 1;
           continue;
       end
        nextNumInStateRange = midiSeq(n+1)-stateRangeMIDINote(1)+1;
        countNoteTran(nextNumInStateRange,currentNumInStateRange) = countNoteTran(nextNumInStateRange,currentNumInStateRange) + 1;
   end
end

%make the probNoteTran column stochastic
for i = 1:size(countNoteTran,2)
    if sum(countNoteTran(:,i)) ~= 0
        probNoteTran(:,i) = countNoteTran(:,i)./sum(countNoteTran(:,i));
    end
end

figure(1)
surf(stateRangeMIDINote,stateRangeMIDINote,probNoteTran);
view(2);
title('PDF of trained note transition');
xlabel('From MIDI NN (MIDI NN 34 is silent)');
ylabel('To MIDI NN (MIDI NN 34 is silent)');
xlim([stateRangeMIDINote(1) stateRangeMIDINote(end)]);
ylim([stateRangeMIDINote(1) stateRangeMIDINote(end)]);
%-----------------------------------------------------------------




