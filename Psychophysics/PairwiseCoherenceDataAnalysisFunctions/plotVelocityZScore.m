function Q = plotVelocityZScore(Q)

    figure;
    duration = Q.stimDuration*1000;

    M = []; % to keep a record of the times at which z score > 1 (after second frame)

    for ii = 1:length(Q.coherenceVals)

        % pick out relevant trials according to coherence
        y = Q.NaNlessEyeVelocityWithoutSaccades(Q.symmetrizedCoherences==Q.coherenceVals(ii),:);
        
        % z scores
        z = y/1000; % divide by 1000 to convert from deg/s to deg/ms
        s = std(z,0,1); % standard deviation at each ms
        zscores = abs(mean(z,1)./s); % list of z scores at each ms
        
        % find times (ms) when z score > 1 before second frame
        ix = find(zscores(1:floor(1000/Q.updateRate))>1);
        scatter(Q.coherenceVals(ii),ix,50,[0.8500 0.3250 0.0980]); % red
        hold on

        % find earliest time (ms) when z score > 1 after second frame
        ix = find(zscores(ceil(1000/Q.updateRate):duration)>1,1) + floor(1000/Q.updateRate);

        M = [M,ix];
        
        scatter(Q.coherenceVals(ii),ix,50,[0 0.4470 0.7410]); % blue
        hold on

    end

    hold off
    title('Pairwise Correlation Eye Velocity Z Score > 1');
    yline(0,'--');
    for ii = 1:ceil(max(M)/(1000/Q.updateRate)) % max(M) = latest time at which z score > 1
        yl = yline(ii*1000/Q.updateRate,'--',['frame ',num2str(ii+1)]);
        yl.LabelHorizontalAlignment = 'left';
    end
    xlabel('coherence');
    ylabel('t (ms)');

end