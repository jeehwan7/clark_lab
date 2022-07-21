function plotSuccess = plotPosX(numTrials, coherences, eyeMovementMatrix)

    figure;
    for ii = 1:numTrials
        if ~isnan(coherences(ii)) % coherence stimuli
            color = [0.8500, 0.3250, 0.0980].*abs(coherences(ii)); % between copper and black
        elseif isnan(coherences(ii)) % triple stimuli
            color = [0.3010 0.7450 0.9330]; % all blue
        end
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