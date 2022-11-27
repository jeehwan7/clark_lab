function Q = removeSaccades(Q, threshold, cutTime)

    removeSaccades = Q.eyeVelocity;
    
    for ii = 1:size(removeSaccades,1)
        % find all local extrema
        index = find(or(islocalmax(removeSaccades(ii,:),'FlatSelection','all'),(islocalmin(removeSaccades(ii,:),'FlatSelection','all'))));
        % find all local extrema whose absolute values exceed threshold
        index = index(find(abs(removeSaccades(ii,index))>threshold));
        % invalidate values from -cut time to +cut time
        for pp = -cutTime:cutTime
            newIndex = index+pp;
            newIndex(newIndex<1) = 1;
            newIndex(newIndex>1000) = 1000;
            removeSaccades(ii,newIndex) = NaN(1,size(newIndex,2));
        end
        % extrema at bounds
        if abs(removeSaccades(ii,1))>threshold
            removeSaccades(ii,1:cutTime) = NaN(1,cutTime);
        end
        if abs(removeSaccades(ii,1000))>threshold
            removeSaccades(ii,1001-cutTime:1000) = NaN(1,cutTime);
        end
    end

    Q.eyeVelocityWithoutSaccades = removeSaccades;
    
end