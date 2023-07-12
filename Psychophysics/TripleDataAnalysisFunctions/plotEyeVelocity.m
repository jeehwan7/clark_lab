function Q = plotEyeVelocity(Q)

    %% PAIRWISE COHERENCE

    % UNSYMMETRIZED EYE VELOCITY

    % Pairwise Eye Velocity (Individual Trials)
    figure;
    color = colormap(copper(11));
    for ii = 1:Q.numTrials
        if ~isnan(Q.coherences(ii))
            x = 1:1000;
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

    %{
    % Pairwise Eye Velocity (Average)
    figure;
    coherences = [-1; -0.2; 0; 0.2; 1];
    color = colormap(copper(11));
    for ii = 1:length(coherences)
        x = 1:1000;
        % pick out relevant trials, cut off at 1000 ms
        y = Q.eyeVelocity(Q.symmetrizedCoherences==coherences(ii),1:1000);
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
    title('Pairwise Correlation Eye Velocity (Average, With Saccades)');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye velocity (deg/s)');
    %}

    %% TRIPLE

    % SYMMETRIZED EYE VELOCITY

    % Triple Eye Velocity (Individual Trials)
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
    
    %{
    % Triple Eye Velocity (Average)
    figure;
    subplot(2,2,1);
    Q = plotLocalDataTripleAverage(Q,'Converging',1);
    subplot(2,2,2);
    Q = plotLocalDataTripleAverage(Q,'Converging',-1);
    subplot(2,2,3);
    Q = plotLocalDataTripleAverage(Q,'Diverging',1);
    subplot(2,2,4);
    Q = plotLocalDataTripleAverage(Q,'Diverging',-1);
    sgtitle('Triple Correlation Eye Velocity (Average, With Saccades)');
    %}

end

function Q = plotLocalDataTripleIndividual(Q,type,parity)

    for ii = 1:Q.numTrials
        if strcmpi(Q.types(ii),type) && Q.parities(ii)==parity
            x = 1:1000;
            % pick out relevant trials, cut off at 1000 ms
            y = Q.symmetrizedEyeVelocity(ii,1:1000);

            % Filter
            y(isnan(y))=0;
            windowSize = 5; 
            b = (1/windowSize)*ones(1,windowSize);
            a = 1;
            z = filtfilt(b,a,y);

            plot(x,z);
        end
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

%{
function Q = plotLocalDataTripleAverage(Q,type,parity)

    x = 1:1000;
    % pick out relevant trials, cut off at 1000 ms
    y = Q.symmetrizedEyeVelocity(logical((reshape(strcmpi(Q.types,type),length(strcmpi(Q.types,type)),1)).*(Q.parities==parity)),1:1000);
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
%}