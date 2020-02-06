function [ transcribedDataCorrected ] = onsetCorrectFlux( transcribedData,audioName,windowLength,step )
%ONSETCORRECFLUX using the spectral flux onset function to detect onset
%within note, and split the two notes having same pitch.
%   Input
%   @transcribedData: the transcribed note data. [start time:end time:MIDI]
%   @audioName: the audio file name.
%   @windowLength: the window length for calculate spectrogram
%   @step: the step for spectrogram
%   Output:
%   @transcribedDataCorrected: the corrected transcribed data. [start time:end time:MIDI]
    
    [audioData,Fs] = audioread(audioName);
%     [audioData,Fs] = wavread(audioName);
    nfft = windowLength;
    
    %----spectral flux for onset detection---------
    [spec,~,tSpec] = spectrogram(audioData,windowLength,step,nfft,Fs);
    tSpec = tSpec - tSpec(1);   %make the time start from zero
    tSpec = tSpec';
    spec = abs(spec);

    specDiff = zeros(size(spec));
    specDiff(:,2:end) = diff(spec,1,2); 
    specDiffHWRP = (specDiff + abs(specDiff))/2; %half-wave rectifier function
    specFluxP = sum(specDiffHWRP);
    
    %smooth the spectral flux data
    specFluxP = smooth(specFluxP);
    
    %normalize to zero mean and one unit standard deviation
    specFluxP = specFluxP-mean(specFluxP);
    specFluxP = specFluxP./std(specFluxP);

    %-----peak-picking from Simon2006----
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

    %find onsets that within any transcribed note
    threshold = 0.1;    %in second, threshold let the interval of this value to the boundary not considered
    selectedPeaks = [];
    for i = 1:size(transcribedData,1)
        startTime = transcribedData(i,1)+threshold;
        endTime = transcribedData(i,2)-threshold;
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
                    addedNotes(t,2) = transcribedData(uniqueCorrspNotes(i),2);
                else
                    addedNotes(t,2) = addedNotes(t+1,1);
                end
                addedNotes(t,3) = transcribedData(uniqueCorrspNotes(i),3); %the pitch is the same as the original note
            end
            transcribedData(uniqueCorrspNotes(i),2) = addedNotes(numNowNote-numInserted+1,1);
        end

        %add the added notes into the original notes and sort them by time
        totalNotes = [transcribedData;addedNotes];
        [~,order] = sort(totalNotes(:,1));
        transcribedDataCorrected = totalNotes(order,:);
    else
        transcribedDataCorrected = transcribedData;
    end
end

