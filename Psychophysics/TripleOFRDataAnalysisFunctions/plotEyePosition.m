function Q = plotEyePosition(Q,screenWidthpx)

    duration = Q.stimDuration*1000;
    x = 0:duration;

    screenCenter = screenWidthpx/2;

    %{
    % Pairwise
    figure;
    color = colormap(copper(Q.numColors));
    for ii = 1:Q.numTrials
        if ~isnan(Q.coherences(ii))
            y = Q.eyePosition(ii,1:duration+1)-screenCenter;
            plot(x,y,'Color',color(uint8(Q.coherences(ii)/Q.coherenceGCD+1),:));
        end
        hold on
    end
    hold off
    title('Pairwise Correlation Eye Position');
    xlabel('t (ms)');
    ylabel('x position (px)');
    %}

    % Triple
    figure;
    
    % Converging,+
    subplot(2,2,1);
    z = Q.eyePosition(Q.isConvergingPositive,1:duration+1)-screenCenter;
    for ii = 1:size(z,1)
        plot(x,z);
        hold on
    end
    hold off
    title('Converging,+')
    xlabel('t (ms)');
    ylabel('x position (px)');

    % Converging,-
    subplot(2,2,2);
    z = Q.eyePosition(Q.isConvergingNegative,1:duration+1)-screenCenter;
    for ii = 1:size(z,1)
        plot(x,z);
        hold on
    end
    hold off
    title('Converging,-')
    xlabel('t (ms)');
    ylabel('x position (px)');

    % Diverging,+
    subplot(2,2,3);
    z = Q.eyePosition(Q.isDivergingPositive,1:duration+1)-screenCenter;
    for ii = 1:size(z,1)
        plot(x,z);
        hold on
    end
    hold off
    title('Diverging,+')
    xlabel('t (ms)');
    ylabel('x position (px)');

    % Diverging,-
    subplot(2,2,4);
    z = Q.eyePosition(Q.isDivergingNegative,1:duration+1)-screenCenter;
    for ii = 1:size(z,1)
        plot(x,z);
        hold on
    end
    hold off
    title('Diverging,-')
    xlabel('t (ms)');
    ylabel('x position (px)');

    sgtitle('Triple Correlation Eye Position');

end