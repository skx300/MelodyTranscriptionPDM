%show the 2-variable pdf
clear;
clf;

mu = [61 0];
Sigma = [4 -0.5; -0.5 0.1];
x1 = 1:.1:128; x2 = -5:.1:5;
[X1,X2] = meshgrid(x1,x2);
F = mvnpdf([X1(:) X2(:)],mu,Sigma);
F = reshape(F,length(x2),length(x1));


figure(9)
surf(x1,x2,F);
caxis([min(F(:))-.5*range(F(:)),max(F(:))]);
axis([58 64 -3 3 0 .4]), view(2);
xlabel('f0'); ylabel('\Delta f0'); zlabel('Probability Density');
title('Likelihood of MIDI NN = 61 sustain state');