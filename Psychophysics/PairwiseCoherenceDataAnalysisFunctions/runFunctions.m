% fileName = '.mat';

% convert edf files to mat files (EXECUTE ONLY ONCE)
% edf2matErrors = convertFiles(fileName);

% create matrices for data (EXECUTE ONLY ONCE)
% [numTrials] = createMatrices(fileName);

% load parameters
load('matrices.mat');

Q = struct;

Q.eyePosition = eyePosition; % x axis: eye position (at each ms), y axis: trial number
Q.numTrials = numTrials; % total number of trials
Q.directions = directions; % x axis: stimulus direction, y axis: trial number
Q.coherences = coherences; % x axis: stimulus coherence, y axis: trial number
% Q.parities = parities; % x axis: stimulus parity, y axis: trial number
% Q.types = types; % x axis: trial number, y axis: type
Q.responses = responses; % x axis: psychometric response, y axis: trial number

% PLOT eye position
Q = plotEyePosition(Q);

% CREATE eye velocity
Q = createEyeVelocity(Q); % x axis: eye velocity, y axis: trial number

% threshold and cut time for saccades
param.threshold = 50; % deg/s
param.cutTime = 15; % ms

% CREATE eye velocity without saccades
Q = removeSaccades(Q, param.threshold, param.cutTime);

% symmetrize data
Q = symmetrize(Q);

% CREATE logical arrays
Q = createLogicalArrays(Q);

% PLOT eye velocity
Q = plotEyeVelocity(Q);

% PLOT eye velocity without saccades
Q = plotEyeVelocityWithoutSaccades(Q);

% PLOT eye displacement
Q = plotEyeDisplacement(Q);

% CREATE P(Right)
Q = createPright(Q);

% PLOT P(Right)
Q = plotPright(Q);

% PLOT Z Score
updateRate = 30; % Hz
Q = plotDisplacementZScore(Q,updateRate);

% PLOT Velocity Z Score
Q = plotVelocityZScore(Q,updateRate);

% PLOT Spectogram
Q = plotSpectrogram(Q);