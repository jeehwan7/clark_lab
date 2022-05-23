%% Nanki Experiment Documentation Summary for innate pattern preferences project
% All experiments are pattern vs. gray 
%% Checker Size Sweep 
paths = {'Practice_Nanki\InterocularCheckGrayCheckSizeSweep','Nanki_Practice\InterocularCheckGrayCheckSizeSweep'};
out_size = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX', log([5,10,20,45,90]),...
'dataX', log([5,10,20,45,90]),...
'tickLabelX', [5,10,20,45,90],'labelX',...
'Log Checker Size','combOpp',1,'numIgnore',1,'figLeg',{'5','10','20','45','90'});

%% Update Rate Sweep with randomly flickering 2D checkerboards 
 
  % Update sweep function for 5 degrees
paths = {'Practice_Nanki\InterocularCheckGrayUpdateSweep'};
out_update5 = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX',log([3,6,15,30,60,180]),...
'dataX',log([3,6,15,30,60,180]),...
'tickLabelX',[3,6,15,30,60,180],'labelX',...
'Log Flicker Frequency','combOpp',1,'numIgnore',1,'figLeg',{'3','6','15','30','60','180'});

  % Update sweep function for 10 degrees
paths = {'Practice_Nanki\InterocularCheckGrayUpdateSweepCheckSize10'};
out_update10 = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX',log([3,6,15,30,60,180]),...
'dataX',log([3,6,15,30,60,180]),...
'tickLabelX',[3,6,15,30,60,180],'labelX',...
'Log Flicker Frequency','combOpp',1,'numIgnore',1,'figLeg',{'3','6','15','30','60','180'});
 
% Update Sweep function for 20 degrees
paths = {'Practice_Nanki\InterocularCheckGrayUpdateSweepCheckSize20'};
out_update20 = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX',log([3,6,15,30,60,180]),...
'dataX',log([3,6,15,30,60,180]),...
'tickLabelX',[3,6,15,30,60,180],'labelX',...
'Log Flicker Frequency','combOpp',1,'numIgnore',1,'figLeg',{'3','6','15','30','60','180'});
% Update Sweep function for 45 degrees
paths = {'Practice_Nanki\InterocularCheckGrayUpdateSweepCheckSize45'};
out_update45 = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX',log([3,6,15,30,60,180]),...
'dataX',log([3,6,15,30,60,180]),...
'tickLabelX',[3,6,15,30,60,180],'labelX',...
'Log Flicker Frequency','combOpp',1,'numIgnore',1,'figLeg',{'3','6','15','30','60','180'});
% Update Sweep function for 90 degrees
paths = {'Practice_Nanki\InterocularCheckGrayUpdateSweepCheckSize90'};
out_update90 = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX',log([3,6,15,30,60,180]),...
'dataX',log([3,6,15,30,60,180]),...
'tickLabelX',[3,6,15,30,60,180],'labelX',...
'Log Flicker Frequency','combOpp',1,'numIgnore',1,'figLeg',{'3','6','15','30','60','180'});


% plot all checker sizes in one figure 

length = 5;
red = [1, 0, 0];
blue = [16, 78, 139]/139;
colors_p = [linspace(red(1),blue(1),length)', linspace(red(2),blue(2),length)', linspace(red(3),blue(3),length)'];


figure; hold on;

PlotXvsY(([3,6,15,30,60,180])', out_update5.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update5.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', colors_p(1,:))
PlotXvsY(([3,6,15,30,60,180])', out_update10.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update10.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', colors_p(2,:))
PlotXvsY(([3,6,15,30,60,180])', out_update20.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update20.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', colors_p(3,:))
PlotXvsY(([3,6,15,30,60,180])', out_update45.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update45.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', colors_p(4,:))
PlotXvsY(([3,6,15,30,60,180])', out_update90.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update90.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', colors_p(5,:))
xticks([3,6,15,30,60,180]);
yline(0, '--k', 'LineWidth', 3);
xlabel('Flicker Frequency (Hz)');
ylabel('Turning Response (deg/s)');
legend('5 degree', '10 degree', '20 degree', '45 degree', '90 degree');
set(gca, 'XScale', 'log');

% false color plot 
figure;
update_check = [out_update5.analysis{1}.respMatPlot(6,1,1) out_update10.analysis{1}.respMatPlot(6,1,1) out_update20.analysis{1}.respMatPlot(6,1,1) out_update45.analysis{1}.respMatPlot(6,1,1) out_update90.analysis{1}.respMatPlot(6,1,1);...
    out_update5.analysis{1}.respMatPlot(5,1,1) out_update10.analysis{1}.respMatPlot(5,1,1) out_update20.analysis{1}.respMatPlot(5,1,1) out_update45.analysis{1}.respMatPlot(5,1,1) out_update90.analysis{1}.respMatPlot(5,1,1);...
    out_update5.analysis{1}.respMatPlot(4,1,1) out_update10.analysis{1}.respMatPlot(4,1,1) out_update20.analysis{1}.respMatPlot(4,1,1) out_update45.analysis{1}.respMatPlot(4,1,1) out_update90.analysis{1}.respMatPlot(4,1,1);...
    out_update5.analysis{1}.respMatPlot(3,1,1) out_update10.analysis{1}.respMatPlot(3,1,1) out_update20.analysis{1}.respMatPlot(3,1,1) out_update45.analysis{1}.respMatPlot(3,1,1) out_update90.analysis{1}.respMatPlot(3,1,1);...
    out_update5.analysis{1}.respMatPlot(2,1,1) out_update10.analysis{1}.respMatPlot(2,1,1) out_update20.analysis{1}.respMatPlot(2,1,1) out_update45.analysis{1}.respMatPlot(2,1,1) out_update90.analysis{1}.respMatPlot(2,1,1);...
    out_update5.analysis{1}.respMatPlot(1,1,1) out_update10.analysis{1}.respMatPlot(1,1,1) out_update20.analysis{1}.respMatPlot(1,1,1) out_update45.analysis{1}.respMatPlot(1,1,1) out_update90.analysis{1}.respMatPlot(1,1,1);]

imagesc(update_check)
colormap(gray);
colorbar;
set(gca, 'xTickLabel', {'5', '10' '20', '45', '90'})
set(gca, 'yTickLabel', {'180', '60' '30', '15', '6', '3'})
xlabel('Checker Size (deg)')
ylabel('Flicker Frequency (Hz)')
title('Turning Response (deg/s)')




%% Update Rate Sweep with randomly flickering 1D checkerboards  
%Horizontal checkers
paths = {'Practice_Nanki\InterocularCheck1DHUpdateSweep'};
out_1DH10 = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX',log([3,6,15,30,60,180]),...
'dataX',[3,6,15,30,60,180],...
'tickLabelX',log([3,6,15,30,60,180]),'labelX',...
'Log Flicker Frequency','combOpp',1,'numIgnore',1,'figLeg',{'3','6','15','30','60','180'});
% Vertical checkers
paths = {'Practice_Nanki\InterocularCheck1DVUpdateSweep'};
out_1DV10 = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX',log([3,6,15,30,60,180]),...
'dataX', [3,6,15,30,60,180],...
'tickLabelX',log([3,6,15,30,60,180]),'labelX',...
'Log Flicker Frequency','combOpp',1,'numIgnore',1,'figLeg',{'3','6','15','30','60','180'});
% plot horizontal and vertical together

figure; hold on;

PlotXvsY(([3,6,15,30,60,180])', out_1DH10.analysis{1}.respMatPlot(:,:,1),'error',...
     out_1DH10.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [0,0,1])
PlotXvsY(([3,6,15,30,60,180])', out_1DV10.analysis{1}.respMatPlot(:,:,1),'error',...
     out_1DV10.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [1,0,0])
xticks([3,6,15,30,60,180]);
yline(0, '--k', 'LineWidth', 3);
xlabel('Flicker Frequency (Hz)');
ylabel('Turning Response (deg/s)');
legend('horizontal', 'vertical', 'location', 'best');
set(gca, 'XScale', 'log');

%% Genotype screening for flickering 2D checkerboard update rate sweep
% Note: L1/L2, Rh1-Gal4, split Mi1 and Tm3 have to be redone
% due to contaminated shibire, T4/T5 is split
%% Update sweep function for 10 degree checkers - split T4/T5 / shi
paths = {'Nanki_T4T5_shi\InterocularCheckGrayUpdateSweepCheckSize10'};
out_update10T4T5shi = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX',log([3,6,15,30,60,180]),...
'dataX', log([3,6,15,30,60,180]),...
'tickLabelX', [3,6,15,30,60,180],'labelX',...
'Log Flicker Frequency','combOpp',1,'numIgnore',1,'figLeg',{'3','6','15','30','60','180'}, 'duration', 1500);


%% Update sweep function for 10 degree checkers - empty shi
paths = {'Nanki_empty_shi\InterocularCheckGrayUpdateSweepCheckSize10'};
out_update10emptyshi = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX',log([3,6,15,30,60,180]),...
'dataX',log([3,6,15,30,60,180]),...
'tickLabelX',[3,6,15,30,60,180],'labelX',...
'Log Flicker Frequency','combOpp',1,'numIgnore',1,'figLeg',{'3','6','15','30','60','180'}, 'duration', 1500);

%% Update sweep function for 10 degree checkers - T4/T5 / +
paths = {'Nanki_T4T5_+\InterocularCheckGrayUpdateSweepCheckSize10'};
out_update10T4T5wt = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX',log([3,6,15,30,60,180]),...
'dataX',log([3,6,15,30,60,180]),...
'tickLabelX',[3,6,15,30,60,180],'labelX',...
'Log Flicker Frequency','combOpp',1,'numIgnore',1,'figLeg',{'3','6','15','30','60','180'}, 'duration', 1500);


%% Update sweep function for 10 degree checkers - T2/shi
paths = {'T2_Shts\InterocularCheckGrayUpdateSweepCheckSize10'};
out_update10T2shi = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX',log([3,6,15,30,60,180]),...
'dataX', log([3,6,15,30,60,180]),...
'tickLabelX', [3,6,15,30,60,180],'labelX',...
'Log Flicker Frequency','combOpp',1,'numIgnore',1,'figLeg',{'3','6','15','30','60','180'});

%% Update sweep function for 10 degree checkers - T2/+
paths = {'T2_+\InterocularCheckGrayUpdateSweepCheckSize10'};
out_update10T2wt = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX',log([3,6,15,30,60,180]),...
'dataX', log([3,6,15,30,60,180]),...
'tickLabelX', [3,6,15,30,60,180],'labelX',...
'Log Flicker Frequency','combOpp',1,'numIgnore',1,'figLeg',{'3','6','15','30','60','180'});

%% Update sweep function for 10 degree checkers - T3/Shts
paths = {'T3_Shts\InterocularCheckGrayUpdateSweepCheckSize10'};
out_update10T3shi = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX',log([3,6,15,30,60,180]),...
'dataX', log([3,6,15,30,60,180]),...
'tickLabelX', [3,6,15,30,60,180],'labelX',...
'Log Flicker Frequency','combOpp',1,'numIgnore',1,'figLeg',{'3','6','15','30','60','180'});
%% Update sweep function for 10 degree checkers - T3/+
paths = {'T3_+\InterocularCheckGrayUpdateSweepCheckSize10'};
out_update10T3wt = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX',log([3,6,15,30,60,180]),...
'dataX', log([3,6,15,30,60,180]),...
'tickLabelX', [3,6,15,30,60,180],'labelX',...
'Log Flicker Frequency','combOpp',1,'numIgnore',1,'figLeg',{'3','6','15','30','60','180'});
%%  Update sweep function for 10 degree checkers - L1L2/Shts
paths = {'L1L2_shts\InterocularCheckGrayUpdateSweepCheckSize10'};
out_update10L1L2shts = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX',log([3,6,15,30,60,180]),...
'dataX', log([3,6,15,30,60,180]),...
'tickLabelX', [3,6,15,30,60,180],'labelX',...
'Log Flicker Frequency','combOpp',1,'numIgnore',1,'figLeg',{'3','6','15','30','60','180'});
%% Update sweep function for 10 degree checkers - Rh1/Shts
paths = {'Rh1_shts\InterocularCheckGrayUpdateSweepCheckSize10'};
out_update10Rh1shts = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX',log([3,6,15,30,60,180]),...
'dataX', log([3,6,15,30,60,180]),...
'tickLabelX', [3,6,15,30,60,180],'labelX',...
'Log Flicker Frequency','combOpp',1,'numIgnore',1,'figLeg',{'3','6','15','30','60','180'});

%% Update sweep function for 10 degree checkers - L1L2/+
paths = {'L1L2_+\InterocularCheckGrayUpdateSweepCheckSize10'};
out_update10L1L2wt = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX',log([3,6,15,30,60,180]),...
'dataX', log([3,6,15,30,60,180]),...
'tickLabelX', [3,6,15,30,60,180],'labelX',...
'Log Flicker Frequency','combOpp',1,'numIgnore',1,'figLeg',{'3','6','15','30','60','180'});
%% %% Update sweep function for 10 degree checkers - Rh1/+
paths = {'Rh1_+\InterocularCheckGrayUpdateSweepCheckSize10'};
out_update10Rh1wt = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX',log([3,6,15,30,60,180]),...
'dataX', log([3,6,15,30,60,180]),...
'tickLabelX', [3,6,15,30,60,180],'labelX',...
'Log Flicker Frequency','combOpp',1,'numIgnore',1,'figLeg',{'3','6','15','30','60','180'});
%% %% %% Update sweep function for 10 degree checkers - Mi1/shts
paths = {'Nanki_Mi1_shts\InterocularCheckGrayUpdateSweepCheckSize10'};
out_update10Mi1shts = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX',log([3,6,15,30,60,180]),...
'dataX', log([3,6,15,30,60,180]),...
'tickLabelX', [3,6,15,30,60,180],'labelX',...
'Log Flicker Frequency','combOpp',1,'numIgnore',1,'figLeg',{'3','6','15','30','60','180'});
%% Update sweep function for 10 degree checkers - Tm3/shts
paths = {'Nanki_Tm3_shts\InterocularCheckGrayUpdateSweepCheckSize10'};
out_update10Tm3shts = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX',log([3,6,15,30,60,180]),...
'dataX', log([3,6,15,30,60,180]),...
'tickLabelX', [3,6,15,30,60,180],'labelX',...
'Log Flicker Frequency','combOpp',1,'numIgnore',1,'figLeg',{'3','6','15','30','60','180'});



%% Update sweep function for 10 degree checkers- Mi1/+
paths = {'Mi1_+\InterocularCheckGrayUpdateSweepCheckSize10'};
out_update10Mi1wt = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX',log([3,6,15,30,60,180]),...
'dataX', log([3,6,15,30,60,180]),...
'tickLabelX', [3,6,15,30,60,180],'labelX',...
'Log Flicker Frequency','combOpp',1,'numIgnore',1,'figLeg',{'3','6','15','30','60','180'});

%% split T4/T5 turning response analysis 
figure; hold on;
PlotXvsY(([3,6,15,30,60,180])', out_update10.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update10.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [0,0,1])
PlotXvsY(([3,6,15,30,60,180])', out_update10T4T5shi.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update10T4T5shi.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [1,0,0])
PlotXvsY(([3,6,15,30,60,180])', out_update10emptyshi.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update10emptyshi.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [0,0,0])
PlotXvsY(([3,6,15,30,60,180])', out_update10T4T5wt.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update10T4T5wt.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [0,0,0] + 0.5)
 
 
xticks([3,6,15,30,60,180]);

yline(0, '--k', 'LineWidth', 3);
xlabel('Flicker Frequency (Hz)');
ylabel('Turning Response (deg/s)');
legend('wt', 'T4T5/shi', 'empty/shi', 'T4T5/+', 'location', 'best');
set(gca, 'XScale', 'log');

%% turning response analysis of silenced-flies

figure; hold on;
PlotXvsY(([3,6,15,30,60,180])', out_update10.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update10.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [0,0,1])
PlotXvsY(([3,6,15,30,60,180])', out_update10T4T5shi.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update10T4T5shi.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [1,0,0])
PlotXvsY(([3,6,15,30,60,180])', out_update10Mi1shts.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update10Mi1shts.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [0,0,0])
PlotXvsY(([3,6,15,30,60,180])', out_update10Tm3shts.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update10Tm3shts.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [0,0,0] + 0.5)

 
xticks([3,6,15,30,60,180]);

yline(0, '--k', 'LineWidth', 3);
xlabel('Flicker Frequency (Hz)');
ylabel('Turning Response (deg/s)');
legend('wt', 'T4T5/shi', 'Mi1/shi', 'Tm3/shi', 'location', 'best');
set(gca, 'XScale', 'log');

%% split T4/T5 walking speed analysis

figure; hold on;
PlotXvsY(([3,6,15,30,60,180])', out_update10.analysis{1}.respMatPlot(:,:,2),'error',...
     out_update10.analysis{1}.respMatSemPlot(:,:,2), 'plotColor', [0,0,1])
PlotXvsY(([3,6,15,30,60,180])', out_update10T4T5shi.analysis{1}.respMatPlot(:,:,2),'error',...
     out_update10T4T5shi.analysis{1}.respMatSemPlot(:,:,2), 'plotColor', [1,0,0])
PlotXvsY(([3,6,15,30,60,180])', out_update10emptyshi.analysis{1}.respMatPlot(:,:,2),'error',...
     out_update10emptyshi.analysis{1}.respMatSemPlot(:,:,2), 'plotColor', [0,0,0])
PlotXvsY(([3,6,15,30,60,180])', out_update10T4T5wt.analysis{1}.respMatPlot(:,:,2),'error',...
     out_update10T4T5wt.analysis{1}.respMatSemPlot(:,:,2), 'plotColor', [0,0,0] + 0.5)
 
 
xticks([3,6,15,30,60,180]);

yline(1, '--k', 'LineWidth', 3);
xlabel('Flicker Frequency (Hz)');
ylabel('Walking Response (fold change)');
legend('wt', 'T4T5/shi', 'empty/shi', 'T4T5/+', 'location', 'best');
set(gca, 'XScale', 'log');
%% L1/L2 analysis of turning response
figure; hold on;
PlotXvsY(([3,6,15,30,60,180])',out_update10L1L2shts.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update10L1L2shts.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [1,0,0])
PlotXvsY(([3,6,15,30,60,180])', out_update10.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update10.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [0,0,1])
PlotXvsY(([3,6,15,30,60,180])', out_update10L1L2wt.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update10L1L2wt.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [0,0,0])
PlotXvsY(([3,6,15,30,60,180])', out_update10emptyshi.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update10emptyshi.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [0,0,0] + 0.5)
 
xticks([3,6,15,30,60,180]);

yline(0, '--k', 'LineWidth', 3);
xlabel('Flicker Frequency (Hz)');
ylabel('Turning Response (deg/s)');
legend( 'L1L2/shi','wt', 'L1L2/+', 'empty/shi', 'location', 'best');
set(gca, 'XScale', 'log');

%% Mi1 analysis of turning response
figure; hold on;
PlotXvsY(([3,6,15,30,60,180])',out_update10Mi1shts.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update10Mi1shts.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [1,0,0])
PlotXvsY(([3,6,15,30,60,180])', out_update10.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update10.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [0,0,1])
PlotXvsY(([3,6,15,30,60,180])', out_update10Mi1wt.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update10Mi1wt.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [0,0,0])

 
xticks([3,6,15,30,60,180]);

yline(0, '--k', 'LineWidth', 3);
xlabel('Flicker Frequency (Hz)');
ylabel('Turning Response (deg/s)');
legend( 'Mi1/shi','wt', 'Mi1/+', 'location', 'best');
set(gca, 'XScale', 'log');
%% Mi1 analysis of walking response
figure; hold on;
PlotXvsY(([3,6,15,30,60,180])',out_update10Mi1shts.analysis{1}.respMatPlot(:,:,2),'error',...
     out_update10Mi1shts.analysis{1}.respMatSemPlot(:,:,2), 'plotColor', [1,0,0])
PlotXvsY(([3,6,15,30,60,180])', out_update10.analysis{1}.respMatPlot(:,:,2),'error',...
     out_update10.analysis{1}.respMatSemPlot(:,:,2), 'plotColor', [0,0,1])
PlotXvsY(([3,6,15,30,60,180])', out_update10Mi1wt.analysis{1}.respMatPlot(:,:,2),'error',...
     out_update10Mi1wt.analysis{1}.respMatSemPlot(:,:,2), 'plotColor', [0,0,0])

 
xticks([3,6,15,30,60,180]);

yline(1, '--k', 'LineWidth', 3);
xlabel('Flicker Frequency (Hz)');
ylabel('Turning Response (deg/s)');
legend( 'Mi1/shi','wt', 'Mi1/+', 'location', 'best');
set(gca, 'XScale', 'log');



%% L1/L2 analysis of walking response
figure; hold on;
PlotXvsY(([3,6,15,30,60,180])',out_update10L1L2shts.analysis{1}.respMatPlot(:,:,2),'error',...
     out_update10L1L2shts.analysis{1}.respMatSemPlot(:,:,2), 'plotColor', [1,0,0])
PlotXvsY(([3,6,15,30,60,180])', out_update10.analysis{1}.respMatPlot(:,:,2),'error',...
     out_update10.analysis{1}.respMatSemPlot(:,:,2), 'plotColor', [0,0,1])
PlotXvsY(([3,6,15,30,60,180])', out_update10L1L2wt.analysis{1}.respMatPlot(:,:,2),'error',...
     out_update10L1L2wt.analysis{1}.respMatSemPlot(:,:,2), 'plotColor', [0,0,0])
 
 
xticks([3,6,15,30,60,180]);
yline(1, '--k', 'LineWidth', 3);
xlabel('Flicker Frequency (Hz)');
ylabel('Walking Response (fold change)');
legend( 'L1L2/shi','wt', 'L1L2/+', 'location', 'best');
set(gca, 'XScale', 'log');

%% Rh1-gal4 analysis of turning response

figure; hold on;
PlotXvsY(([3,6,15,30,60,180])',out_update10Rh1shts.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update10Rh1shts.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [1,0,0])
PlotXvsY(([3,6,15,30,60,180])', out_update10.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update10.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [0,0,1])
PlotXvsY(([3,6,15,30,60,180])', out_update10Rh1wt.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update10Rh1wt.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [0,0,0])
 
 
xticks([3,6,15,30,60,180]);

yline(0, '--k', 'LineWidth', 3);
xlabel('Flicker Frequency (Hz)');
ylabel('Turning Response (deg/s)');
legend( 'Rh1-Gal4/shi','wt', 'Rh1-Gal4/+', 'location', 'best');
set(gca, 'XScale', 'log');

%% walking response Rh1-Gal4 analysis
figure; hold on;
PlotXvsY(([3,6,15,30,60,180])',out_update10Rh1shts.analysis{1}.respMatPlot(:,:,2),'error',...
     out_update10Rh1shts.analysis{1}.respMatSemPlot(:,:,2), 'plotColor', [1,0,0])
PlotXvsY(([3,6,15,30,60,180])', out_update10.analysis{1}.respMatPlot(:,:,2),'error',...
     out_update10.analysis{1}.respMatSemPlot(:,:,2), 'plotColor', [0,0,1])
PlotXvsY(([3,6,15,30,60,180])', out_update10Rh1wt.analysis{1}.respMatPlot(:,:,2),'error',...
     out_update10Rh1wt.analysis{1}.respMatSemPlot(:,:,2), 'plotColor', [0,0,0])
 
 
xticks([3,6,15,30,60,180]);

yline(1, '--k', 'LineWidth', 3);
xlabel('Flicker Frequency (Hz)');
ylabel('Walking Response (fold change)');
legend( 'Rh1-Gal4/shi','wt', 'Rh1-Gal4/+', 'location', 'best');
set(gca, 'XScale', 'log');

%% T2 analysis of turning response

figure; hold on;
PlotXvsY(([3,6,15,30,60,180])',out_update10T2shi.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update10T2shi.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [1,0,0])
PlotXvsY(([3,6,15,30,60,180])', out_update10.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update10.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [0,0,1])
PlotXvsY(([3,6,15,30,60,180])', out_update10T2wt.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update10T2wt.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [0,0,0])
 
 
xticks([3,6,15,30,60,180]);

yline(0, '--k', 'LineWidth', 3);
xlabel('Flicker Frequency (Hz)');
ylabel('Turning Response (deg/s)');
legend( 'T2/shi','wt', 'T2/+', 'location', 'best');
set(gca, 'XScale', 'log');

%% T2 analysis of walking speed
figure; hold on;
PlotXvsY(([3,6,15,30,60,180])',out_update10T2shi.analysis{1}.respMatPlot(:,:,2),'error',...
     out_update10T2shi.analysis{1}.respMatSemPlot(:,:,2), 'plotColor', [1,0,0])
PlotXvsY(([3,6,15,30,60,180])', out_update10.analysis{1}.respMatPlot(:,:,2),'error',...
     out_update10.analysis{1}.respMatSemPlot(:,:,2), 'plotColor', [0,0,1])
PlotXvsY(([3,6,15,30,60,180])', out_update10T2wt.analysis{1}.respMatPlot(:,:,2),'error',...
     out_update10T2wt.analysis{1}.respMatSemPlot(:,:,2), 'plotColor', [0,0,0])
 
 
xticks([3,6,15,30,60,180]);

yline(1, '--k', 'LineWidth', 3);
xlabel('Flicker Frequency (Hz)');
ylabel('Walking Response (fold change)');
legend( 'T2/shi','wt', 'T2/+', 'location', 'best');
set(gca, 'XScale', 'log');

%% %% T3 analysis of turning response

figure; hold on;
PlotXvsY(([3,6,15,30,60,180])',out_update10T3shi.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update10T3shi.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [1,0,0])
PlotXvsY(([3,6,15,30,60,180])', out_update10.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update10.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [0,0,1])
PlotXvsY(([3,6,15,30,60,180])', out_update10T3wt.analysis{1}.respMatPlot(:,:,1),'error',...
     out_update10T3wt.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [0,0,0])
 
 
xticks([3,6,15,30,60,180]);

yline(0, '--k', 'LineWidth', 3);
xlabel('Flicker Frequency (Hz)');
ylabel('Turning Response (deg/s)');
legend( 'T3/shi','wt', 'T3/+', 'location', 'best');
set(gca, 'XScale', 'log');


%% T3 analysis of walking response
figure; hold on;
PlotXvsY(([3,6,15,30,60,180])',out_update10T3shi.analysis{1}.respMatPlot(:,:,2),'error',...
     out_update10T3shi.analysis{1}.respMatSemPlot(:,:,2), 'plotColor', [1,0,0])
PlotXvsY(([3,6,15,30,60,180])', out_update10.analysis{1}.respMatPlot(:,:,2),'error',...
     out_update10.analysis{1}.respMatSemPlot(:,:,2), 'plotColor', [0,0,1])
PlotXvsY(([3,6,15,30,60,180])', out_update10T3wt.analysis{1}.respMatPlot(:,:,2),'error',...
     out_update10T3wt.analysis{1}.respMatSemPlot(:,:,2), 'plotColor', [0,0,0])
 
 
xticks([3,6,15,30,60,180]);

yline(1, '--k', 'LineWidth', 3);
xlabel('Flicker Frequency (Hz)');
ylabel('Walking Response (fold change)');
legend( 'T3/shi','wt', 'T3/+', 'location', 'best');
set(gca, 'XScale', 'log');

%% T4/T5-silenced control experiment - successful
% T4/T5-silenced data
paths = {'Nanki_T4T5_shi\sinMir_VcontFreq_rot_lam30_C025_180hz'};
out_poscontrol15T4T5shi = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX', [0,0.25,0.375,0.5,0.75,1,1.5,2,3,4,6,8,12,16,24,32],...
'dataX', [0,0.25,0.375,0.5,0.75,1,1.5,2,3,4,6,8,12,16,24,32],...
'tickLabelX', [0,0.25,0.375,0.5,0.75,1,1.5,2,3,4,6,8,12,16,24,32],'labelX',...
'Temporal Frequency (Hz)','combOpp',1,'numIgnore',1,'figLeg',{'0','0.25','0.375','0.5','0.75','1','1.5','2','3','4','6','8','12','16','24','32'});
% empty shibire data
paths = {'Nanki_empty_shi\sinMir_VcontFreq_rot_lam30_C025_180hz'};
out_poscontrol15emptyshi = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX', log([0,0.25,0.375,0.5,0.75,1,1.5,2,3,4,6,8,12,16,24,32]),...
'dataX', log([0,0.25,0.375,0.5,0.75,1,1.5,2,3,4,6,8,12,16,24,32]),...
'tickLabelX', [0,0.25,0.375,0.5,0.75,1,1.5,2,3,4,6,8,12,16,24,32],'labelX',...
'Temporal Frequency (Hz)','combOpp',1,'numIgnore',1,'figLeg',{'0','0.25','0.375','0.5','0.75','1','1.5','2','3','4','6','8','12','16','24','32'});
% T4/T5 / + data 
paths = {'Nanki_T4T5_+\sinMir_VcontFreq_rot_lam30_C025_180hz'};
out_poscontrol15T4T5wt = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX', log([0,0.25,0.375,0.5,0.75,1,1.5,2,3,4,6,8,12,16,24,32]),...
'dataX', log([0,0.25,0.375,0.5,0.75,1,1.5,2,3,4,6,8,12,16,24,32]),...
'tickLabelX', log([0,0.25,0.375,0.5,0.75,1,1.5,2,3,4,6,8,12,16,24,32]),'labelX',...
'Temporal Frequency (Hz)','combOpp',1,'numIgnore',1,'figLeg',{'0','0.25','0.375','0.5','0.75','1','1.5','2','3','4','6','8','12','16','24','32'});

%% plot figure with controls and silenced T4/T5
figure; hold on;
PlotXvsY(([0,0.25,0.375,0.5,0.75,1,1.5,2,3,4,6,8,12,16,24,32])', out_poscontrol15T4T5shi.analysis{1}.respMatPlot(:,:,1),'error',...
     out_poscontrol15T4T5shi.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [1,0,0])
PlotXvsY(([0,0.25,0.375,0.5,0.75,1,1.5,2,3,4,6,8,12,16,24,32])', out_poscontrol15emptyshi.analysis{1}.respMatPlot(:,:,1),'error',...
     out_poscontrol15emptyshi.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [0,0,0])
PlotXvsY(([0,0.25,0.375,0.5,0.75,1,1.5,2,3,4,6,8,12,16,24,32])', out_poscontrol15T4T5wt.analysis{1}.respMatPlot(:,:,1),'error',...
     out_poscontrol15T4T5wt.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [0,0,0] + 0.5)

 
xticks([0,2,4,6,8,12,16,24,32]);

yline(0, '--k', 'LineWidth', 3);
xlabel('Temporal Frequency (Hz)');
ylabel('Turning Response (deg/s)');
legend('T4T5/shi', 'empty/shi', 'T4T5/+');

%% Orientation-dependent sweeps of counterphase grating - need to  rerun at 2, 4, 30, 45 Hz with properly flipped stimulus
% Orientation sweep at 15 Hz flicker frequency - correct
paths = {'IsoD1_Nanki\InterocularSineGrayFlickerOrientationSweep15Flipped'};
out_orientationflicker15flipped = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX', [0,22.5,45,67.5,90,112.5,135,157.5],...
'dataX', [0,22.5,45,67.5,90,112.5,135,157.5],...
'tickLabelX', [0,22.5,45,67.5,90,112.5,135,157.5],'labelX',...
'Orientation (degree)','combOpp',1,'numIgnore',1,'figLeg',{'0','22.5','45','67.5','90','112.5','135','157.5'});


% Orientation sweep at 2 Hz flicker frequency - must flip
% (same for all other frequencies) 
paths = {'Practice_Nanki\InterocularSineGrayFlickerOrientationSweep2'};
out_orientationflicker2 = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX', [0,22.5,45,67.5,90,112.5,135,157.5],...
'dataX', [0,22.5,45,67.5,90,112.5,135,157.5],...
'tickLabelX', [0,22.5,45,67.5,90,112.5,135,157.5],'labelX',...
'Orientation (degree)','combOpp',1,'numIgnore',1,'figLeg',{'0','22.5','45','67.5','90','112.5','135','157.5'});
% Orientation sweep at 30 Hz flicker frequency - must flip
paths = {'Practice_Nanki\InterocularSineGrayFlickerOrientationSweep30'};
out_orientationflicker30 = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX', [0,22.5,45,67.5,90,112.5,135,157.5],...
'dataX', [0,22.5,45,67.5,90,112.5,135,157.5],...
'tickLabelX', [0,22.5,45,67.5,90,112.5,135,157.5],'labelX',...
'Orientation (degree)','combOpp',1,'numIgnore',1,'figLeg',{'0','22.5','45','67.5','90','112.5','135','157.5'});
% Orientation sweep at 45 Hz flicker frequency - must flip
paths = {'Practice_Nanki\InterocularSineGrayFlickerOrientationSweep45'};
out_orientationflicker45 = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX', [0,22.5,45,67.5,90,112.5,135,157.5],...
'dataX', [0,22.5,45,67.5,90,112.5,135,157.5],...
'tickLabelX', [0,22.5,45,67.5,90,112.5,135,157.5],'labelX',...
'Orientation (degree)','combOpp',1,'numIgnore',1,'figLeg',{'0','22.5','45','67.5','90','112.5','135','157.5'});

%% turning speed analysis code for all frequencies (would have to redo for everything but 15 Hz)
length = 3;
red = [1, 0, 0];
blue = [16, 78, 139]/139;
colors_p = [linspace(red(1),blue(1),length)', linspace(red(2),blue(2),length)', linspace(red(3),blue(3),length)'];

figure; hold on;
PlotXvsY([0,22.5,45,67.5,90,112.5,135,157.5]', out_orientationflicker15flipped.analysis{1}.respMatPlot(:,:,1),'error',...
     out_orientationflicker15flipped.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [0,0,1])
PlotXvsY([0,22.5,45,67.5,90,112.5,135,157.5]', out_orientationflicker30.analysis{1}.respMatPlot(:,:,1),'error',...
     out_orientationflicker30.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [0,1,0])
PlotXvsY([0,22.5,45,67.5,90,112.5,135,157.5]', out_orientationflicker45.analysis{1}.respMatPlot(:,:,1),'error',...
     out_orientationflicker45.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [1,0,0])
yline(0, '--k', 'LineWidth', 3);
xticks([0,22.5,45,67.5,90,112.5,135,157.5]);
xlabel('Orientation (degrees from vertical)');
ylabel('Turning Response (deg/s)');
legend('15 Hz','30 Hz', '45 Hz','location', 'best');


%% walking speed analysis code for all frequencies (would have to redo for everything but 15 Hz)
figure; hold on;
PlotXvsY([0,22.5,45,67.5,90,112.5,135,157.5]', out_orientationflicker15flipped.analysis{1}.respMatPlot(:,:,2),'error',...
     out_orientationflicker15flipped.analysis{1}.respMatSemPlot(:,:,2), 'plotColor', [0,0,1])
PlotXvsY([0,22.5,45,67.5,90,112.5,135,157.5]', out_orientationflicker30.analysis{1}.respMatPlot(:,:,2),'error',...
     out_orientationflicker30.analysis{1}.respMatSemPlot(:,:,2), 'plotColor', [0,1,0])
PlotXvsY([0,22.5,45,67.5,90,112.5,135,157.5]', out_orientationflicker45.analysis{1}.respMatPlot(:,:,2),'error',...
     out_orientationflicker45.analysis{1}.respMatSemPlot(:,:,2), 'plotColor', [1,0,0])
yline(1, '--k', 'LineWidth', 3);
xticks([0,22.5,45,67.5,90,112.5,135,157.5]);
xlabel('Orientation (degrees from vertical)');
ylabel('Walking Response (fold change)');
legend('15 Hz', '30 Hz', '45 Hz');
ylim([0.7 1.3])

%% Split T4/T5-silenced analysis with 15 Hz flicker frequency - must be repeated with the flipped stimulus as noted above
% this stimulus is not flipped but is here to show the silenced result - willh have to be redone, however
paths = {'Practice_Nanki\InterocularSineGrayFlickerOrientationSweep15'};
out_orientationflicker15 = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX', [0,22.5,45,67.5,90,112.5,135,157.5],...
'dataX', [0,22.5,45,67.5,90,112.5,135,157.5],...
'tickLabelX', [0,22.5,45,67.5,90,112.5,135,157.5],'labelX',...
'Orientation (degree)','combOpp',1,'numIgnore',1,'figLeg',{'0','22.5','45','67.5','90','112.5','135','157.5'});
%T4/T5 silenced 
paths = {'Nanki_T4T5_shi\InterocularSineGrayFlickerOrientationSweep15'};
out_orientationflicker15T4T5shi = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX', [0,22.5,45,67.5,90,112.5,135,157.5],...
'dataX', [0,22.5,45,67.5,90,112.5,135,157.5],...
'tickLabelX', [0,22.5,45,67.5,90,112.5,135,157.5],'labelX',...
'Orientation (degree)','combOpp',1,'numIgnore',1,'figLeg',{'0','22.5','45','67.5','90','112.5','135','157.5'});
% T4T5/+
paths = {'Nanki_T4T5_+\InterocularSineGrayFlickerOrientationSweep15'};
out_orientationflicker15T4T5wt = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX', [0,22.5,45,67.5,90,112.5,135,157.5],...
'dataX', [0,22.5,45,67.5,90,112.5,135,157.5],...
'tickLabelX', [0,22.5,45,67.5,90,112.5,135,157.5],'labelX',...
'Orientation (degree)','combOpp',1,'numIgnore',1,'figLeg',{'0','22.5','45','67.5','90','112.5','135','157.5'});
% empty/shi
paths = {'Nanki_empty_shi\InterocularSineGrayFlickerOrientationSweep15'};
out_orientationflicker15emptyshi = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX', [0,22.5,45,67.5,90,112.5,135,157.5],...
'dataX', [0,22.5,45,67.5,90,112.5,135,157.5],...
'tickLabelX', [0,22.5,45,67.5,90,112.5,135,157.5],'labelX',...
'Orientation (degree)','combOpp',1,'numIgnore',1,'figLeg',{'0','22.5','45','67.5','90','112.5','135','157.5'});

% analysis of turning response
figure; hold on;
PlotXvsY([0,22.5,45,67.5,90,112.5,135,157.5]', out_orientationflicker15.analysis{1}.respMatPlot(:,:,1),'error',...
     out_orientationflicker15.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [0,0,1])
PlotXvsY([0,22.5,45,67.5,90,112.5,135,157.5]', out_orientationflicker15T4T5shi.analysis{1}.respMatPlot(:,:,1),'error',...
     out_orientationflicker15T4T5shi.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [1,0,0])
PlotXvsY([0,22.5,45,67.5,90,112.5,135,157.5]', out_orientationflicker15emptyshi.analysis{1}.respMatPlot(:,:,1),'error',...
     out_orientationflicker15emptyshi.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [0,0,0]) 
PlotXvsY([0,22.5,45,67.5,90,112.5,135,157.5]', out_orientationflicker15T4T5wt.analysis{1}.respMatPlot(:,:,1),'error',...
     out_orientationflicker15T4T5wt.analysis{1}.respMatSemPlot(:,:,1), 'plotColor', [0,0,0] + 0.5)
yline(0, '--k', 'LineWidth', 3);
xticks([0,22.5,45,67.5,90,112.5,135,157.5]);
xlabel('Orientation (degrees from vertical)');
ylabel('Turning Response (deg/s)');
legend('wt', 'T4T5/shi', 'empty/shi', 'T4T5/+','location', 'best');

% analysis of walking response
figure; hold on;
PlotXvsY([0,22.5,45,67.5,90,112.5,135,157.5]', out_orientationflicker15.analysis{1}.respMatPlot(:,:,2),'error',...
     out_orientationflicker15.analysis{1}.respMatSemPlot(:,:,2), 'plotColor', [0,0,1])
PlotXvsY([0,22.5,45,67.5,90,112.5,135,157.5]', out_orientationflicker15T4T5shi.analysis{1}.respMatPlot(:,:,2),'error',...
     out_orientationflicker15T4T5shi.analysis{1}.respMatSemPlot(:,:,2), 'plotColor', [1,0,0])
PlotXvsY([0,22.5,45,67.5,90,112.5,135,157.5]', out_orientationflicker15emptyshi.analysis{1}.respMatPlot(:,:,2),'error',...
     out_orientationflicker15emptyshi.analysis{1}.respMatSemPlot(:,:,2), 'plotColor', [0,0,0]) 
PlotXvsY([0,22.5,45,67.5,90,112.5,135,157.5]', out_orientationflicker15T4T5wt.analysis{1}.respMatPlot(:,:,2),'error',...
     out_orientationflicker15T4T5wt.analysis{1}.respMatSemPlot(:,:,2), 'plotColor', [0,0,0] + 0.5)
yline(1, '--k', 'LineWidth', 3);
xticks([0,22.5,45,67.5,90,112.5,135,157.5]);
xlabel('Orientation (degrees from vertical)');
ylabel('Walking Response (fold change)');
legend('wt', 'T4T5/shi', 'empty/shi', 'T4T5/+','location', 'best');



%% Orientation-dependent sweep of local counterphase grating and its net motion components 
paths = {'IsoD1_Nanki\InterocularSineGrayMotionOrientationSweepFlipped'};
out_updatemotionflipped = RunAnalysis('analysisFile',{'CombAndSep','PlotTimeTraces'},'dataPath',paths,'tickX',[0,45,90,135],...
'dataX',[0,45,90,135],...
'tickLabelX',[0,45,90,135],'labelX',...
'Orientation (degree from vertical)','combOpp',1,'numIgnore',1,'figLeg',{'0(U)','45(U)','90(U)','135(U)','0(D)','45(D)','90(D)','135(D)','0(F)','45(F)','90(F)','135(F)'},'numSep', 3,'sepType','contiguous');

% plots  - U, D, F, U+D, turning response analysis 
figure; hold on;
PlotXvsY(([0,45,90,135])', out_updatemotionflipped.analysis{1}.respMatPlot(:,1,1),'error',...
     out_updatemotionflipped.analysis{1}.respMatSemPlot(:,1,1), 'plotColor', [0,0,1])
PlotXvsY(([0,45,90,135])', out_updatemotionflipped.analysis{1}.respMatPlot(:,2,1),'error',...
     out_updatemotionflipped.analysis{1}.respMatSemPlot(:,2,1), 'plotColor', [1,0,0])
PlotXvsY(([0,45,90,135])', out_updatemotionflipped.analysis{1}.respMatPlot(:,3,1),'error',...
     out_updatemotionflipped.analysis{1}.respMatSemPlot(:,3,1), 'plotColor', [0,0,0])
PlotXvsY(([0,45,90,135])', out_updatemotionflipped.analysis{1}.respMatPlot(:,1,1) + out_updatemotionflipped.analysis{1}.respMatPlot(:,2,1),'error',...
     sqrt(out_updatemotionflipped.analysis{1}.respMatSemPlot(:,1,1).^2 + out_updatemotionflipped.analysis{1}.respMatSemPlot(:,2,1).^2), 'plotColor', [107 76 154]./255)
hold off;
xticks([0,45,90,135]);
yline(0, '--k', 'LineWidth', 3);
xlabel('Orientation from vertical (degrees)');
ylabel('Turning Response (deg/s)');
legend('D+', 'D-', 'FLICKER', 'sum of D+ and D-');


% U + D - F, analysis of turning response
figure; 
PlotXvsY(([0,45,90,135])', out_updatemotionflipped.analysis{1}.respMatPlot(:,1,1) + out_updatemotionflipped.analysis{1}.respMatPlot(:,2,1) - out_updatemotionflipped.analysis{1}.respMatPlot(:,3,1),'error',...
     sqrt(out_updatemotionflipped.analysis{1}.respMatSemPlot(:,1,1).^2 + out_updatemotionflipped.analysis{1}.respMatSemPlot(:,2,1).^2 + out_updatemotionflipped.analysis{1}.respMatSemPlot(:,3,1).^2), 'plotColor', [0,0,0])
xticks([0,45,90,135]);
yline(0, '--k', 'LineWidth', 3);
xlabel('Orientation from vertical (degrees)');
ylabel('Turning Response (deg/s)');
legend('D1 + D2 - FLICKER');

% plots  - U, D, F, U+D, walking response analysis 
figure; hold on;
PlotXvsY(([0,45,90,135])', out_updatemotionflipped.analysis{1}.respMatPlot(:,1,2),'error',...
     out_updatemotionflipped.analysis{1}.respMatSemPlot(:,1,2), 'plotColor', [0,0,1])
PlotXvsY(([0,45,90,135])', out_updatemotionflipped.analysis{1}.respMatPlot(:,2,2),'error',...
     out_updatemotionflipped.analysis{1}.respMatSemPlot(:,2,2), 'plotColor', [1,0,0])
PlotXvsY(([0,45,90,135])', out_updatemotionflipped.analysis{1}.respMatPlot(:,3,2),'error',...
     out_updatemotionflipped.analysis{1}.respMatSemPlot(:,3,2), 'plotColor', [0,0,0])
PlotXvsY(([0,45,90,135])', 1 - ((1 - out_updatemotionflipped.analysis{1}.respMatPlot(:,1,2)) + (1 - out_updatemotionflipped.analysis{1}.respMatPlot(:,2,2))),'error',...
     sqrt(out_updatemotionflipped.analysis{1}.respMatSemPlot(:,1,2).^2 + out_updatemotionflipped.analysis{1}.respMatSemPlot(:,2,2).^2), 'plotColor', [107 76 154]./255)
hold off;
xticks([0,45,90,135]);
yline(1, '--k', 'LineWidth', 3);
xlabel('Orientation from vertical (degrees)');
ylabel('Walking Response (fold change)');
legend('D+', 'D-', 'FLICKER', 'Sum of D+ and D-');

% U + D - F, analysis of walking response 
figure; 
PlotXvsY(([0,45,90,135])', out_updatemotionflipped.analysis{1}.respMatPlot(:,1,2) + out_updatemotionflipped.analysis{1}.respMatPlot(:,2,2) - out_updatemotionflipped.analysis{1}.respMatPlot(:,3,2),'error',...
     sqrt(out_updatemotionflipped.analysis{1}.respMatSemPlot(:,1,2).^2 + out_updatemotionflipped.analysis{1}.respMatSemPlot(:,2,2).^2 + out_updatemotionflipped.analysis{1}.respMatSemPlot(:,3,2).^2), 'plotColor', [0,0,0])
xticks([0,45,90,135]);
yline(0, '--k', 'LineWidth', 3);
xlabel('Orientation from vertical (degrees)');
ylabel('Walking Response (fold change)');
legend('UP + DOWN - FLICKER');

%% Note: a preliminary glider stimulus was also created - however, it needed to be converted from 120 frames per up to 3 frames per up and an entirely new stimulus would need to be created 




