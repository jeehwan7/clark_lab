function Q = createNaNPercentage(Q)

    A = NaN(Q.numTrials, 2);

    for i = 1:Q.numTrials
        A(i,1) = i;
        A(i,2) = round(sum(isnan(Q.eyeVelocityWithoutSaccades(i,1:1000)))/10);
    end

    Q.NaNPercentage = array2table(A,'VariableNames',{'Trial Number','NaN Percentage'});

end