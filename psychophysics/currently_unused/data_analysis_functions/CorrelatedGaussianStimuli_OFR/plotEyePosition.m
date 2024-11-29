function Q = plotEyePosition(Q,screenWidthpx)

    duration = Q.stimDuration*1000;
    x = 0:duration;

    figure;
    color = colormap(copper(Q.numColors));
    for ii = 1:Q.numTrials
        y = Q.eyePosition(ii,1:duration+1)-screenWidthpx/2;
        plot(x,y,'Color',color(uint8(Q.correlations(ii)/Q.correlationGCD+1),:));
        hold on
    end
    hold off
    title('Gaussian Field Eye Position');
    xlabel('t (ms)');
    ylabel('x position (px)');

end