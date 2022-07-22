fileName = '.mat';

%{
% convert edf files to mat files (EXECUTE ONLY ONCE)
edf2matErrors = convertFiles(fileName);
%}

% create matrices for data
[numTrials, posXbyTrial, paramsbyTrial, coherences, directions, responses, responseTimes] = createMatrices(fileName);

% PLOT posX by trial
plotSuccess = plotPosX(numTrials, coherences, posXbyTrial); 

% create dtheta/dt by trial
dThetabyTrial = createDThetabyTrial(posXbyTrial);

% PLOT dtheta/dt by trial
plotSuccess = plotDTheta(numTrials, coherences, dThetabyTrial);

% set threshold and cut time for removing saccades
param.threshold = 57; % (deg/s)
param.cutTime = 15; % (ms)
% create dtheta by trial without saccades
dThetabyTrialWithoutSaccades = removeSaccades(dThetabyTrial, param.threshold, param.cutTime);

% PLOT dtheta/dt by trial without saccades
plotSuccess = plotDTheta(numTrials, coherences, dThetabyTrialWithoutSaccades);

% invalid trial if number of NaN values is above threshold
param.nanThreshold = 500;

% create and PLOT deltatheta by coherence
deltaThetabyCoherence = createDeltaThetabyCoherence(param.nanThreshold, numTrials, dThetabyTrialWithoutSaccades, coherences, directions, responses);

% set interval and range for deltatheta by coherence by time interval
param.interval = 1; % factor of range
param.range = 200; % max 1000
% create and PLOT deltatheta by coherence by time interval
deltaThetabyCoherencebyTimeInterval = createDeltaThetabyCoherencebyTimeInterval(param.interval, param.range, deltaThetabyCoherence, dThetabyTrialWithoutSaccades, coherences, directions);

% create and PLOT p(right) by coherence
prightbyCoherence = createPrightbyCoherence(responses, coherences, directions);

% create and PLOT skewness by coherence
skewnessbyCoherence = createSkewnessbyCoherence(numTrials, dThetabyTrial, coherences, directions);