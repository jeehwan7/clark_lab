function Q = replaceNaNs(Q,option)
    
    Q.NaNlessEyeVelocityWithoutSaccades = NaN(Q.numTrials,1000);
    
    % Pairwise
    
    coherences = [-1;-0.2;0;0.2;1];
    
    for ii = 1:length(coherences)

        % pick out relevant trials according to coherence, cut off at 1000 ms
        A = Q.eyeVelocityWithoutSaccades(Q.symmetrizedCoherences==coherences(ii),1:1000);
       
        if option == 1
            A = option1(A);
        elseif option == 2
            A = option2(A);
        end

        Q.NaNlessEyeVelocityWithoutSaccades(Q.symmetrizedCoherences==coherences(ii),:) = A;

    end

    % Triple

    % pick out relevant trials according to type and parity, cut off at 1000 ms
    B = Q.eyeVelocityWithoutSaccades(Q.isConvergingPositive,1:1000);
    C = Q.eyeVelocityWithoutSaccades(Q.isConvergingNegative,1:1000);
    D = Q.eyeVelocityWithoutSaccades(Q.isDivergingPositive,1:1000);
    E = Q.eyeVelocityWithoutSaccades(Q.isDivergingNegative,1:1000);
    
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