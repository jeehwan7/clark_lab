function [betaEstimate,tMean, pdf2d, x, log2Beta]=QuestBetaAnalysisLogistic(q,printOutput,log2BetaGuess,log2BetaSd,log2BetaGrain,log2BetaSteps,plotpdf)

%% Modified to accomodate logistic pmf by RT based on QuestBetaAnalysis
% You can find the original distribution here: 
% http://psychtoolbox.org/docs/Quest
% Changed lines are commented as MODIFIED

% betaEstimate=QuestBetaAnalysis(q,[fid]);
% 
% Analyzes the quest function with beta as a free parameter. It prints (in
% the file or files pointed to by fid) the mean estimates of alpha (as
% logC) and beta. Gamma is left at whatever value the user fixed it at.
% 
% Note that normalization of the pdf, by QuestRecompute, is disabled because it
% would need to be done across the whole q vector. Without normalization,
% the pdf tends to underflow at around 1000 trials. You will have some warning
% of this because the printout mentions any values of beta that were dropped 
% because they had zero probability. Thus you should keep the number of trials
% under around 1000, to avoid the zero-probability warnings.
% 
% See Quest.

% Denis Pelli 5/6/99
% 8/23/99 dgp streamlined the printout
% 8/24/99 dgp add sd's to printout
% 10/13/04 dgp added comment explaining 1/beta

% Modified by Ryosuke Tanaka (Oct. 28 2019)
if nargin<1 || nargin>7
	error('Usage: QuestBetaAnalysis(q,[fid],logBetaGuess,logBetaGuessSd,logBetaGrain,logBetaSteps)')
end
if nargin<7
    plotpdf = 0;
end
if nargin<6
    log2BetaSteps = 23;
end
if nargin < 5
    log2BetaGrain = 0.25;
end
if nargin < 4
    log2BetaSd = 0;
end
if nargin < 3
    log2BetaGuess = 3;
end
if nargin<2
	printOutput=1;
end
if printOutput
    fprintf('Now re-analyzing with both threshold and beta as free parameters. ...\n');
	fprintf(1,'T 	    +-sd  log2Beta	 +-sd	 gamma\n');
end
for i=1:length(q(:))
	[betaEstimate(i),tMean(i), pdf2d(:,:,i), x(i,:), log2Beta(i,:)]=QuestBetaAnalysis1(q(i),printOutput,log2BetaGuess,log2BetaSd,log2BetaGrain,log2BetaSteps,plotpdf);
end
return

function [betaEstimate,tMean, pdf2d, x, log2Beta]=QuestBetaAnalysis1(q,printOutput,log2BetaGuess,log2BetaSd,log2BetaGrain,log2BetaSteps,plotpdf)
% The range of beta to be explored is determined here: can be changed
% (or made more flexible by adding more input arguments)
log2Beta = (1:log2BetaSteps)*log2BetaGrain;
log2Beta = log2Beta - mean(log2Beta) + log2BetaGuess;
beta2 = 2.^log2Beta;
for i=1:log2BetaSteps
	q2(i)=q;
	q2(i).beta=beta2(i);
end
% Recalculate pdf from scratch, using all the data so far, with different
% values of beta. i.e. obtaining 2d posterior distribution of T and beta
% Note that, prior disribution of beta is uniform distribution here
% which can be changed
qq=QuestRecomputeLogistic(q2);

% Reorganize 2d pdf in a matrix
pdf2d = [];
for ii = 1:log2BetaSteps
    pdf2d(ii,:) = qq(ii).pdf;
end

% multiply prior distribution of log2Beta if nonzero log2BetaSd is given
if log2BetaSd~=0
    log2BetaPrior = exp(-(log2Beta-log2BetaGuess).^2 / (2*log2BetaSd^2))/sqrt(2*pi*log2BetaSd^2);
    pdf2d = pdf2d .* repmat(log2BetaPrior',[1,size(pdf2d,2)]);
end

% Calculate mean and sd of t and beta
% note that x is around tGuess
x = q.x + q.tGuess;
tMean = sum(x.*sum(pdf2d,1))/sum(pdf2d(:));
tSd   = sqrt(sum(((x-tMean).^2).*sum(pdf2d,1))/sum(pdf2d(:)));

log2BetaMean = sum(log2Beta'.*sum(pdf2d,2))/sum(pdf2d(:));
log2BetaSd   = sqrt(sum(((log2Beta'-log2BetaMean).^2).*sum(pdf2d,2))/sum(pdf2d(:)));
% visualization
if plotpdf
    subplot(1,2,1);
    mesh(x,log2Beta,pdf2d);
    xlabel('Intensity'); ylabel('Log Slope'); zlabel('Posterior PDF'); drawnow;
    subplot(1,2,2);
    theta = mod(now*1000000,360);
    plot(x,1./(1+exp(-2^log2BetaMean*(x-tMean))),'Color',([sind(theta),sind(theta+120),sind(theta+240)]+1)/2); hold on
    xlabel('Intensity'); ylabel('P(yes)');
end
if printOutput
	fprintf(1,'%5.2f	%5.2f	%4.1f	%4.1f	%6.3f\n',tMean,tSd,log2BetaMean,log2BetaSd,q.gamma);
end
betaEstimate=2^log2BetaMean;
