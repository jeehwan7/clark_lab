function Q = plotEyeVelocity(Q)

    duration = Q.stimDuration*1000;
    x = 1:(duration-1);

    figure;
    for ii = 1:Q.numTrials
        y = Q.eyeVelocity(ii,1:duration-1);     
        plot(x,y);
        hold on
    end
    hold off
    yline(0,'--');
    title('Raw Eye Velocity');
    xlabel('t (ms)');
    ylabel('eye velocity (deg/s)');