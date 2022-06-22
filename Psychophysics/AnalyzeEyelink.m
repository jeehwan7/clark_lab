% trialNumber = 1;

% fileName = ['Trial',num2str(trialNumber),'.edf'];

% trial = Edf2Mat(fileName);

stimulusStartTime = trial.Events.Messages.time(find(trial.Events.Messages.info == 'STIMULUS_START'));

timeposX = zeros(size(trial.Samples.time,1),2);
timeposX(1:size(timeposX,1),1) = trial.Samples.time;
timeposX(1:size(timeposX,1),2) = trial.Samples.posX;



% stimulusEndTime = trial.Events.Messages.time(find(trial.Events.Messages.info == 'STIMULUS_END'));

% find(trial.Samples.time == stimulusStartTime)
