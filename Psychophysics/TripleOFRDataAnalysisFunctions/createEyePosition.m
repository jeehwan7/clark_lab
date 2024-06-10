function Q = createEyePosition(Q)

    % Q.stimDuration is in sec, multiply by 1000 to convert to ms
    duration = Q.stimDuration*1000;

    Q.eyePosition = nan(Q.numTrials,duration+10); % add 10 ms at the end as a buffer

    for ii = 1:Q.numTrials
        if isfile(['MatFiles/Trial',num2str(ii),'.mat'])
            load(['MatFiles/Trial',num2str(ii),'.mat']);
            % find stimulus start time
            stimulusStartTime = data.Events.Messages.time(find(strcmp(data.Events.Messages.info,'STIMULUS_START')));
            % find stimulus end time
            stimulusEndTime = data.Events.Messages.time(find(strcmp(data.Events.Messages.info,'STIMULUS_END')));
            % build eyePosition matrix
            Q.eyePosition(ii,1:1+stimulusEndTime-stimulusStartTime) = data.Samples.posX(find(data.Samples.time==stimulusStartTime):find(data.Samples.time==stimulusEndTime));
        end
    end

end