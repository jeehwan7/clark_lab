function Q = plotEyeVelocityWithoutSaccades(Q)
    
    duration = Q.stimDuration*1000;
    x = 1:duration;
    
    % Averages (without saccades)
    figure;
    color = colormap(copper(Q.numColors));
    for ii = 1:length(Q.correlationVals)
        % pick out relevant trials according to correlation
        y = Q.eyeVelocityWithoutSaccades(Q.symmetrizedCorrelations==Q.correlationVals(ii),:);
        y = mean(y,1,'omitnan');

        % Filter
        y(isnan(y))=0;
        windowSize = 5; 
        b = (1/windowSize)*ones(1,windowSize);
        a = 1;
        z = filtfilt(b,a,y);

        shade = uint8(abs(Q.correlationVals(ii))/Q.correlationGCD+1); % shade of copper
        plot(x,z,'Color',color(shade,:));
        hold on           
    end
    hold off
    title('Gaussian Field Eye Velocity (Average, Without Saccades)');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye velocity (deg/s)');