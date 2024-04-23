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
        windowSize = 10; 
        b = (1/windowSize)*ones(1,windowSize);
        a = 1;
        z = filtfilt(b,a,y);
        
        plot(x,z,'Color',color(uint8(Q.coherences(ii)/Q.coherenceGCD+1),:));
        hold on
    end
    hold off
    title('Pairwise Correlation Eye Velocity (Individual Trials with Saccades)');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye velocity (deg/s)');