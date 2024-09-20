function Q = removeSaccades(Q, threshold, cutTime)

    adapDuration = Q.adapDuration*1000; % s to ms
    stimDuration = Q.stimDuration*1000; % s to ms

    Q.adapEyeXVelwithoutSaccades = removeSaccadesLocal(Q,adapeyeXVel,Q.numTrials,adapDuration,threshold,cutTime);
    Q.stimEyeXVelwithoutSaccades = removeSaccadesLocal(Q.stimEyeXVel,Q.numTrials,stimDuration,threshold,cutTime);

end

function output = removeSaccadesLocal(input,numTrials,duration,threshold,cutTime)
    
    for ii = 1:numTrials
        
        % find index of all local extrema
        maximaLogical = islocalmax(input(ii,:),'FlatSelection','all');
        minimaLogical = islocalmin(input(ii,:),'FlatSelection','all');
        extremaIndex = find(or(maximaLogical,minimaLogical)); % find returns index of nonzero elements
        
        % find index of local extrema whose absolute values exceed threshold
        thresholdLogical = abs(input(ii,extremaIndex))>threshold;
        thresholdIndex = extremaIndex(thresholdLogical);
        
        % invalidate values within [-cutTime,+cutTime]
        for pp = -cutTime:cutTime
            ix = thresholdIndex+pp;
            ix(ix<1) = 1;
            ix(ix>duration-1) = duration-1;
            input(ii,ix) = NaN(1,size(ix,2));
        end
        
        % extrema at bounds
        if abs(input(ii,1))>threshold
            input(ii,1:cutTime) = NaN(1,cutTime);
        end
        if abs(input(ii,duration-1))>threshold
            input(ii,duration-cutTime:duration-1) = NaN(1,cutTime);
        end
    end

    output = input(:,1:duration-1); % cut off at stimulus duration

end