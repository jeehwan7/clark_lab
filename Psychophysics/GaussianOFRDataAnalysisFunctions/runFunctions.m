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

% list of correlation values
Q.correlationVals = unique(Q.correlations.*Q.directions);
Q.correlationGCD = double(gcd(sym(Q.correlationVals)));
Q.numColors = max(Q.correlationVals)/Q.correlationGCD+1;

% Create eye position
Q = createEyePosition(Q);

% Create eye velocity
Q = createEyeVelocity(Q,param.viewDist,screenWidthpx,pxPermm);

% threshold and cut time for saccades
threshold = 20; % deg/s
cutTime = 15; % ms

% Create eye velocity without saccades
Q = removeSaccades(Q,threshold,cutTime);

% Symmetrize data
Q = symmetrize(Q);

% Calculate NaN percentage for each trial (eye velocity without saccades)
Q = createNaNPercentage(Q);

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

% Plot Displacement Z Score
Q = plotDisplacementZScore(Q);

% Plot Velocity Z Score
Q = plotVelocityZScore(Q);