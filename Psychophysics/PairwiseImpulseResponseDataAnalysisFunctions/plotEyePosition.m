function Q = plotEyePosition(Q,screenWidthpx)

    duration = Q.stimDuration*1000;
    x = 0:(duration-1);

    figure;
    for ii = 1:Q.numTrials
        y = Q.eyePosition(ii,1:duration)-screenWidthpx/2;
        plot(x,y);
        hold on
    end
    hold off
    title('Raw Eye Position');
    xlabel('t (ms)');
    ylabel('x position (px)');
    
end