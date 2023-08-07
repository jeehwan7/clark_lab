function Q = plotEyePosition(Q,screenWidthpx)

    figure;
    color = colormap(copper(Q.numColors));
    for ii = 1:Q.numTrials
        x = 0:length(Q.eyePosition(ii,:))-1;
        y = Q.eyePosition(ii,:)-screenWidthpx/2;
        plot(x,y,'Color',color(uint8(Q.correlations(ii)/Q.correlationGCD+1),:));
        hold on
    end
    hold off
    title('Gaussian Field Eye Position');
    xlabel('t (ms)');
    ylabel('x axis position (px)');

end