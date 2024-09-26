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
Q.coherences = vertcat(results.coherence); % x axis: stimulus coherence, y axis: trial number
Q.parities = vertcat(results.parity); % x axis: stimulus parity, y axis: trial number
Q.types = reshape({results(:).type},length({results(:).type}),1); % x axis: stimulus type, y axis: trial number
Q.responses = vertcat(results.response); % x axis: psychometric response, y axis: trial number

% list of coherence values
% Q.coherenceVals = [-1;-0.2;0;0.2;1];
Q.coherenceVals = unique(Q.coherences.*Q.directions);
Q.coherenceVals = Q.coherenceVals(~isnan(Q.coherenceVals));
Q.coherenceGCD = double(gcd(sym(Q.coherenceVals)));
Q.numColors = max(Q.coherenceVals)/Q.coherenceGCD+1;

% Create eye position
Q = createEyePosition(Q);

% Create eye velocity
Q = createEyeVelocity(Q,param.viewDist,screenWidthpx,pxPermm);

% threshold and cut time for saccades
threshold = 20; % deg/s
cutTime = 15; % ms

% Create eye velocity without saccades
Q = removeSaccades(Q, threshold, cutTime);

% symmetrize data
Q = symmetrize(Q);

% Create logical arrays
Q = createLogicalArrays(Q);

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

% Create P(Right)
Q = createPright(Q);

% Plot P(Right)
Q = plotPright(Q);

% Run t-test
Q = runTTest(Q);
