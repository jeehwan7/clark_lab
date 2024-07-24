function Q = calculateCoefficientsByBlock(Q,param,directions)

    % block by block coefficients
    Q.bbbCoefficients = NaN(param.numBlocks,Q.numCoefficients);

    for kk = 1:param.numBlocks
        tempD = NaN(param.numTrialsPerBlock*Q.updateRate*Q.stimDuration,Q.numCoefficients); % all the directions
        tempV = NaN(param.numTrialsPerBlock*Q.updateRate*Q.stimDuration,1); % all the velocities      

        for ll = (1:10)+(kk-1)*10
            for mm = 1:(Q.updateRate*Q.stimDuration)
                if ~isnan(Q.downSampled(ll,mm))
                    tempV(mod(ll-1,10)*Q.updateRate*Q.stimDuration+mm) = Q.downSampled(ll,mm);
                    tempD(mod(ll-1,10)*Q.updateRate*Q.stimDuration+mm,:) = flip(directions(ll,(mm-Q.numCoefficients):(mm-1)));
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

    x = (1:Q.numCoefficients)*1000/Q.updateRate;
    color = [0 0.4470 0.7410;
             0.8500 0.3250 0.0980;
             0.9290 0.6940 0.1250;
             0.4940 0.1840 0.5560;
             0.4660 0.6740 0.1880];

    % plot
    figure;
    for ii = 1:param.numBlocks
        s = std(Q.tbtCoefficients((1:10)+(ii-1)*10,:),0,1);
        sem = s/sqrt(param.numTrialsPerBlock);

        z = filtfilt(b,a,Q.bbbCoefficients(ii,:));

        patch([x fliplr(x)],[z-sem  fliplr(z+sem)],color(ii,:),'FaceAlpha',0.2,'EdgeColor','none');
        hold on
        plot(x,z,'Color',color(ii,:),'LineWidth',2);
        hold on
    end
    hold off

    yline(0,'--');
    title('Impulse Response');
    xlabel('-t (ms)');
    ylabel('weighting');
    legend('','block 1','','block 2','','block 3','','block 4','','block 5');
    legend('Location','northeast');

end