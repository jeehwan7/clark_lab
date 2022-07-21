function plotSuccess = plotDTheta(numTrials, coherences, eyeMovementMatrix)

    figure;
    for ii = 1:numTrials
        % if size(find(isnan(eyeMovementMatrix(ii,:)))) < ? % filtering creates these long flat lines I don't want to see
            if ~isnan(coherences(ii)) % coherence stimuli
                color = [0.8500, 0.3250, 0.0980].*abs(coherences(ii)); % between copper and black
            elseif isnan(coherences(ii)) % triple stimuli
                color = [0.3010 0.7450 0.9330]; % all blue
            end
            x = 1:1000;
            y = eyeMovementMatrix(ii,1:1000);
            
            % REGULAR OPTION
            plot(x,y,'Color',color);

            %{
            % FILTERED OPTION
            f = ones(1,10)/10;
            index = find(~isnan(y));
            filteredX = x(index);
            filteredY = filtfilt(f,1,y(index));
            plot(filteredX,filteredY,'Color',color);
            %}
            
            hold on
        % end
    end
    hold off
    title('d\theta/dt');
    xlabel('t (ms)');
    ylabel('d\theta/dt (deg/s)');
    plotSuccess = 1;
end