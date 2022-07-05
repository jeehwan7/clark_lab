function deltaThetabyTimeInterval = deltaThetabyTimeInterval(interval, deltaThetabyCoherence, removeSaccades, coherences, directions)

    deltaThetabyTimeInterval = zeros(200/interval,2);
    deltaThetabyTimeInterval(:,2) = interval:interval:200;
    r = 1;
    for tt = 1:interval:200-interval+1
        for ii = 1:size(deltaThetabyCoherence,1)
            % sum dtheta to get deltatheta
            deltaThetabyCoherence(ii,1) = sum(removeSaccades(ii,interval:tt+interval-1),'omitnan');
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
        x = deltaThetabyCoherence(:,2);
        y = deltaThetabyCoherence(:,1);
        index = isnan(y);
        p = polyfit(x(~index),y(~index),1);
        deltaThetabyTimeInterval(r,1) = p(1);
        r = r+1;
    end
    % scatter plot
    figure;
    scatter(deltaThetabyTimeInterval(:,2),deltaThetabyTimeInterval(:,1));
    title('\Delta\theta / Coherence');
    yline(0,'--');
    xlabel(['Time Interval = ',num2str(interval),' (ms)']);
    ylabel('\Delta\theta (rad) / Coherence');

end