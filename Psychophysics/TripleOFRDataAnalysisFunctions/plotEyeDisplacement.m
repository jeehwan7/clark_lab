function Q = plotEyeDisplacement(Q)

    %{
    % Pairwise
    figure;
    duration = Q.stimDuration*1000;
    x = 1:duration;
    color = colormap(copper(Q.numColors));
    for ii = 1:length(Q.coherenceVals)
        
        % pick out relevant trials
        y = Q.NaNlessEyeVelocityWithoutSaccades(Q.symmetrizedCoherences==Q.coherenceVals(ii),:);       
        y = mean(y,1);

        %{
        if Q.coherenceVals(ii) > 0
            plot(x,cumsum(y,'omitnan')/1000,'Color','green','LineWidth',1);
        elseif Q.coherenceVals(ii) < 0
            plot(x,cumsum(y,'omitnan')/1000,'Color','red','LineWidth',1);
        else
            plot(x,cumsum(y,'omitnan')/1000,'Color','blue','LineWidth',1);
        end
        %}

        shade = uint8(abs(Q.coherenceVals(ii))/Q.coherenceGCD+1); % shade of copper
        plot(x,cumsum(y,'omitnan')/1000,'Color',color(shade,:),'LineWidth',1); % divide by 1000 to convert from deg/s to deg/ms
        hold on           
    end
    hold off
    title('Pairwise Correlation Eye Displacement');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye displacement (deg)');
    %}

    deltas = NaN(1,4); % final displacements
    sems = NaN(1,4); % final standard errors

    % Triple
    figure;
    subplot(2,2,1);
    [Q,deltas(1),sems(1)] = plotLocalDataTriple(Q,'Diverging',1);
    subplot(2,2,2);
    [Q,deltas(2),sems(2)] = plotLocalDataTriple(Q,'Diverging',-1);
    subplot(2,2,3);
    [Q,deltas(3),sems(3)] = plotLocalDataTriple(Q,'Converging',1);
    subplot(2,2,4);
    [Q,deltas(4),sems(4)] = plotLocalDataTriple(Q,'Converging',-1);
    sgtitle('Triple Correlation Eye Displacement');

    % bar graph
    figure;
    b = bar(deltas);
    b.BaseLine.LineStyle = '--';
    x = ["div,+" "div,-" "con,+" "con,-"];
    xticklabels(x);
    xlabel('type');
    ylabel('eye displacement (deg)');
    title('Triple Correlation Eye Displacement');

    hold on

    errbar = errorbar(deltas,sems);
    errbar.Color = [0 0 0];
    errbar.LineStyle = 'none';

    hold off

end

function [Q,delta,error] = plotLocalDataTriple(Q,type,parity)

    duration = Q.stimDuration*1000;
    x = 1:duration;
    % pick out relevant trials
    y = Q.NaNlessEyeVelocityWithoutSaccades(logical(strcmpi(Q.types,type).*(Q.parities==parity)),:);

    % standard error of the mean
    z = cumsum(y,2)/1000; % cumsum for each trial % divide by 1000 to convert from deg/s to deg/ms
    s = std(z,0,1); % standard deviation for each ms
    sem = s/sqrt(size(z,1)); % standard error of the mean
    
    % overall cumsum
    w = cumsum(mean(y,1))/1000; % divide by 1000 to convert from deg/s to deg/ms
    
    delta = w(end); % final displacement
    error = sem(end); % final standard error

    patch([x fliplr(x)],[w-sem  fliplr(w+sem)],'blue','FaceAlpha',0.2,'EdgeColor','none');
    hold on
    plot(x,w);
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