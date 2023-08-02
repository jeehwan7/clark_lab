function Q = plotEyeDisplacement(Q)

    figure;
    coherences = [-1;-0.9;-0.8;-0.7;-0.6;-0.5;-0.4;-0.3;-0.2;-0.1;0;0.1;0.2;0.3;0.4;0.5;0.6;0.7;0.8;0.9;1];
    color = colormap(copper(11));
    for ii = 1:length(coherences)

        x = 1:1000;
        % pick out relevant trials according to coherence
        y = Q.NaNlessEyeVelocityWithoutSaccades(Q.symmetrizedCoherences==coherences(ii),:);
        
        y = mean(y,1);

        plot(x,cumsum(y,'omitnan')/1000,'Color',color(10*abs(coherences(ii))+1,:),'LineWidth',1); % divide by 1000 to convert from deg/s to deg/ms
        hold on           
    end
    hold off
    title('Pairwise Correlation Eye Displacement');
    yline(0,'--');
    xlabel('t (ms)');
    ylabel('eye displacement (deg)');

end