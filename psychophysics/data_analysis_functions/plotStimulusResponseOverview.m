function Q = plotStimulusResponseOverview(Q,param)

    Q.stimVelocity = Q.directions; % deg/s
    trials = 1; % trials to display traces and distributions for
    
    % Plot displacement/velocity traces
    x_sv = (1:Q.stimDuration*Q.updateRate)/Q.updateRate; % x values for stimulus velocity
    x_rd = (0:Q.stimDuration*1000-1)/1000; % x values for response displacement
    x_rv = (1:Q.stimDuration*1000-1)/1000; % x values for response velocity
    
    for ii = trials
        figure;
        % stimulus velocity
        subplot(3,1,1);
        plot(x_sv,Q.stimVelocity(ii,:));
        title('Stimulus Velocity');
        xlabel('t (s)');
        ylabel('velocity (deg/s)');
        yline(0,'--');
        % response displacement
        subplot(3,1,2);
        plot(x_rd,Q.eyeDisplacement(ii,1:(Q.stimDuration*1000)));
        title('Eye Displacement');
        xlabel('t (s)');
        ylabel('displacement (deg)');
        yline(0,'--');
        % response velocity (eye velocity without saccades)
        subplot(3,1,3);
        plot(x_rv,Q.eyeVelocityWithoutSaccades(ii,1:(Q.stimDuration*1000-1)));
        title('Eye Velocity');
        xlabel('t (s)');
        ylabel('velocity (deg/s)');
        yline(0,'--');
        sgtitle(['Trial ',num2str(ii)]);
    end
    
    % Plot distributions
    figure;
    % stimulus velocity
    subplot(2,1,1);
    histogram(Q.stimVelocity);
    yline(0,'--');
    title('Stimulus Velocity');
    xlabel('velocity (deg/s)');
    ylabel('frequency');
    % response velocity (eye velocity without saccades)
    subplot(2,1,2);
    histogram(Q.eyeVelocityWithoutSaccades);
    yline(0,'--');
    title('Response Velocity');
    xlabel('velocity (deg/s)');
    ylabel('frequency');
    sgtitle('Distribution');

    % Plot autocorrelation

    %{
    % obtain corrFrames
    if length(param.corrTime) > 1
        corrFrames = length(param.corrTime);
    elseif param.corrTime == 0 
        corrFrames = 5;
    else
        corrFrames = param.corrTime/1000*Q.updateRate;
    end
    %}

    % obtain stimulus velocity autocorrelation for each trial
    maxlag = 90; % this is the number of frames; convert to ms for response velocity measured at 1000 Hz

    Q.stimulusAutocorrelation = [];
    for jj = 1:Q.numTrials
        g = Q.stimVelocity(jj,2:end);
        [Q.stimulusAutocorrelation(jj,:),lags1] = xcorr(g,g,maxlag,'normalized');
    end

    %{
    % replace NaN values in response velocity (DOWNSAMPLED eye velocity without saccades)
    Q.downSampledWithoutNaNs = NaN(Q.numTrials,Q.updateRate*Q.stimDuration-Q.numCoefficients-1);
    for kk = 1:Q.numTrials
        Q.downSampledWithoutNaNs(kk,:) = fillmissing(Q.downSampled(kk,Q.numCoefficients+2:Q.updateRate*Q.stimDuration),...
                                                     'linear','SamplePoints',Q.numCoefficients+2:Q.updateRate*Q.stimDuration);
    end
    % obtain response velocity (DOWNSAMPLED eye velocity without saccades) autocorrelation for each trial
    Q.responseAutocorrelation = [];
    for jj = 1:Q.numTrials
        g = Q.downSampledWithoutNaNs(jj,:);
        [Q.responseAutocorrelation(jj,:),lags2] = xcorr(g,g,maxlag,'normalized');
    end
    %}

    % replace NaN values in response velocity (eye velocity without saccades)
    Q.eyeVelocityWithoutSaccadesWithoutNaNs = NaN(size(Q.eyeVelocityWithoutSaccades));
    for kk = 1:Q.numTrials
        Q.eyeVelocityWithoutSaccadesWithoutNaNs(kk,:) = fillmissing(Q.eyeVelocityWithoutSaccades(kk,:),'linear','SamplePoints',1:size(Q.eyeVelocityWithoutSaccades,2));
    end
    % obtain response velocity (eye velocity without saccades) autocorrelation for each trial
    Q.responseAutocorrelation = [];
    for jj = 1:Q.numTrials
        g = Q.eyeVelocityWithoutSaccadesWithoutNaNs(jj,:);
        [Q.responseAutocorrelation(jj,:),lags2] = xcorr(g,g,round(maxlag*1000/Q.updateRate),'normalized');
    end

    % Plot mean autocorrelations
    figure;
    % stimulus velocity
    plot(lags1/Q.updateRate,mean(Q.stimulusAutocorrelation,1),'LineWidth',2); % convert lag (frames) to secs
    hold on
    % response velocity (eye velocity without saccades)
    plot(lags2/1000,mean(Q.responseAutocorrelation,1),'LineWidth',2); % convert lag (ms) to secs
    hold off

    xline(0,'--');
    yline(0,'--');
    legend('stimulus velocity','response velocity');
    legend('Location','northeast');
    xlabel('lag (s)');
    ylabel('autocorrelation');
    title('Autocorrelation');

end