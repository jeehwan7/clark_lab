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
% plotSuccess = plotPosX(numTrials, coherences, posXbyTrial);

% create dTheta/dt by Trial
dThetabyTrial = createDThetabyTrial(posXbyTrial);

% PLOT dTheta/dt by Trial
% plotSuccess = plotDTheta(numTrials, coherences, dThetabyTrial);

% set threshold and cut time to remove saccades
param.threshold = 40; % (deg/s)
param.cutTime = 15; % (ms)
% create dTheta by Trial without saccades
dThetabyTrialWithoutSaccades = removeSaccades(dThetabyTrial, param.threshold, param.cutTime);

% PLOT dTheta/dt by Trial without Saccades
plotSuccess = plotDTheta(numTrials, coherences, dThetabyTrialWithoutSaccades);

%{

% DeltaTheta is unreliable because trials with more saccades have more NaN values, resulting in smaller DeltaTheta.

% create and PLOT DeltaTheta by Type
[deltaThetabyCoherence, deltaThetabyTriple, tripleType] = createDeltaThetabyType(numTrials, dThetabyTrialWithoutSaccades, coherences, directions, responses, types, parities);

% create and PLOT Mean DeltaTheta by Type
meanDeltaTheta = createMeanDeltaThetabyType(deltaThetabyTriple, tripleType);

%}

% calculate mean dtheta/dt and mean mean dtheta/dt from start to finish
param.start = 120; % ms
param.finish = 200; % ms

% create and PLOT Mean dTheta/dt by Type
[meanDThetabyCoherence, meanDThetabyTriple, tripleType] = createMeanDThetabyType(param.start, param.finish, numTrials, dThetabyTrialWithoutSaccades, coherences, directions, responses, types, parities);

% create and PLOT Mean of Mean dTheta/dt by Type
meanMeanDTheta = createMeanMeanDThetabyType(param.start, param.finish, meanDThetabyTriple, tripleType);

% create and PLOT P(Right) by Type
prightbyType = createPrightbyType(responses, directions, types, parities);