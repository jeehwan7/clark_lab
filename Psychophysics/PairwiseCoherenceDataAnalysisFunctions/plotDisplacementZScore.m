function Q = plotDisplacementZScore(Q,updateRate)

    coherences = [-1;-0.9;-0.8;-0.7;-0.6;-0.5;-0.4;-0.3;-0.2;-0.1;0;0.1;0.2;0.3;0.4;0.5;0.6;0.7;0.8;0.9;1];
    figure;

    M = []; % to keep a record of the times at which z score > 1 (after second frame)

    for ii = 1:length(coherences)

        % pick out relevant trials according to coherence
        y = Q.NaNlessEyeVelocityWithoutSaccades(Q.symmetrizedCoherences==coherences(ii),:);
        
        % z scores
        z = cumsum(y,2,'omitnan')/1000; % cumsum for each trial % divide by 1000 to convert from deg/s to deg/ms
        s = std(z,0,1); % standard deviation at each ms
        zscores = abs(mean(z,1)./s); % list of z scores at each ms
        
        % find times (ms) when z score > 1 before the second frame
        ix = find(zscores(1:floor(1000/updateRate))>1);
        scatter(coherences(ii),ix,50,[0.8500 0.3250 0.0980]); % red
        hold on

        % find earliest time (ms) when z score > 1 after the second frame
        ix = find(zscores(ceil(1000/updateRate):1000)>1,1) + floor(1000/updateRate);

        M = [M,ix];
        
        scatter(coherences(ii),ix,50,[0 0.4470 0.7410]); % blue
        hold on

    end

    hold off
    title('Pairwise Correlation Eye Displacement Z Score > 1');
    yline(0,'--');
    for ii = 1:ceil(max(M)/(1000/updateRate)) % max(M) = latest time at which z score > 1
        yl = yline(ii*1000/updateRate,'--',['frame ',num2str(ii+1)]);
        yl.LabelHorizontalAlignment = 'left';
    end
    xlabel('coherence');
    ylabel('t (ms)');

end