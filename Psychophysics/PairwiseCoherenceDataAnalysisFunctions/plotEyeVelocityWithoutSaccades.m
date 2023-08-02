function Q = plotEyeVelocityWithoutSaccades(Q)
    
    % Averages (without saccades)
    figure;
    coherences = [-1;-0.9;-0.8;-0.7;-0.6;-0.5;-0.4;-0.3;-0.2;-0.1;0;0.1;0.2;0.3;0.4;0.5;0.6;0.7;0.8;0.9;1];
    color = colormap(copper(11));
    for ii = 1:length(coherences)
        
        x = 1:1000;
        % pick out relevant trials according to coherence, cut off at 1000 ms
        y = Q.eyeVelocityWithoutSaccades(Q.symmetrizedCoherences==coherences(ii),1:1000);
        y = mean(y,1,'omitnan');

        % Filter
        % y(isnan(y))=0;
        windowSize = 5; 
        b = (1/windowSize)*ones(1,windowSize);
        a = 1;
        z = filtfilt(b,a,y);

        plot(x,z,'Color',color(10*abs(coherences(ii))+1,:));
        hold on           
    end
    hold off
    title('Pairwise Correlation Eye Velocity (Average, Without Saccades)');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye velocity (deg/s)');