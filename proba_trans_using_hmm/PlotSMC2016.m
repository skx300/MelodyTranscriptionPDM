%plot for SMC2016
clf;
clear;

folderPath = '../../Dataset/EvaluationFramework_ISMIR2014/DATASET/';

data = csvread([folderPath,'f0_pyin/afemale9_f0_pyin.csv']); 
time = data(:,1);
pitchRaw = data(:,2);
%let the pyin outputs engative frequencies as unvoiced, then make
%the unvoiced as 0;
pitchRaw(pitchRaw <= 0) = NaN;
pitchFs = 1/(time(2)-time(1));
midiPitchOriginal = freqToMidi(pitchRaw);

deltaMidiPitch = [0;diff(smooth(midiPitchOriginal,10))];

%----get ground truth data-----
fileID = fopen([folderPath,'afemale9.GroundTruth.txt'],'r');
dataGT = fscanf(fileID,'%f');
dataGT_2 = zeros(size(dataGT,1)/3,3);
for i = 1:size(dataGT,1)/3
    dataGT_2(i,1) = dataGT((i-1)*3+1);
    dataGT_2(i,3) = dataGT((i-1)*3+2)-dataGT_2(i,1);
    dataGT_2(i,2) = dataGT((i-1)*3+3);
end
%------------------------------

notes = getPassages(time,midiPitchOriginal,dataGT_2,0); 

fontSize = 34;
figure(1)
subplot(2,1,1)
plot(time,midiPitchOriginal,'.','LineWidth',2,'MarkerSize',12);
hold on
for i = 1:size(dataGT_2,1)
   plot([dataGT_2(i,1),dataGT_2(i,1)+dataGT_2(i,3)],[dataGT_2(i,2),dataGT_2(i,2)],'LineWidth',3,'Color','r'); 
end
hold off
ylim([50 70]);
xlim([13.7 time(end)]);
xlabel('Time(s)');
ylabel('MIDI note');
lh = legend('$f_0$','Note Annotation');
set(lh,'Interpreter','latex');
set(gca,'FontSize',fontSize);
subplot(2,1,2)
plot(time,midiPitchOriginal,'.','LineWidth',2,'MarkerSize',12);
ylim([50 70]);
xlim([13.7 time(end)]);
xlabel('Time(s)');
ylabel('MIDI note');
lh = legend('$f_0$','Annotation');
set(lh,'Interpreter','latex');
set(gca,'FontSize',fontSize);

figure(2)
notesPassName = fieldnames(notes);

% for i = 1:length(notesPassName)
for i = 23
    tempInfo = notes.(char(notesPassName(i)));
    plot(tempInfo(:,2),[0;diff(tempInfo(:,2))],'+');
end
xh = xlabel('$f_0$');
yh = ylabel('$\Delta f_0$');
set(xh,'Interpreter','latex');
set(yh,'Interpreter','latex');
set(gca,'FontSize',fontSize);

figure1 = figure(3);
plot(time,midiPitchOriginal,'.','LineWidth',5,'MarkerSize',22);
hold on
faceAlpha = 0.3;
faceColor = [1,0,0];
noteWidth = 0.3;
for i = 1:size(dataGT_2,1)
%    plot([dataGT_2(i,1),dataGT_2(i,1)+dataGT_2(i,3)],[dataGT_2(i,2),dataGT_2(i,2)],'LineWidth',10,'Color','r','FaceAlpha',0.5);
   fill([dataGT_2(i,1),dataGT_2(i,1)+dataGT_2(i,3),dataGT_2(i,1)+dataGT_2(i,3),dataGT_2(i,1)],...
            [dataGT_2(i,2)-noteWidth,dataGT_2(i,2)-noteWidth,dataGT_2(i,2)+noteWidth,dataGT_2(i,2)+noteWidth],faceColor,'EdgeColor','none','FaceAlpha',faceAlpha);
end
hold off
ylim([53 65]);
xlim([13.7 23]);
xlabel('Time(s)');
ylabel('MIDI note');
% [lh,BLicons] = legend('$f_0$','Note Annotation');
[lh,BLicons,plots,txt] = legend('f0','Note Annotation');
% set(lh,'Interpreter','latex');
% set(lh.BoxFace, 'ColorType', 'truecoloralpha', 'ColorData', uint8([255;255;255;0.5*255]));

set(gca,'FontSize',fontSize);
PatchInLegend = findobj(BLicons, 'type', 'patch');
set(PatchInLegend, 'facea', faceAlpha);
TextInLegend = findobj(BLicons,'type','text');
set(TextInLegend, 'FontSize', fontSize);


%annotations
% Create rectangle
annotation(figure1,'rectangle',...
    [0.2109375 0.546061415220294 0.03828125 0.0587449933244326],'LineWidth',2,...
    'LineStyle','--');

% Create rectangle
annotation(figure1,'rectangle',...
    [0.428125 0.546061415220293 0.03828125 0.0587449933244326],'LineWidth',2,...
    'LineStyle','--');

% Create rectangle
annotation(figure1,'rectangle',...
    [0.8171875 0.231462389202795 0.0632812500000007 0.0587449933244326],...
    'LineWidth',2,...
    'LineStyle','--');

% Create ellipse
annotation(figure1,'ellipse',...
    [0.369750000000001 0.391117478510028 0.0325937499999994 0.189111747851003],...
    'LineWidth',2,...
    'LineStyle','-.');

% Create ellipse
annotation(figure1,'ellipse',...
    [0.692406250000002 0.38538681948424 0.031031249999998 0.169054441260746],...
    'LineWidth',2,...
    'LineStyle','-.');

% Create ellipse
annotation(figure1,'ellipse',...
    [0.635375000000003 0.293696275071633 0.0232187499999973 0.137535816618911],...
    'LineWidth',2,...
    'LineStyle','-.');

% Create ellipse
annotation(figure1,'ellipse',...
    [0.13225 0.310888252148997 0.03884375 0.282234957020057],'LineWidth',2,...
    'LineStyle','-.');

% Create textbox
annotation(figure1,'textbox',...
    [0.374437500000001 0.745708650743444 0.1818125 0.106017191977077],...
    'String',{'Between-note fluctuations.'},...
    'LineStyle','none',...
    'FontSize',fontSize,...
    'FitBoxToText','off');

% Create textbox
annotation(figure1,'textbox',...
    [0.365062500000001 0.149720112061496 0.1818125 0.106017191977077],...
    'String',{'Within-note fluctuations'},...
    'LineStyle','none',...
    'FontSize',fontSize,...
    'FitBoxToText','off');

% Create arrow
annotation(figure1,'arrow',[0.38046875 0.23828125],...
    [0.256446991404011 0.535816618911175]);

% Create arrow
annotation(figure1,'arrow',[0.44453125 0.44453125],...
    [0.262177650429799 0.532951289398281]);

% Create arrow
annotation(figure1,'arrow',[0.48125 0.80546875],...
    [0.216332378223496 0.236389684813754]);

% Create arrow
annotation(figure1,'arrow',[0.36640625 0.1640625],...
    [0.754102040816327 0.612244897959184]);

% Create arrow
annotation(figure1,'arrow',[0.41171875 0.384375],...
    [0.717996289424861 0.603151862464183]);

% Create arrow
annotation(figure1,'arrow',[0.47890625 0.62421875],...
    [0.702153988868275 0.443413729128015]);

% Create arrow
annotation(figure1,'arrow',[0.5 0.67890625],...
    [0.728128014842301 0.536178107606679]);

