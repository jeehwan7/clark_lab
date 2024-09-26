function Q = createNaNPercentage(Q)

    adapTemp = NaN(Q.numTrials, 2);
    stimTemp = NaN(Q.numTrials, 2);

    adapDuration = Q.adapDuration*1000;
    stimDuration = Q.stimDuration*1000;

    for ii = 1:Q.numTrials
        adapTemp(ii,1) = ii;
        adapTemp(ii,2) = round(sum(isnan(Q.adapEyeXVelwithoutSaccades(ii,1:adapDuration-1)))/(adapDuration-1)*100);

        stimTemp(ii,1) = ii;
        stimTemp(ii,2) = round(sum(isnan(Q.stimEyeXVelwithoutSaccades(ii,1:stimDuration-1)))/(stimDuration-1)*100);
    end

    Q.adapNaNPercentage = array2table(adapTemp,'VariableNames',{'Trial Number','NaN Percentage'});
    Q.stimNaNPercentage = array2table(stimTemp,'VariableNames',{'Trial Number','NaN Percentage'});

end