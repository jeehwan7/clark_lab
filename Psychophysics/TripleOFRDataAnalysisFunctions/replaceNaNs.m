function Q = replaceNaNs(Q,option)
    
    duration = Q.stimDuration*1000;
    
    Q.NaNlessEyeVelocityWithoutSaccades = NaN(Q.numTrials,duration);
    
    % Pairwise
    
    for ii = 1:length(Q.coherenceVals)

        % pick out relevant trials according to coherence
        A = Q.eyeVelocityWithoutSaccades(Q.symmetrizedCoherences==Q.coherenceVals(ii),:);
       
        if option == 1
            A = option1(A);
        elseif option == 2
            A = option2(A);
        end

        Q.NaNlessEyeVelocityWithoutSaccades(Q.symmetrizedCoherences==Q.coherenceVals(ii),:) = A;

    end

    % Triple

    % pick out relevant trials according to type and parity
    B = Q.symmetrizedEyeVelocityWithoutSaccades(Q.isConvergingPositive,:);
    C = Q.symmetrizedEyeVelocityWithoutSaccades(Q.isConvergingNegative,:);
    D = Q.symmetrizedEyeVelocityWithoutSaccades(Q.isDivergingPositive,:);
    E = Q.symmetrizedEyeVelocityWithoutSaccades(Q.isDivergingNegative,:);
    
    if option == 1
        B = option1(B);
        C = option1(C);
        D = option1(D);
        E = option1(E);
    elseif option == 2
        B = option2(B);
        C = option2(C);
        D = option2(D);
        E = option2(E);
    end

    Q.NaNlessEyeVelocityWithoutSaccades(Q.isConvergingPositive,:) = B;
    Q.NaNlessEyeVelocityWithoutSaccades(Q.isConvergingNegative,:) = C;
    Q.NaNlessEyeVelocityWithoutSaccades(Q.isDivergingPositive,:) = D;
    Q.NaNlessEyeVelocityWithoutSaccades(Q.isDivergingNegative,:) = E;

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