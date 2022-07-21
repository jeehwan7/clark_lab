fileName = '.mat';

%{

% convert edf files to mat files (EXECUTE ONLY ONCE)
edf2matErrors = convertFiles(fileName);

%}

% create matrices for data
[numTrials, posXbyTrial, paramsbyTrial, coherences, directions, responses, responseTimes] = createMatrices(fileName);

% PLOT posX by Trial
plotSuccess = plotPosX(numTrials, coherences, posXbyTrial); 

% create dTheta by Trial
dThetabyTrial = createDThetabyTrial(posXbyTrial);

% PLOT dTheta by Trial
plotSuccess = plotDTheta(numTrials, coherences, dThetabyTrial);

% set threshold and cut time to remove saccades
param.threshold = 57; % (deg/s)
param.cutTime = 15; % (ms)
% create dTheta by Trial without saccades
dThetabyTrialWithoutSaccades = removeSaccades(dThetabyTrial, param.threshold, param.cutTime);

% PLOT dTheta by Trial without Saccades
plotSuccess = plotDTheta(numTrials, coherences, dThetabyTrialWithoutSaccades);

% create and PLOT DeltaTheta by Coherence
deltaThetabyCoherence = createDeltaThetabyCoherence(numTrials, dThetabyTrialWithoutSaccades, coherences, directions, responses);

%{
% set interval and range for DeltaTheta by Coherence by Time Interval
param.interval = 1; % factor of range
param.range = 200; % max 1000
% create and PLOT DeltaTheta by Coherence by Time Interval
deltaThetabyCoherencebyTimeInterval = createDeltaThetabyCoherencebyTimeInterval(param.interval, param.range, deltaThetabyCoherence, dThetabyTrialWithoutSaccades, coherences, directions);
%}

% create and PLOT P(Right) by Coherence
prightbyCoherence = createPrightbyCoherence(responses, coherences, directions);

% crate and PLOT Skewness by coherence
skewnessbyCoherence = createSkewnessbyCoherence(numTrials, dThetabyTrial, coherences, directions);