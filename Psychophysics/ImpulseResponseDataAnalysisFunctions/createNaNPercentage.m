function Q = createNaNPercentage(Q)

    A = NaN(Q.numTrials, 2);
    duration = Q.stimDuration*1000;

    for i = 1:Q.numTrials
        A(i,1) = i;
        A(i,2) = round(sum(isnan(Q.eyeVelocityWithoutSaccades(i,1:duration-1)))/(duration-1)*100);
    end

    Q.NaNPercentage = array2table(A,'VariableNames',{'Trial Number','NaN Percentage'});

end