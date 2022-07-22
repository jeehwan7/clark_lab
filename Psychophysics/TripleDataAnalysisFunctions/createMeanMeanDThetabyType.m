function meanMeanDTheta = createMeanMeanDThetabyType(start, finish, meanDThetabyTriple, tripleType)

    meanMeanDTheta = zeros(4,1); % mean of mean dtheta/dt
    convPos = meanDThetabyTriple(tripleType == 'conv, +');
    convPos = convPos(~isnan(convPos));
    meanMeanDTheta(1,1) = mean(convPos);
    sem1 = std(convPos)/sqrt(length(convPos));

    convNeg = meanDThetabyTriple(tripleType == 'conv, -');
    convNeg = convNeg(~isnan(convNeg));
    meanMeanDTheta(2,1) = mean(convNeg);
    sem2 = std(convNeg)/sqrt(length(convNeg));
    
    divPos = meanDThetabyTriple(tripleType == 'div, +');
    divPos =divPos(~isnan(divPos));
    meanMeanDTheta(3,1) = mean(divPos);
    sem3 = std(divPos)/sqrt(length(divPos));

    divNeg = meanDThetabyTriple(tripleType == 'div, -');
    divNeg = divNeg(~isnan(divNeg));
    meanMeanDTheta(4,1) = mean(divNeg);
    sem4 = std(divNeg)/sqrt(length(divNeg));

    x = {'conv, +','conv, -','div, +','div, -'};
    y = meanMeanDTheta;

    sem = [sem1 sem2 sem3 sem4];

    figure;
    bar(y);
    title(['Mean of Mean d\theta/dt (Symmetrized, Excluding Saccades, ',num2str(start),' ms to ',num2str(finish),' ms)']);
    xlabel('Type');
    ylabel('d\theta/dt (deg/s)')
    xticklabels(x);
    hold on
    er = errorbar(y,sem);
    er.Color = [0 0 0];
    er.LineStyle = 'none';
    hold off
end
