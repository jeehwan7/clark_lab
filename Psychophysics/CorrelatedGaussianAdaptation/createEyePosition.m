function Q = createEyePosition(Q)

    % multiply by 1000 to convert from seconds to ms
    adapDuration = Q.adapDuration*1000;
    stimDuration = Q.stimDuration*1000;

    % add 10 columns at the end as a buffer
    Q.adapEyeXPos = nan(Q.numTrials,adapDuration+10);
    Q.stimEyeXPos = nan(Q.numTrials,stimDuration+10);

    for ii = 1:Q.numTrials
        if isfile(['MatFiles/','sub',num2str(Q.subjectID),'.mat'])
            load(['MatFiles/','sub',num2str(Q.subjectID),'.mat']);
            if ii ~= 1
                % find adaptation start time
                adapStartTime = data.Events.Messages.time(find(strcmp(data.Events.Messages.info,['adap',num2str(ii),'_start'])));
                % find adaptation end time
                adapEndTime = data.Events.Messages.time(find(strcmp(data.Events.Messages.info,['adap',num2str(ii),'_end'])));
                
                Q.adapEyeXPos(ii,1:1+adapEndTime-adapStartTime) = data.Samples.posX(find(data.Samples.time==adapStartTime):find(data.Samples.time==adapEndTime));
            end

            % find stimulus start time
            stimStartTime = data.Events.Messages.time(find(strcmp(data.Events.Messages.info,['stim',num2str(ii),'_start'])));
            % find stimulus end time
            stimEndTime = data.Events.Messages.time(find(strcmp(data.Events.Messages.info,['stim',num2str(ii),'_end'])));

            Q.stimEyeXPos(ii,1:1+stimEndTime-stimStartTime) = data.Samples.posX(find(data.Samples.time==stimStartTime):find(data.Samples.time==stimEndTime));
        end
    end

end