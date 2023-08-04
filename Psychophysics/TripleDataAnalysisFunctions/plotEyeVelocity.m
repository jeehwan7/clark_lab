function Q = plotEyeVelocity(Q)

    % Individual Trials (with saccades)

    %% Pairwise

    figure;
    x = 1:1000;
    color = colormap(copper(11));
    for ii = 1:Q.numTrials
        if ~isnan(Q.coherences(ii))
            y = Q.eyeVelocity(ii,1:1000);

            % Filter
            y(isnan(y))=0;
            windowSize = 5; 
            b = (1/windowSize)*ones(1,windowSize);
            a = 1;
            z = filtfilt(b,a,y);

            plot(x,z,'Color',color(10*abs(Q.coherences(ii))+1,:));
        end
        hold on
    end
    hold off
    title('Pairwise Correlation Eye Velocity (Individual Trials, With Saccades)');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye velocity (deg/s)');

    %% Triple

    figure;
    subplot(2,2,1);
    Q = plotLocalDataTripleIndividual(Q,'Converging',1);
    subplot(2,2,2);
    Q = plotLocalDataTripleIndividual(Q,'Converging',-1);
    subplot(2,2,3);
    Q = plotLocalDataTripleIndividual(Q,'Diverging',1);
    subplot(2,2,4);
    Q = plotLocalDataTripleIndividual(Q,'Diverging',-1);
    sgtitle('Triple Correlation Eye Velocity (Individual Trials, With Saccades)');

end

function Q = plotLocalDataTripleIndividual(Q,type,parity)

    x = 1:1000;
    % pick out relevant trials, cut off at 1000 ms
    y = Q.eyeVelocity(logical(strcmpi(Q.types,type).*(Q.parities==parity)),1:1000);

    % Filter
    y(isnan(y))=0;
    windowSize = 5; 
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;

    for ii = 1:size(y,1)
        z = filtfilt(b,a,y(ii,:));
        plot(x,z);
        hold on
    end
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