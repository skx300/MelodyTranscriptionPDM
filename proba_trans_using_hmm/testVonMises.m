%This is for the test of Von Mises function which used for observation.
clear;
clf;

f0 = [55:0.1:65]; delta_f0 = [-5:0.1:5];

[F0,DELTA_F0] = meshgrid(f0,delta_f0);

%parameter to change the shape
K1 = 0.5; a1= 0.4; b1 = 1; f0S1 = 1; delta_f0S1 = 1;%for start state
% K1 = 5; a1= 0.4; b1 = 1; f0S1 = 1; delta_f0S1 = 1;%for start state
K2 = 0; a2= 0.1; b2 = 1; f0S2 = 5; delta_f0S2 = 1;%for sustain state
% K2 = 0.5; a2= 0.1; b2 = 1; f0S2 = 5; delta_f0S2 = 1;%for sustain state
% K2 = 1; a2= 0.1; b2 = 1; f0S2 = 5; delta_f0S2 = 1;%for sustain state
K3 = 0.5; a3= 0.2; b3 = 1; f0S3 = 1; delta_f0S3 = 1;%for end state
% K3 = 5; a3= 0.2; b3 = 1; f0S3 = 1; delta_f0S3 = 1;%for end state
mu1 = 60/100*pi;
mu2 = 0;
mu3 = 30/100*pi;

%create Von Mises distribution
z1 = VonMisesPDF(F0,DELTA_F0,61,K1,a1,b1,f0S1,delta_f0S1,0);
z2 = VonMisesPDF(F0,DELTA_F0,61,K2,a2,b2,f0S2,delta_f0S2,1);
z3 = VonMisesPDF(F0,DELTA_F0,61,K3,a3,b3,f0S3, delta_f0S3,2);

%create Yang-Maezawa distribution
z11 = VonMisesPDF_2(F0,DELTA_F0,61,K1,a1,b1,mu1);
z22 = VonMisesPDF_2(F0,DELTA_F0,61,K2,a2,b2,mu2);
z33 = VonMisesPDF_2(F0,DELTA_F0,61,K3,a3,b3,mu3);

b = (0.1:0.05:10); %evenly spaced
kappa = (logspace(-2,1,199)); %logarithmically spaced between 0.01 and 10

%interpolation
z1q = inpaint_nans(z1,5);
z2q = inpaint_nans(z2,5);
z3q = inpaint_nans(z3,5);

fontSize = 30;
figure(3)
subplot(2,2,1);
surf(F0,DELTA_F0,z1,'LineStyle','none','MeshStyle','row');
view(2);
title('Start state of MIDI NN = 61');
xl = xlabel('$f_0$ (MIDI)');
yl = ylabel('$\Delta f_0$ (MIDI)');
set(xl,'Interpreter','latex');
set(yl,'Interpreter','latex');
set(gca, 'FontSize', fontSize);

subplot(2,2,2);
surf(F0,DELTA_F0,z2,'LineStyle','none');
view(2);
title('Sustain state of MIDI NN = 61');
xl = xlabel('$f_0$ (MIDI)');
yl = ylabel('$\Delta f_0$ (MIDI)');
set(xl,'Interpreter','latex');
set(yl,'Interpreter','latex');
set(gca, 'FontSize', fontSize);

subplot(2,2,3);
surf(F0,DELTA_F0,z3,'LineStyle','none');
view(2);
title('End state of MIDI NN = 61');
xl = xlabel('$f_0$ (MIDI)');
yl = ylabel('$\Delta f_0$ (MIDI)');
set(xl,'Interpreter','latex');
set(yl,'Interpreter','latex');
set(gca, 'FontSize', fontSize);


%Yang-Maezawa distribution
figure(4)
subplot(2,2,1);
surf(F0,DELTA_F0,z11,'LineStyle','none');
view(2);
title('Start state of MIDI NN = 61');
xl = xlabel('$f_0$ (MIDI)');
yl = ylabel('$\Delta f_0$ (MIDI)');
set(xl,'Interpreter','latex');
set(yl,'Interpreter','latex');
set(gca, 'FontSize', fontSize);

subplot(2,2,2);
surf(F0,DELTA_F0,z22,'LineStyle','none');
view(2);
title('Sustain state of MIDI NN = 61');
xl = xlabel('$f_0$ (MIDI)');
yl = ylabel('$\Delta f_0$ (MIDI)');
set(xl,'Interpreter','latex');
set(yl,'Interpreter','latex');
set(gca, 'FontSize', fontSize);

subplot(2,2,3);
surf(F0,DELTA_F0,z33,'LineStyle','none');
view(2);
title('End state of MIDI NN = 61');
xl = xlabel('$f_0$ (MIDI)');
yl = ylabel('$\Delta f_0$ (MIDI)');
set(xl,'Interpreter','latex');
set(yl,'Interpreter','latex');
set(gca, 'FontSize', fontSize);

fontSize = 30;
figure(5)
subplot(2,2,1);
surf(F0,DELTA_F0,z1q,'LineStyle','none','MeshStyle','row');
view(2);
title('Start state of MIDI NN = 61');
xl = xlabel('$f_0$ (MIDI)');
yl = ylabel('$\Delta f_0$ (MIDI)');
set(xl,'Interpreter','latex');
set(yl,'Interpreter','latex');
set(gca, 'FontSize', fontSize);

subplot(2,2,2);
surf(F0,DELTA_F0,z2q,'LineStyle','none');
view(2);
title('Sustain state of MIDI NN = 61');
xl = xlabel('$f_0$ (MIDI)');
yl = ylabel('$\Delta f_0$ (MIDI)');
set(xl,'Interpreter','latex');
set(yl,'Interpreter','latex');
set(gca, 'FontSize', fontSize);

subplot(2,2,3);
surf(F0,DELTA_F0,z3q,'LineStyle','none');
view(2);
title('End state of MIDI NN = 61');
xl = xlabel('$f_0$ (MIDI)');
yl = ylabel('$\Delta f_0$ (MIDI)');
set(xl,'Interpreter','latex');
set(yl,'Interpreter','latex');
set(gca, 'FontSize', fontSize);

