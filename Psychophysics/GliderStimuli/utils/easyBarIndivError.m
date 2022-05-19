function easyBarIndivError(M,E,varargin)

%% IMPORTANT: they changed properties of bar graphs at around Matlab R2017
%% So this could fail in older versions of matlab (runs fine in 2019b)
% Plot bar graphs with individual data points, with error bras around each
% data point.

if iscell(M)
    Mnew = nan(max(cellfun(@length,M)),length(M));
    for ii = 1:length(M)
        Mnew(1:length(M{ii}(:)),ii) = M{ii}(:);
    end
    M = Mnew;
end
% I don't know even if this works or not
if iscell(E)
    Enew = nan(max(cellfun(@length,E)),length(E));
    for ii = 1:length(E)
        Enew(1:length(E{ii}(:)),ii) = E{ii}(:);
    end
    E = Enew;
end

% If you provide E with the same size as M, E is interpreted as the length
% of error bar on each side (e.g. SEM)
if size(E,3) == 1
    Elen(:,:,1) = E;
    Elen(:,:,2) = E;
elseif size(E,3) == 2
    % If E has two numbers, it is interpreted as the ends of errorbars
    % (e.g. xx perctile point of pdf)
    Elen(:,:,1) = M-E(:,:,1);
    Elen(:,:,2) = E(:,:,2)-M;
end

doSignrank = 0;
numCol = size(M,2);
newFigure = 1;
scatterExpansionRatio = 4;

% plot colors
colors = colormap('lines');
colors = colors(1:numCol,:);
conditionNames = {};
connectPaired =  0;

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

if isempty(conditionNames)
    for ii=1:numCol
        conditionNames{ii} = ['condition #',num2str(ii)];
    end
end

if newFigure == 1
    MakeFigure;
end
meanM = nanmean(M,1);
semM  = nanstd(M,[],1)/sqrt(size(M,1));
% draw bars
b = bar(1:numCol,meanM,'LineStyle','none','FaceColor','flat'); hold on
% draw error bars
e = errorbar(1:numCol,meanM',semM','CapSize',0);
e.Color = [0,0,0];
e.Marker = 'none';
e.LineStyle = 'none';

% prepare scatter positions
sbar = scatterBar(M);
for ii = 1:size(sbar,3)
    sbar(:,1,ii) = (sbar(:,1,ii)-ii+1)*scatterExpansionRatio+ii-1;
end
% prepare statistics
pval = ones(numCol,1);

% connect paired data points
if connectPaired == 1
    % figure out the original order of the data
    correspMat = zeros(size(M));
    for ii = 1:size(M,2)
        for jj = 1:size(M,1)
            correspMat(jj,ii) = find(sbar(:,2,ii) == M(jj,ii));
        end
    end
    % reorder sbar
    for ii = 1:size(sbar,3)
        sbar(:,:,ii) = sbar(correspMat(:,ii),:,ii);
    end
    
    for ii = 1:size(sbar,1)
        plot(permute(sbar(ii,1,:),[3,1,2])+1,permute(sbar(ii,2,:),[3,1,2]),'color',[1,1,1]*0.8);
    end
end


% prettification
for ii = 1:numCol
    % change colors
    b.CData(ii,:) = (colors(ii,:)+1)/2; % make bars brighter
    % add individual data
    errorbar(sbar(:,1,ii)+1,sbar(:,2,ii),Elen(:,ii,1),Elen(:,ii,2),'CapSize',0,'LineStyle','none','Color',colors(ii,:));
    scatter(sbar(:,1,ii)+1,sbar(:,2,ii),40,'filled','MarkerFaceColor',colors(ii,:),'MarkerEdgeColor','none');
    if doSignrank==1
        pval(ii) = signrank(M(:,ii));
        text(ii,max(M(:))*1.2,num2str(pval(ii)),'HorizontalAlignment','center');
    end
end
xlim([0,numCol+1]);
ylim([min(0,min(M(:))),max(M(:))]*1.2);
box off
b.BaseLine.LineStyle = 'none';
PlotConstLine(0)
ConfAxis('tickX',1:numCol,'tickLabelX',conditionNames);
end
