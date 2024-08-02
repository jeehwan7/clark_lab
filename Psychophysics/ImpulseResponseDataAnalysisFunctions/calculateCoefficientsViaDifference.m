function Q = calculateCoefficientsViaDifference(Q)

    Q.velocityDifference = Q.stimVelocity - Q.downSampled; % deg/s

    % normalize
    Q.velocityDifferenceNormalized = NaN(Q.numTrials,Q.updateRate*Q.stimDuration);
    for jj = 1:Q.numTrials
        Q.velocityDifferenceNormalized(jj,:) = Q.velocityDifference(jj,:) - mean(Q.velocityDifference(jj,:),'omitnan');
    end

    % build the matrix for regression
    D = NaN(Q.numTrials*Q.updateRate*Q.stimDuration,Q.numCoefficients); % all the velocity differences (deg/s)
    R = NaN(Q.numTrials*Q.updateRate*Q.stimDuration,1); % all the response velocities (deg/s)
    for kk = 1:Q.numTrials
        for ll = 1:(Q.updateRate*Q.stimDuration)
            if ~isnan(Q.downSampledNormalized(kk,ll))
                R((kk-1)*Q.updateRate*Q.stimDuration+ll) = Q.downSampledNormalized(kk,ll);
                D((kk-1)*Q.updateRate*Q.stimDuration+ll,:) = flip(Q.velocityDifferenceNormalized(kk,(ll-Q.numCoefficients):(ll-1)));
            end
        end
    end

    % clean up R and D
    index = ~isnan(R);
    R = R(index); % remove NaN values in R
    D = D(index,:); % make D match with R

    rows = [];
    for ii = 1:size(D,1)
        if sum(isnan(D(ii,:))) > 0 % if there is a NaN value in the row
            rows = [ii rows]; % record that row
        end
    end
    D(rows,:) = []; % remove rows in D
    R(rows) = []; % make R match with D

    Q.ddd = D;
    Q.rrr = R;
    
    Q.coefficientsViaDifference = D\R; % calculate coefficients

    % calculate trial by trial coefficients (for standard error)
    Q.tbtCoefficientsViaDifference = NaN(Q.numTrials,Q.numCoefficients);

    for kk = 1:Q.numTrials
        tempD = NaN(Q.updateRate*Q.stimDuration,Q.numCoefficients); % all the directions
        tempR = NaN(Q.updateRate*Q.stimDuration,1); % all the velocities

        for ll = 1:(Q.updateRate*Q.stimDuration)
            if ~isnan(Q.downSampledNormalized(kk,ll))
                tempR(ll) = Q.downSampledNormalized(kk,ll);
                tempD(ll,:) = flip(Q.velocityDifferenceNormalized(kk,(ll-Q.numCoefficients):(ll-1)));
            end
        end

        % clean up tempR and tempD
        index = ~isnan(tempR);
        tempR = tempR(index); % remove NaN values in tempR
        tempD = tempD(index,:); % make tempD match with tempR

        rows = [];
        for ii = 1:size(tempD,1)
            if sum(isnan(tempD(ii,:))) > 0 % if there is a NaN value in the row
                rows = [ii rows]; % record that row
            end
        end
        tempD(rows,:) = []; % remove rows in tempD
        tempR(rows) = []; % make tempR match with tempD

        Q.tbtCoefficientsViaDifference(kk,:) = tempD\tempR;
    end

    % filter coefficients
    b = [1/4 1/2 1/4];
    a = 1;
    z = filtfilt(b,a,Q.coefficientsViaDifference);

    % filter trial by trial coefficients
    for ii = 1:Q.numTrials
        Q.tbtCoefficientsViaDifferenceFiltered(ii,:) = filtfilt(b,a,Q.tbtCoefficientsViaDifference(ii,:));
    end

    % obtain standard error using filtered trial by trial coefficients
    s = std(Q.tbtCoefficientsViaDifferenceFiltered,0,1);
    sem = s/sqrt(Q.numTrials);    

    % plot impulse response
    x = (1:Q.numCoefficients)*1000/Q.updateRate;
    figure;
    patch([x fliplr(x)],[rot90(z)-sem  fliplr(rot90(z)+sem)],[0 0.4470 0.7410],'FaceAlpha',0.2,'EdgeColor','none');
    hold on
    plot(x,z,'LineWidth',2);
    hold off
    yline(0,'--');
    title('Overall Impulse Response (Via Velocity Difference)');
    xlabel('-t (ms)');
    ylabel('weighting');

    % plot cumsum
    figure;
    plot((1:Q.numCoefficients)*1000/Q.updateRate,filtfilt(b,a,cumsum(Q.coefficientsViaDifference)));
    yline(0,'--');
    title('Cumulative Sum (Via Velocity Difference)');
    xlabel('-t (ms)');

    % calculate rsq
    Rhat = D*Q.coefficientsViaDifference;
    Q.rsqCoefficientsViaDifference = 1 - sum((R - Rhat).^2)/sum((R - mean(R)).^2);

end