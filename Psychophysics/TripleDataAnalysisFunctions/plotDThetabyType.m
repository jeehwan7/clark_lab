function plotSuccess = plotDThetabyType(numTrials, coherences, dThetabyTrial, types, parities)

    range = 250;

    figure;
    subplot(2,2,1);
    for k = 1:numTrials
        if strcmp(types(k), 'converging') && parities(k) == 1
            plot(1:range,dThetabyTrial(k,1:range),'color',[0.4940 0.1840 0.5560]); % purple
        end
        hold on
    end
    hold off
    title('d\theta/dt (Conv, +)');
    xlabel('t (ms)');
    ylabel('d\theta/dt (deg/s)');

    subplot(2,2,2);
    for k = 1:numTrials
        if strcmp(types(k), 'converging') && parities(k) == -1
            plot(1:range,dThetabyTrial(k,1:range),'color',[0.4660 0.6740 0.1880]); % green
        end
        hold on
    end
    hold off
    title('d\theta/dt (Conv, -)');
    xlabel('t (ms)');
    ylabel('d\theta/dt (deg/s)');
    
    subplot(2,2,3);
    for k = 1:numTrials
        if strcmp(types(k), 'diverging') && parities(k) == 1
            plot(1:range,dThetabyTrial(k,1:range),'color',[0.6350 0.0780 0.1840]); % red
        end
        hold on
    end
    hold off
    title('d\theta/dt (Div, +)');
    xlabel('t (ms)');
    ylabel('d\theta/dt (deg/s)');
    
    subplot(2,2,4);
    for k = 1:numTrials
        if strcmp(types(k), 'diverging') && parities(k) == 1
            plot(1:range,dThetabyTrial(k,1:range),'color',[0.3010 0.7450 0.9330]); % blue
        end
        hold on
    end
    hold off
    title('d\theta/dt (Div, -)');
    xlabel('t (ms)');
    ylabel('d\theta/dt (deg/s)');
    
    figure;
    for k = 1:numTrials
        if coherences(k) == 0
            plot(1:range,dThetabyTrial(k,1:range),'color',[0 0 0]); % black
        elseif coherences(k) == 0.2
            plot(1:range,dThetabyTrial(k,1:range),'color',[0.8500 0.3250 0.0980]/2); % brown
        elseif coherences(k) == 1
            plot(1:range,dThetabyTrial(k,1:range),'color',[0.8500 0.3250 0.0980]); % orange
        end
        hold on
    end
    hold off
    title('d\theta/dt (Pairwise)');
    xlabel('t (ms)');
    ylabel('d\theta/dt (deg/s)');
    
    plotSuccess = 1;
    
end