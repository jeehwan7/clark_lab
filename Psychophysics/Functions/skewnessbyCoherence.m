function skewnessbyCoherence = skewnessbyCoherence(numTrials, dThetabyTrial, coherences, directions)

    skewnessbyCoherence = zeros(numTrials,2);
    for ii = 1:size(skewnessbyCoherence)
        skewnessbyCoherence(ii,1) = skewness(dThetabyTrial(ii,:));
        % if it was a left trial, multiply the coherence by -1
        if directions(ii,1) == 1
            skewnessbyCoherence(ii,2) = coherences(ii,1);
        elseif directions(ii,1) == -1
            skewnessbyCoherence(ii,2) = -coherences(ii,1);
        end
    end
    
    figure;
    scatter(skewnessbyCoherence(:,2),skewnessbyCoherence(:,1));
    title('Skewness');
    yline(0,'--');
    xlabel('Coherence');
    ylabel('Skewness');

end