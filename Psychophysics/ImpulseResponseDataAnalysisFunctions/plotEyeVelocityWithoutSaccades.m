function Q = plotEyeVelocityWithoutSaccades(Q)
    
    duration = Q.stimDuration*1000;
    x = 1:(duration-1);

    figure;
    for ii = 1:Q.numTrials
        y = Q.eyeVelocityWithoutSaccades(ii,:);

        plot(x,y);
        hold on           
    end
    hold off
    title('Eye Velocity (Individual Trials, Saccades Removed)');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye velocity (deg/s)');

    