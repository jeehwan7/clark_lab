function Q = plotEyeDisplacement(Q)

    adapDuration = Q.adapDuration*1000;
    stimDuration = Q.stimDuration*1000;

    % adaptation
    figure;
    for ii = 1:Q.numTrials
        x = 0:adapDuration-1;
        y = Q.adapEyeXDisp(ii,1:adapDuration);
        plot(x,y);
        hold on
    end
    hold off
    title('Raw Eye X Displacement (Adaptation)');
    xlabel('t (ms)');
    ylabel('x displacement (deg)');

    % stimulus
    figure;
    for ii = 1:Q.numTrials
        x = 0:stimDuration-1;
        y = Q.stimEyeXDisp(ii,1:stimDuration);
        plot(x,y);
        hold on
    end
    hold off
    title('Raw Eye X Displacement (Stimulus)');
    xlabel('t (ms)');
    ylabel('x displacement (deg)');
    
end