function Q = plotEyeVelocityWithoutSaccades(Q)

    duration = Q.stimDuration*1000;

    % Averages (without saccades)

    %% Pairwise
    figure;
    color = colormap(copper(Q.numColors));
    x = 1:duration;
    for ii = 1:length(Q.coherenceVals)
        % pick out relevant trials, cut off at stimulus duration
        y = Q.eyeVelocityWithoutSaccades(Q.symmetrizedCoherences==Q.coherenceVals(ii),1:duration);
        y = mean(y,1,'omitnan');

        % Filter
        y(isnan(y))=0;
        windowSize = 5; 
        b = (1/windowSize)*ones(1,windowSize);
        a = 1;
        z = filtfilt(b,a,y);

        shade = uint8(abs(Q.coherenceVals(ii))/Q.coherenceGCD+1); % shade of copper
        plot(x,z,'Color',color(shade,:));
        hold on           
    end
    hold off
    title('Pairwise Correlation Eye Velocity (Averages, Without Saccades)');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye velocity (deg/s)');

    %% Triple

    figure;
    subplot(2,2,1);
    Q = plotLocalDataTripleAverage(Q,'Converging',1);
    subplot(2,2,2);
    Q = plotLocalDataTripleAverage(Q,'Converging',-1);
    subplot(2,2,3);
    Q = plotLocalDataTripleAverage(Q,'Diverging',1);
    subplot(2,2,4);
    Q = plotLocalDataTripleAverage(Q,'Diverging',-1);
    sgtitle('Triple Correlation Eye Velocity (Averages, Without Saccades)');

end

function Q = plotLocalDataTripleAverage(Q,type,parity)

    duration = Q.stimDuration*1000;

    x = 1:duration;
    % pick out relevant trials, cut off at stimulus duration
    y = Q.symmetrizedEyeVelocityWithoutSaccades(logical(strcmpi(Q.types,type).*(Q.parities==parity)),1:duration);
    y = mean(y,1,'omitnan');

    % Filter
    y(isnan(y))=0;
    windowSize = 5; 
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    z = filtfilt(b,a,y);
    
    plot(x,z);

    if parity==1
        sign = '+';
    elseif parity==-1
        sign = '-';
    end

    title([type,',',sign]);
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye velocity (deg/s)');

end