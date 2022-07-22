function deltaThetabyCoherence = createDeltaThetabyCoherence(nanThreshold, numTrials, dThetabyTrialWithoutSaccades, coherences, directions, responses)

    deltaThetabyCoherence = zeros(numTrials,2); % deltatheta, coherence (in that order)

    for ii = 1:size(deltaThetabyCoherence,1)
        % sum dtheta to get deltatheta
        deltaThetabyCoherence(ii,1) = sum(dThetabyTrialWithoutSaccades(ii,:),'omitnan');
        % render the sum NaN if there are too many NaN values in the trial
        if sum(isnan(dThetabyTrialWithoutSaccades(ii,:)))>nanThreshold
            deltaThetabyCoherence(ii,1) = NaN;
        end
        % if it was a left trial, multiply the coherence by -1
        if directions(ii,1) == 1
            deltaThetabyCoherence(ii,2) = coherences(ii,1);
        elseif directions(ii,1) == -1
            deltaThetabyCoherence(ii,2) = -coherences(ii,1);
        end
    end
    deltaThetabyCoherence(:,1) = deltaThetabyCoherence(:,1)/1000;
    % index
    leftResponseIndex = find(responses == -1);
    rightResponseIndex = find(responses == 1);
    % scatter plot
    figure;
    scatter(deltaThetabyCoherence(leftResponseIndex,2),deltaThetabyCoherence(leftResponseIndex,1));
    hold on
    scatter(deltaThetabyCoherence(rightResponseIndex,2),deltaThetabyCoherence(rightResponseIndex,1));
    hold off
    title('\Delta\theta (Excluding Saccades)');
    yline(0,'--');
    xlabel('Coherence');
    ylabel('\Delta\theta (deg)');
    legend({'response = left','response = right'},'Location','southeast');
    
end