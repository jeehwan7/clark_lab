function Q = plotEyeVelocityWithoutSaccades(Q) % Individual Trials
    
    adapDuration = Q.adapDuration*1000;
    stimDuration = Q.stimDuration*1000;

    % adaptation
    figure;
    for ii = 1:Q.numTrials
        x = 1:adapDuration-1;
        y = Q.adapEyeXVelwithoutSaccades(ii,:);
        plot(x,y);
        hold on
    end
    hold off
    title('Eye X Velocity without Saccades (Adaptation)');
    xline(0,'--');
    xlabel('t (ms)');
    ylabel('x velocity (deg/s)');

    % stimulus
    figure;
    for ii = 1:Q.numTrials
        x = 1:stimDuration-1;
        y = Q.stimEyeXVelwithoutSaccades(ii,:);
        plot(x,y);
        hold on
    end
    hold off
    title('Eye X Velocity without Saccades (Stimulus)');
    xline(0,'--');
    xlabel('t (ms)');
    ylabel('x velocity (deg/s)');
