function Q = plotEyePosition(Q,screenWidthpx)

    duration = Q.stimDuration*1000;
    x = 0:duration;

    screenCenter = screenWidthpx/2;

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
    ylabel('x axis position (px)');

    % Triple
    figure;

    subplot(2,2,1);
    plotLocalDataTriple(Q,'Diverging',1,screenCenter);
    subplot(2,2,2);
    plotLocalDataTriple(Q,'Diverging',-1,screenCenter);
    subplot(2,2,3);
    plotLocalDataTriple(Q,'Converging',1,screenCenter);
    subplot(2,2,4);
    plotLocalDataTriple(Q,'Converging',-1,screenCenter);   
    sgtitle('Triple Correlation Eye Position');

end

function Q = plotLocalDataTriple(Q,type,parity,screenCenter)

    duration = Q.stimDuration*1000;
    x = 0:duration;
    z = Q.eyePosition(logical(strcmpi(Q.types,type).*(Q.parities==parity)),1:duration+1)-screenCenter;
    for ii = 1:size(z,1)
        plot(x,z);
        hold on
    end
    hold off
    
    if parity==1
        sign = '+';
    elseif parity==-1
        sign = '-';
    end

    title([type,',',sign']);
    xlabel('t (ms)');
    ylabel('x axis position (px)');

end