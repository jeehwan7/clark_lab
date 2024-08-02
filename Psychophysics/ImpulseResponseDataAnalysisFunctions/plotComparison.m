function Q = plotComparison(Q,param)

    % obtain predicted velocity
    temp = NaN(Q.numTrials,Q.updateRate*Q.stimDuration);

    for ii = 1:Q.numTrials
        for jj = (Q.numCoefficients+2):(Q.updateRate*Q.stimDuration)
            temp(ii,jj) = Q.directionsNormalized(ii,(jj-Q.numCoefficients):(jj-1))*flip(Q.coefficients);
        end
    end

    Q.predictedVelocity = temp;

    % plot trial by trial comparison
    x = (1:Q.updateRate*Q.stimDuration)*1000/Q.updateRate;
    for i = 1
        figure;
        
        % trace
        % subplot(3,1,1)
        color = colormap(cool(2));
        plot(x,Q.downSampledNormalized(i,:),'Color',color(1,:),'LineWidth',2); % actual
        hold on
        plot(x,Q.predictedVelocity(i,:),'Color',color(2,:),'LineWidth',2); % predicted
        hold off
        
        % title('Trace');
        title(['Trial ',num2str(i),' Trace Comparison']);
        yline(0,'--');
        xlabel('t (ms)');
        ylabel('velocity (deg/s)');
        legend('actual eye velocity','predicted eye velocity');
        legend('Location','northeast');

        %{
        % parametric
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

        title('Parametric');
        yline(0,':');
        xline(0,':');
        ylabel('actual eye velocity (deg/s)');
        xlabel('predicted eye velocity (deg/s)');
        %}

        % sgtitle(['Trial ',num2str(i),' Comparison']);
    end

    %{
    % plot block by block comparison
    % x = (1:Q.updateRate*Q.stimDuration)*1000/Q.updateRate;
    for i = 1:param.numBlocks
        figure;

        %{
        % trace (mean across trials within block)
        % subplot(3,1,1)
        color = colormap(cool(2));
        meanActual = mean(Q.downSampledNormalized((1:param.numTrialsPerBlock)+(i-1)*param.numTrialsPerBlock,:),1,'omitnan');
        plot(x,meanActual,'Color',color(1,:),'LineWidth',2); % actual
        hold on
        meanPredicted = mean(Q.predictedVelocity((1:param.numTrialsPerBlock)+(i-1)*param.numTrialsPerBlock,:),1,'omitnan');
        plot(x,meanPredicted,'Color',color(2,:),'LineWidth',2); % predicted
        hold off
        
        title('Trace');
        yline(0,'--');
        xlabel('t (ms)');
        ylabel('eye velocity (deg/s)');
        legend('actual eye velocity','predicted eye velocity');
        legend('Location','northeast');
        %}

        % parametric
        % subplot(3,1,[2,3]);
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
        [p,S] = polyfit(predictedData(~isnan(actualData)),actualData(~isnan(actualData)),1);
        Q.rsqParametric = 1 - (S.normr/norm(actualData(~isnan(actualData)) - mean(actualData(~isnan(actualData)))))^2;
        plot(range,range*p(1)+p(2),'Color',[0.9290 0.6940 0.1250],'LineWidth',2);
        hold off

        % title('Parametric');
        title(['Block ',num2str(i),' Parametric Comparison']);
        yline(0,':');
        xline(0,':');
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

        % sgtitle(['Block ',num2str(i),' Comparison']);
    end
    %}

    % plot overall parametric comparison
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
    p = polyfit(Q.predictedVelocity(~isnan(Q.downSampledNormalized)),Q.downSampledNormalized(~isnan(Q.downSampledNormalized)),1);
    plot(range,range*p(1)+p(2),'Color',[0.9290 0.6940 0.1250],'LineWidth',2);
    hold off

    title('Parametric Comparison');
    yline(0,':');
    xline(0,':');
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

    % plot simplified overall parametric comparison
    rhat = Q.predictedVelocity;
    r = Q.downSampledNormalized;
    rhat(isnan(r)) = NaN; % so that we're dealing with only the points actually plotted

    % bins
    numBins = 10;
    rhat_mean = NaN(numBins,1);
    r_mean = NaN(numBins,1);

    rhat_min = min(rhat,[],'all');
    rhat_max = max(rhat,[],'all');
    binSize = (rhat_max-rhat_min)/numBins;
    
    for nn = 1:numBins
        if nn == numBins
            rhat_mean(nn) = mean(rhat(rhat>=(rhat_min+binSize*(nn-1))&rhat<=(rhat_min+binSize*nn)),'omitnan');
            r_mean(nn) = mean(r(rhat>=(rhat_min+binSize*(nn-1))&rhat<=(rhat_min+binSize*nn)),'omitnan');
        else
            rhat_mean(nn) = mean(rhat(rhat>=(rhat_min+binSize*(nn-1))&rhat<(rhat_min+binSize*nn)),'omitnan');
            r_mean(nn) = mean(r(rhat>=(rhat_min+binSize*(nn-1))&rhat<(rhat_min+binSize*nn)),'omitnan');
        end        
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

    title('Parametric Comparison');
    yline(0,':');
    xline(0,':');
    ylabel('actual eye velocity (deg/s)');
    xlabel('predicted eye velocity (deg/s)');
    legend('','','identity line');
    legend('Location','southeast');

end