function Q = createPright(Q)

    %% Pairwise

    % List of coherences
    c = Q.coherenceVals;
    
    % List of frequencies at which the respective coherences appear
    f = NaN(length(c),1);
    
    for ii = 1:length(c)  
        isSymmetrizedCoherence = Q.symmetrizedCoherences==c(ii);
        f(ii) = sum(Q.isPairwise.*isSymmetrizedCoherence);
    end

    % List of frequencies at which the respective responses are right
    r = NaN(length(c),1);

    for ii = 1:length(c)
        isSymmetrizedCoherence = Q.symmetrizedCoherences==c(ii);
        r(ii) = sum(Q.isPairwise.*isSymmetrizedCoherence.*Q.responseIsRight);
    end

    % List of probabilities
    p = NaN(length(c),1);
    for ii = 1:length(c)
        p(ii) = r(ii)/f(ii);
    end

    % List of standard errors
    e = NaN(length(c),1);
    for ii = 1:length(c)
        e(ii) = sqrt(p(ii)*(1-p(ii))/f(ii)); % standard error for binomial distribution
    end

    varTypes = {'double','double','double','double','double'};
    varNames = {'Coherence','Trial Frequency','Right Frequency','P(Right)','Standard Error'};
    T = table('Size',[length(c), 5],'VariableTypes',varTypes,'VariableNames',varNames);

    T(:,1) = num2cell(c);
    T(:,2) = num2cell(f);
    T(:,3) = num2cell(r);
    T(:,4) = num2cell(p);
    T(:,5) = num2cell(e);

    Q.PrightPairwiseCoherence = T;


    %% Triple

    % List of types
    t = ["con,+";"con,-";"div,+";"div,-"];

    % List of frequencies at which the respective types appear
    f = NaN(4,1);

    f(1) = sum(Q.isConvergingPositive);
    f(2) = sum(Q.isConvergingNegative);
    f(3) = sum(Q.isDivergingPositive);
    f(4) = sum(Q.isDivergingNegative);

    % List of frequencies at which the respective SYMMETRIZED responses are right
    r = NaN(4,1);

    r(1) = sum(Q.isConvergingPositive.*Q.symmetrizedResponseIsRight);
    r(2) = sum(Q.isConvergingNegative.*Q.symmetrizedResponseIsRight);
    r(3) = sum(Q.isDivergingPositive.*Q.symmetrizedResponseIsRight);
    r(4) = sum(Q.isDivergingNegative.*Q.symmetrizedResponseIsRight);

    % List of probabilities
    p = NaN(4,1);
    for ii = 1:4
        p(ii) = r(ii)/f(ii);
    end

    % List of standard errors
    e = NaN(4,1);
    for ii = 1:4
        e(ii) = sqrt(p(ii)*(1-p(ii))/f(ii));
    end

    varTypes = {'string','double','double','double','double'};
    varNames = {'Type','Trial Frequency','Right Frequency','P(Right)','Standard Error'};
    T = table('Size',[4, 5],'VariableTypes',varTypes,'VariableNames',varNames);

    T(:,1) = cellstr(t);
    T(:,2) = num2cell(f);
    T(:,3) = num2cell(r);
    T(:,4) = num2cell(p);
    T(:,5) = num2cell(e);

    Q.PrightTriple = T;

end