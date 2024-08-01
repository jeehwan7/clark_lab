function Q = plotStimulusResponseOverview(Q,param)

    Q.stimVelocity = Q.directions*Q.updateRate; % deg/s
    trials = 1; % trials to display traces and distributions for
    
    % plot traces
    x_sv = (1:Q.updateRate*Q.stimDuration)/Q.updateRate*1000; % x for stimulus velocity
    x_rd = 0:(Q.stimDuration*1000-1); % x for response displacement
    x_rv = 1:(Q.stimDuration*1000-1); % x for response velocity
    
    for ii = trials
        figure;
        % stimulus velocity
        subplot(3,1,1);
        plot(x_sv,Q.stimVelocity(ii,:));
        title('Stimulus Velocity');
        xlabel('t (ms)');
        ylabel('velocity (deg/s)');
        yline(0,'--');
        % response displacement
        subplot(3,1,2);
        plot(x_rd,Q.eyeDisplacement(ii,1:(Q.stimDuration*1000)));
        title('Eye Displacement');
        xlabel('t (ms)');
        ylabel('displacement (deg)');
        yline(0,'--');
        % response velocity (eye velocity without saccades)
        subplot(3,1,3);
        plot(x_rv,Q.eyeVelocityWithoutSaccades(ii,1:(Q.stimDuration*1000-1)));
        title('Eye Velocity without Saccades');
        xlabel('t (ms)');
        ylabel('velocity (deg/s)');
        yline(0,'--');
        sgtitle(['Trial ',num2str(ii),' Traces']);
    end
    
    % plot distributions
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
    title('Eye Velocity Without Saccades');
    xlabel('velocity (deg/s)');
    ylabel('frequency');
    sgtitle('Distributions');

    % plot autocorrelation
    % obtain corrFrames
    if length(param.corrTime) > 1
        corrFrames = length(param.corrTime);
    elseif param.corrTime == 0 
        corrFrames = 5;
    else
        corrFrames = param.corrTime/1000*Q.updateRate;
    end
    % obtain stimulus velocity autocorrelation for each trial
    Q.stimulusAutocorrelation = [];
    for jj = 1:Q.numTrials
        g = Q.stimVelocity(jj,2:end);
        [Q.stimulusAutocorrelation(jj,:),Q.lags] = xcorr(g,g,corrFrames*3,'normalized');
    end
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
        [Q.responseAutocorrelation(jj,:),Q.lags] = xcorr(g,g,corrFrames*3,'normalized');
    end
    % plot mean autocorrelations
    figure;
    % stimulus velocity
    plot(Q.lags/Q.updateRate*1000,mean(Q.stimulusAutocorrelation,1),'LineWidth',2); % convert lags (frames) to ms
    hold on
    % response velocity (DOWNSAMPLED eye velocity without saccades)
    plot(Q.lags/Q.updateRate*1000,mean(Q.responseAutocorrelation,1),'LineWidth',2); % convert lags (frames) to ms
    hold off

    xline(0,'--');
    yline(0,'--');
    legend('stimulus velocity','downsampled eye velocity without saccades');
    legend('Location','southeast');
    xlabel('lag (ms)');
    ylabel('autocorrelation');
    title('Autocorrelations');

end