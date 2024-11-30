function Q = calculateCoefficients(Q, results)

    original = [nan(Q.numTrials,1) Q.eyeVelocityWithoutSaccades]; % matrix with original velocities (without saccades)
                                                                  % added column of NaNs because there is no velocity in the beginning
    Q.numCoefficients = Q.updateRate/2;
    range = floor(1000/Q.updateRate/2); % will average original velocities from index-range to index+range to downsample

    Q.downSampledIndex = NaN(Q.numTrials,Q.updateRate*Q.stimDuration);
    % index is the ms passed since the presentation of the first frame
    % when the frame corresponding to the downsampled velocity was presented,
    % since we are downsampling to the frame rate
    Q.downSampled = NaN(Q.numTrials,Q.updateRate*Q.stimDuration); % matrix with downsampled velocities

    for ii = 1:Q.numTrials % for each trial

        timeElapsed = results(ii).durationInfo{:,"timeElapsed"}; % extract the time elapsed (in secs) by the start of each frame
    
        for jj = 1:(Q.updateRate*Q.stimDuration) % want to find the number of ms passed by the start of each frame
            if jj == 1
                Q.downSampledIndex(ii,jj) = 0; % no time has passed by the start of the 1st frame
            else
                Q.downSampledIndex(ii,jj) = round(timeElapsed(jj)*1000); % otherwise calculate time passed (multiply by 1000 to convert from sec to ms)
            end
        end
        
        for kk = 1:(Q.updateRate*Q.stimDuration) % want to find average velocity at the start of each frame
            if kk <= (Q.numCoefficients + 1)
                Q.downSampled(ii,kk) = NaN; % the first stimulus velocity is NaN and we want at least "Q.numCoefficients" preceding stimulus velocities
            else
                try
                    % average from index-range to index+range ms
                    Q.downSampled(ii,kk) = mean(original(ii,(Q.downSampledIndex(ii,kk)-range):(Q.downSampledIndex(ii,kk)+range)));
                catch
                    warning('Error while creating Q.downSampled (downsampled response velocities). Most likely due to slip during stimulus presentation. Check Q.downSampledIndex.');
                    Q.downSampled(ii,kk) = mean(original(ii,(Q.downSampledIndex(ii,kk)-range):Q.downSampledIndex(ii,kk)));
                end
            end
        end
    end

    Q.stimVelocityNormalized = NaN(Q.numTrials,Q.updateRate*Q.stimDuration);
    Q.downSampledNormalized = NaN(Q.numTrials,Q.updateRate*Q.stimDuration);

    % normalize eye velocities of each trial
    for jj = 1:Q.numTrials
        Q.downSampledNormalized(jj,:) = Q.downSampled(jj,:) - mean(Q.downSampled(jj,:),'omitnan');
    end
    % normalize stimulus velocities of each trial
    for jj = 1:Q.numTrials
        Q.stimVelocityNormalized(jj,:) = Q.stimVelocity(jj,:) - mean(Q.stimVelocity(jj,:),'omitnan');
    end

    % build the matrix for regression
    S = NaN(Q.numTrials*Q.updateRate*Q.stimDuration,Q.numCoefficients); % all the stimulus velocities (deg/s)
    R = NaN(Q.numTrials*Q.updateRate*Q.stimDuration,1); % all the response velocities (deg/s)
    for kk = 1:Q.numTrials
        for ll = 1:(Q.updateRate*Q.stimDuration)
            if ~isnan(Q.downSampledNormalized(kk,ll))
                R((kk-1)*Q.updateRate*Q.stimDuration+ll) = Q.downSampledNormalized(kk,ll);
                S((kk-1)*Q.updateRate*Q.stimDuration+ll,:) = flip(Q.stimVelocityNormalized(kk,(ll-Q.numCoefficients):(ll-1)));
            end
        end
    end

    % clean up R and S
    index = ~isnan(R);
    R = R(index); % remove NaN values in R
    S = S(index,:); % make S's number of rows match with number of elements in R

    % calculate coefficients
    Q.coefficients = S\R;
    Q.coefficientsNormalized = Q.coefficients/norm(Q.coefficients); % make 2-norm = 1

    % calculate trial by trial coefficients
    Q.tbtCoefficients = NaN(Q.numTrials,Q.numCoefficients);
    Q.tbtCoefficientsNormalized = NaN(Q.numTrials,Q.numCoefficients);

    for kk = 1:Q.numTrials
        tempS = NaN(Q.updateRate*Q.stimDuration,Q.numCoefficients); % all the stimulus velocities (deg/s)
        tempR = NaN(Q.updateRate*Q.stimDuration,1); % all the response velocities (deg/s)

        for ll = 1:(Q.updateRate*Q.stimDuration)
            if ~isnan(Q.downSampledNormalized(kk,ll))
                tempR(ll) = Q.downSampledNormalized(kk,ll);
                tempS(ll,:) = flip(Q.stimVelocityNormalized(kk,(ll-Q.numCoefficients):(ll-1)));
            end
        end

        % clean up tempR and tempS
        index = ~isnan(tempR);
        tempR = tempR(index); % remove NaN values in tempR
        tempS = tempS(index,:); % make tempS's number of rows match with number of elements in tempR

        % calculate coefficients
        mdl = fitlm(tempS,tempR,'Intercept',false);
        Q.tbtCoefficients(kk,:) = mdl.Coefficients.Estimate;
        Q.tbtCoefficientsCI(:,:,kk) = coefCI(mdl);

        Q.tbtCoefficientsNormalized(kk,:) = Q.tbtCoefficients(kk,:)/norm(Q.tbtCoefficients(kk,:)); % make L2-norm = 1
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
    ylabel('coefficient (1/frame)');

    %{
    % filter
    b = [1/2 1/2];
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

    % plot coefficients (filtered)
    x = (1:Q.numCoefficients)/Q.updateRate;
    figure;
    patch([x fliplr(x)],[rot90(Q.coefficientsFiltered)-sem  fliplr(rot90(Q.coefficientsFiltered)+sem)],[0 0.4470 0.7410],'FaceAlpha',0.2,'EdgeColor','none');
    hold on
    plot(x,Q.coefficientsFiltered,'LineWidth',2);
    hold off
    yline(0,'--');
    title('Impulse Response (Filtered)');
    xlabel('-t (s)');
    ylabel('coefficient (1/frame)');
    %}

    % plot trial by trial coefficients (unfiltered)

    color = colormap(cool(Q.numTrials));

    x = (1:Q.numCoefficients)/Q.updateRate;
    leg = cell(Q.numTrials*2,1); % legend
    figure;
    for ii = 1:Q.numTrials
        % confidence intervals
        patch([x fliplr(x)],[rot90(Q.tbtCoefficientsCI(:,1,ii)) fliplr(rot90(Q.tbtCoefficientsCI(:,2,ii)))],color(ii,:),'FaceAlpha',0.2,'EdgeColor','none')
        hold on
        leg{ii*2-1} = '';
        % coefficients
        plot(x,Q.tbtCoefficients(ii,:),'Color',color(ii,:),'LineWidth',2);
        hold on
        leg{ii*2} = ['trial ',num2str(ii)];
    end
    hold off
    yline(0,'--');
    title('Impulse Responses (Unfiltered)');
    xlabel('-t (s)');
    ylabel('coefficient (1/frame)');
    legend(leg);
    legend('Location','northeast');

    %{
    % calculate rsq
    Rhat = S*Q.coefficients;
    Q.rsqCoefficients = 1 - sum((R - Rhat).^2)/sum((R - mean(R)).^2);
    %}