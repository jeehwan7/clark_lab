function Q = plotEyePosition(Q,screenWidthpx)

    figure;
    color = colormap(copper(Q.numColors));
    for ii = 1:Q.numTrials
        if ~isnan(Q.coherences(ii))
            x = 0:length(Q.eyePosition(ii,:))-1;
            y = Q.eyePosition(ii,:)-screenWidthpx/2;
            plot(x,y,'Color',color(uint8(Q.coherences(ii)/Q.coherenceGCD+1),:));
        end
        hold on
    end
    hold off
    title('Pairwise Correlation Eye Position');
    xlabel('t (ms)');
    ylabel('x axis position (px)');

end