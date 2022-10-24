function Q = plotEyePosition(Q)

    figure; % pairwise coherence
    for ii = 1:Q.numTrials
        if ~isnan(Q.coherences(ii))
            color = [0.8500, 0.3250, 0.0980].*abs(Q.coherences(ii)); % between copper and black
            x = 0:length(Q.eyePosition(ii,:))-1;
            y = Q.eyePosition(ii,:)-960;
            plot(x,y,'Color',color);
        end
        hold on
    end
    hold off
    title('Pairwise Coherence');
    xlabel('t (ms)');
    ylabel('x position (px)');

    figure; % converging,+
    for ii = 1:Q.numTrials
        if strcmp(Q.types(ii),'converging') && Q.parities(ii)==1
            x = 0:length(Q.eyePosition(ii,:))-1;
            y = Q.eyePosition(ii,:)-960;
            plot(x,y);
        end
        hold on
    end
    hold off
    title('Converging,+')
    xlabel('t (ms)');
    ylabel('x position (px)');

    figure; % converging,-
    for ii = 1:Q.numTrials
        if strcmp(Q.types(ii),'converging') && Q.parities(ii)==-1
            x = 0:length(Q.eyePosition(ii,:))-1;
            y = Q.eyePosition(ii,:)-960;
            plot(x,y);
        end
        hold on
    end
    hold off
    title('Converging,-')
    xlabel('t (ms)');
    ylabel('x position (px)');

    figure; % diverging,+
    for ii = 1:Q.numTrials
        if strcmp(Q.types(ii),'diverging') && Q.parities(ii)==1
            x = 0:length(Q.eyePosition(ii,:))-1;
            y = Q.eyePosition(ii,:)-960;
            plot(x,y);
        end
        hold on
    end
    hold off
    title('Diverging,+')
    xlabel('t (ms)');
    ylabel('x position (px)');

    figure; % diverging,-
    for ii = 1:Q.numTrials
        if strcmp(Q.types(ii),'diverging') && Q.parities(ii)==-1
            x = 0:length(Q.eyePosition(ii,:))-1;
            y = Q.eyePosition(ii,:)-960;
            plot(x,y);
        end
        hold on
    end
    hold off
    title('Diverging,-')
    xlabel('t (ms)');
    ylabel('x position (px)');

end