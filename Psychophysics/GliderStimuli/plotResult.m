function [ET,Ek,confmat] = plotResult

%% Last updated on Mar 21 2020 by RT
%% This function plots all the figures and calculates p-values shown in 
%% Figure 5 and S6.

% set path to custom QUEST scripts / plot utility functions
addpath('./utils')
addpath('./myQuest')
% load result files
datadir = './resultsmat';
mats = dir([datadir,'/*.mat']);
qs = cell(0);
for ss = 1:length(mats)
    load([datadir,'/',mats(ss).name],'abortFlag');
    load([datadir,'/',mats(ss).name],'subID');
    if abortFlag==0 && subID~=0
        qs{end+1} = load([datadir,'/',mats(ss).name],'q');
    end
end

%% Plot individual psychometric curves (Fig. 5C/S6)
% Create a figure panel
MakeFigure;
% define color scheme
pcols = [90/255,90/255,90/255;33/255,121/255,180/255;246/255,151/255,153/255];
% define condition names
cnames = {'no adaptor','ON adaptor','OFF adaptor'};
% extract the number of subjects
nSub = length(qs);
% prepare matrices to hold point estimates of parameters
ET = []; Ek = [];
% for each subject
for ss = 1:nSub
    subplot(4,3,ss); hold on
    % for eaach condition
    for ii = 1:3
      % Use a custom QUEST function to pull out posterior distribution
      [Ek(ss,ii),ET(ss,ii),pdf2d(:,:,ii,ss),T,log2k] = QuestBetaAnalysisLogistic(qs{ss}.q{ii},0,3.5,3);  
      % Plot PMF by randomly resampling from the posterior distribution
      % error area corresponds to 68% credible interval
      sampleBayesianLogisticPMF(pdf2d(:,:,ii,ss),T,log2k,pcols(ii,:),1000);
      title(['Subject #',num2str(ss)]); hold on
      PlotConstLine(0.5);PlotConstLine(0,2);
      legend(cnames);
      xlabel('rotational velocity deg/s');
      ylabel('P(toward light shade)');
    end
end


%% show bar graphs with errorbars around each individual data
% calculate 68% credible interval (1SD) of T based on marginal distribution
ETerror = nan(nSub,3,2); 
for ss = 1:nSub
    for ii = 1:3
        margpdf = mean(pdf2d(:,:,ii,ss),1);
        margpdf = margpdf/sum(margpdf);
        cmargdis = cumsum(margpdf);
        [~,indlow] = min(abs(cmargdis-0.16));
        [~,indhigh] = min(abs(cmargdis-0.84));
        ETerror(ss,ii,1) = T(indlow);
        ETerror(ss,ii,2) = T(indhigh);
    end
end

% calculate 68% credible interval (1SD) of log2k (slope)
Elog2kerror = nan(nSub,3,2); 
for ss = 1:nSub
    for ii = 1:3
        margpdf = mean(pdf2d(:,:,ii,ss),2);
        margpdf = margpdf/sum(margpdf);
        cmargdis = cumsum(margpdf);
        [~,indlow] = min(abs(cmargdis-0.16));
        [~,indhigh] = min(abs(cmargdis-0.84));
        Elog2kerror(ss,ii,1) = log2k(indlow);
        Elog2kerror(ss,ii,2) = log2k(indhigh);
    end
end

% plot results
MakeFigure; 
subplot(1,2,1);
easyBarIndivError(ET,ETerror,'newFigure',0,'connectPaired',1,'colors',pcols,'conditionNames',cnames);
title('Estimated Threshold');

subplot(1,2,2);
easyBarIndivError(Ek,2.^Elog2kerror,'newFigure',0,'connectPaired',1,'colors',pcols,'conditionNames',cnames);
title('Estimated Slope');

%% Calculate within individual significance of nulling velocity (Fig. S6)
confmat = [];
% for each individual,
for ss = 1:size(pdf2d,4)
    thispdf = pdf2d(:,:,:,ss);
    margpdf = squeeze(sum(thispdf,1));
    margpdf = margpdf./sum(margpdf);
    margcdf = cumsum(margpdf);
    % for each pair of conditions, calculate probability that T in
    % condition 1 is larger than T in condition 2 
    for ii=1:3
        for jj=1:3
            confmat(ii,jj,ss) = sum(margpdf(:,ii).*margcdf(:,jj));
        end
    end
end
% calculate pdiff (see Methods)
pdiff = 1-2*abs(squeeze([confmat(1,2,:),confmat(1,3,:),confmat(2,3,:)])-0.5);
% columns correspond to sibjects
% Row1: no adaptor VS ON adaptor
% Row2: no adaptor VS OFF adaptor
% Row3: ON adaptor VS OFF adaptor
disp(pdiff);

end