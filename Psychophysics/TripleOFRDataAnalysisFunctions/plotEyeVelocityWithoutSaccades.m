function Q = plotEyeVelocityWithoutSaccades(Q)

    duration = Q.stimDuration*1000;

    % Averages

    %{
    % Pairwise
    figure;
    color = colormap(copper(Q.numColors));
    x = 1:duration;
    for ii = 1:length(Q.coherenceVals)
        % pick out relevant trials
        y = Q.NaNlessEyeVelocityWithoutSaccades(Q.symmetrizedCoherences==Q.coherenceVals(ii),:);
        y = mean(y,1);

        % Filter
        y(isnan(y))=0;
        windowSize = 10; 
        b = (1/windowSize)*ones(1,windowSize);
        a = 1;
        z = filtfilt(b,a,y);

        shade = uint8(abs(Q.coherenceVals(ii))/Q.coherenceGCD+1); % shade of copper
        plot(x,z,'Color',color(shade,:));
        hold on           
    end
    hold off
    title('Pairwise Correlation Mean Eye Velocity (Saccades Removed)');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye velocity (deg/s)');
    %}

    % Triple

    figure;
    subplot(2,2,1);
    Q = plotLocalDataTripleAverage(Q,'Converging',1);
    subplot(2,2,2);
    Q = plotLocalDataTripleAverage(Q,'Converging',-1);
    subplot(2,2,3);
    Q = plotLocalDataTripleAverage(Q,'Diverging',1);
    subplot(2,2,4);
    Q = plotLocalDataTripleAverage(Q,'Diverging',-1);
    sgtitle('Triple Correlation Mean Eye Velocity (Saccades Removed)');

end

function Q = plotLocalDataTripleAverage(Q,type,parity)

    duration = Q.stimDuration*1000;

    x = 1:duration;
    % pick out relevant trials
    y = Q.symmetrizedEyeVelocityWithoutSaccades(logical(strcmpi(Q.types,type).*(Q.parities==parity)),:);

    % standard error
    s = std(y,'omitnan');
    sem = s/sqrt(size(y,1));

    y = mean(y,1,'omitnan');

    % Filter
    y(isnan(y))=0;
    windowSize = 10; 
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    z = filtfilt(b,a,y);
    
    plot(x,z);
    hold on
    patch([x fliplr(x)],[y-sem fliplr(y+sem)],[0 0.4470 0.7410],'FaceAlpha',0.2,'EdgeColor','none');
    hold off

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