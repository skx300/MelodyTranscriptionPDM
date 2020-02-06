%test the energy, spectral flux for spliting the note that the consecutive
%notes having same pitch
% clf;
clear;

folderPath = '../../Dataset/EvaluationFramework_ISMIR2014/DATASET/';
fileNames = readtable([folderPath,'fileNames.csv']);
fileName = char(fileNames{5,1});

data = csvread([folderPath,'f0_pyin/',fileName,'_f0_pyin.csv']); 
timePitch = data(:,1);
pitchRaw = data(:,2);

[audioData,Fs] = audioread([folderPath,fileName,'.wav']);
timeAudio = (1:length(audioData))./Fs;

annotation = GT_Molina2OUR([folderPath,fileName,'.GroundTruth.txt']);

resultHMMNoteModel = csvread(['data/forMolinaMetric/',fileName,'.notesHMMNoteModel.csv']);

windowLength = 1024;
step = windowLength/2;
[ powerCurve, ZCRCurve, time ] = GetPowerZCR([folderPath,fileName,'.wav'], windowLength, step);

%-----tony post-processing-------
%--amplitude-based onset segmentation---
ampRise = zeros(size(powerCurve));
for i = 2:length(powerCurve)-1
    ampRise(i) = powerCurve(i+1)/powerCurve(i-1);
end
s = 1./ampRise;
%---------------------------------

%----spectral flux for onset detection---------
[spec,fSpec,tSpec] = spectrogram(audioData,windowLength,step,windowLength,Fs);
tSpec = tSpec - tSpec(1);   %make the time start from zero
tSpec = tSpec';
spec = abs(spec);

specDiff = zeros(size(spec));
specDiff(:,2:end) = diff(spec,1,2); 
specDiffHWRP = (specDiff + abs(specDiff))/2; %half-wave rectifier function
specDiffHWRN = (-specDiff + abs(specDiff))/2; %half-wave rectifier function
specFluxP = sum(specDiffHWRP);
specFluxN = sum(specDiffHWRN);

specFluxP = smooth(specFluxP);
%normalize to zero mean and one unit standard deviation
specFluxP = specFluxP-mean(specFluxP);
specFluxP = specFluxP./std(specFluxP);

%peak-picking from Simon2006
w = 3; %window size
step = 1;
m = 3;  %multiplier
peakIndex = [];
%threshold
th1 = 1;
alpha = 0.9;

g = zeros(size(specFluxP));
for i = 2:length(specFluxP)
    g(i) = max([specFluxP(i),alpha*g(i-1)+(1-alpha)*specFluxP(i)]);
end

for i = 1+w*m:step:length(specFluxP)-w
   frame = specFluxP(i-w:i+w);
   if specFluxP(i) >= max(frame) &&...
      specFluxP(i) >= mean(specFluxP(i-m*w:i+w))+th1 &&...
      specFluxP(i) >= g(i-1)
       peakIndex(end+1) = i;
   end
end
onsetTime = tSpec(peakIndex);
%---------------------------------------

%----------------------------
%find onsets that within any transcribed note
threshold = 0.1;    %threshold let the interval of this value to the boundary not considered
% notesTotal = cell(1,numCol);
selectedPeaks = [];
for i = 1:size(resultHMMNoteModel,1)
    startTime = resultHMMNoteModel(i,1)+threshold;
    endTime = resultHMMNoteModel(i,2)-threshold;
    temp = onsetTime(onsetTime > startTime & onsetTime < endTime);
    if isempty(temp) == 0
        selectedPeaks = [selectedPeaks;[temp,zeros(length(temp),1)]];
        selectedPeaks(end-length(temp)+1:end,2) = i; %the corresponding num of note
    end
end

%get the added notes information
if isempty(selectedPeaks) == 0
    addedNotes = zeros(size(selectedPeaks,1),3);
    uniqueCorrspNotes = unique(selectedPeaks(:,2));
    for i = 1:length(uniqueCorrspNotes)
        numInserted = sum((selectedPeaks(:,2) == uniqueCorrspNotes(i)));
        addedNotes((selectedPeaks(:,2) == uniqueCorrspNotes(i)),1) = selectedPeaks((selectedPeaks(:,2) == uniqueCorrspNotes(i)),1);

        numNowNote = sum(addedNotes(:,1) ~= 0);
        %in case if there are more than three notes for one original note
        for t = numNowNote:-1:numNowNote-numInserted+1
            %start from the last transcribed note
            if t == numNowNote
                addedNotes(t,2) = resultHMMNoteModel(uniqueCorrspNotes(i),2);
            else
                addedNotes(t,2) = addedNotes(t+1,1);
            end
            addedNotes(t,3) = resultHMMNoteModel(uniqueCorrspNotes(i),3); %the pitch is the same as the original note
        end
        resultHMMNoteModel(uniqueCorrspNotes(i),2) = addedNotes(numNowNote-numInserted+1,1);
    end

    %add the added notes into the original notes and sort them by time
    totalNotes = [resultHMMNoteModel;addedNotes];
    [~,order] = sort(totalNotes(:,1));
    resultHMMNoteModelNew = totalNotes(order,:);
else
    resultHMMNoteModelNew = resultHMMNoteModel;
end
%-----------------------------------------------------

%----------START of note refinement--------------------------
% duration = resultHMMNoteModelNew(:,2)-resultHMMNoteModelNew(:,1);
% shortNoteIndex = find(duration <= 0.2);
% %the index indicates to which note of the short note should belong
% shortNoteBelongIndex = zeros(size(shortNoteIndex));
% for i = 1:length(shortNoteIndex)
% % for i = 26
%     
%     currentNote = resultHMMNoteModelNew(shortNoteIndex(i),:);
%     
%     weightPre = 0;
%     weightSub = 0;
%     if (shortNoteIndex(i) ~= 1) && (shortNoteIndex(i) ~= length(duration))
%         %calcuate the weights to previous note
%         preIntervalPitch = abs(resultHMMNoteModelNew(shortNoteIndex(i),3)-resultHMMNoteModelNew(shortNoteIndex(i)-1,3));
%         preIntervalTime = abs(resultHMMNoteModelNew(shortNoteIndex(i),1)-resultHMMNoteModelNew(shortNoteIndex(i)-1,2));
%         preDuration = duration(shortNoteIndex(i)-1);
% 
%         %calculate the weights to subsequent note
%         subIntervalPitch = abs(resultHMMNoteModelNew(shortNoteIndex(i),3)-resultHMMNoteModelNew(shortNoteIndex(i)+1,3));
%         subIntervalTime = abs(resultHMMNoteModelNew(shortNoteIndex(i),2)-resultHMMNoteModelNew(shortNoteIndex(i)+1,1));
%         subDuration = duration(shortNoteIndex(i)+1);
%         
%         %calculate the weight
%         weightPre = normpdf(preIntervalPitch,0,1)+normpdf(preIntervalTime,0,1)+preDuration;
%         weightSub = normpdf(subIntervalPitch,0,1)+normpdf(subIntervalTime,0,1)+subDuration;
%     end
%     
%   
%     if (shortNoteIndex(i) == length(duration)) || weightPre > weightSub 
%         %directly let the last short note belong to the second last note
%         shortNoteBelongIndex(i) = shortNoteIndex(i)-1;
%     elseif(shortNoteIndex(i) == 1) || weightPre < weightSub   
%         %directly let the first short note belong to the second note
%         shortNoteBelongIndex(i) = shortNoteIndex(i)+1;
%     end
% end
% 
% % add the short notes'duration to the note it belongs to
% for i =1:length(shortNoteIndex)
%     currentNote = resultHMMNoteModelNew(shortNoteIndex(i),:);
%     
%     if shortNoteBelongIndex(i) < shortNoteIndex(i) && shortNoteBelongIndex(i) ~= 0
%         %if the note is before the short note, add short note duration to
%         %the note end time
%         resultHMMNoteModelNew(shortNoteBelongIndex(i),2) = resultHMMNoteModelNew(shortNoteBelongIndex(i),2) + duration(shortNoteIndex(i));
%     elseif shortNoteBelongIndex(i) > shortNoteIndex(i)&& shortNoteBelongIndex(i) ~= 0
%         %if the note is behind the short note, subtract short note duration
%         %from the note start time
%         resultHMMNoteModelNew(shortNoteBelongIndex(i),1) = resultHMMNoteModelNew(shortNoteBelongIndex(i),1) - duration(shortNoteIndex(i));
%     end
% end
% 
% resultHMMNoteModelNew(shortNoteIndex,:) = [];
%----------END of note refinement--------------------------

%---------START of note refinement from the shortest note--------
duration = resultHMMNoteModelNew(:,2)-resultHMMNoteModelNew(:,1);
[durationMin,durationMinIndex] = min(duration);

while (durationMin < 0.15)
    if (durationMinIndex ~= 1) && (durationMinIndex ~= length(duration))
        %calcuate the weights to previous note
        preIntervalPitch = abs(resultHMMNoteModelNew(durationMinIndex,3)-resultHMMNoteModelNew(durationMinIndex-1,3));
        preIntervalTime = abs(resultHMMNoteModelNew(durationMinIndex,1)-resultHMMNoteModelNew(durationMinIndex-1,2));
        preDuration = duration(durationMinIndex-1);

        %calculate the weights to subsequent note
        subIntervalPitch = abs(resultHMMNoteModelNew(durationMinIndex,3)-resultHMMNoteModelNew(durationMinIndex+1,3));
        subIntervalTime = abs(resultHMMNoteModelNew(durationMinIndex,2)-resultHMMNoteModelNew(durationMinIndex+1,1));
        subDuration = duration(durationMinIndex+1);

        %calculate the weight
        weightPre = normpdf(preIntervalPitch,0,1)+normpdf(preIntervalTime,0,1);
        weightSub = normpdf(subIntervalPitch,0,1)+normpdf(subIntervalTime,0,1);
    end

    if (durationMinIndex == length(duration)) || weightPre > weightSub 
        %if the short note is designated to previous note, add the short note
        %duration to the previous ending time.
        resultHMMNoteModelNew(durationMinIndex-1,2) = resultHMMNoteModelNew(durationMinIndex-1,2) + durationMin;
    elseif(durationMinIndex == 1) || weightPre < weightSub   
        %if the short note is designated to subsequent note, subtract the short
        %note duration from the subsequent starting time.
        resultHMMNoteModelNew(durationMinIndex+1,1) = resultHMMNoteModelNew(durationMinIndex+1,1) - durationMin;
    end

    %delete the short note
    resultHMMNoteModelNew(durationMinIndex,:) = [];

    duration = resultHMMNoteModelNew(:,2)-resultHMMNoteModelNew(:,1);
    [durationMin,durationMinIndex] = min(duration);

end
%---------END of note refinement from the shortest note--------

csvwrite(['data/',fileName,'.notesHMMNoteModelNew.csv'],resultHMMNoteModelNew);
evaluation(cellstr([folderPath,fileName,'.GroundTruth.txt']),cellstr(['data/',fileName,'.notesHMMNoteModelNew.csv']));

fontSize = 20;
lineWidth = 2;
figure(1)
subplot(3,1,1);
plot(timeAudio,audioData);
title([fileName,' Waveform']);
xlim([timeAudio(1),timeAudio(end)]);
xlabel('Time(s)');
ylabel('Amplitude');

subplot(3,1,2);
plot(time,powerCurve);
title([fileName,' Power Curve']);
xlim([time(1),time(end)]);
xlabel('Time(s)');
ylabel('Power');


subplot(3,1,3)
plot(time,ZCRCurve);
title([fileName,' ZCR']);
xlim([time(1),time(end)]);
xlabel('Time(s)');
ylabel('ZCR');

figure(2)
subplot(3,1,1);
plot(timeAudio,audioData);
title([fileName,' Waveform']);
xlim([timeAudio(1),timeAudio(end)]);
xlabel('Time(s)');
ylabel('Amplitude');

subplot(3,1,2);
plot(time,s);
title([fileName,' sensitivity(Tony)']);
xlim([time(1),time(end)]);
xlabel('Time(s)');
ylabel('Power');

figure(3)
subplot(3,1,1);
surf(tSpec,fSpec,20*log10(spec),'EdgeColor','none','LineStyle','none');    %,'FaceColor','interp'
axis xy; axis tight; colormap(jet); view(0,90);
% title([fileName,' Spectrogram']);
title('Spectrogram');
ylabel('Frequency(Hz)');
xlabel('Time(s)');
xlim([time(1),time(round(11*86.1328))]);
ylim([0 10000]);
set(gca, 'FontSize', fontSize);

subplot(3,1,2);
plot(timePitch,pitchRaw,'LineWidth',lineWidth);    %,'FaceColor','interp'
hold on
faceColor = [.5,.5,.5];
faceAlpha = 0.2;
for i = [2 3 5 6 9 10 13 14]
    fill([resultHMMNoteModelNew(i,1),resultHMMNoteModelNew(i,2),resultHMMNoteModelNew(i,2),resultHMMNoteModelNew(i,1)],...
            [-10,-10,1000,1000],faceColor,'EdgeColor','none','FaceAlpha',faceAlpha);
end
for i = [3 5 7 9]
    plot([onsetTime(i),onsetTime(i)],[-100,1000],'k--','LineWidth',lineWidth);
end
hold off
axis xy; axis tight; colormap(jet); view(0,90);
% title([fileName,' Pitch Curve']);
title('Pitch Curve');
ylabel('Frequency(Hz)');
xlabel('Time(s)');
xlim([time(1),time(round(11*86.1328))]);
ylim([190 410]);
set(gca, 'FontSize', fontSize);

subplot(3,1,3)
plot(tSpec,specFluxP,'LineWidth',lineWidth);
hold on
% plot(tSpec,specFluxN,'r');
% for i = 1:size(annotation,1)
%     plot([annotation(i,1),annotation(i,1)+annotation(i,3)],[annotation(i,2)-55,annotation(i,2)-55],'g','LineWidth',2);
% end
% for i = 1:size(resultHMMNoteModelNew,1)
%     plot([resultHMMNoteModelNew(i,1),resultHMMNoteModelNew(i,2)],[resultHMMNoteModelNew(i,3)-55,resultHMMNoteModelNew(i,3)-55],'k','LineWidth',2);
% end
for i = 1:length(peakIndex)
   plot(onsetTime(i),specFluxP(peakIndex(i)),'rx','markers',12,'LineWidth',lineWidth); 
end
for i = [3 5 7 9]
    plot([onsetTime(i),onsetTime(i)],[-100,1000],'k--','LineWidth',lineWidth);
end
% for i = 1:length(selectedPeaks)
%    plot(selectedPeaks(i),0,'ko'); 
% end
faceColor = [.5,.5,.5];
faceAlpha = 0.2;
for i = [2 3 5 6 9 10 13 14]
    fill([resultHMMNoteModelNew(i,1),resultHMMNoteModelNew(i,2),resultHMMNoteModelNew(i,2),resultHMMNoteModelNew(i,1)],...
            [-10,-10,100,100],faceColor,'EdgeColor','none','FaceAlpha',faceAlpha);
end
hold off
% title([fileName,' Spectral Flux']);
title('Spectral Flux');
xlim([time(1),time(round(11*86.1328))]);
ylim([-2 8]);
xlabel('Time(s)');
ylabel('Spectral Flux');
set(gca, 'FontSize', fontSize);
legend('Spectral Flux','Selected Peaks');

figure(4)
subplot(2,1,1);
surf(tSpec,fSpec,20*log10(spec),'EdgeColor','none','LineStyle','none');    %,'FaceColor','interp'
axis xy; axis tight; colormap(jet); view(0,90);
% title([fileName,' Spectrogram']);
title('Spectrogram');
ylabel('Frequency(Hz)');
xlabel('Time(s)');
xlim([time(1),time(round(11*86.1328))]);
ylim([0 10000]);
set(gca, 'FontSize', fontSize);

subplot(2,1,2)
plot(tSpec,specFluxP,'LineWidth',lineWidth);
hold on
for i = 1:size(annotation,1)
    plot([annotation(i,1),annotation(i,1)+annotation(i,3)],[annotation(i,2)-55,annotation(i,2)-55],'g','LineWidth',2);
end
for i = 1:size(resultHMMNoteModelNew,1)
    plot([resultHMMNoteModelNew(i,1),resultHMMNoteModelNew(i,2)],[resultHMMNoteModelNew(i,3)-55,resultHMMNoteModelNew(i,3)-55],'k','LineWidth',2);
end
for i = 1:length(peakIndex)
   plot(onsetTime(i),specFluxP(peakIndex(i)),'rx','markers',12,'LineWidth',lineWidth); 
end
for i = [3 5 7 9]
    plot([onsetTime(i),onsetTime(i)],[-100,1000],'k--','LineWidth',lineWidth);
end
% for i = 1:length(selectedPeaks)
%    plot(selectedPeaks(i),0,'ko'); 
% end
faceColor = [.5,.5,.5];
faceAlpha = 0.2;
for i = [2 3 5 6 9 10 13 14]
    fill([resultHMMNoteModelNew(i,1),resultHMMNoteModelNew(i,2),resultHMMNoteModelNew(i,2),resultHMMNoteModelNew(i,1)],...
            [-10,-10,100,100],faceColor,'EdgeColor','none','FaceAlpha',faceAlpha);
end
hold off
% title([fileName,' Spectral Flux']);
title('Spectral Flux');
xlim([time(1),time(round(11*86.1328))]);
ylim([-2 8]);
xlabel('Time(s)');
ylabel('Spectral Flux');
set(gca, 'FontSize', fontSize);
legend('Spectral Flux','Selected Peaks');
