fileName = '.mat';

% convert edf files to mat files (EXECUTE ONLY ONCE)
% edf2matError = convertFile(fileName);

load(fileName);

Q = struct;

Q.subjectID = subjectID;

Q.updateRate = param.framesPerSec; % Hz
Q.checkSize = param.degPerSquare; % deg

Q.adapDuration = param.adapDuration; % sec
Q.stimDuration = param.stimDuration; % sec

Q.numTrials = param.numTrials;

Q.adapVelocities = adapVelocities; % x axis: adaptation velocity (deg/s), y axis: trial number
Q.stimVelocities = stimVelocities; % x axis: stimulus velocity (deg/s), y axis: trial number

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

% Plot eye displacement
Q = plotEyeDisplacement(Q);

% Plot eye velocity
Q = plotEyeVelocity(Q);

% Plot eye velocity without saccades
Q = plotEyeVelocityWithoutSaccades(Q);

% Calculate and Plot coefficients
Q = calculateCoefficients(Q,durationInfo);

%{
% Plot comparison (between actual velocity (downsampled) and predicted velocity)
Q = plotComparison(Q,param);

% Plot traces, distributions, and autocorrelations
Q = plotStimulusResponseOverview(Q,param);

% Calculate and plot coefficients via velocity difference (stimulus - response)
% Q = calculateCoefficientsViaDifference(Q);

% Calculate FWHM
Q = calculateFWHM(Q);
%}