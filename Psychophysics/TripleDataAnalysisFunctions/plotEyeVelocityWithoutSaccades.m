function Q = plotEyeVelocityWithoutSaccades(Q)

    figure; % pairwise coherence
    for ii = 1:Q.numTrials
        if ~isnan(Q.coherences(ii))
            color = [0.8500, 0.3250, 0.0980].*abs(Q.coherences(ii)); % between copper and black
            x = 1:length(Q.eyeVelocityWithoutSaccades(ii,:));
            y = Q.eyeVelocityWithoutSaccades(ii,:);
            plot(x,y,'Color',color);
        end
        hold on
    end
    hold off
    title('Pairwise Coherence (Saccades Removed)');
    xlabel('t (ms)');
    ylabel('eye velocity (deg/s)');

    figure; % converging,+
    for ii = 1:Q.numTrials
        if strcmp(Q.types(ii),'converging') && Q.parities(ii)==1
            x = 1:length(Q.eyeVelocityWithoutSaccades(ii,:));
            y = Q.eyeVelocityWithoutSaccades(ii,:);
            plot(x,y);
        end
        hold on
    end
    hold off
    title('Converging,+ (Saccades Removed)')
    xlabel('t (ms)');
    ylabel('eye velocity (deg/s)');

    figure; % converging,-
    for ii = 1:Q.numTrials
        if strcmp(Q.types(ii),'converging') && Q.parities(ii)==-1
            x = 1:length(Q.eyeVelocityWithoutSaccades(ii,:));
            y = Q.eyeVelocityWithoutSaccades(ii,:);
            plot(x,y);
        end
        hold on
    end
    hold off
    title('Converging,- (Saccades Removed)')
    xlabel('t (ms)');
    ylabel('eye velocity (deg/s)');

    figure; % diverging,+
    for ii = 1:Q.numTrials
        if strcmp(Q.types(ii),'diverging') && Q.parities(ii)==1
            x = 1:length(Q.eyeVelocityWithoutSaccades(ii,:));
            y = Q.eyeVelocityWithoutSaccades(ii,:);
            plot(x,y);
        end
        hold on
    end
    hold off
    title('Diverging,+ (Saccades Removed)')
    xlabel('t (ms)');
    ylabel('eye velocity (deg/s)');

    figure; % diverging,-
    for ii = 1:Q.numTrials
        if strcmp(Q.types(ii),'diverging') && Q.parities(ii)==-1
            x = 1:length(Q.eyeVelocityWithoutSaccades(ii,:));
            y = Q.eyeVelocityWithoutSaccades(ii,:);
            plot(x,y);
        end
        hold on
    end
    hold off
    title('Diverging,- (Saccades Removed)')
    xlabel('t (ms)');
    ylabel('eye velocity (deg/s)');

end