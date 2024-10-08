function Q = plotComparison(Q,param)

    % Calculate predicted velocity
    temp = NaN(Q.numTrials,Q.updateRate*Q.stimDuration);

    for ii = 1:Q.numTrials
        for jj = (Q.numCoefficients+2):(Q.updateRate*Q.stimDuration)
            temp(ii,jj) = Q.directionsNormalized(ii,(jj-Q.numCoefficients):(jj-1))*flip(Q.coefficients);
        end
    end

    Q.predictedVelocity = temp;

    %% Comparisons by Trial
    
    x = (1:Q.updateRate*Q.stimDuration)/Q.updateRate;
    for i = 1
        figure;
        
        % Traces
        % subplot(3,1,1)
        color = colormap(cool(2));
        plot(x,Q.downSampledNormalized(i,:),'Color',color(1,:),'LineWidth',2); % actual velocity
        hold on
        plot(x,Q.predictedVelocity(i,:),'Color',color(2,:),'LineWidth',2); % predicted velocity
        hold off
        
        yline(0,'--');
        % title('Actual Eye Velocity vs. Predicted Eye Velocity');
        title(['Actual Eye Velocity vs. Predicted Eye Velocity',' (Trial ',num2str(i),')']);
        xlabel('t (s)');
        ylabel('eye velocity (deg/s)');
        legend('actual eye velocity','predicted eye velocity');
        legend('Location','northeast');

        %{
        % Parametric
        subplot(3,1,[2,3]);
        scatter(Q.predictedVelocity(i,:),Q.downSampledNormalized(i,:),...
               'MarkerEdgeColor',[0 .5 .5],...
               'MarkerFaceColor',[0 .7 .7],...
               'LineWidth',1.5);
        
        % center y-axis
        limit = max(abs(xlim));
        xlim([-limit limit]);
        range = -limit:limit;
        hold on

        % identity line
        plot(range,range,'Color',[0.8500 0.3250 0.0980],'LineStyle','--','LineWidth',2);
        hold off

        yline(0,':');
        xline(0,':');
        title('Actual Eye Velocity vs. Predicted Eye Velocity');
        ylabel('actual eye velocity (deg/s)');
        xlabel('predicted eye velocity (deg/s)');
        %}

        % sgtitle(['Trial ',num2str(i)]);
    end

    %{
    %% Comparisons by Block

    % x = (1:Q.updateRate*Q.stimDuration)/Q.updateRate;
    for i = 1:param.numBlocks
        figure;
        
        % Traces (average across trials within block)
        subplot(3,1,1)
        color = colormap(cool(2));
        meanActual = mean(Q.downSampledNormalized((1:param.numTrialsPerBlock)+(i-1)*param.numTrialsPerBlock,:),1,'omitnan');
        plot(x,meanActual,'Color',color(1,:),'LineWidth',2); % actual velocity
        hold on
        meanPredicted = mean(Q.predictedVelocity((1:param.numTrialsPerBlock)+(i-1)*param.numTrialsPerBlock,:),1,'omitnan');
        plot(x,meanPredicted,'Color',color(2,:),'LineWidth',2); % predicted velocity
        hold off
        
        yline(0,'--');
        title('Actual Eye Velocity vs. Predicted Eye Velocity');
        xlabel('t (s)');
        ylabel('eye velocity (deg/s)');
        legend('actual eye velocity','predicted eye velocity');
        legend('Location','northeast');

        % Parametric
        subplot(3,1,[2,3]);
        for j = 1:param.numTrialsPerBlock
            scatter(Q.predictedVelocity(j+(i-1)*param.numTrialsPerBlock,:),...
                    Q.downSampledNormalized(j+(i-1)*param.numTrialsPerBlock,:),...
                   'MarkerEdgeColor',[0 .5 .5],...
                   'MarkerFaceColor',[0 .7 .7],...
                   'LineWidth',1.5);
            hold on
        end
        hold off
        
        % center y-axis
        limit = max(abs(xlim));
        xlim([-limit limit]);
        range = -limit:limit;
        hold on

        % identity line
        plot(range,range,'Color',[0.8500 0.3250 0.0980],'LineStyle','--','LineWidth',2);
        hold on

        % line of best fit
        predictedData = Q.predictedVelocity((1:param.numTrialsPerBlock)+(i-1)*param.numTrialsPerBlock,:);
        actualData = Q.downSampledNormalized((1:param.numTrialsPerBlock)+(i-1)*param.numTrialsPerBlock,:);
        p = polyfit(predictedData(~isnan(actualData)),actualData(~isnan(actualData)),1);
        plot(range,range*p(1)+p(2),'Color',[0.9290 0.6940 0.1250],'LineWidth',2);
        hold off

        yline(0,':');
        xline(0,':');
        title('Actual Eye Velocity vs. Predicted Eye Velocity');
        ylabel('actual eye velocity (deg/s)');
        xlabel('predicted eye velocity (deg/s)');

        % legend
        leg = cell(param.numTrialsPerBlock+2,1);
        for k = 1:param.numTrialsPerBlock
            leg{k} = '';
        end
        leg{param.numTrialsPerBlock+1} = 'identity line';
        leg{param.numTrialsPerBlock+2} = 'line of best fit';
        legend(leg);
        legend('Location','southeast');

        sgtitle(['Block ',num2str(i)]);
    end
    %}

    %% Overall Parametric Plot
    
    figure;
    for i = 1:Q.numTrials
        scatter(Q.predictedVelocity(i,:),Q.downSampledNormalized(i,:),...
               'MarkerEdgeColor',[0 .5 .5],...
               'MarkerFaceColor',[0 .7 .7],...
               'LineWidth',1.5);
        hold on
    end
    
    % center y-axis
    limit = max(abs(xlim));
    xlim([-limit limit]);
    range = -limit:limit;

    % identity line
    plot(range,range,'Color',[0.8500 0.3250 0.0980],'LineStyle','--','LineWidth',2);
    hold on

    % line of best fit
    [p,S] = polyfit(Q.predictedVelocity(~isnan(Q.downSampledNormalized)),Q.downSampledNormalized(~isnan(Q.downSampledNormalized)),1);
    Q.rsqParametric = 1 - (S.normr/norm(Q.downSampledNormalized(~isnan(Q.downSampledNormalized)) - mean(Q.downSampledNormalized(~isnan(Q.downSampledNormalized)))))^2;
    plot(range,range*p(1)+p(2),'Color',[0.9290 0.6940 0.1250],'LineWidth',2);
    hold off

    yline(0,':');
    xline(0,':');
    title('Actual Eye Velocity vs. Predicted Eye Velocity');  
    ylabel('actual eye velocity (deg/s)');
    xlabel('predicted eye velocity (deg/s)');

    % legend
    leg = cell(Q.numTrials+2,1);
    for i = 1:Q.numTrials
        leg{i} = '';
    end
    leg{Q.numTrials+1} = 'identity line';
    leg{Q.numTrials+2} = 'line of best fit';
    legend(leg);
    legend('Location','southeast');

    Q.stdPredictedVelocity = std(Q.predictedVelocity,0,'all','omitmissing');

    %% Averaged Overall Parametric Plot

    rhat = Q.predictedVelocity;
    r = Q.downSampledNormalized;
    rhat(isnan(r)) = NaN; % only deal with points actually plotted

    % calculate averages
    numBins = 10;
    rhat_mean = NaN(numBins,1);
    r_mean = NaN(numBins,1);

    binSize = 100/numBins;
    
    for nn = 1:numBins
        lowLim = prctile(rhat,(nn-1)*binSize);
        highLim = prctile(rhat,nn*binSize);

        rhat_mean(nn) = mean(rhat(rhat > lowLim & rhat <= highLim),'omitnan');
        r_mean(nn) = mean(r(rhat > lowLim & rhat <= highLim),'omitnan');
    end

    figure;
    plot(rhat_mean,r_mean,'Color',[0.3010 0.7450 0.9330],'LineWidth',2);
    hold on
    scatter(rhat_mean,r_mean,...
           'MarkerEdgeColor',[0 .5 .5],...
           'MarkerFaceColor',[0 .7 .7],...
           'LineWidth',1.5);
    hold on
    
    % center y-axis
    limit = max(abs(xlim));
    xlim([-limit limit]);
    range = -limit:limit;

    % identity line
    plot(range,range,'Color',[0.8500 0.3250 0.0980],'LineStyle','--','LineWidth',2);
    hold on

    yline(0,':');
    xline(0,':');
    title('Actual Eye Velocity vs. Predicted Eye Velocity');
    ylabel('actual eye velocity (deg/s)');
    xlabel('predicted eye velocity (deg/s)');
    legend('','','identity line');
    legend('Location','southeast');

end