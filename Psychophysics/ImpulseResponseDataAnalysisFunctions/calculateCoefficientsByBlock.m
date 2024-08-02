function Q = calculateCoefficientsByBlock(Q,param)

    % block by block coefficients
    Q.bbbCoefficients = NaN(param.numBlocks,Q.numCoefficients);

    for kk = 1:param.numBlocks
        tempS = NaN(param.numTrialsPerBlock*Q.updateRate*Q.stimDuration,Q.numCoefficients); % all the stimulus velocities (deg/frame)
        tempR = NaN(param.numTrialsPerBlock*Q.updateRate*Q.stimDuration,1); % all the response velocities (deg/s)

        for ll = (1:param.numTrialsPerBlock)+(kk-1)*param.numTrialsPerBlock
            for mm = 1:(Q.updateRate*Q.stimDuration)
                if ~isnan(Q.downSampledNormalized(ll,mm))
                    tempR(mod(ll-1,param.numTrialsPerBlock)*Q.updateRate*Q.stimDuration+mm) = Q.downSampledNormalized(ll,mm);
                    tempS(mod(ll-1,param.numTrialsPerBlock)*Q.updateRate*Q.stimDuration+mm,:) = flip(Q.directionsNormalized(ll,(mm-Q.numCoefficients):(mm-1)));
                end
            end
        end

        % clean up tempR and tempS
        index = ~isnan(tempR);
        tempR = tempR(index); % remove NaN values in tempR
        tempS = tempS(index,:); % make tempS match with tempR

        Q.bbbCoefficients(kk,:) = tempS\tempR;
    end

    % plot unfiltered coefficients
    figure;
    x = (1:Q.numCoefficients)*1000/Q.updateRate;
    color = colormap(cool(param.numBlocks)); % colormap
    leg = cell(param.numBlocks*2,1); % legend
    for ii = 1:param.numBlocks
        s = std(Q.tbtCoefficients((1:param.numTrialsPerBlock)+(ii-1)*param.numTrialsPerBlock,:),0,1);
        sem = s/sqrt(param.numTrialsPerBlock);

        z = Q.bbbCoefficients(ii,:);

        patch([x fliplr(x)],[z-sem  fliplr(z+sem)],color(ii,:),'FaceAlpha',0.2,'EdgeColor','none');
        leg{ii*2-1} = '';
        hold on

        plot(x,z,'Color',color(ii,:),'LineWidth',2);
        leg{ii*2} = ['block ',num2str(ii)];
        hold on
    end
    hold off

    yline(0,'--');
    title('Impulse Response');
    xlabel('-t (ms)');
    ylabel('weighting');
    legend(leg)
    legend('Location','northeast');

    % filter
    b = [1/4 1/2 1/4];
    a = 1;

    % plot filtered coefficients
    figure;
    x = (1:Q.numCoefficients)*1000/Q.updateRate;
    color = colormap(cool(param.numBlocks)); % colormap
    leg = cell(param.numBlocks*2,1); % legend
    for ii = 1:param.numBlocks
        s = std(Q.tbtCoefficientsFiltered((1:param.numTrialsPerBlock)+(ii-1)*param.numTrialsPerBlock,:),0,1);
        sem = s/sqrt(param.numTrialsPerBlock);

        z = filtfilt(b,a,Q.bbbCoefficients(ii,:));

        patch([x fliplr(x)],[z-sem  fliplr(z+sem)],color(ii,:),'FaceAlpha',0.2,'EdgeColor','none');
        leg{ii*2-1} = '';
        hold on

        plot(x,z,'Color',color(ii,:),'LineWidth',2);
        leg{ii*2} = ['block ',num2str(ii)];
        hold on
    end
    hold off

    yline(0,'--');
    title('Impulse Response');
    xlabel('-t (ms)');
    ylabel('weighting');
    legend(leg)
    legend('Location','northeast');

end