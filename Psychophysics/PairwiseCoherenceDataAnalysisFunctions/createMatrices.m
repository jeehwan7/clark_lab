function createMatrices(fileName)
    
    % LOAD PARAMETERS
    load(fileName,'param');

    load(fileName,'screenWidthpx');
    load(fileName,'pxpermm');
    
    % LOAD RESULTS
    load(fileName,'results');
    numTrials = height(struct2table(results));

    % CREATE MATRICES

    % param.stimDuration is in seconds, multiply by 1000 to convert to ms
    % add 10 ms at the end as a buffer in case EyeLink overrecorded
    % (that shouldn't really happen with correct stimulus timing)
    eyePosition = nan(numTrials,param.stimDuration*1000+10);
    
    for ii = 1:numTrials
        if isfile(['MatFiles/Trial',num2str(ii),'.mat'])
            load(['MatFiles/Trial',num2str(ii),'.mat']);
            % find stimulus start time
            stimulusStartTime = data.Events.Messages.time(find(strcmp(data.Events.Messages.info,'STIMULUS_START')));
            % find stimulus end time
            stimulusEndTime = data.Events.Messages.time(find(strcmp(data.Events.Messages.info,'STIMULUS_END')));
            % build eyePosition matrix
            eyePosition(ii,1:1+stimulusEndTime-stimulusStartTime) = data.Samples.posX(find(data.Samples.time == stimulusStartTime):find(data.Samples.time == stimulusEndTime));
        end
    end
    
    % the following matrices depend on stimulus type
    coherences = vertcat(results.coherence);
    directions = vertcat(results.direction);
    responses = vertcat(results.response);
    
%     % triple only
%     types = {results(:).type};
%     parities = vertcat(results.parity);

    save('matrices.mat','param','pxpermm','screenWidthpx','numTrials','eyePosition','coherences','directions','responses');

end