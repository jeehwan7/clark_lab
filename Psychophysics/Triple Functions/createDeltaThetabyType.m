function [deltaThetabyCoherence, deltaThetabyTripleLeft, deltaThetabyTripleRight, tripleLeftType, tripleRightType] = createDeltaThetabyType(numTrials, dThetabyTrialWithoutSaccades, coherences, directions, responses, types, parities)

    deltaThetabyCoherence = NaN(numTrials,2); % deltatheta, coherence
    deltaThetabyTripleLeft = NaN(numTrials,1); % deltatheta
    deltaThetabyTripleRight = NaN(numTrials,1); % deltatheta
    % string arrays for type
    deltaThetabyTripleLeftType = strings(numTrials,1); % type
    deltaThetabyTripleRightType = strings(numTrials,1); % type

    for ii = 1:numTrials
        if convertCharsToStrings(types(ii)) == "pairwise"
            deltaThetabyCoherence(ii,1) = sum(dThetabyTrialWithoutSaccades(ii,:),'omitnan');
            if directions(ii) == 1
                deltaThetabyCoherence(ii,2) = coherences(ii);
            elseif directions(ii) == -1
                deltaThetabyCoherence(ii,2) = -coherences(ii);
            end
        elseif convertCharsToStrings(types(ii)) == "converging" && directions(ii) == 1
            deltaThetabyTripleRight(ii) = sum(dThetabyTrialWithoutSaccades(ii,:),'omitnan');
            if parities(ii) == 1
                deltaThetabyTripleRightType(ii) = "Conv, +";
            elseif parities(ii) == -1
                deltaThetabyTripleRightType(ii) = "Conv, -";
            end
        elseif convertCharsToStrings(types(ii)) == "diverging" && directions(ii) == 1
            deltaThetabyTripleRight(ii) = sum(dThetabyTrialWithoutSaccades(ii,:),'omitnan');
            if parities(ii) == 1
                deltaThetabyTripleRightType(ii) = "Div, +";
            elseif parities(ii) == -1
                deltaThetabyTripleRightType(ii) = "Div, -";
            end
        elseif convertCharsToStrings(types(ii)) == "converging" && directions(ii) == -1
            deltaThetabyTripleLeft(ii) = sum(dThetabyTrialWithoutSaccades(ii,:),'omitnan');
            if parities(ii) == 1
                deltaThetabyTripleLeftType(ii) = "Conv, +";
            elseif parities(ii) == -1
                deltaThetabyTripleLeftType(ii) = "Conv, -";
            end
        elseif convertCharsToStrings(types(ii)) == "diverging" && directions(ii) == -1
            deltaThetabyTripleLeft(ii) = sum(dThetabyTrialWithoutSaccades(ii,:),'omitnan');
            if parities(ii) == 1
                deltaThetabyTripleLeftType(ii) = "Div, +";
            elseif parities(ii) == -1
                deltaThetabyTripleLeftType(ii) = "Div, -";
            end
        end
        % render the sum NaN if it was from an unreadable edf file
        % (i.e. if all of the values were NaN because the sum comes out as zero)
        if sum(~isnan(dThetabyTrialWithoutSaccades(ii,:))) == 0
            deltaThetabyCoherence(ii,1) = NaN;
            deltaThetabyTripleLeft(ii) = NaN;
            deltaThetabyTripleRight(ii) = NaN;
        end
    end

    % because dt = 1 ms
    deltaThetabyCoherence(:,1) = deltaThetabyCoherence(:,1)/1000;
    deltaThetabyTripleLeft = deltaThetabyTripleLeft/1000;
    deltaThetabyTripleRight = deltaThetabyTripleRight/1000;

    % response index
    leftResponseIndex = find(responses == -1);
    rightResponseIndex = find(responses == 1);
    
    % create categoricals for type
    tripleLeftType = categorical(deltaThetabyTripleLeftType);
    tripleRightType = categorical(deltaThetabyTripleRightType);

    % scatter plot for coherence
    figure;
    scatter(deltaThetabyCoherence(leftResponseIndex,2),deltaThetabyCoherence(leftResponseIndex,1));
    hold on
    scatter(deltaThetabyCoherence(rightResponseIndex,2),deltaThetabyCoherence(rightResponseIndex,1));
    hold off
    title('\Delta\theta for Coherence (Excluding Saccades)');
    yline(0,'--');
    xlabel('Coherence');
    ylabel('\Delta\theta (deg)');
    legend({'response = left','response = right'},'Location','southeast');
    
    % scatter plot for triple left
    figure;
    scatter(tripleLeftType(leftResponseIndex),deltaThetabyTripleLeft(leftResponseIndex));
    hold on
    scatter(tripleLeftType(rightResponseIndex),deltaThetabyTripleLeft(rightResponseIndex));
    hold off
    title('\Delta\theta for Triple Left (Excluding Saccades)');
    yline(0,'--');
    xlabel('type');
    ylabel('\Delta\theta (deg)');
    legend({'response = left','response = right'},'Location','northeast');

    % scatter plot for triple right
    figure;
    scatter(tripleRightType(leftResponseIndex),deltaThetabyTripleRight(leftResponseIndex));
    hold on
    scatter(tripleRightType(rightResponseIndex),deltaThetabyTripleRight(rightResponseIndex));
    hold off
    title('\Delta\theta for Triple Right (Excluding Saccades)');
    yline(0,'--');
    xlabel('type');
    ylabel('\Delta\theta (deg)');
    legend({'response = left','response = right'},'Location','northeast');
end