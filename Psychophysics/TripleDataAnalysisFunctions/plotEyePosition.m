function Q = plotEyePosition(Q,screenWidthpx)

    screenCenter = screenWidthpx/2;
    x = 0:size(Q.eyePosition,2)-1;

    % Pairwise
    figure;
    color = colormap(copper(11)); % 11 because 11 coherences [0:0.1:1]
    for ii = 1:Q.numTrials
        if ~isnan(Q.coherences(ii))
            y = Q.eyePosition(ii,:)-screenCenter;
            plot(x,y,'Color',color(10*abs(Q.coherences(ii))+1,:));
        end
        hold on
    end
    hold off
    title('Pairwise Correlation Eye Position');
    xlabel('t (ms)');
    ylabel('x axis position (px)');

    % Triple
    figure;
    
    % Converging,+
    subplot(2,2,1);
    z = Q.eyePosition(Q.isConvergingPositive,:)-screenCenter;
    for ii = 1:size(z,1)
        plot(x,z);
        hold on
    end
    hold off
    title('Converging,+')
    xlabel('t (ms)');
    ylabel('x axis position (px)');

    % Converging,-
    subplot(2,2,2);
    z = Q.eyePosition(Q.isConvergingNegative,:)-screenCenter;
    for ii = 1:size(z,1)
        plot(x,z);
        hold on
    end
    hold off
    title('Converging,-')
    xlabel('t (ms)');
    ylabel('x axis position (px)');

    % Diverging,+
    subplot(2,2,3);
    z = Q.eyePosition(Q.isDivergingPositive,:)-screenCenter;
    for ii = 1:size(z,1)
        plot(x,z);
        hold on
    end
    hold off
    title('Diverging,+')
    xlabel('t (ms)');
    ylabel('x axis position (px)');

    % Diverging,-
    subplot(2,2,4);
    z = Q.eyePosition(Q.isDivergingNegative,:)-screenCenter;
    for ii = 1:size(z,1)
        plot(x,z);
        hold on
    end
    hold off
    title('Diverging,-')
    xlabel('t (ms)');
    ylabel('x axis position (px)');

    sgtitle('Triple Correlation Eye Position');

end