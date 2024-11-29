function Q = removeSaccades(Q,threshold,cutTime)

    temp = Q.eyeVelocity;
    duration = Q.stimDuration*1000;
    
    for ii = 1:Q.numTrials
        
        % index of all local extrema
        maximaLogical = islocalmax(temp(ii,:),'FlatSelection','all');
        minimaLogical = islocalmin(temp(ii,:),'FlatSelection','all');
        extremaIndex = find(or(maximaLogical,minimaLogical)); % find returns index of nonzero elements
        
        % find all local extrema whose absolute values exceed threshold
        thresholdLogical = abs(temp(ii,extremaIndex))>threshold;
        thresholdIndex = extremaIndex(thresholdLogical);
        
        % invalidate values within [-cutTime,+cutTime]
        for pp = -cutTime:cutTime
            ix = thresholdIndex+pp;
            ix(ix<1) = 1;
            ix(ix>duration) = duration;
            temp(ii,ix) = NaN(1,size(ix,2));
        end
        
        % extrema at bounds
        if abs(temp(ii,1))>threshold
            temp(ii,1:cutTime) = NaN(1,cutTime);
        end
        if abs(temp(ii,duration))>threshold
            temp(ii,duration+1-cutTime:duration) = NaN(1,cutTime);
        end
    end

    Q.eyeVelocityWithoutSaccades = temp(:,1:duration); % cut off at stimulus duration
    
end