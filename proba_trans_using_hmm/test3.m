
lowPassFilter = smooth(midiPitchOriginal,3);
medianFilter = medf(midiPitchOriginal',3,length(midiPitchOriginal));


figure(6)
plot(time,midiPitchOriginal);
hold on
plot(time,lowPassFilter);
plot(time,medianFilter);
hold off
legend('f0','Low-pass','Median');

firstNote = decodedHMMStru(54:111);
firstNoteNew = zeros(size(firstNote));
firstNoteNew(mod(firstNote,1) ~= 0) = 0.3;
firstNoteNew(mod(firstNote,1) == 0) = 1;

secondNote = decodedHMMStru(112:137);
secondNoteNew = zeros(size(secondNote));
secondNoteNew(mod(secondNote,1) ~= 0) = 0.3;
secondNoteNew(mod(secondNote,1) == 0) = 1;

thirdNote = decodedHMMStru(138:166);
thirdNoteNew = zeros(size(thirdNote));
thirdNoteNew(mod(thirdNote,1) ~= 0) = 0.3;
thirdNoteNew(mod(thirdNote,1) == 0) = 1;

figure(7);
subplot(2,1,1)
hist(firstNote,100);
title('Histogram of a note with vibrato');
subplot(2,1,2)
hist(firstNoteNew);

figure(8);
subplot(2,1,1)
hist(secondNote,100);
title('Histogram of portamento');
subplot(2,1,2)
hist(secondNoteNew);

figure(9);
subplot(2,1,1)
hist(thirdNote,100);
title('Histogram of vibrato');
subplot(2,1,2)
hist(thirdNoteNew);