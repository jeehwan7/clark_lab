fileName = '.mat';

% convert edf files to mat files (EXECUTE ONLY ONCE)
% edf2matErrors = convertFiles(fileName);

load(fileName);

Q = struct;

Q.subjectID = subjectID;
Q.updateRate = param.framesPerSec;
Q.checkSize = param.degPerSquare; % deg
Q.stimDuration = param.stimDuration; % sec

Q.numTrials = height(struct2table(results)); % total number of trials

% the following matrices depend on stimulus type
Q.directions = vertcat(results.direction); % x axis: stimulus direction, y axis: trial number
Q.correlations = vertcat(results.correlation); % x axis: stimulus correlation, y axis: trial number
Q.responses = vertcat(results.response); % x axis: psychometric response, y axis: trial number

% list of correlation values
Q.correlationVals = [-0.5;-0.4;-0.3;-0.2;-0.1;-0.05;-0.025;0;0.025;0.05;0.1;0.2;0.3;0.4;0.5];
Q.correlationGCD = gcd(sym(Q.correlationValues));
Q.numColors = max(Q.correlationValues)/Q.correlationGCD+1;

% Create eye position
Q = createEyePosition(Q);

% Create eye velocity
Q = createEyeVelocity(Q,param.viewDist,screenWidthpx,pxPermm);

% threshold and cut time for saccades
threshold = 50; % deg/s
cutTime = 15; % ms

% Create eye velocity without saccades
Q = removeSaccades(Q,threshold,cutTime);

% Symmetrize data
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

% Plot Displacement Z Score
Q = plotDisplacementZScore(Q);

% Plot Velocity Z Score
Q = plotVelocityZScore(Q,param.framesPerSec,c);



% Plot Spectrogram
Q = plotSpectrogram(Q);
