function PMF = sampleBayesianLogisticPMF(pdf2d,T,log2k,pcol,NB,x)

%% Last updated on Mar 21 2020 by RT for annotation
% This function plots logistic psychometric function by resampling from
% posterior distribution, with 68% credible intervals.

if nargin<6
    x = -1.5:0.01:1.5;
end
if nargin<5
    NB = 1000;
end
if nargin<4
    pcol = [1,0,0];
end
% Because posterior is discrete, we just 'cheat' by extending it to 1D...
pdf2d = pdf2d/sum(pdf2d(:));
cdf1d = cumsum(pdf2d(:));
PMF = [];
logisticPMF = @(x,T,k)(1./(1+exp(-k*(x-T))));
%figure; hold on;
for bb = 1:NB
    [~,Ind1d] = min(abs(cdf1d-rand));
    [i,j] = ind2sub(size(pdf2d),Ind1d);
    thisT = T(j); 
    thisk = 2^log2k(i);
    %plot(x,logisticPMF(x,thisT,thisk),'Color',[0.7,0.7,0.9]); 
    PMF(bb,:) = logisticPMF(x,thisT,thisk);
end
xe = [x,x(end:-1:1)];
p95 = prctile(PMF,84);
p05 = prctile(PMF,16);
ye = [p95,p05(end:-1:1)];
hold on
h=fill(xe,ye,pcol,'linestyle','none','FaceAlpha',0.25);
h.FaceColor = pcol;
hAnnotation = get(h,'Annotation');
if ~iscell(hAnnotation)
    hAnnotation = {hAnnotation};
end

for ii = 1:length(h)
    hLegendEntry = get(hAnnotation{ii},'LegendInformation');
    set(hLegendEntry,'IconDisplayStyle','off');
end
g=plot(x,mean(PMF));
g.Color = pcol;
end