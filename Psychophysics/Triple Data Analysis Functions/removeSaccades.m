function dThetabyTrialWithoutSaccades = removeSaccades(dThetabyTrial, threshold, cutTime)

    dThetabyTrialWithoutSaccades = dThetabyTrial;
    
    for aa = 1:size(dThetabyTrialWithoutSaccades,1)
        % find all local minima and maxima
        index = find(or(islocalmax(dThetabyTrialWithoutSaccades(aa,:),'FlatSelection','all'),(islocalmin(dThetabyTrialWithoutSaccades(aa,:),'FlatSelection','all'))));
        % find the ones whose absolute values exceed the threshold
        index = index(find(abs(dThetabyTrialWithoutSaccades(aa,index))>threshold));
        % remove all the values from cut time to the left to cut time to the right
        for pp = -cutTime:cutTime
            newIndex = index+pp;
            newIndex(newIndex<1) = 1;
            newIndex(newIndex>1000) = 1000;
            dThetabyTrialWithoutSaccades(aa,newIndex) = NaN(1,size(newIndex,2));
        end
        % in case there is a discontinuous spike at the start or the end
        if abs(dThetabyTrialWithoutSaccades(aa,1))>threshold
            dThetabyTrialWithoutSaccades(aa,1:cutTime) = NaN(1,cutTime);
        end
        if abs(dThetabyTrialWithoutSaccades(aa,1000))>threshold
            dThetabyTrialWithoutSaccades(aa,1001-cutTime:1000) = NaN(1,cutTime);
        end
    end

end