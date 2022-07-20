function [deltaThetabyCoherence, deltaThetabyTriple, tripleType] = createDeltaThetabyType(numTrials, dThetabyTrialWithoutSaccades, coherences, directions, responses, types, parities)

    deltaThetabyCoherence = NaN(numTrials,2); % deltatheta, coherence
    deltaThetabyTriple = NaN(numTrials,1); % deltatheta
    % string arrays for type
    deltaThetabyTripleType = strings(numTrials,1); % type

    for ii = 1:numTrials
        if convertCharsToStrings(types(ii)) == "pairwise"
            deltaThetabyCoherence(ii,1) = sum(dThetabyTrialWithoutSaccades(ii,:),'omitnan');
            if directions(ii) == 1
                deltaThetabyCoherence(ii,2) = coherences(ii);
            elseif directions(ii) == -1
                deltaThetabyCoherence(ii,2) = -coherences(ii);
            end
        elseif convertCharsToStrings(types(ii)) == "converging" && directions(ii) == 1
            deltaThetabyTriple(ii) = sum(dThetabyTrialWithoutSaccades(ii,:),'omitnan');
            if parities(ii) == 1
                deltaThetabyTripleType(ii) = "conv, +";
            elseif parities(ii) == -1
                deltaThetabyTripleType(ii) = "conv, -";
            end
        elseif convertCharsToStrings(types(ii)) == "diverging" && directions(ii) == 1
            deltaThetabyTriple(ii) = sum(dThetabyTrialWithoutSaccades(ii,:),'omitnan');
            if parities(ii) == 1
                deltaThetabyTripleType(ii) = "div, +";
            elseif parities(ii) == -1
                deltaThetabyTripleType(ii) = "div, -";
            end
        elseif convertCharsToStrings(types(ii)) == "converging" && directions(ii) == -1
            deltaThetabyTriple(ii) = -sum(dThetabyTrialWithoutSaccades(ii,:),'omitnan');
            if parities(ii) == 1
                deltaThetabyTripleType(ii) = "conv, +";
            elseif parities(ii) == -1
                deltaThetabyTripleType(ii) = "conv, -";
            end
        elseif convertCharsToStrings(types(ii)) == "diverging" && directions(ii) == -1
            deltaThetabyTriple(ii) = -sum(dThetabyTrialWithoutSaccades(ii,:),'omitnan');
            if parities(ii) == 1
                deltaThetabyTripleType(ii) = "div, +";
            elseif parities(ii) == -1
                deltaThetabyTripleType(ii) = "div, -";
            end
        end
        % render the sum NaN if it was from an unreadable edf file
        % (i.e. if all of the values were NaN because the sum comes out as zero)
        if sum(~isnan(dThetabyTrialWithoutSaccades(ii,:))) == 0
            deltaThetabyCoherence(ii,1) = NaN;
            deltaThetabyTriple(ii) = NaN;
        end
    end

    % because dt = 1 ms
    deltaThetabyCoherence(:,1) = deltaThetabyCoherence(:,1)/1000;
    deltaThetabyTriple = deltaThetabyTriple/1000;

    % response index
    responsesSymmetrized = responses;
    responsesSymmetrized(directions == -1) = -responsesSymmetrized(directions == -1);
    leftResponseIndexSymmetrized = find(responsesSymmetrized == -1);
    rightResponseIndexSymmetrized = find(responsesSymmetrized == 1);

    leftResponseIndex = find(responses == -1);
    rightResponseIndex = find(responses == 1);
    
    % create categoricals for type
    tripleType = categorical(deltaThetabyTripleType);

    % scatter plot for coherence
    figure;
    scatter(deltaThetabyCoherence(leftResponseIndex,2),deltaThetabyCoherence(leftResponseIndex,1));
    hold on
    scatter(deltaThetabyCoherence(rightResponseIndex,2),deltaThetabyCoherence(rightResponseIndex,1));
    hold off
    title('\Delta\theta for Pairwise (Excluding Saccades)');
    yline(0,'--');
    xlabel('Coherence');
    ylabel('\Delta\theta (deg)');
    legend({'response = left','response = right'},'Location','southeast');
    
    % scatter plot for triple
    figure;
    scatter(tripleType(leftResponseIndexSymmetrized),deltaThetabyTriple(leftResponseIndexSymmetrized));
    hold on
    scatter(tripleType(rightResponseIndexSymmetrized),deltaThetabyTriple(rightResponseIndexSymmetrized));
    hold off
    title('\Delta\theta for Triple (Symmetrized, Excluding Saccades)');
    yline(0,'--');
    xlabel('type');
    ylabel('\Delta\theta (deg)');
    legend({'response = left','response = right'},'Location','northeast');
end