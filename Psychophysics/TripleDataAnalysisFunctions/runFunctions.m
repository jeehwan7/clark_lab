% fileName = '.mat';

% convert edf files to mat files (EXECUTE ONLY ONCE)
% edf2matErrors = convertFiles(fileName);

% create matrices for data (EXECUTE ONLY ONCE)
% createMatrices(fileName);

% load parameters
load('matrices.mat');

Q = struct;

Q.numTrials = numTrials; % total number of trials
Q.eyePosition = eyePosition; % x axis: eye position (at each ms), y axis: trial number
Q.directions = directions; % x axis: stimulus direction, y axis: trial number
Q.coherences = coherences; % x axis: stimulus coherence, y axis: trial number
Q.parities = parities; % x axis: stimulus parity, y axis: trial number
Q.types = types; % x axis: stimulus type, y axis: trial number
Q.responses = responses; % x axis: psychometric response, y axis: trial number

% Create eye velocity
Q = createEyeVelocity(Q,param.viewDist,screenWidthpx,pxPermm);

% threshold and cut time for saccades
threshold = 50; % deg/s
cutTime = 15; % ms

% Create eye velocity without saccades
Q = removeSaccades(Q, threshold, cutTime);

% symmetrize data
Q = symmetrize(Q);

% Create logical arrays
Q = createLogicalArrays(Q);

% Calculate NaN percentage for each trial (eye velocity without saccades)
Q = NaNPercentage(Q);

% Replace NaN values
Q = replaceNaNs(Q,2);

% Plot eye position
Q = plotEyePosition(Q,screenWidthpx);

% Plot eye velocity
Q = plotEyeVelocity(Q);

% Plot eye velocity without saccades
Q = plotEyeVelocityWithoutSaccades(Q);

% Plot eye displacement
Q = plotEyeDisplacement(Q);

% Create P(Right)
Q = createPright(Q);

% Plot P(Right)
Q = plotPright(Q);
