%------------plots transcription for ------------------------
fontSize = 30;
figure(1)
plot(time,midiPitchOriginal,'.');
hold on
% plot(time,decodedBaseline,'r');
plot([annotation(1,1),annotation(1,1)+annotation(1,3)],[annotation(1,2),annotation(1,2)],'g','LineWidth',3);
plot([notesBaseline{1,1}(1,1),notesBaseline{1,1}(1,1)+notesBaseline{1,1}(1,3)],[notesBaseline{1,1}(1,2),notesBaseline{1,1}(1,2)],'r','LineWidth',3);
for i = 2:size(annotation,1)
    plot([annotation(i,1),annotation(i,1)+annotation(i,3)],[annotation(i,2),annotation(i,2)],'g','LineWidth',3);
end
for i = 2:size(notesBaseline{1,1},1)
    plot([notesBaseline{1,1}(i,1),notesBaseline{1,1}(i,1)+notesBaseline{1,1}(i,3)],[notesBaseline{1,1}(i,2),notesBaseline{1,1}(i,2)],'r','LineWidth',3);
end
hold off
xlabel('Time(s)','FontSize',fontSize);
ylabel('Midi Note Number','FontSize',fontSize);
title('Baseline','FontSize',fontSize);
legend('f0','Ground Truth','Transcription','Location','NorthWest');
set(gca, 'FontSize', fontSize);
xlim([25.5 29.5]);
ylim([50 63]);

figure(2)
subplot(3,1,1)
plot(time,midiPitchOriginal,'.');
hold on
plot(time,decodedHMMStru(:,1),'r');
for i = 1:size(annotation,1)
    plot([annotation(i,1),annotation(i,1)+annotation(i,3)],[annotation(i,2),annotation(i,2)],'g','LineWidth',2);
end
for i = 1:size(notesHMMStruSteady{1,1},1)
    plot([notesHMMStruSteady{1,1}(i,1),notesHMMStruSteady{1,1}(i,1)+notesHMMStruSteady{1,1}(i,3)],[notesHMMStruSteady{1,1}(i,2),notesHMMStruSteady{1,1}(i,2)],'r','LineWidth',2);
end
hold off
xlabel('Time(s)','FontSize',fontSize);
ylabel('Midi Note Number','FontSize',fontSize);
title('F0, HMM Structure','FontSize',fontSize);
legend('f0','Raw','Ground Truth');
set(gca, 'FontSize', fontSize);

subplot(3,1,2)
plot(time,midiPitchGround,'.');
hold on
plot(time,decodedHMMStru(:,2),'r');
for i = 1:size(annotation,1)
    plot([annotation(i,1),annotation(i,1)+annotation(i,3)],[annotation(i,2),annotation(i,2)],'g','LineWidth',2);
end
for i = 1:size(notesHMMStruSteady{1,2},1)
    plot([notesHMMStruSteady{1,2}(i,1),notesHMMStruSteady{1,2}(i,1)+notesHMMStruSteady{1,2}(i,3)],[notesHMMStruSteady{1,2}(i,2),notesHMMStruSteady{1,2}(i,2)],'r','LineWidth',2);
end
hold off
xlabel('Time(s)','FontSize',fontSize);
ylabel('Midi Note Number','FontSize',fontSize);
title('F0 with Ground Pitch Deviation Fixing, HMM Structure','FontSize',fontSize);
legend('f0','Raw','Ground Truth');
set(gca, 'FontSize', fontSize);

subplot(3,1,3)
plot(time,midiPitchCeil,'.');
hold on
plot(time,decodedHMMStru(:,3),'r');
for i = 1:size(annotation,1)
    plot([annotation(i,1),annotation(i,1)+annotation(i,3)],[annotation(i,2),annotation(i,2)],'g','LineWidth',2);
end
for i = 1:size(notesHMMStruSteady{1,3},1)
    plot([notesHMMStruSteady{1,3}(i,1),notesHMMStruSteady{1,3}(i,1)+notesHMMStruSteady{1,3}(i,3)],[notesHMMStruSteady{1,3}(i,2),notesHMMStruSteady{1,3}(i,2)],'r','LineWidth',2);
end
hold off
xlabel('Time(s)','FontSize',fontSize);
ylabel('Midi Note Number','FontSize',fontSize);
title('F0 with Ceil Pitch Deviation Fixing, HMM Structure','FontSize',fontSize);
legend('f0','Raw','Ground Truth');
set(gca, 'FontSize', fontSize);

figure(3)
subplot(3,1,1)
plot(time,midiPitchOriginal,'.');
hold on
% plot(time,decodedHMMNote(:,1),'r');
for i = 1:size(annotation,1)
    plot([annotation(i,1),annotation(i,1)+annotation(i,3)],[annotation(i,2),annotation(i,2)],'g','LineWidth',2);
end
for i = 1:size(notesHMMNoteModel{1,1},1)
    plot([notesHMMNoteModel{1,1}(i,1),notesHMMNoteModel{1,1}(i,1)+notesHMMNoteModel{1,1}(i,3)],[notesHMMNoteModel{1,1}(i,2),notesHMMNoteModel{1,1}(i,2)],'r','LineWidth',2);
end
hold off
xlabel('Time(s)','FontSize',fontSize);
ylabel('Midi Note Number','FontSize',fontSize);
title('F0, HMM Note Model','FontSize',fontSize);
legend('f0','Raw','Ground Truth');
set(gca, 'FontSize', fontSize);

subplot(3,1,2)
plot(time,midiPitchGround,'.');
hold on
plot(time,decodedHMMNote(:,2),'r');
for i = 1:size(annotation,1)
    plot([annotation(i,1),annotation(i,1)+annotation(i,3)],[annotation(i,2),annotation(i,2)],'g','LineWidth',2);
end
for i = 1:size(notesHMMNoteModel{1,2},1)
    plot([notesHMMNoteModel{1,2}(i,1),notesHMMNoteModel{1,2}(i,1)+notesHMMNoteModel{1,2}(i,3)],[notesHMMNoteModel{1,2}(i,2),notesHMMNoteModel{1,2}(i,2)],'r','LineWidth',2);
end
hold off
xlabel('Time(s)','FontSize',fontSize);
ylabel('Midi Note Number','FontSize',fontSize);
title('F0 with Ground Pitch Deviation Fixing, HMM Note Model','FontSize',fontSize);
legend('f0','Raw','Ground Truth');
set(gca, 'FontSize', fontSize);

subplot(3,1,3)
plot(time,midiPitchCeil,'.');
hold on
plot(time,decodedHMMNote(:,3),'r');
for i = 1:size(annotation,1)
    plot([annotation(i,1),annotation(i,1)+annotation(i,3)],[annotation(i,2),annotation(i,2)],'g','LineWidth',2);
end
for i = 1:size(notesHMMNoteModel{1,3},1)
    plot([notesHMMNoteModel{1,3}(i,1),notesHMMNoteModel{1,3}(i,1)+notesHMMNoteModel{1,3}(i,3)],[notesHMMNoteModel{1,3}(i,2),notesHMMNoteModel{1,3}(i,2)],'r','LineWidth',2);
end
hold off
xlabel('Time(s)','FontSize',fontSize);
ylabel('Midi Note Number','FontSize',fontSize);
title('F0 with Ceil Pitch Deviation Fixing, HMM Note Model','FontSize',fontSize);
legend('f0','Raw','Ground Truth');
set(gca, 'FontSize', fontSize);


%-----tony post-processing-------
%--amplitude-based onset segmentation---
ampRise = zeros(size(powerCurve));
for i = 2:length(powerCurve)-1
    ampRise(i) = powerCurve(i+1)/powerCurve(i-1);
end
s = 1./ampRise;

%---------------------------------

figure(4)
subplot(4,1,1)
plot(time,midiPitchOriginal,'.');
hold on
% plot(time,decodedHMMStru(:,1),'r');
for i = 1:size(annotation,1)
    plot([annotation(i,1),annotation(i,1)+annotation(i,3)],[annotation(i,2),annotation(i,2)],'g','LineWidth',2);
end
for i = 1:size(notesHMMNoteModel{1},1)
    plot([notesHMMNoteModel{1}(i,1),notesHMMNoteModel{1}(i,1)+notesHMMNoteModel{1}(i,3)],[notesHMMNoteModel{1}(i,2),notesHMMNoteModel{1}(i,2)],'r','LineWidth',2);
end
hold off
xlabel('Time(s)','FontSize',fontSize);
ylabel('Midi Note Number','FontSize',fontSize);
title('F0','FontSize',fontSize);
legend('f0','Raw','Ground Truth');
% xlim([0 5]);
ylim([50 80])

subplot(4,1,2)
plot(time,powerCurve);
title('Power(RMS)','FontSize',fontSize);
% xlim([0 5]);

subplot(4,1,3)
plot(time,s);
title('rise','FontSize',fontSize);

subplot(4,1,4)
plot(time,ZCRCurve);
title('ZCR','FontSize',fontSize);
% xlim([0 5]);