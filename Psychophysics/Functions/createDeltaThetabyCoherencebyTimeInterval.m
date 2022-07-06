function deltaThetabyCoherencebyTimeInterval = createDeltaThetabyCoherencebyTimeInterval(interval, range, deltaThetabyCoherence, dThetabyTrialWithoutSaccades, coherences, directions)

    deltaThetabyCoherencebyTimeInterval = zeros(range/interval,2);
    deltaThetabyCoherencebyTimeInterval(:,2) = interval:interval:range;
    r = 1;
    for tt = 1:interval:range-interval+1
        for ii = 1:size(deltaThetabyCoherence,1)
            % sum dtheta to get deltatheta
            deltaThetabyCoherence(ii,1) = sum(dThetabyTrialWithoutSaccades(ii,1:tt+interval-1),'omitnan');
            % render the sum NaN if it was from an unreadable edf file
            % (i.e. if all of the values were NaN because the sum comes out as zero)
            if sum(~isnan(dThetabyTrialWithoutSaccades(ii,:))) == 0
                deltaThetabyCoherence(ii,1) = NaN;
            end
            % if it was a left trial, multiply the coherence by -1
            if directions(ii,1) == 1
                deltaThetabyCoherence(ii,2) = coherences(ii,1);
            elseif directions(ii,1) == -1
                deltaThetabyCoherence(ii,2) = -coherences(ii,1);
            end
        end
        x = deltaThetabyCoherence(:,2);
        y = deltaThetabyCoherence(:,1);
        index = isnan(y);
        p = polyfit(x(~index),y(~index),1);
        deltaThetabyCoherencebyTimeInterval(r,1) = p(1);
        r = r+1;
    end
    % scatter plot
    figure;
    scatter(deltaThetabyCoherencebyTimeInterval(:,2),deltaThetabyCoherencebyTimeInterval(:,1));
    title('\Delta\theta / Coherence');
    yline(0,'--');
    xlabel(['Time Interval = ',num2str(interval),' (ms)']);
    ylabel('\Delta\theta (rad) / Coherence');

end