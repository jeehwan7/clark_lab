function plotSuccess = plotPosX(numTrials, coherences, eyeMovementMatrix)

    figure;
    for ii = 1:numTrials
        color = [0.8500, 0.3250, 0.0980].*abs(coherences(ii));
        x = 0:1000;
        y = eyeMovementMatrix(ii,1:1001)-960;
        plot(x,y,'Color',color);
        hold on
    end
    hold off
    title('X Position');
    xlabel('t (ms)');
    ylabel('X Position (px)');
    plotSuccess = 1;
end