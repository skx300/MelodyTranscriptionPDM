clf;
clear;

%using my data
data = csvread('../../Dataset/Huangjiangqin/Huangjiangqin-1.csv');
time = data(:,1);
pitch = data(:,2);

% load('Huangjiangqin-2-VibratoFree.mat');
% pitch = midiSpitchNoVibrato;

pitch = smooth(pitch,10);
%--------------------------
% using YAMAHA data
% data = csvread('../SingingVoiceCorpus_toLuwei/reference/clk_vt_ky013.pitch');
% pitch = data(:,3); 
% audioFs = 44100;
% pitchWindow = 441;
% time = (data(:,1)+pitchWindow/2)/audioFs;
% pitch = smooth(pitch,10);
%--------------------------

annotation = csvread('../../Dataset/Huangjiangqin/Huangjiangqin-1-Note-Annotation-new.csv');
% annotation = csvread('../SingingVoiceCorpus_toLuwei/GroundTruth/reference/clk_vt_ky013.lab');
stateGroundTruth = zeros(size(pitch))';
for i = 1:size(annotation,1)
    startPoint = annotation(i,1);
    endPoint = startPoint+annotation(i,3);
    stateGroundTruth(time>=startPoint & time <= endPoint) = annotation(i,2);
end

%get pitch deviation
pitchDeviation = GetPitchDeviation(pitch);
pitchDevGround = pitchDeviation(1);
pitchDevCeil = pitchDeviation(2);

midiPitchOriginal = freqToMidi(pitch);
midiPitchGround = zeros(size(midiPitchOriginal));
midiPitchCeil = zeros(size(midiPitchOriginal));
midiPitchGround(midiPitchOriginal > 0) = midiPitchOriginal(midiPitchOriginal > 0)-pitchDevGround;
midiPitchCeil(midiPitchOriginal > 0) = midiPitchOriginal(midiPitchOriginal > 0)+pitchDevCeil;

pitchRangeTrans = [0:128]; %[0,1,2,...128], 0 means silent,

initialStateDistribution = 1/length(pitchRangeTrans)*ones(1,length(pitchRangeTrans));
transPitch = GetTransMatrix(pitchRangeTrans,[]);
observsPitchOriginal = GetObservsMatrixBaseline(midiPitchOriginal,pitchRangeTrans);
observsPitchGround = GetObservsMatrixBaseline(midiPitchGround,pitchRangeTrans);
observsPitchCeil = GetObservsMatrixBaseline(midiPitchCeil,pitchRangeTrans);

%%
midiTranscriptionOriginal = ViterbiAlgHMM(transPitch,observsPitchOriginal,initialStateDistribution);
midiTranscriptionGround = ViterbiAlgHMM(transPitch,observsPitchGround,initialStateDistribution);
midiTranscriptionCeil = ViterbiAlgHMM(transPitch,observsPitchCeil,initialStateDistribution);
midiTranscriptionOriginal = midiTranscriptionOriginal -1;
midiTranscriptionGround = midiTranscriptionGround -1;
midiTranscriptionCeil = midiTranscriptionCeil -1;

%----evaluation-------------------
%1. framewise accuracy
accuracyOriginal = AccuracyEva(midiTranscriptionOriginal,stateGroundTruth);
accuracyGroundCorrected = AccuracyEva(midiTranscriptionGround,stateGroundTruth);
accuracyCeilCorrected = AccuracyEva(midiTranscriptionCeil,stateGroundTruth);

%2. edit distance
editDOriginal= EditDistance_2(midiTranscriptionOriginal,stateGroundTruth);
editDGroundCorrected = EditDistance_2(midiTranscriptionGround,stateGroundTruth);
editDCeilCorrected = EditDistance_2(midiTranscriptionCeil,stateGroundTruth);

editDOriginal = editDOriginal/length(stateGroundTruth);
editDGroundCorrected = editDGroundCorrected/length(stateGroundTruth);
editDCeilCorrected = editDCeilCorrected/length(stateGroundTruth);
%----------------------------------

%---------------------plots------------------------
fontSize = 20;
figure(1)
subplot(3,1,1)
plot(time,midiPitchOriginal,'.');
hold on
plot(time,midiTranscriptionOriginal,'r');
for i = 1:size(annotation,1)
    plot([annotation(i,1),annotation(i,1)+annotation(i,3)],[annotation(i,2),annotation(i,2)],'g','LineWidth',2);
end
hold off
xlabel('Time(s)','FontSize',fontSize);
ylabel('Midi Note Number','FontSize',fontSize);
title('Original F0','FontSize',fontSize);
legend('f0','HMM Decoded','Ground Truth');
set(gca, 'FontSize', fontSize);
% ylim([60 75]);
% xlim([10 18]);

subplot(3,1,2)
plot(time,midiPitchGround,'.');
hold on
plot(time,midiTranscriptionGround,'r');
for i = 1:size(annotation,1)
    plot([annotation(i,1),annotation(i,1)+annotation(i,3)],[annotation(i,2),annotation(i,2)],'g','LineWidth',2);
end
hold off
xlabel('Time(s)','FontSize',fontSize);
ylabel('Midi Note Number','FontSize',fontSize);
title('F0 with Ground Pitch Deviation Fixing','FontSize',fontSize);
legend('f0','HMM Decoded','Ground Truth');
set(gca, 'FontSize', fontSize);
% ylim([60 75]);
% xlim([10 18]);

subplot(3,1,3)
plot(time,midiPitchCeil,'.');
hold on
plot(time,midiTranscriptionCeil,'r');
% plot(time,midiTranscriptionCeilCorrectedEsti,'k');
for i = 1:size(annotation,1)
    plot([annotation(i,1),annotation(i,1)+annotation(i,3)],[annotation(i,2),annotation(i,2)],'g','LineWidth',2);
end
hold off
xlabel('Time(s)','FontSize',fontSize);
ylabel('Midi Note Number','FontSize',fontSize);
title('F0 with Ceil Pitch Deviation Fixing','FontSize',fontSize);
legend('f0','HMM Decoded','Ground Truth');
set(gca, 'FontSize', fontSize);
% ylim([60 75]);
% xlim([10 18]);

figure(2)
plot(time,midiPitchCeil,'.');
hold on
plot(time,midiTranscriptionCeil,'r');
% plot(time,midiTranscriptionCeilCorrectedEsti,'k');
for i = 1:size(annotation,1)
    plot([annotation(i,1),annotation(i,1)+annotation(i,3)],[annotation(i,2),annotation(i,2)],'g','LineWidth',2);
end
hold off
xlabel('Time(s)','FontSize',fontSize);
ylabel('Midi Note Number','FontSize',fontSize);
title('Pitch curve based transcription','FontSize',fontSize);
legend('f0','HMM Decoded','Ground Truth');
set(gca, 'FontSize', fontSize);
xlim([0 15]);
ylim([50 80]);