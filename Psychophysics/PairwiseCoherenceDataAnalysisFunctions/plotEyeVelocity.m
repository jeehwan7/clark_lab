function Q = plotEyeVelocity(Q)

    % Individual Trials (with saccades)
    figure;
    color = colormap(copper(11));
    for ii = 1:Q.numTrials
            x = 1:1000;
            y = Q.eyeVelocity(ii,1:1000); 
            
            % Filter
            y(isnan(y))=0;
            windowSize = 5; 
            b = (1/windowSize)*ones(1,windowSize);
            a = 1;
            z = filtfilt(b,a,y);
            
            plot(x,z,'Color',color(10*abs(Q.coherences(ii))+1,:));
            hold on
    end
    hold off
    title('Pairwise Correlation Eye Velocity (Individual Trials, With Saccades)');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye velocity (deg/s)');