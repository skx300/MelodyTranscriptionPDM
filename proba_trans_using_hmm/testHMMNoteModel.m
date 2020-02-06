%Note model HMM (start-sustain-end)

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
transitionNoteModel = GetTransMatrixNoteModel(stateRangeMIDINote);

%------observation matrix---------
% observationNoteModelOriginal = GetObservsMatrixNoteModel(midiPitchOriginal,deltaMidiPitch,numStatesNoteModel);
% observationNoteModelGround = GetObservsMatrixNoteModel(midiPitchGround,deltaMidiPitch,numStatesNoteModel);
observationNoteModelCeil = GetObservsMatrixNoteModel(midiPitchCeil,deltaMidiPitch,numStatesNoteModel);

decodedHMMNote = zeros(length(midiPitchOriginal),3); 
% decodedHMMNote(:,1) = ViterbiAlgHMM(transitionNoteModel',observationNoteModelOriginal,initalDistributionNoteModel);
% decodedHMMNote(:,2) = ViterbiAlgHMM(transitionNoteModel',observationNoteModelGround,initalDistributionNoteModel);
decodedHMMNote(:,3) = ViterbiAlgHMM(transitionNoteModel',observationNoteModelCeil,initalDistributionNoteModel);

decodedHMMNote = decodedHMMNote.*repmat(decodedPower',1,3);
decodedHMMNote = (decodedHMMNote-1)/3;
decodedHMMNoteRounded = floor(decodedHMMNote);

%-----END of the HMM note level model--------


notesHMMNoteModel1 = NoteAggreBaseline(decodedHMMNoteRounded(:,1),pitchFs);
notesHMMNoteModel2 = NoteAggreBaseline(decodedHMMNoteRounded(:,2),pitchFs);
notesHMMNoteModel3 = NoteAggreBaseline(decodedHMMNoteRounded(:,3),pitchFs);

durationThresh = 0.1;
notesHMMNoteModel1 = NotePruning(notesHMMNoteModel1, durationThresh);
notesHMMNoteModel2 = NotePruning(notesHMMNoteModel2, durationThresh);
notesHMMNoteModel3 = NotePruning(notesHMMNoteModel3, durationThresh);

editDHMMNoteModel1  = EditDistance_2(notesHMMNoteModel1(:,2),annotation(:,2))/length(annotation(:,2));
editDHMMNoteModel2  = EditDistance_2(notesHMMNoteModel2(:,2),annotation(:,2))/length(annotation(:,2));
editDHMMNoteModel3  = EditDistance_2(notesHMMNoteModel3(:,2),annotation(:,2))/length(annotation(:,2));

csvwrite('data/notesHMMNoteModel1.csv',notesHMMNoteModel1);
csvwrite('data/notesHMMNoteModel2.csv',notesHMMNoteModel2);
csvwrite('data/notesHMMNoteModel3.csv',notesHMMNoteModel3);


figure(3)
fontSize = 20;
subplot(3,1,1)
plot(time,midiPitchOriginal,'.');
hold on
plot(time,decodedHMMNote(:,1),'r');
for i = 1:size(annotation,1)
    plot([annotation(i,1),annotation(i,1)+annotation(i,3)],[annotation(i,2),annotation(i,2)],'g','LineWidth',2);
end
for i = 1:size(notesHMMNoteModel1,1)
    plot([notesHMMNoteModel1(i,1),notesHMMNoteModel1(i,1)+notesHMMNoteModel1(i,3)],[notesHMMNoteModel1(i,2),notesHMMNoteModel1(i,2)],'r','LineWidth',2);
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
for i = 1:size(notesHMMNoteModel2,1)
    plot([notesHMMNoteModel2(i,1),notesHMMNoteModel2(i,1)+notesHMMNoteModel2(i,3)],[notesHMMNoteModel2(i,2),notesHMMNoteModel2(i,2)],'r','LineWidth',2);
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
for i = 1:size(notesHMMNoteModel3,1)
    plot([notesHMMNoteModel3(i,1),notesHMMNoteModel3(i,1)+notesHMMNoteModel3(i,3)],[notesHMMNoteModel3(i,2),notesHMMNoteModel3(i,2)],'r','LineWidth',2);
end
hold off
xlabel('Time(s)','FontSize',fontSize);
ylabel('Midi Note Number','FontSize',fontSize);
title('F0 with Ceil Pitch Deviation Fixing, HMM Note Model','FontSize',fontSize);
legend('f0','Raw','Ground Truth');
set(gca, 'FontSize', fontSize);

