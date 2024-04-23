function Q = plotEyeVelocityWithoutSaccades(Q)
    
    duration = Q.stimDuration*1000;
    x = 1:duration;

    % Averages per symmetrized coherence (without saccades)
    figure;
    color = colormap(copper(Q.numColors));
    for ii = 1:length(Q.coherenceVals)
        % pick out relevant trials according to coherence
        y = Q.NaNlessEyeVelocityWithoutSaccades(Q.symmetrizedCoherences==Q.coherenceVals(ii),:);
        y = mean(y,1);

        % Filter
        y(isnan(y)) = 0;
        windowSize = 5; 
        b = (1/windowSize)*ones(1,windowSize);
        a = 1;
        z = filtfilt(b,a,y);

        shade = uint8(abs(Q.coherenceVals(ii))/Q.coherenceGCD+1); % shade of copper
        plot(x,z,'Color',color(shade,:));
        hold on           
    end
    hold off
    title('Pairwise Correlation Eye Velocity (Average, Without Saccades)');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye velocity (deg/s)');

    % Average across all trials with coherence magnitude 1 (without sacccades)
    A = NaN(Q.numTrials,duration);

    for ii = 1:Q.numTrials
        if Q.symmetrizedCoherences(ii) == 1
            A(ii,:) = Q.NaNlessEyeVelocityWithoutSaccades(ii,:);
        elseif Q.symmetrizedCoherences(ii) == -1
            A(ii,:) = -Q.NaNlessEyeVelocityWithoutSaccades(ii,:);
        end
    end
    
    s = std(A,'omitnan'); % standard deviation for each ms
    sem = s/sqrt(length(find(Q.coherences))); % standard error for each ms

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
    title('Pairwise Correlation Mean Eye Velocity (Coherence \pm1 without Saccades)');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye velocity (deg/s)');

    