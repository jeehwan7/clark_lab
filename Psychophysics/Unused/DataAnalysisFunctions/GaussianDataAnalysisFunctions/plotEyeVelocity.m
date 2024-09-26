function Q = plotEyeVelocity(Q)

    duration = Q.stimDuration*1000;
    x = 1:duration;

    % Individual Trials (with saccades)
    figure;
    color = colormap(copper(Q.numColors));
    for ii = 1:Q.numTrials
        y = Q.eyeVelocity(ii,1:duration); 
        
        % Filter
        y(isnan(y))=0;
        windowSize = 5; 
        b = (1/windowSize)*ones(1,windowSize);
        a = 1;
        z = filtfilt(b,a,y);
        
        plot(x,z,'Color',color(uint8(Q.correlations(ii)/Q.correlationGCD+1),:));
        hold on
    end
    hold off
    title('Gaussian Field Eye Velocity (Individual Trials, With Saccades)');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye velocity (deg/s)');

    % ===== anything below here is for OFR ===== %

    % Average (with saccades, but there shouldn't be any right at the start)
    figure;

    Y = Q.eyeVelocity(:,1:duration);
    c = Q.symmetrizedCorrelations;
    Ypos = mean(Y(c==0.5,:),1,'omitnan');
    Yneg = mean(Y(c==-0.5,:),1,'omitnan');
    Ymean = (Ypos-Yneg)/2;

    % Filter
    Ymean(isnan(Ymean))=0;
    windowSize = 30; 
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    Z = filtfilt(b,a,Ymean);

    plot(1:120,Z(1:120));
    title('Gaussian Field Eye Velocity (Average, Correlation = 0.5)');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye velocity (deg/s)');