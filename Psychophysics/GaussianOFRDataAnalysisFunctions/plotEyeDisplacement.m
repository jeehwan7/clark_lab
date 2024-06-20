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

    % Average across all trials with correlation 2/9
    A = NaN(Q.numTrials,duration);

    for ii = 1:Q.numTrials
        if Q.symmetrizedCorrelations(ii) == 2/9
            A(ii,:) = cumsum(Q.NaNlessEyeVelocityWithoutSaccades(ii,:))/1000;
        elseif Q.symmetrizedCorrelations(ii) == -2/9
            A(ii,:) = -cumsum(Q.NaNlessEyeVelocityWithoutSaccades(ii,:))/1000;
        end
    end

    s = std(A,'omitnan'); % standard deviation for each ms
    sem = s/sqrt(sum(Q.correlations~=0)); % standard error for each ms

    z = mean(A,'omitnan');

    windowSize = 10; 
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    z = filtfilt(b,a,z);

    figure;
    
    patch([x fliplr(x)],[z-sem  fliplr(z+sem)],[0 0.4470 0.7410],'FaceAlpha',0.2,'EdgeColor','none');
    hold on
    plot(x,z);
    hold off
    title('Gaussian Field Mean Eye Displacement');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye displacement (deg)');

end