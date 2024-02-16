function Q = plotSpectrogram(Q)

    z = Q.eyeVelocityWithoutSaccades;
    c = Q.symmetrizedCoherences;
    zPos = mean(z(c>0.5,:),1,'omitnan');
    zNeg = mean(z(c<-0.5,:),1,'omitnan');
    zMean = (zPos-zNeg)/2;
    
    % without HPF
    subplot(2,2,1)
    [s f t] = spectrogram(zMean,100,50,100,1000);   
    imagesc(log(abs(s)));
    xlabel('time interval');
    ylabel('frequency index');
    title('Without HPF');
    
    % HPF
    [B,A] = butter(1,1/pi/10,'high');
    zMeanf = filter(B,A,zMean);
    
    % with HPF
    subplot(2,2,2)
    [s f t] = spectrogram(zMeanf,100,50,100,1000);
    imagesc(log(abs(s)));
    xlabel('time interval');
    ylabel('frequency index');
    title('With HPF');
    
    % with HPF
    subplot(2,2,[3 4])
    plot(mean(abs(s),2));
    xlabel('frequency index');
    ylabel('power');
    title('With HPF')

    sgtitle('Spectrograms (100 ms Interval)');

end
