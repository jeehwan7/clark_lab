function Q = plotEyePosition(Q,screenWidthpx)

    figure;
    color = colormap(copper(11)); % 11 because 11 coherences [0:0.1:1]
    for ii = 1:Q.numTrials
        if ~isnan(Q.coherences(ii))
            x = 0:length(Q.eyePosition(ii,:))-1;
            y = Q.eyePosition(ii,:)-screenWidthpx/2;
            plot(x,y,'Color',color(10*Q.coherences(ii)+1,:));
        end
        hold on
    end
    hold off
    title('Pairwise Correlation Eye Position');
    xlabel('t (ms)');
    ylabel('x axis position (px)');

end