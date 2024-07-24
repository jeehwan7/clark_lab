function Q = plotComparison(Q)

    temp = NaN(Q.numTrials,Q.updateRate*Q.stimDuration);

    for ii = 1:Q.numTrials
        for jj = (Q.numCoefficients+2):(Q.updateRate*Q.stimDuration)
            temp(ii,jj) = Q.directions(ii,(jj-Q.numCoefficients):(jj-1))*flip(Q.coefficients);
        end
    end

    Q.predictedVelocity = temp;

    % plot comparison
    x = (1:Q.updateRate*Q.stimDuration)*1000/Q.updateRate;
    for i = 1:5
        figure;
        
        % trace
        subplot(3,1,1)
        color = colormap(cool(2));
        plot(x,Q.downSampled(i,:),'Color',color(1,:),'LineWidth',2); % actual
        hold on
        plot(x,Q.predictedVelocity(i,:),'Color',color(2,:),'LineWidth',2); % predicted
        hold off
        
        title('Trace');
        yline(0,'--');
        xlabel('t (ms)');
        ylabel('eye velocity (deg/s)');
        legend('actual velocity','predicted velocity');
        legend('Location','northeast');

        % parametric
        subplot(3,1,[2,3]);
        scatter(Q.downSampled(i,:),Q.predictedVelocity(i,:),...
               'MarkerEdgeColor',[0 .5 .5],...
               'MarkerFaceColor',[0 .7 .7],...
               'LineWidth',1.5);
        % center y-axis
        limit = max(abs(xlim));
        xlim([-limit limit]);
        hold on

        plot(-limit:limit,-limit:limit,'Color',[0.8500 0.3250 0.0980],'LineStyle','--','LineWidth',2);
        hold off

        title('Parametric');
        yline(0,':');
        xline(0,':');
        xlabel('actual velocity (deg/s)');
        ylabel('predicted velocity (deg/s)');

        sgtitle(['Trial ',num2str(i),' Comparison']);
    end

    % plot overall parametric comparison
    figure;
    for i = 1:Q.numTrials
        scatter(Q.downSampled(i,:),Q.predictedVelocity(i,:),...
               'MarkerEdgeColor',[0 .5 .5],...
               'MarkerFaceColor',[0 .7 .7],...
               'LineWidth',1.5);
        hold on
    end
    % center y-axis
    limit = max(abs(xlim));
    xlim([-limit limit]);

    plot(-limit:limit,-limit:limit,'Color',[0.8500 0.3250 0.0980],'LineStyle','--','LineWidth',2);
    hold off

    title('Overall Parametric Comparison');
    yline(0,':');
    xline(0,':');
    xlabel('actual eye velocity (deg/s)');
    ylabel('predicted eye velocity (deg/s)');

end