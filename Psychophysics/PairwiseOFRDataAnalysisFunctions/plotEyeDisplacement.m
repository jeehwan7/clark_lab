function Q = plotEyeDisplacement(Q)

    duration = Q.stimDuration*1000;
    x = 1:duration;

    figure;
    color = colormap(copper(Q.numColors));
    for ii = 1:length(Q.coherenceVals)
        % pick out relevant trials according to coherence
        y = Q.NaNlessEyeVelocityWithoutSaccades(Q.symmetrizedCoherences==Q.coherenceVals(ii),:);     
        y = mean(y,1);

        shade = uint8(abs(Q.coherenceVals(ii))/Q.coherenceGCD+1); % shade of copper
        plot(x,cumsum(y,'omitnan')/1000,'Color',color(shade,:),'LineWidth',1); % divide by 1000 to convert from deg/s to deg/ms
        hold on
    end
    hold off
    title('Pairwise Correlation Eye Displacement');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye displacement (deg)');

    lgd = legend({'1','0'},'Location','northwest');
    lgd.Title.String = 'coherence magnitude';

    % Average across all trials with coherence magnitude 1
    A = NaN(Q.numTrials,duration);

    for ii = 1:Q.numTrials
        if Q.symmetrizedCoherences(ii) == 0.3
            A(ii,:) = cumsum(Q.NaNlessEyeVelocityWithoutSaccades(ii,:))/1000;
        elseif Q.symmetrizedCoherences(ii) == -0.3
            A(ii,:) = -cumsum(Q.NaNlessEyeVelocityWithoutSaccades(ii,:))/1000;
        end
    end
    
    s = std(A,'omitnan'); % standard deviation for each ms
    sem = s/sqrt(length(find(Q.coherences))); % standard error for each ms

    z = mean(A,'omitnan');

    windowSize = 10; 
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    z = filtfilt(b,a,z);

    figure;
    plot(x,z);
    hold on
    patch([x fliplr(x)],[z-sem  fliplr(z+sem)],'blue','FaceAlpha',0.2,'EdgeColor','none');
    hold off
    title('Pairwise Correlation Mean Eye Displacement (Coherence \pm0.3)');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye displacement (deg)');

end