%tuning frequency estimation using circular statistics.


c = midiPitchOriginal*100;

phi = 2*pi/100*c;

u = 1*exp(1i*phi);

centsDev = 100/(2*pi)*angle(sum(u)/length(u));

fRef = 2^(centsDev/1200)*440;