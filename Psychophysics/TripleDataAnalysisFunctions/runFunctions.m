%{
fileName = '.mat';

% convert edf files to mat files (EXECUTE ONLY ONCE)
edf2matErrors = convertFiles(fileName);

% create matrices for data (EXECUTE ONLY ONCE)
[numTrials, posXbyTrial] = createMatrices(fileName);
%}

% load parameters
load('matrices.mat');

% PLOT posX by trial
% plotSuccess = plotPosX(numTrials, coherences, posXbyTrial);

% create dtheta/dt by trial
dThetabyTrial = createDThetabyTrial(posXbyTrial);

% PLOT dtheta/dt by trial
% plotSuccess = plotDTheta(numTrials, coherences, dThetabyTrial);

% set threshold and cut time for removing saccades
param.threshold = 55; % (deg/s)
param.cutTime = 15; % (ms)
% create dtheta/dt by trial without saccades
dThetabyTrialWithoutSaccades = removeSaccades(dThetabyTrial, param.threshold, param.cutTime);

% PLOT dtheta/dt by trial without saccades
plotSuccess = plotDTheta(numTrials, coherences, dThetabyTrialWithoutSaccades);

% a trial with too many NaN values should be excluded
param.nanThreshold = 500;
%{
% deltatheta is unreliable because more saccades -> more NaN values -> smaller deltatheta

% create and PLOT deltatheta by type
[deltaThetabyCoherence, deltaThetabyTriple, tripleType] = createDeltaThetabyType(param.nanThreshold, numTrials, dThetabyTrialWithoutSaccades, coherences, directions, responses, types, parities);

% create and PLOT mean deltatheta by type
meanDeltaTheta = createMeanDeltaThetabyType(deltaThetabyTriple, tripleType);
%}

% start and finish time for calculating mean dtheta/dt and mean of mean dtheta/dt
param.start = 80; % ms
param.finish = 120; % ms

% create and PLOT mean dtheta/dt by type
[meanDThetabyCoherence, meanDThetabyTriple, tripleType] = createMeanDThetabyType(param.nanThreshold, param.start, param.finish, numTrials, dThetabyTrialWithoutSaccades, coherences, directions, responses, types, parities);

% create and PLOT mean of mean dtheta/dt by type
meanMeanDTheta = createMeanMeanDThetabyType(param.start, param.finish, meanDThetabyTriple, tripleType);

% create and PLOT p(right) by type
prightbyType = createPrightbyType(responses, directions, types, parities);

% create and PLOT accumulative mean dtheta/dt by trial
accumulativeMeanDTheta = createAccumulativeMeanDThetabyTrial(param.nanThreshold, numTrials, dThetabyTrialWithoutSaccades, coherences, parities, types);

% PLOT dtheta/dt by type
plotSuccess = plotDThetabyType(numTrials, coherences, dThetabyTrial, types, parities);