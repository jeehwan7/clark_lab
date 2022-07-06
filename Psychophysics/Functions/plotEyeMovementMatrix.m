function plotSuccess = plotEyeMovementMatrix(numTrials, coherences, eyeMovementMatrix)

    figure;
    for ii = 1:numTrials
        color = [0.8500, 0.3250, 0.0980].*abs(coherences(ii));
        x = 1:1000;
        y = eyeMovementMatrix(ii,1:1000);
        plot(x,y,'Color',color);
        hold on
    end
    hold off
    title('d\theta');
    xlabel('t (ms)');
    ylabel('d\theta (rad)');
    plotSuccess = 1;
end