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
    yline(0,'--');
    title('Eye Velocity without Saccades');   
    xlabel('t (ms)');
    ylabel('eye velocity (deg/s)');

    