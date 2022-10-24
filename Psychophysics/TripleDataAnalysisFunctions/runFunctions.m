% fileName = '.mat';

% convert edf files to mat files (EXECUTE ONLY ONCE)
% edf2matErrors = convertFiles(fileName);

% create matrices for data (EXECUTE ONLY ONCE)
% [numTrials] = createMatrices(fileName);

% load parameters
load('matrices.mat');

Q = struct;

Q.eyePosition = eyePosition; % x axis: eye position, y axis: trial number
Q.numTrials = numTrials; % total number of trials
Q.directions = directions; % x axis: direction, y axis: trial number
Q.coherences = coherences; % x axis: coherence, y axis: trial number
Q.parities = parities; % x axis: parity, y axis: trial number
Q.types = types; % x axis: trial number, y axis: type
Q.responses = responses; % x axis: psychometric response, y axis: trial number

% PLOT Eye Position
Q = plotEyePosition(Q);

% CREATE Eye Velocity
Q = createEyeVelocity(Q); % x axis: eye velocity, y axis: trial number

% PLOT Eye Velocity
Q = plotEyeVelocity(Q);

% Threshold and Cut Time to Remove Saccades
param.threshold = 38; % deg/s
param.cutTime = 15; % ms

% CREATE Eye Velocity without Saccades
Q = removeSaccades(Q, param.threshold, param.cutTime);

% PLOT Eye Velocity without Saccades
Q = plotEyeVelocityWithoutSaccades(Q);

% Symmetrize Data
Q = symmetrize(Q);

% Start and Finish Time for Mean Eye Velocity
param.start = 80; % ms
param.finish = 120; % ms

param.nanThreshold = 0.2; % between 0 and 1

% CREATE Mean Eye Velocity for each Trial
Q = createTrialMeanEyeVelocity(Q, param.start, param.finish, param.nanThreshold);

% PLOT Mean Eye Velocity per Trial
Q = plotTrialMeanEyeVelocity(Q);

% CREATE Mean Eye Velocity per Type (Triple)
Q = createTypeMeanEyeVelocity(Q);

% PLOT Mean Eye Velocity per Type (Triple)
Q = plotTypeMeanEyeVelocity(Q);

% CREATE P(right)
Q = createPright(Q);

% PLOT P(Right)
Q = plotPright(Q);