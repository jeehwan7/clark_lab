function Q = replaceNaNs(Q,option)
    
    Q.NaNlessEyeVelocityWithoutSaccades = NaN(Q.numTrials,1000);
    
    coherences = [-1;-0.9;-0.8;-0.7;-0.6;-0.5;-0.4;-0.3;-0.2;-0.1;0;0.1;0.2;0.3;0.4;0.5;0.6;0.7;0.8;0.9;1];
    
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

end