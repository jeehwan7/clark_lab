function Q = replaceNaNs(Q,option)
    
    duration = Q.stimDuration*1000;

    Q.NaNlessEyeVelocityWithoutSaccades = NaN(Q.numTrials,duration);
    
    for ii = 1:length(Q.correlationVals)
        
        % pick out relevant trials according to correlation, cut off at stimulus duration
        A = Q.eyeVelocityWithoutSaccades(Q.symmetrizedCorrelations==Q.correlationVals(ii),1:duration);
       
        if option == 1
            A = option1(A);
        elseif option == 2
            A = option2(A);
        end

        Q.NaNlessEyeVelocityWithoutSaccades(Q.symmetrizedCorrelations==Q.correlationVals(ii),:) = A;

    end

end

% Option 1: replace NaN values with 0
function X = option1(X)
    X(isnan(X)) = 0;
end

% Option 2: replace NaN values with mean of non-NaN values at that ms
function X = option2(X)
    m = mean(X,1,'omitnan'); % array of all the mean values at each ms
    for jj = 1:size(X,2)
        col = X(:,jj);
        col(isnan(col)) = m(jj);
        X(:,jj) = col;
    end
end