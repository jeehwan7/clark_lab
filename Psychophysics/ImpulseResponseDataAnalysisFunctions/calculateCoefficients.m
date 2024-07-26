function Q = calculateCoefficients(Q, results)

    original = [nan(Q.numTrials,1) Q.eyeVelocityWithoutSaccades]; % column of NaNs because there is no velocity in the beginning
    Q.numCoefficients = Q.updateRate/2;
    range = floor(1000/Q.updateRate/2); % averaging velocity from [index-range, index+range]

    Q.downSampledIndex = NaN(Q.numTrials,Q.updateRate*Q.stimDuration); % index (in ms)
    Q.downSampled = NaN(Q.numTrials,Q.updateRate*Q.stimDuration); % average velocity across 2*range ms around index

    for ii = 1:Q.numTrials % for each trial

        timeElapsed = results(ii).indivFrameInfo{:,"timeElapsed"}; % extract the time elapsed (in secs) by the start of each frame
    
        for jj = 1:(Q.updateRate*Q.stimDuration) % want to find the number of ms passed at the start of each frame
            if jj == 1
                Q.downSampledIndex(ii,jj) = 0; % no time has passed at the start of the 1st frame
            else
                Q.downSampledIndex(ii,jj) = round(timeElapsed(jj)*1000); % otherwise calculate time passed (multiply by 1000 because s -> ms)
            end
        end
        
        for kk = 1:(Q.updateRate*Q.stimDuration) % want to find the average velocity at the start of each frame
            if kk <= (Q.numCoefficients + 1)
                Q.downSampled(ii,kk) = NaN; % the first direction is NaN and we want at least "Q.numCoefficients" preceding directions
            else
                Q.downSampled(ii,kk) = mean(original(ii,(Q.downSampledIndex(ii,kk)-range):(Q.downSampledIndex(ii,kk)+range))); % average across 2*range ms around index
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
    D = NaN(Q.numTrials*Q.updateRate*Q.stimDuration,Q.numCoefficients); % all the directions
    V = NaN(Q.numTrials*Q.updateRate*Q.stimDuration,1); % all the velocities
    for kk = 1:Q.numTrials
        for ll = 1:(Q.updateRate*Q.stimDuration)
            if ~isnan(Q.downSampled(kk,ll))
                V((kk-1)*Q.updateRate*Q.stimDuration+ll) = Q.downSampled(kk,ll);
                D((kk-1)*Q.updateRate*Q.stimDuration+ll,:) = flip(Q.directions(kk,(ll-Q.numCoefficients):(ll-1)));
            end
        end
    end

    V = V(~isnan(V)); % remove NaN values

    rows = [];
    for ii = 1:size(D,1)
        if sum(isnan(D(ii,:))) == Q.numCoefficients % if every single value in the row is NaN
            rows = [ii rows]; % record that row
        end
    end

    D(rows,:) = []; % remove those rows

    Q.coefficients = D\V; % calculate coefficients

    % calculate trial by trial coefficients (for standard error)
    Q.tbtCoefficients = NaN(Q.numTrials,Q.numCoefficients);

    for kk = 1:Q.numTrials
        tempD = NaN(Q.updateRate*Q.stimDuration,Q.numCoefficients); % all the directions
        tempV = NaN(Q.updateRate*Q.stimDuration,1); % all the velocities

        for ll = 1:(Q.updateRate*Q.stimDuration)
            if ~isnan(Q.downSampled(kk,ll))
                tempV(ll) = Q.downSampled(kk,ll);
                tempD(ll,:) = flip(Q.directions(kk,(ll-Q.numCoefficients):(ll-1)));
            end
        end

        tempV = tempV(~isnan(tempV));

        rows = [];
        for ii = 1:size(tempD,1)
            if sum(isnan(tempD(ii,:))) == Q.numCoefficients
                rows = [ii rows];
            end
        end

        tempD(rows,:) = [];

        Q.tbtCoefficients(kk,:) = tempD\tempV;
    end

    % filter coefficients
    b = [1/4 1/2 1/4];
    a = 1;
    z = filtfilt(b,a,Q.coefficients);

    % filter trial by trial coefficients
    for ii = 1:Q.numTrials
        Q.tbtCoefficientsFiltered(ii,:) = filtfilt(b,a,Q.tbtCoefficients(ii,:));
    end

    % obtain standard error using filtered trial by trial coefficients
    s = std(Q.tbtCoefficientsFiltered,0,1);
    sem = s/sqrt(Q.numTrials);    

    % plot impulse response
    x = (1:Q.numCoefficients)*1000/Q.updateRate;
    figure;
    patch([x fliplr(x)],[rot90(z)-sem  fliplr(rot90(z)+sem)],[0 0.4470 0.7410],'FaceAlpha',0.2,'EdgeColor','none');
    hold on
    plot(x,z,'LineWidth',2);
    hold off
    yline(0,'--');
    title('Overall Impulse Response');
    xlabel('-t (ms)');
    ylabel('weighting');

    % plot cumsum
    figure;
    plot((1:Q.numCoefficients)*1000/Q.updateRate,filtfilt(b,a,cumsum(Q.coefficients)));
    yline(0,'--');
    title('Cumulative Sum');
    xlabel('-t (ms)');

    % calculate rsq
    VCalc = D*Q.coefficients;
    Q.rsq = 1 - sum((V - VCalc).^2)/sum((V - mean(V)).^2);