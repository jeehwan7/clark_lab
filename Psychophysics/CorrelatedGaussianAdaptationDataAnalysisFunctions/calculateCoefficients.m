function Q = calculateCoefficients(Q, durationInfo)

    original = [nan(Q.numTrials,1) Q.stimEyeXVelwithoutSaccades]; % matrix with original velocities
                                                                  % added a column of NaNs because there is no velocity to begin with
    Q.numCoefficients = Q.updateRate/2;
    range = floor(1000/Q.updateRate/2); % will average the original velocity from index-range to index+range to downsample

    Q.downSampledIndex = NaN(Q.numTrials,Q.updateRate*Q.stimDuration); % index is the ms that corresponds to the downsampled velocity (when the corresponding frame was presented, since we downsampling to the frame rate)
    Q.downSampled = NaN(Q.numTrials,Q.updateRate*Q.stimDuration); % matrix with downsampled velocities

    for ii = 1:Q.numTrials % for each trial

        timeElapsed = durationInfo(ii).stimDurationInfo{:,"timeElapsed"}; % extract the time elapsed (in secs) by the start of each frame
    
        for jj = 1:(Q.updateRate*Q.stimDuration) % want to find the number of ms passed by the start of each frame
            if jj == 1
                Q.downSampledIndex(ii,jj) = 0; % no time has passed by the start of the 1st frame
            else
                Q.downSampledIndex(ii,jj) = round(timeElapsed(jj)*1000); % otherwise calculate time passed (multiply by 1000 to convert from sec to ms)
            end
        end
        
        for kk = 1:(Q.updateRate*Q.stimDuration) % want to find the average velocity at the start of each frame
            if kk <= (Q.numCoefficients + 1)
                Q.downSampled(ii,kk) = NaN; % the first stimulus velocity is NaN and we want at least "Q.numCoefficients" preceding stimulus velocities
            else
                try
                    % average from index-range to index_range ms
                    Q.downSampled(ii,kk) = mean(original(ii,(Q.downSampledIndex(ii,kk)-range):(Q.downSampledIndex(ii,kk)+range)));
                catch
                    warning('Error while creating Q.downSampled (downsampled response velocities). Most likely a slip during stimulus presentation. Check Q.downSampledIndex.');
                    % average from index-range to index ms instead
                    Q.downSampled(ii,kk) = mean(original(ii,(Q.downSampledIndex(ii,kk)-range):Q.downSampledIndex(ii,kk)));
                end
            end
        end
    end

    Q.stimVelocitiesNormalized = NaN(Q.numTrials,Q.updateRate*Q.stimDuration);
    Q.downSampledNormalized = NaN(Q.numTrials,Q.updateRate*Q.stimDuration);

    % normalize stimulus velocities of each trial
    for ii = 1:Q.numTrials
        Q.stimVelocitiesNormalized(ii,:) = Q.stimVelocities(ii,:) - mean(Q.stimVelocities(ii,:),'omitnan');
    end
    % normalize eye velocities of each trial
    for ii = 1:Q.numTrials
        Q.downSampledNormalized(ii,:) = Q.downSampled(ii,:) - mean(Q.downSampled(ii,:),'omitnan');
    end

    % build the matrix for regression
    S = NaN(Q.numTrials*Q.updateRate*Q.stimDuration,Q.numCoefficients); % all the stimulus velocities (deg/s)
    R = NaN(Q.numTrials*Q.updateRate*Q.stimDuration,1); % all the response velocities (deg/s)
    for kk = 1:Q.numTrials
        for ll = 1:(Q.updateRate*Q.stimDuration)
            if ~isnan(Q.downSampledNormalized(kk,ll))
                R((kk-1)*Q.updateRate*Q.stimDuration+ll) = Q.downSampledNormalized(kk,ll);
                S((kk-1)*Q.updateRate*Q.stimDuration+ll,:) = flip(Q.stimVelocitiesNormalized(kk,(ll-Q.numCoefficients):(ll-1)));
            end
        end
    end

    % clean up R and S
    index = ~isnan(R);
    R = R(index); % remove NaN values in R
    S = S(index,:); % make S's number of rows match with number of elements in R

    % calculate coefficients
    Q.coefficients = S\R * Q.updateRate; % must multiply by update rate because we are working with a Riemann sum
                                         % (therefore unit = 1/time; in this case I'm choosing Hz)

    % calculate trial by trial coefficients
    Q.tbtCoefficients = NaN(Q.numTrials,Q.numCoefficients);

    for kk = 1:Q.numTrials
        tempS = NaN(Q.updateRate*Q.stimDuration,Q.numCoefficients); % all the stimulus velocities (deg/s)
        tempR = NaN(Q.updateRate*Q.stimDuration,1); % all the response velocities (deg/s)

        for ll = 1:(Q.updateRate*Q.stimDuration)
            if ~isnan(Q.downSampledNormalized(kk,ll))
                tempR(ll) = Q.downSampledNormalized(kk,ll);
                tempS(ll,:) = flip(Q.stimVelocitiesNormalized(kk,(ll-Q.numCoefficients):(ll-1)));
            end
        end

        % clean up tempR and tempS
        index = ~isnan(tempR);
        tempR = tempR(index); % remove NaN values in tempR
        tempS = tempS(index,:); % make tempS's number of rows match with number of elements in tempR

        Q.tbtCoefficients(kk,:) = tempS\tempR * Q.updateRate;
    end

    % =================================================================== %

    % obtain standard error using unfiltered trial by trial coefficients
    s = std(Q.tbtCoefficients,0,1);
    sem = s/sqrt(Q.numTrials);

    % plot coefficients (unfiltered)
    x = (1:Q.numCoefficients)/Q.updateRate;
    figure;
    patch([x fliplr(x)],[rot90(Q.coefficients)-sem  fliplr(rot90(Q.coefficients)+sem)],[0 0.4470 0.7410],'FaceAlpha',0.2,'EdgeColor','none');
    hold on
    plot(x,Q.coefficients,'LineWidth',2);
    hold off
    yline(0,'--');
    title('Impulse Response (Unfiltered)');
    xlabel('-t (s)');
    ylabel('weighting (Hz)');

    % filter
    b = [1/4 1/2 1/4];
    a = 1;

    % filter coefficients
    Q.coefficientsFiltered = filtfilt(b,a,Q.coefficients);

    % filter trial by trial coefficients
    for ii = 1:Q.numTrials
        Q.tbtCoefficientsFiltered(ii,:) = filtfilt(b,a,Q.tbtCoefficients(ii,:));
    end

    % obtain standard error using filtered trial by trial coefficients
    s = std(Q.tbtCoefficientsFiltered,0,1);
    sem = s/sqrt(Q.numTrials);    

    % Plot coefficients (filtered)
    x = (1:Q.numCoefficients)/Q.updateRate;
    figure;
    patch([x fliplr(x)],[rot90(Q.coefficientsFiltered)-sem  fliplr(rot90(Q.coefficientsFiltered)+sem)],[0 0.4470 0.7410],'FaceAlpha',0.2,'EdgeColor','none');
    hold on
    plot(x,Q.coefficientsFiltered,'LineWidth',2);
    hold off
    yline(0,'--');
    title('Impulse Response (Filtered)');
    xlabel('-t (s)');
    ylabel('weighting (Hz)');

    % trial by trial ==================================================== %

    color = colormap(cool(Q.numTrials)); % colormap

    % plot trial by trial coefficients (unfiltered)
    x = (1:Q.numCoefficients)/Q.updateRate;
    leg = cell(Q.numTrials,1); % legend
    figure;
    for ii = 1:Q.numTrials
        plot(x,Q.tbtCoefficients(ii,:),'Color',color(ii,:),'LineWidth',2);
        hold on
        leg{ii} = ['trial ',num2str(ii)];
    end
    hold off
    yline(0,'--');
    title('Impulse Responses (Unfiltered)');
    xlabel('-t (s)');
    ylabel('weighting (Hz)');
    legend(leg);
    legend('Location','northeast');

    % plot trial by trial coefficients (filtered)
    x = (1:Q.numCoefficients)/Q.updateRate;
    leg = cell(Q.numTrials,1); % legend
    figure;
    for ii = 1:Q.numTrials
        plot(x,Q.tbtCoefficientsFiltered(ii,:),'Color',color(ii,:),'LineWidth',2);
        hold on
        leg{ii} = ['trial ',num2str(ii)];
    end
    hold off
    yline(0,'--');
    title('Impulse Responses (Filtered)');
    xlabel('-t (s)');
    ylabel('weighting (Hz)');
    legend(leg);
    legend('Location','northeast');

    % statistics ======================================================== %

    % plot peaks
    peaks = NaN(1,Q.numTrials);
    for ii = 1:Q.numTrials
        peaks(ii) = max(Q.tbtCoefficients(ii,:));
    end
    figure;
    plot(1:Q.numTrials,peaks);
    hold on
    scatter(1:Q.numTrials,peaks);
    yline(0,'--');
    title('Impulse Response Peaks');
    xlabel('trial');
    ylabel('weighting (Hz)');

    % plot cumsums
    cumsums = NaN(1,Q.numTrials);
    for ii = 1:Q.numTrials
        cumsums(ii) = sum(Q.tbtCoefficients(ii,:))/Q.updateRate;
    end
    figure;
    plot(1:Q.numTrials,cumsums);
    hold on
    scatter(1:Q.numTrials,cumsums);
    yline(0,'--');
    title('Impulse Response Cumulative Sums');
    xlabel('trial');
    ylabel('cumulative sum');

    %{
    % calculate rsqs
    for ii = 1:Q.numTrials
        Rhat = S*Q.tbtCoefficients(ii)/Q.updateRate;
        Q(ii).rsq = 1 - sum((R - Rhat).^2)/sum((R - mean(R)).^2);
    end

    % plot rsqs
    figure;
    scatter(1:Q.numTrials,horzcat(Q.rsq));
    title('R-Squared Values');
    xlabel('trial');
    ylabel('rsq');
    %}

