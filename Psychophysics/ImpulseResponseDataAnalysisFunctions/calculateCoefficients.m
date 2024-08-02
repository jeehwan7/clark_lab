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

    Q.directionsNormalized = NaN(Q.numTrials,Q.updateRate*Q.stimDuration);
    Q.downSampledNormalized = NaN(Q.numTrials,Q.updateRate*Q.stimDuration);

    % normalize velocities of each trial
    for jj = 1:Q.numTrials
        Q.downSampledNormalized(jj,:) = Q.downSampled(jj,:) - mean(Q.downSampled(jj,:),'omitnan');
    end
    % normalize directions of each trial
    for jj = 1:Q.numTrials
        Q.directionsNormalized(jj,:) = Q.directions(jj,:) - mean(Q.directions(jj,:),'omitnan');
    end

    % build the matrix for regression
    S = NaN(Q.numTrials*Q.updateRate*Q.stimDuration,Q.numCoefficients); % all the stimulus velocities (deg/frame)
    R = NaN(Q.numTrials*Q.updateRate*Q.stimDuration,1); % all the response velocities (deg/s)
    for kk = 1:Q.numTrials
        for ll = 1:(Q.updateRate*Q.stimDuration)
            if ~isnan(Q.downSampledNormalized(kk,ll))
                R((kk-1)*Q.updateRate*Q.stimDuration+ll) = Q.downSampledNormalized(kk,ll);
                S((kk-1)*Q.updateRate*Q.stimDuration+ll,:) = flip(Q.directionsNormalized(kk,(ll-Q.numCoefficients):(ll-1)));
            end
        end
    end

    % clean up R and S
    index = ~isnan(R);
    R = R(index); % remove NaN values in R
    S = S(index,:); % make S match with R

    Q.coefficients = S\R; % calculate coefficients

    % calculate trial by trial coefficients (for standard error)
    Q.tbtCoefficients = NaN(Q.numTrials,Q.numCoefficients);

    for kk = 1:Q.numTrials
        tempS = NaN(Q.updateRate*Q.stimDuration,Q.numCoefficients); % all the stimulus velocities (deg/frame)
        tempR = NaN(Q.updateRate*Q.stimDuration,1); % all the response velocities (deg/s)

        for ll = 1:(Q.updateRate*Q.stimDuration)
            if ~isnan(Q.downSampledNormalized(kk,ll))
                tempR(ll) = Q.downSampledNormalized(kk,ll);
                tempS(ll,:) = flip(Q.directionsNormalized(kk,(ll-Q.numCoefficients):(ll-1)));
            end
        end

        % clean up tempR and tempS
        index = ~isnan(tempR);
        tempR = tempR(index); % remove NaN values in tempR
        tempS = tempS(index,:); % make tempS match with tempR

        Q.tbtCoefficients(kk,:) = tempS\tempR;
    end

    % obtain standard error using unfiltered trial by trial coefficients
    s = std(Q.tbtCoefficients,0,1);
    sem = s/sqrt(Q.numTrials);

    % plot unfiltered impulse response
    x = (1:Q.numCoefficients)*1000/Q.updateRate;
    figure;
    patch([x fliplr(x)],[rot90(Q.coefficients)-sem  fliplr(rot90(Q.coefficients)+sem)],[0 0.4470 0.7410],'FaceAlpha',0.2,'EdgeColor','none');
    hold on
    plot(x,Q.coefficients,'LineWidth',2);
    hold off
    yline(0,'--');
    title('Overall Impulse Response');
    xlabel('-t (ms)');
    ylabel('weighting');

    % filter coefficients
    b = [1/4 1/2 1/4];
    a = 1;
    Q.coefficientsFiltered = filtfilt(b,a,Q.coefficients);

    % filter trial by trial coefficients
    for ii = 1:Q.numTrials
        Q.tbtCoefficientsFiltered(ii,:) = filtfilt(b,a,Q.tbtCoefficients(ii,:));
    end

    % obtain standard error using filtered trial by trial coefficients
    s = std(Q.tbtCoefficientsFiltered,0,1);
    sem = s/sqrt(Q.numTrials);    

    % plot filtered impulse response
    x = (1:Q.numCoefficients)*1000/Q.updateRate;
    figure;
    patch([x fliplr(x)],[rot90(Q.coefficientsFiltered)-sem  fliplr(rot90(Q.coefficientsFiltered)+sem)],[0 0.4470 0.7410],'FaceAlpha',0.2,'EdgeColor','none');
    hold on
    plot(x,Q.coefficientsFiltered,'LineWidth',2);
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
    Rhat = S*Q.coefficients;
    Q.rsqCoefficients = 1 - sum((R - Rhat).^2)/sum((R - mean(R)).^2);