function Q = plotEyeDisplacement(Q)

    % Pairwise
    figure;
    coherences = [-1; -0.2; 0; 0.2; 1];
    color = colormap(copper(11));
    for ii = 1:length(coherences)
        x = 1:1000;
        % pick out relevant trials, cut off at 1000 ms
        y = Q.NaNlessEyeVelocityWithoutSaccades(Q.symmetrizedCoherences==coherences(ii),1:1000);
        
        y = mean(y,1);

        plot(x,cumsum(y,'omitnan')/1000,'Color',color(10*abs(coherences(ii))+1,:),'LineWidth',1); % divide by 1000 to convert from deg/s to deg/ms
        hold on           
    end
    hold off
    title('Pairwise Correlation Eye Displacement');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye displacement (deg)');

    % Triple
    figure;
    subplot(2,2,1);
    Q = plotLocalDataTriple(Q,'Converging',1);
    subplot(2,2,2);
    Q = plotLocalDataTriple(Q,'Converging',-1);
    subplot(2,2,3);
    Q = plotLocalDataTriple(Q,'Diverging',1);
    subplot(2,2,4);
    Q = plotLocalDataTriple(Q,'Diverging',-1);
    sgtitle('Triple Correlation Eye Displacement');

end

function Q = plotLocalDataTriple(Q,type,parity)

    x = 1:1000;
    % pick out relevant trials, cut off at 1000 ms
    y = Q.NaNlessEyeVelocityWithoutSaccades(logical(strcmpi(Q.types,type).*(Q.parities==parity)),1:1000);

    % standard error of the mean
    z = cumsum(y,2)/1000; % cumsum for each trial % divide by 1000 to convert from deg/s to deg/ms
    s = std(z,0,1); % standard deviation for each ms
    sem = s/sqrt(size(z,1)); % standard error of the mean
    
    y = mean(y,1);
    
    plot(x,cumsum(y)/1000); % divide by 1000 to convert from deg/s to deg/ms
    hold on
    patch([x fliplr(x)],[cumsum(y)/1000-sem  fliplr(cumsum(y)/1000+sem)],'blue','FaceAlpha',0.2,'EdgeColor','none');
    hold off

    if parity==1
        sign = '+';
    elseif parity==-1
        sign = '-';
    end

    title([type,',',sign']);
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye displacement (deg)');

end