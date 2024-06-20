function Q = plotEyeDisplacement(Q)

    duration = Q.stimDuration*1000;
    x = 1:duration;

    figure;
    color = colormap(copper(Q.numColors));
    for ii = 1:length(Q.correlationVals)
        % pick out relevant trials according to correlation
        y = Q.NaNlessEyeVelocityWithoutSaccades(Q.symmetrizedCorrelations==Q.correlationVals(ii),:);
        y = mean(y,1);

        shade = uint8(abs(Q.correlationVals(ii))/Q.correlationGCD+1); % shade of copper
        plot(x,cumsum(y,'omitnan')/1000,'Color',color(shade,:),'LineWidth',1); % divide by 1000 to convert from deg/s to deg/ms
        hold on           
    end
    hold off
    title('Gaussian Field Eye Displacement');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye displacement (deg)');

end