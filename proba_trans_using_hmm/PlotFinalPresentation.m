%Plots for YAMAHA final presentation

%plot the transition probability matrix
fontSize = 30;
figure(11)
surf(transNoteModel,'LineStyle','None');
view(2);
title('Transition Probability for Note Model HMM','FontSize',fontSize);
xlabel('MIDI NN (from)');
ylabel('MIDI NN (to)');
% xlim([172,190]);
% ylim([172,190]);
xTick = 2.5:3:386.5;
xTickLabel = mat2cell((0:128),1);
set(gca, 'FontSize', fontSize,...
    'XTickLabel',xTickLabel,'XTick',xTick,...
    'YTickLabel',xTickLabel,'YTick',xTick);

%plot the vibrato and portmaneto comparison between baseline and note model
%HMM
%numer 11 in Monina2014 dataset
figure(12)
% subplot(2,1,1)
% plot(time,midiPitchOriginal,'.');
% hold on
% % plot(time,decodedBaseline,'r');
% plot([annotation(1,1),annotation(1,1)+annotation(1,3)],[annotation(1,2),annotation(1,2)],'g','LineWidth',3);
% plot([notesBaseline{1,1}(1,1),notesBaseline{1,1}(1,1)+notesBaseline{1,1}(1,3)],[notesBaseline{1,1}(1,2),notesBaseline{1,1}(1,2)],'r','LineWidth',3);
% for i = 2:size(annotation,1)
%     plot([annotation(i,1),annotation(i,1)+annotation(i,3)],[annotation(i,2),annotation(i,2)],'g','LineWidth',3);
% end
% for i = 2:size(notesBaseline{1,1},1)
%     plot([notesBaseline{1,1}(i,1),notesBaseline{1,1}(i,1)+notesBaseline{1,1}(i,3)],[notesBaseline{1,1}(i,2),notesBaseline{1,1}(i,2)],'r','LineWidth',3);
% end
% hold off
% xlabel('Time(s)','FontSize',fontSize);
% ylabel('Midi Note Number','FontSize',fontSize);
% title('Baseline','FontSize',fontSize);
% legend('f0','Ground Truth','Transcription','Location','NorthWest');
% set(gca, 'FontSize', fontSize);
% xlim([25.5 29.5]);
% ylim([50 63]);

% subplot(2,1,2)
plot(time,midiPitchOriginal,'.');
hold on
% plot(time,decodedHMMNote(:,1),'r');
plot([annotation(1,1),annotation(1,1)+annotation(1,3)],[annotation(1,2),annotation(1,2)],'g','LineWidth',3);
plot([notesHMMNoteModel{1,1}(1,1),notesHMMNoteModel{1,1}(1,1)+notesHMMNoteModel{1,1}(1,3)],[notesHMMNoteModel{1,1}(1,2),notesHMMNoteModel{1,1}(1,2)],'r','LineWidth',3);
for i = 2:size(annotation,1)
    plot([annotation(i,1),annotation(i,1)+annotation(i,3)],[annotation(i,2),annotation(i,2)],'g','LineWidth',3);
end
for i = 2:size(notesHMMNoteModel{1,1},1)
    plot([notesHMMNoteModel{1,1}(i,1),notesHMMNoteModel{1,1}(i,1)+notesHMMNoteModel{1,1}(i,3)],[notesHMMNoteModel{1,1}(i,2),notesHMMNoteModel{1,1}(i,2)],'r','LineWidth',3);
end
hold off
xlabel('Time(s)','FontSize',fontSize);
ylabel('Midi Note Number','FontSize',fontSize);
title('Note Model HMM','FontSize',fontSize);
legend('f0','Ground Truth','Transcription','Location','NorthWest');
set(gca, 'FontSize', fontSize);
xlim([25.5 29.5]);
ylim([50 63]);