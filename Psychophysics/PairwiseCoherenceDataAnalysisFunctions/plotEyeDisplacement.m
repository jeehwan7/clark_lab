function Q = plotEyeDisplacement(Q)

    duration = Q.stimDuration*1000;
    x = 1:duration;

    figure;
    color = colormap(copper(Q.numColors));
    for ii = 1:length(Q.coherenceVals)
        % pick out relevant trials according to coherence
        y = Q.NaNlessEyeVelocityWithoutSaccades(Q.symmetrizedCoherences==Q.coherenceVals(ii),:);     
        y = mean(y,1);

        shade = uint8(abs((Q.coherenceVals(ii))/Q.coherenceGCD)+1); % shade of copper
        plot(x,cumsum(y,'omitnan')/1000,'Color',color(shade,:),'LineWidth',1); % divide by 1000 to convert from deg/s to deg/ms
        hold on
    end
    hold off
    title('Pairwise Correlation Eye Displacement');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye displacement (deg)');

end