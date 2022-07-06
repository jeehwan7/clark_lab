fileName = 'Subject0_2022.06.28_1406.mat';
% create matrices for data
[numTrials, posXbyTrial, paramsbyTrial, coherences, directions, responses, responseTimes] = createMatrices(fileName);

% create dTheta by Trial
dThetabyTrial = createDThetabyTrial(posXbyTrial);

% PLOT dTheta by Trial
plotSuccess = plotEyeMovementMatrix(numTrials, coherences, dThetabyTrial);

% set threshold and cut time to remove saccades
threshold = 0.001; cutTime = 15;
% create dTheta by Trial without saccades
dThetabyTrialWithoutSaccades = removeSaccades(dThetabyTrial, threshold, cutTime);

% PLOT dTheta by Trial without Saccades
plotSuccess = plotEyeMovementMatrix(numTrials, coherences, dThetabyTrialWithoutSaccades);

% create and PLOT DeltaTheta by Coherence
deltaThetabyCoherence = createDeltaThetabyCoherence(numTrials, dThetabyTrialWithoutSaccades, coherences, directions, responses);

% set interval and range for DeltaTheta by Coherence by Time Interval
interval = 1; % factor of range
range = 200; % max 1000
% create and PLOT DeltaTheta by Coherence by Time Interval
% deltaThetabyCoherencebyTimeInterval = createDeltaThetabyCoherencebyTimeInterval(interval, range, deltaThetabyCoherence, dThetabyTrialWithoutSaccades, coherences, directions);

% create and PLOT P(Right) by Coherence
prightbyCoherence = createPrightbyCoherence(responses, coherences, directions);

% crate and PLOT Skewness by coherence
skewnessbyCoherence = createSkewnessbyCoherence(numTrials, dThetabyTrial, coherences, directions);