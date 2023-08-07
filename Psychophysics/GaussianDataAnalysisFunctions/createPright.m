function Q = createPright(Q)
    
    % list of correlations
    c = Q.correlationVals;

    % list of frequencies at which the respective correlations appear
    f = NaN(length(c),1);
    
    for ii = 1:length(c) 
        isSymmetrizedCorrelation = Q.symmetrizedCorrelations==c(ii);
        
        f(ii) = sum(isSymmetrizedCorrelation);
    end

    % list of frequencies at which the respective responses are right
    r = NaN(length(c),1);

    for ii = 1:length(c)
        isSymmetrizedCorrelation = Q.symmetrizedCorrelations==c(ii);

        r(ii) = sum(isSymmetrizedCorrelation.*Q.responseIsRight);
    end

    % list of probabilities
    p = NaN(length(c),1);
    for ii = 1:length(c)
        p(ii) = r(ii)/f(ii);
    end

    varTypes = {'double','double','double','double'};
    varNames = {'Correlation','Trial Frequency','Right Frequency','P(Right)'};
    T = table('Size',[length(c), 4],'VariableTypes',varTypes,'VariableNames',varNames);

    T(:,1) = num2cell(c);
    T(:,2) = num2cell(f);
    T(:,3) = num2cell(r);
    T(:,4) = num2cell(p);

    Q.Pright = T;

end