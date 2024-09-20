function Q = plotEyeVelocity(Q) % Individual Trials

    adapDuration = Q.adapDuration*1000;
    stimDuration = Q.stimDuration*1000;

    % adaptation
    figure;
    for ii = 1:Q.numTrials
        x = 1:adapDuration-1;
        y = Q.adapEyeXVel(ii,1:adapDuration-1);     
        plot(x,y);
        hold on
    end
    hold off
    title('Raw Eye X Velocity (Adaptation)');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('x velocity (deg/s)');

    % stimulus
    figure;
    for ii = 1:Q.numTrials
        x = 1:stimDuration-1;
        y = Q.stimEyeXVel(ii,1:stimDuration-1);     
        plot(x,y);
        hold on
    end
    hold off
    title('Raw Eye X Velocity (Stimulus)');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('x velocity (deg/s)');