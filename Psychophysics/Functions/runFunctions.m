filename = 'Subject0_2022.06.28_1406.mat';
[numTrials, posXbyTrial, paramsbyTrial, coherences, directions, responses, responseTimes] = matrices(filename);
dThetabyTrial = dThetabyTrial(posXbyTrial);
threshold = 0.001; cutTime = 15;
removeSaccades = removeSaccades(dThetabyTrial, threshold, cutTime);
deltaThetabyCoherence = deltaThetabyCoherence(numTrials, removeSaccades, coherences, directions);
prightbyCoherence = prightbyCoherence(responses, coherences, directions);
skewnessbyCoherence = skewnessbyCoherence(numTrials, dThetabyTrial, coherences, directions);