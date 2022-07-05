function removeSaccades = removeSaccades(dThetabyTrial, threshold, cutTime)

    removeSaccades = dThetabyTrial;
    
    for aa = 1:size(removeSaccades,1)
        % find all local minima and maxima
        index = find(or(islocalmax(removeSaccades(aa,:),'FlatSelection','all'),(islocalmin(removeSaccades(aa,:),'FlatSelection','all'))));
        % find the ones whose absolute values exceed the threshold
        index = index(find(abs(removeSaccades(aa,index))>threshold));
        % remove all the values from cut time to the left to cut time to the right
        for pp = -cutTime:cutTime
            newIndex = index+pp;
            newIndex(newIndex<1) = 1;
            newIndex(newIndex>1000) = 1000;
            removeSaccades(aa,newIndex) = NaN(1,size(newIndex,2));
        end
        % in case there is a discontinuous spike at the start or the end
        if abs(removeSaccades(aa,1))>threshold
            removeSaccades(aa,1:cutTime) = NaN(1,cutTime);
        end
        if abs(removeSaccades(aa,1000))>threshold
            removeSaccades(aa,1001-cutTime:1000) = NaN(1,cutTime);
        end
    end

end