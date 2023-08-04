function Q = plotEyeVelocityWithoutSaccades(Q)

    % Averages (without saccades)

    %% Pairwise
    figure;
    coherences = [-1; -0.2; 0; 0.2; 1];
    color = colormap(copper(11));
    x = 1:1000;
    for ii = 1:length(coherences)
        % pick out relevant trials, cut off at 1000 ms
        y = Q.eyeVelocityWithoutSaccades(Q.symmetrizedCoherences==coherences(ii),1:1000);
        y = mean(y,1,'omitnan');

        % Filter
        y(isnan(y))=0;
        windowSize = 5; 
        b = (1/windowSize)*ones(1,windowSize);
        a = 1;
        z = filtfilt(b,a,y);

        plot(x,z,'Color',color(10*abs(coherences(ii))+1,:));
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

    x = 1:1000;
    % pick out relevant trials, cut off at 1000 ms
    y = Q.symmetrizedEyeVelocityWithoutSaccades(logical(strcmpi(Q.types,type).*(Q.parities==parity)),1:1000);
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