function Q = plotEyeVelocity(Q)

    duration = Q.stimDuration*1000;
    x = 1:duration;

    % Individual Trials (with saccades)
    figure;
    color = colormap(copper(11));
    for ii = 1:Q.numTrials
        y = Q.eyeVelocity(ii,1:duration); 
        
        % Filter
        y(isnan(y))=0;
        windowSize = 5; 
        b = (1/windowSize)*ones(1,windowSize);
        a = 1;
        z = filtfilt(b,a,y);
        
        plot(x,z,'Color',color(uint8(Q.coherences(ii)/Q.coherenceGCD+1),:));
        hold on
    end
    hold off
    title('Pairwise Correlation Eye Velocity (Individual Trials, With Saccades)');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye velocity (deg/s)');

    % ===== anything below here is for OFR ===== %

    % Average (with saccades, but there shouldn't be any right at the start)
    figure;

    Y = Q.eyeVelocity(:,1:duration);
    c = Q.symmetrizedCoherences;
    Ypos = mean(Y(c==1,:),1,'omitnan');
    Yneg = mean(Y(c==-1,:),1,'omitnan');
    Ymean = (Ypos-Yneg)/2;

    % Filter
    Ymean(isnan(Ymean))=0;
    windowSize = 10; 
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    Z = filtfilt(b,a,Ymean);
    
    plot(1:120,Z(1:120));
    title('Pairwise Correlation Eye Velocity (Average, Coherence = 1)');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye velocity (deg/s)');

