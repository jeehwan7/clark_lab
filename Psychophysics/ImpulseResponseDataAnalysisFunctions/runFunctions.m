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
Q.directions = directions; % x axis: stimulus direction, y axis: trial number

% Create eye position
Q = createEyePosition(Q);

% Create eye velocity
Q = createEyeVelocity(Q,param.viewDist,screenWidthpx,pxPermm);

% threshold and cut time for saccades
threshold = 20; % deg/s
cutTime = 15; % ms

% Create eye velocity without saccades
Q = removeSaccades(Q,threshold,cutTime);

% Calculate NaN percentage for each trial (eye velocity without saccades)
Q = createNaNPercentage(Q);

% Plot eye position
Q = plotEyePosition(Q,screenWidthpx);

% Plot eye velocity
Q = plotEyeVelocity(Q);

% Plot eye velocity without saccades
Q = plotEyeVelocityWithoutSaccades(Q);

% Plot coefficients
Q = calculateCoefficients(Q,results);

% Plot coefficients by block
Q = calculateCoefficientsByBlock(Q,param);

% Plot comparison (between actual velocity (downsampled) and predicted velocity)
Q = plotComparison(Q);