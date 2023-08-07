function Q = createPright(Q)
    
    % list of frequencies at which the respective correlations appear
    f = NaN(length(Q.correlationVals),1);
    
    for ii = 1:length(Q.correlationVals) 
        isSymmetrizedCorrelation = Q.symmetrizedCorrelations==Q.correlationVals(ii);
        
        f(ii) = sum(isSymmetrizedCorrelation);
    end

    % list of frequencies at which the respective responses are right
    r = NaN(length(Q.correlationVals),1);

    for ii = 1:length(Q.correlationVals)
        isSymmetrizedCorrelation = Q.symmetrizedCorrelations==Q.correlationVals(ii);

        r(ii) = sum(isSymmetrizedCorrelation.*Q.responseIsRight);
    end

    % list of probabilities
    p = NaN(length(Q.correlationVals),1);
    for ii = 1:length(Q.correlationVals)
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