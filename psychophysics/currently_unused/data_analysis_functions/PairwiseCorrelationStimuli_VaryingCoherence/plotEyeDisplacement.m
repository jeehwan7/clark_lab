function Q = plotEyeDisplacement(Q)

    duration = Q.stimDuration*1000;
    x = 1:duration;
    
    z = NaN(length(Q.coherenceVals),duration); % for OFR

    figure;
    color = colormap(copper(Q.numColors));
    for ii = 1:length(Q.coherenceVals)
        % pick out relevant trials according to coherence
        y = Q.NaNlessEyeVelocityWithoutSaccades(Q.symmetrizedCoherences==Q.coherenceVals(ii),:);     
        y = mean(y,1);

        z(ii,:) = cumsum(y,'omitnan')/1000; % for OFR

        shade = uint8(abs(Q.coherenceVals(ii))/Q.coherenceGCD+1); % shade of copper
        plot(x,cumsum(y,'omitnan')/1000,'Color',color(shade,:),'LineWidth',1); % divide by 1000 to convert from deg/s to deg/ms
        hold on
    end
    hold off
    title('Pairwise Correlation Eye Displacement');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye displacement (deg)');

    lgd = legend({'1','0.9','0.8','0.7','0.6','0.5','0.4','0.3','0.2','0.1','0'},'Location','northwest');
    lgd.Title.String = 'coherence magnitude';

    % for OFR
    z = mean(z(Q.coherenceVals==1,:)-z(Q.coherenceVals==-1,:),1);

    windowSize = 10; 
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    z = filtfilt(b,a,z);

    figure;
    plot(x,z);
    title('Pairwise Correlation Eye Displacement (Average, Coherence = 1)');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye displacement (deg)');

end