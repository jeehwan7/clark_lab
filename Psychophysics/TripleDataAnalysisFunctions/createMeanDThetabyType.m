function [meanDThetabyCoherence, meanDThetabyTriple, tripleType] = createMeanDThetabyType(nanThreshold, start, finish, numTrials, dThetabyTrialWithoutSaccades, coherences, directions, responses, types, parities)

    meanDThetabyCoherence = NaN(numTrials,2); % mean dtheta/dt, coherence
    meanDThetabyTriple = NaN(numTrials,1); % mean dtheta/dt
    % string arrays for type
    meanDThetabyTripleType = strings(numTrials,1); % type

    for ii = 1:numTrials
        if strcmp(types(ii),'pairwise')
            meanDThetabyCoherence(ii,1) = mean(dThetabyTrialWithoutSaccades(ii,start:finish),'omitnan');
            if directions(ii) == 1
                meanDThetabyCoherence(ii,2) = coherences(ii);
            elseif directions(ii) == -1
                meanDThetabyCoherence(ii,2) = -coherences(ii);
            end
        elseif strcmp(types(ii),'converging') && directions(ii) == 1
            meanDThetabyTriple(ii) = mean(dThetabyTrialWithoutSaccades(ii,start:finish),'omitnan');
            if parities(ii) == 1
                meanDThetabyTripleType(ii) = "conv, +";
            elseif parities(ii) == -1
                meanDThetabyTripleType(ii) = "conv, -";
            end
        elseif strcmp(types(ii),'diverging') && directions(ii) == 1
            meanDThetabyTriple(ii) = mean(dThetabyTrialWithoutSaccades(ii,start:finish),'omitnan');
            if parities(ii) == 1
                meanDThetabyTripleType(ii) = "div, +";
            elseif parities(ii) == -1
                meanDThetabyTripleType(ii) = "div, -";
            end
        elseif strcmp(types(ii),'converging') && directions(ii) == -1
            meanDThetabyTriple(ii) = -mean(dThetabyTrialWithoutSaccades(ii,start:finish),'omitnan');
            if parities(ii) == 1
                meanDThetabyTripleType(ii) = "conv, +";
            elseif parities(ii) == -1
                meanDThetabyTripleType(ii) = "conv, -";
            end
        elseif strcmp(types(ii),'diverging') && directions(ii) == -1
            meanDThetabyTriple(ii) = -mean(dThetabyTrialWithoutSaccades(ii,start:finish),'omitnan');
            if parities(ii) == 1
                meanDThetabyTripleType(ii) = "div, +";
            elseif parities(ii) == -1
                meanDThetabyTripleType(ii) = "div, -";
            end
        end
        % render the mean NaN if there are too many NaN values in the trial
        if sum(isnan(dThetabyTrialWithoutSaccades(ii,:)))>nanThreshold
            meanDThetabyCoherence(ii,1) = NaN;
            meanDThetabyTriple(ii) = NaN;
        end
    end

    % response index
    responsesSymmetrized = responses;
    responsesSymmetrized(directions == -1) = -responsesSymmetrized(directions == -1);
    leftResponseIndexSymmetrized = find(responsesSymmetrized == -1);
    rightResponseIndexSymmetrized = find(responsesSymmetrized == 1);

    leftResponseIndex = find(responses == -1);
    rightResponseIndex = find(responses == 1);
    
    % create categoricals for type
    tripleType = categorical(meanDThetabyTripleType);

    % scatter plot for coherence
    figure;
    scatter(meanDThetabyCoherence(leftResponseIndex,2),meanDThetabyCoherence(leftResponseIndex,1));
    hold on
    scatter(meanDThetabyCoherence(rightResponseIndex,2),meanDThetabyCoherence(rightResponseIndex,1));
    hold off
    title(['Mean d\theta/dt for Pairwise (Excluding Saccades, ',num2str(start),' ms to ',num2str(finish),' ms)']);
    yline(0,'--');
    xlabel('Coherence');
    ylabel('d\theta/dt (deg/s)');
    legend({'response = left','response = right'},'Location','southeast');
    
    % scatter plot for triple
    figure;
    scatter(tripleType(leftResponseIndexSymmetrized),meanDThetabyTriple(leftResponseIndexSymmetrized));
    hold on
    scatter(tripleType(rightResponseIndexSymmetrized),meanDThetabyTriple(rightResponseIndexSymmetrized));
    hold off
    title(['Mean d\theta/dt for Triple (Symmetrized, Excluding Saccades, ',num2str(start),' ms to ',num2str(finish),' ms)']);
    yline(0,'--');
    xlabel('Type');
    ylabel('d\theta/dt (deg/s)');
    legend({'response = left','response = right'},'Location','northeast');
end