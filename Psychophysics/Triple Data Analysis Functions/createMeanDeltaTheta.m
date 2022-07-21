function meanDeltaTheta = createMeanDeltaTheta(deltaThetabyTriple, tripleType)

    meanDeltaTheta = zeros(4,1); % mean of deltatheta
    convPos = deltaThetabyTriple(tripleType == 'conv, +');
    convPos = convPos(~isnan(convPos));
    meanDeltaTheta(1,1) = mean(convPos);
    sem1 = std(convPos)/sqrt(length(convPos));

    convNeg = deltaThetabyTriple(tripleType == 'conv, -');
    convNeg = convNeg(~isnan(convNeg));
    meanDeltaTheta(2,1) = mean(convNeg);
    sem2 = std(convNeg)/sqrt(length(convNeg));
    
    divPos = deltaThetabyTriple(tripleType == 'div, +');
    divPos =divPos(~isnan(divPos));
    meanDeltaTheta(3,1) = mean(divPos);
    sem3 = std(divPos)/sqrt(length(divPos));

    divNeg = deltaThetabyTriple(tripleType == 'div, -');
    divNeg = divNeg(~isnan(divNeg));
    meanDeltaTheta(4,1) = mean(divNeg);
    sem4 = std(divNeg)/sqrt(length(divNeg));

    x = {'conv, +','conv, -','div, +','div, -'};
    y = meanDeltaTheta;

    sem = [sem1 sem2 sem3 sem4];

    figure;
    bar(y);
    title('Mean \Delta\theta (Symmetrized)')
    xlabel('Type');
    ylabel('\Delta\theta (deg)')
    xticklabels(x);
    hold on
    er = errorbar(y,sem);
    er.Color = [0 0 0];
    er.LineStyle = 'none';
    hold off
end
