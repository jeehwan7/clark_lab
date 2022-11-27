function [numTrials] = createMatrices(fileName)

    %% LOAD RESULTS
    load(fileName,'results');
    numTrials = height(struct2table(results));

    %% CREATE MATRICES
    eyePosition = nan(numTrials,1004);
    
    for ii = 1:numTrials
        if isfile(['MatFiles/Trial',num2str(ii),'.mat'])
            load(['MatFiles/Trial',num2str(ii),'.mat']);
            stimulusStartTime = data.Events.Messages.time(find(strcmp(data.Events.Messages.info,'STIMULUS_START')));
            stimulusEndTime = data.Events.Messages.time(find(strcmp(data.Events.Messages.info,'STIMULUS_END')));
            eyePosition(ii,1:1+stimulusEndTime-stimulusStartTime) = data.Samples.posX(find(data.Samples.time == stimulusStartTime):find(data.Samples.time == stimulusEndTime));
        end
    end
       
    coherences = vertcat(results.coherence);
    directions = vertcat(results.direction);
    responses = vertcat(results.response);
    responseTimes = vertcat(results.responseTime);
    
%     % triple only
%     types = {results(:).type};
%     parities = vertcat(results.parity);

    save('matrices.mat','numTrials','eyePosition','coherences','directions','responses','responseTimes');

end