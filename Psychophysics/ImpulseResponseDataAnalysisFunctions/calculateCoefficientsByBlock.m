function Q = calculateCoefficientsByBlock(Q,param,directions)

    % block by block coefficients
    Q.bbbCoefficients = NaN(param.numBlocks,Q.numCoefficients);

    for kk = 1:param.numBlocks
        tempD = NaN(param.numTrialsPerBlock*Q.updateRate*Q.stimDuration,Q.numCoefficients); % all the directions
        tempV = NaN(param.numTrialsPerBlock*Q.updateRate*Q.stimDuration,1); % all the velocities      

        for ll = (1:param.numTrialsPerBlock)+(kk-1)*param.numTrialsPerBlock
            for mm = 1:(Q.updateRate*Q.stimDuration)
                if ~isnan(Q.downSampled(ll,mm))
                    tempV(mod(ll-1,param.numTrialsPerBlock)*Q.updateRate*Q.stimDuration+mm) = Q.downSampled(ll,mm);
                    tempD(mod(ll-1,param.numTrialsPerBlock)*Q.updateRate*Q.stimDuration+mm,:) = flip(directions(ll,(mm-Q.numCoefficients):(mm-1)));
                end
            end
        end

        tempV = tempV(~isnan(tempV));

        rows = [];
        for ii = 1:size(tempD,1)
            if sum(isnan(tempD(ii,:))) == Q.numCoefficients
                rows = [ii rows];
            end
        end

        tempD(rows,:) = [];

        Q.bbbCoefficients(kk,:) = tempD\tempV;
    end

    % filter
    b = [1/4 1/2 1/4];
    a = 1;

    % plot
    figure;
    x = (1:Q.numCoefficients)*1000/Q.updateRate;
    color = colormap(cool(param.numBlocks)); % colormap
    leg = cell(param.numBlocks*2,1); % legend
    for ii = 1:param.numBlocks
        s = std(Q.tbtCoefficients((1:param.numTrialsPerBlock)+(ii-1)*param.numTrialsPerBlock,:),0,1);
        sem = s/sqrt(param.numTrialsPerBlock);

        z = filtfilt(b,a,Q.bbbCoefficients(ii,:));

        patch([x fliplr(x)],[z-sem  fliplr(z+sem)],color(ii),'FaceAlpha',0.2,'EdgeColor','none');
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