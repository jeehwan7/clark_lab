function Q = plotEyeDisplacement(Q)

    % Pairwise Eye Displacement
    figure;
    coherences = [-1;-0.9;-0.8;-0.7;-0.6;-0.5;-0.4;-0.3;-0.2;-0.1;0;0.1;0.2;0.3;0.4;0.5;0.6;0.7;0.8;0.9;1];
    color = colormap(copper(11));
    for ii = 1:length(coherences)

        x = 1:1000;
        % pick out relevant trials, cut off at 1000 ms
        y = Q.eyeVelocityWithoutSaccades(Q.symmetrizedCoherences==coherences(ii),1:1000);

%         % Option 1: replace NaN values with 0
%         y(isnan(y)) = 0;
        
        % Option 2: replace NaN values with mean of non-NaN values
        m = mean(y,1,'omitnan'); % mean of non-NaN values for each ms
        for jj = 1:size(y,2)
            column = y(:,jj);
            column(isnan(column)) = m(jj);
            y(:,jj) = column;
        end
        
        y = mean(y,1);

        plot(x,cumsum(y,'omitnan')/1000,'Color',color(10*abs(coherences(ii))+1,:),'LineWidth',1); % divide by 1000 to convert from deg/s to deg/ms
        hold on           
    end
    hold off
    title('Pairwise Eye Displacement');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye displacement (deg)');

%     % Triple Eye Displacement
%     figure;
%     subplot(2,2,1);
%     Q = plotLocalDataTriple(Q,'Converging',1);
%     subplot(2,2,2);
%     Q = plotLocalDataTriple(Q,'Converging',-1);
%     subplot(2,2,3);
%     Q = plotLocalDataTriple(Q,'Diverging',1);
%     subplot(2,2,4);
%     Q = plotLocalDataTriple(Q,'Diverging',-1);
%     sgtitle('Triple Eye Displacement');

end

function Q = plotLocalDataTriple(Q,type,parity)

    x = 1:1000;
    % pick out relevant trials, cut off at 1000 ms
    y = Q.eyeVelocityWithoutSaccades(logical((reshape(strcmpi(Q.types,type),length(strcmpi(Q.types,type)),1)).*(Q.parities==parity)),1:1000);
    
%     % Option 1: replace NaN values with 0
%     y(isnan(y)) = 0;

    % Option 2: replace NaN values with mean of non-NaN values
    m = mean(y,1,'omitnan'); % mean of non-NaN values for each ms
    for ii = 1:size(y,2)
        column = y(:,ii);
        column(isnan(column)) = m(ii);
        y(:,ii) = column;
    end

    % standard error of the mean
    z = cumsum(y,2,'omitnan')/1000; % cumsum for each trial % divide by 1000 to convert from deg/s to deg/ms
    s = std(z,0,1); % standard error for each ms
    sem = s/sqrt(size(z,1));
    
    y = mean(y,1);
    
    plot(x,cumsum(y,'omitnan')/1000); % divide by 1000 to convert from deg/s to deg/ms
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