function Q = plotSpectrogram(Q)

    z = Q.eyeVelocityWithoutSaccades;
    c = Q.symmetrizedCorrelations;
    zPos = mean(z(c>0.2,:),1,'omitnan');
    zNeg = mean(z(c<-0.2,:),1,'omitnan');
    zMean = (zPos-zNeg)/2;
    
    %{
    % without HPF
    s = spectrogram(zMean,100,50,1000);   
    imagesc(abs(s));
    xlabel('interval (100 ms window, 50 ms overlap)');
    ylabel('frequency (Hz)');
    %}
    
    % HPF
    [B,A] = butter(1,1/pi/10,'high');
    zMeanf = filter(B,A,zMean);
    
    % subplot(2,1,1)
    window = 100;
    noverlap = 50;
    nfft = 1000;
    s = spectrogram(zMeanf,window,noverlap,nfft); % data, window, noverlap, nfft
    % imagesc(abs(s)) % imagesc(log(abs(s)));
    % xlabel('window (100 ms length, 50 ms overlap)');
    % ylabel('frequency (Hz)');
    
    % subplot(2,1,2)
    plot(0:nfft/2,mean(abs(s),2));
    xlabel('frequency (Hz)');
    ylabel('mean STFT');
    title('Mean Short-time Fourier Transform')

    % sgtitle('Spectrograms');

end
