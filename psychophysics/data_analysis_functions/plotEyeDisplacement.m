function Q = plotEyeDisplacement(Q)

    duration = Q.stimDuration*1000;
    x = 0:(duration-1);

    figure;
    for ii = 1:Q.numTrials
        y = Q.eyeDisplacement(ii,1:duration);
        plot(x,y);
        hold on
    end
    hold off
    yline(0,'--');
    title('Eye Displacement');
    xlabel('t (ms)');
    ylabel('eye displacement (deg)');
    
end