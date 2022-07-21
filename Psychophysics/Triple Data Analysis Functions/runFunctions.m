fileName = '.mat';

%{

% convert edf files to mat files (EXECUTE ONLY ONCE)
edf2matErrors = convertFiles(fileName);

% create matrices for data (EXECUTE ONLY ONCE)
[numTrials, posXbyTrial] = createMatrices(fileName);

%}

% load parameters
load('matrices.mat');

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

% create and PLOT DeltaTheta by Type
[deltaThetabyCoherence, deltaThetabyTriple, tripleType] = createDeltaThetabyType(numTrials, dThetabyTrialWithoutSaccades, coherences, directions, responses, types, parities);

% create and PLOT Mean DeltaTheta by Type
meanDeltaTheta = createMeanDeltaTheta(deltaThetabyTriple, tripleType);

% create and PLOT P(Right) by Type
prightbyType = createPrightbyType(responses, directions, types, parities);