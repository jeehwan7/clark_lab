function Q = calculateSNR(Q)

    temp = NaN(Q.numTrials,1); % SNR for each trial
    
    for ii = 1:Q.numTrials
        coefficients = Q.tbtCoefficients(ii,:);
        peak = max(coefficients);
        index = coefficients == peak;
        CI = Q.tbtCoefficientsCI(index,2,ii) - Q.tbtCoefficientsCI(index,1,ii);
        temp(ii) = peak/CI;
    end

    Q.SNR = mean(temp); % average SNR