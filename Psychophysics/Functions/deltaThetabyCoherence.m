function deltaThetabyCoherence = deltaThetabyCoherence(numTrials, removeSaccades, coherences, directions)

    deltaThetabyCoherence = zeros(numTrials,2); % deltatheta, coherence (in that order)

    for ii = 1:size(deltaThetabyCoherence,1)
        % sum dtheta to get deltatheta
        deltaThetabyCoherence(ii,1) = sum(removeSaccades(ii,:),'omitnan');
        % render the sum NaN if it was from an unreadable edf file
        % (i.e. if all of the values were NaN because the sum comes out as zero)
        if sum(~isnan(removeSaccades(ii,:))) == 0
            deltaThetabyCoherence(ii,1) = NaN;
        end
        % if it was a left trial, multiply the coherence by -1
        if directions(ii,1) == 1
            deltaThetabyCoherence(ii,2) = coherences(ii,1);
        elseif directions(ii,1) == -1
            deltaThetabyCoherence(ii,2) = -coherences(ii,1);
        end
    end
    % scatter plot
    figure;
    scatter(deltaThetabyCoherence(:,2),deltaThetabyCoherence(:,1));
    title('\Delta\theta (Excluding Saccades');
    yline(0,'--');
    xlabel('Coherence');
    ylabel('\Delta\theta (radians)');
    
end