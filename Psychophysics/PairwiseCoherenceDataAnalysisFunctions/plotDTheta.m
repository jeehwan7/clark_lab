function plotSuccess = plotDTheta(numTrials, coherences, eyeMovementMatrix)

    figure;
    for ii = 1:numTrials
            color = [0.8500, 0.3250, 0.0980].*abs(coherences(ii));
            x = 1:1000;
            y = eyeMovementMatrix(ii,1:1000);
            f = ones(1,10)/10;
            index = find(~isnan(y));
            plot(x(index),filtfilt(f,1,y(index)),'Color',color);
            hold on
    end
    hold off
    title('d\theta/dt');
    xlabel('t (ms)');
    ylabel('d\theta/dt (deg/s)');
    plotSuccess = 1;
end