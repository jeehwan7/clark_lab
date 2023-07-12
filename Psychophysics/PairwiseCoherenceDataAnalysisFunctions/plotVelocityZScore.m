function Q = plotVelocityZScore(Q,updateRate)

    coherences = [-1;-0.9;-0.8;-0.7;-0.6;-0.5;-0.4;-0.3;-0.2;-0.1;0;0.1;0.2;0.3;0.4;0.5;0.6;0.7;0.8;0.9;1];
    figure;
    for ii = 1:length(coherences)

        % pick out relevant trials, cut off at 1000 ms
        y = Q.eyeVelocityWithoutSaccades(Q.symmetrizedCoherences==coherences(ii),1:1000);

%         % Option 1: replace NaN values with 0
%         y(isnan(y)) = 0;
        
        % Option 2: replace NaN values with mean of non-NaN values
        m = mean(y,1,'omitnan'); % mean of non-NaN values for each ms
        for jj = 1:size(y,2)
            column = y(:,jj);
            column(isnan(column)) = m(jj);
            y(:,jj) = column;
        end
        
        % z scores
        z = y/1000; % divide by 1000 to convert from deg/s to deg/ms
        s = std(z,0,1); % standard deviation for each ms
        zscores = abs(mean(z,1)./s); % list of z scores at each ms
        
        % the frame must have changed at least once
        % zscores(1:floor(1000/updateRate)) = zeros(1,floor(1000/updateRate));

        % find earliest time (ms) when z score > 1
        ix = find(zscores>1,10);

        scatter(coherences(ii),ix,50,[0 0.4470 0.7410]);
        hold on

    end

    hold off
    title('Pairwise Correlation Eye Velocity Z Score > 1');
    yline(0,'--');
    for ii = 1:8
        yl = yline(floor(ii*1000/updateRate),'--',['Flip ',num2str(ii)]);
        yl.LabelHorizontalAlignment = 'left';
    end
    xlabel('coherence');
    ylabel('t (ms)');

end