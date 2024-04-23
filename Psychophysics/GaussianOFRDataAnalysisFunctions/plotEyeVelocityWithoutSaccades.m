function Q = plotEyeVelocityWithoutSaccades(Q)
    
    duration = Q.stimDuration*1000;
    x = 1:duration;
    
    % Average per correlation
    figure;
    color = colormap(copper(Q.numColors));
    for ii = 1:length(Q.correlationVals)
        % pick out relevant trials according to correlation
        y = Q.NaNlessEyeVelocityWithoutSaccades(Q.symmetrizedCorrelations==Q.correlationVals(ii),:);
        y = mean(y,1);

        % Filter
        y(isnan(y))=0;
        windowSize = 5; 
        b = (1/windowSize)*ones(1,windowSize);
        a = 1;
        z = filtfilt(b,a,y);

        shade = uint8(abs(Q.correlationVals(ii))/Q.correlationGCD+1); % shade of copper
        plot(x,z,'Color',color(shade,:));
        hold on           
    end
    hold off
    title('Gaussian Field Mean Eye Velocity (Saccades Removed)');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye velocity (deg/s)');

    % Average across all trials with correlation 1/8
    A = NaN(Q.numTrials,duration);

    for ii = 1:Q.numTrials
        if Q.symmetrizedCorrelations(ii) == 1/8
            A(ii,:) = Q.NaNlessEyeVelocityWithoutSaccades(ii,:);
        elseif Q.symmetrizedCorrelations(ii) == -1/8
            A(ii,:) = -Q.NaNlessEyeVelocityWithoutSaccades(ii,:);
        end
    end
    
    s = std(A,'omitnan'); % standard deviation for each ms
    sem = s/sqrt(sum(Q.correlations~=0)); % standard error for each ms

    z = mean(A,'omitnan');

    % Filter
    windowSize = 10; 
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    z = filtfilt(b,a,z);
    
    plot(x,z);
    hold on
    patch([x fliplr(x)],[z-sem  fliplr(z+sem)],'blue','FaceAlpha',0.2,'EdgeColor','none');
    hold off
    title('Gaussian Field Mean Eye Velocity (Correlation 1/8, Saccades Removed)');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye velocity (deg/s)');

    