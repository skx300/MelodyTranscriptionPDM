%test the Gamma function
clear;

pd = makedist('Gamma',2,2);

x = [-20:0.001:20];

y1 = pdf('Gamma',x,1.1,30);
y2 = pdf('Gamma',-x,1.1,30);
y3 = normpdf(x,0,0.01);

figure(5)
plot(x,y1);
hold on
plot(x,y2);
plot(x,y3);
hold off
title('Observation Probability Density Distribution')
xlabel('Delta-Pitch Curve');
ylabel('Probability');

