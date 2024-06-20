function Q = calculateCoefficients(Q, results, directions)

    original = [nan(Q.numTrials,1) Q.eyeVelocityWithoutSaccades];
    numCoefficients = 60;

    Q.downSampledIndex = NaN(Q.numTrials,Q.updateRate*Q.stimDuration); % index (in ms)
    Q.downSampled = NaN(Q.numTrials,Q.updateRate*Q.stimDuration); % average across 17 ms around index

    for ii = 1:Q.numTrials % for each trial

        timeElapsed = results(ii).indivFrameInfo{:,"timeElapsed"}; % extract the time elapsed at the start of each frame
    
        for jj = 1:(Q.updateRate*Q.stimDuration) % want to find the number of ms passed at the start of each frame
            if jj == 1
                Q.downSampledIndex(ii,jj) = 0; % no time has passed at the start of the 1st frame
            else
                Q.downSampledIndex(ii,jj) = round(timeElapsed(jj)*1000); % otherwise time has passed
            end
        end
        
        for kk = 1:(Q.updateRate*Q.stimDuration) % want to find the average velocity at the start of each frame
            if kk <= (numCoefficients + 1)
                Q.downSampled(ii,kk) = NaN; % the first direction is NaN and we want at least "numCoefficients" preceding directions
            else
                Q.downSampled(ii,kk) = mean(original(ii,(Q.downSampledIndex(ii,kk)-8):(Q.downSampledIndex(ii,kk)+8))); % average across 17 ms
            end
        end
    end

    % calculate the mean of each trial (of what's left over a.k.a not NaN)
    averages = NaN(Q.numTrials,1);
    for ii = 1:Q.numTrials
        averages(ii) = mean(Q.downSampled(ii,:),'omitnan');
    end

    % normalize each trial
    for jj = 1:Q.numTrials
        Q.downSampled(jj,:) = Q.downSampled(jj,:) - averages(jj);
    end

    % build the matrix for regression
    Q.D = NaN(Q.numTrials*Q.updateRate*Q.stimDuration,numCoefficients); % all the directions
    Q.V = NaN(Q.numTrials*Q.updateRate*Q.stimDuration,1); % all the velocities
    for kk = 1:Q.numTrials
        for ll = 1:(Q.updateRate*Q.stimDuration)
            if ~isnan(Q.downSampled(kk,ll))
                Q.V((kk-1)*(size(Q.downSampled,2))+ll) = Q.downSampled(kk,ll);
                Q.D((kk-1)*(size(Q.downSampled,2))+ll,:) = flip(directions(kk,(ll-numCoefficients):(ll-1)));
            end
        end
    end


    Q.V = Q.V(~isnan(Q.V)); % remove NaN values

    rows = [];
    for ii = 1:size(Q.D,1)
        if sum(isnan(Q.D(ii,:))) == numCoefficients % if every single value in the row is NaN
            rows = [ii rows]; % record that row
        end
    end

    Q.D(rows,:) = []; % remove those rows

    Q.coefficients = Q.D\Q.V; % calculate the coefficients

    % repeat the process for each trial to obtain standard error
    Q.tbtcoefficients = NaN(Q.numTrials,numCoefficients); % trial by trial coefficients

    for kk = 1:Q.numTrials
        tempD = NaN(Q.updateRate*Q.stimDuration,numCoefficients); % all the directions
        tempV = NaN(Q.updateRate*Q.stimDuration,1); % all the velocities

        for ll = 1:(Q.updateRate*Q.stimDuration)
            if ~isnan(Q.downSampled(kk,ll))
                tempV(ll) = Q.downSampled(kk,ll);
                tempD(ll,:) = flip(directions(kk,(ll-numCoefficients):(ll-1)));
            end
        end

        tempV = tempV(~isnan(tempV));

        rows = [];
        for ii = 1:size(tempD,1)
            if sum(isnan(tempD(ii,:))) == numCoefficients
                rows = [ii rows];
            end
        end

        tempD(rows,:) = [];

        Q.tbtcoefficients(kk,:) = tempD\tempV;
    end

    s = std(Q.tbtcoefficients,0,1);
    sem = s/sqrt(Q.numTrials);

    %{
    % filter
    windowSize = 5;
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    z = filtfilt(b,a,Q.coefficients);
    %}
    

    x = (1:numCoefficients)*1000/60;
    figure;
    patch([x fliplr(x)],[rot90(Q.coefficients)-sem  fliplr(rot90(Q.coefficients)+sem)],[0 0.4470 0.7410],'FaceAlpha',0.2,'EdgeColor','none');
    hold on
    plot(x,Q.coefficients);
    hold off
    yline(0,'--');
    title('Impulse Response');
    xlabel('-t (ms)');
    ylabel('weighting');

    figure;
    plot((1:numCoefficients)*1000/60,cumsum(Q.coefficients));
    yline(0,'--');
    title('Cumulative Sum');
    xlabel('-t (ms)');