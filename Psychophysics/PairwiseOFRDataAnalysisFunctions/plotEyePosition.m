function Q = plotEyePosition(Q,screenWidthpx)

    duration = Q.stimDuration*1000;
    x = 0:duration;

    figure;
    color = colormap(copper(Q.numColors));
    for ii = 1:Q.numTrials
        if ~isnan(Q.coherences(ii))
            y = Q.eyePosition(ii,1:duration+1)-screenWidthpx/2;
            plot(x,y,'Color',color(uint8(Q.coherences(ii)/Q.coherenceGCD+1),:));
        end
        hold on
    end
    hold off
    title('Pairwise Correlation Eye Position');
    xlabel('t (ms)');
    ylabel('x position (px)');
    
end