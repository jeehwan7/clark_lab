function Q = plotEyeVelocity(Q)

    duration = Q.stimDuration*1000;
    x = 1:(duration-1);

    % Individual Trials
    figure;
    for ii = 1:Q.numTrials
        y = Q.eyeVelocity(ii,1:duration-1);     
        plot(x,y);
        hold on
    end
    hold off
    title('Eye Velocity (Individual Trials, Saccades Included)');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye velocity (deg/s)');