function Q = plotSpectrogram(Q)

    z = Q.eyeVelocityWithoutSaccades(:,1:1000);
    c = Q.symmetrizedCoherences;
    zPos = mean(z(c>0.5,:),1,'omitnan');
    zNeg = mean(z(c<-0.5,:),1,'omitnan');
    zMean = (zPos-zNeg)/2;
    
    % without butterworth filter
    [s f t] = spectrogram(zMean,100,50,100,1000);
    figure; imagesc(log(abs(s)));
    
    [B,A] = butter(1,1/pi/20,'high');
    zMeanf = filter(B,A,zMean);
    
    % with butterworth filter
    [s f t] = spectrogram(zMeanf,100,50,100,1000);
    figure; imagesc(log(abs(s)));

    figure; plot(mean(abs(s),2));
    xlabel('frequency index')
    ylabel('power')

end
