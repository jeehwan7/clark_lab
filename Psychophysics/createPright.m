function Q = createPright(Q)

    %% Pairwise

    % List of Coherences
    c = Q.coherenceVals;
    
    % List of Frequencies at which the Respective Coherences Appear
    f = NaN(length(c),1);
    
    for ii = 1:length(c)  
        isSymmetrizedCoherence = Q.symmetrizedCoherences==c(ii);
        f(ii) = sum(logical(Q.isPairwise.*isSymmetrizedCoherence));
    end

    % List of Frequencies at which the Respective Responses are Right
    r = NaN(length(c),1);    
    
    % Logical Array for Response = Right
    Q.responseIsRight = Q.responses==1;

    for ii = 1:length(c)
        isSymmetrizedCoherence = Q.symmetrizedCoherences==c(ii);
        r(ii) = sum(logical(Q.isPairwise.*isSymmetrizedCoherence.*Q.responseIsRight));
    end

    % List of Probabilities
    p = NaN(length(c),1);
    for ii = 1:length(c)
        p(ii) = r(ii)/f(ii);
    end

    varTypes = {'double','double','double','double'};
    varNames = {'Coherence','Trial Frequency','Right Frequency','P(Right)'};
    T = table('Size',[length(c), 4],'VariableTypes',varTypes,'VariableNames',varNames);

    T(:,1) = num2cell(c);
    T(:,2) = num2cell(f);
    T(:,3) = num2cell(r);
    T(:,4) = num2cell(p);

    Q.PrightPairwiseCoherence = T;


    %% Triple

    % List of Types
    t = ["con,+";"con,-";"div,+";"div,-"];

    % List of Frequencies at which the Respective Types Appear
    f = NaN(4,1);

    f(1) = sum(logical(Q.isConvergingPositive));
    f(2) = sum(logical(Q.isConvergingNegative));
    f(3) = sum(logical(Q.isDivergingPositive));
    f(4) = sum(logical(Q.isDivergingNegative));

    % List of Frequencies at which the Respective SYMMETRIZED Responses are Right
    r = NaN(4,1);

    r(1) = sum(logical(Q.isConvergingPositive.*Q.symmetrizedResponseIsRight));
    r(2) = sum(logical(Q.isConvergingNegative.*Q.symmetrizedResponseIsRight));
    r(3) = sum(logical(Q.isDivergingPositive.*Q.symmetrizedResponseIsRight));
    r(4) = sum(logical(Q.isDivergingNegative.*Q.symmetrizedResponseIsRight));

    % List of Probabilities
    p = NaN(4,1);
    for ii = 1:4
        p(ii) = r(ii)/f(ii);
    end

    varTypes = {'string','double','double','double'};
    varNames = {'Type','Trial Frequency','Right Frequency','P(Right)'};
    T = table('Size',[4, 4],'VariableTypes',varTypes,'VariableNames',varNames);

    T(:,1) = cellstr(t);
    T(:,2) = num2cell(f);
    T(:,3) = num2cell(r);
    T(:,4) = num2cell(p);

    Q.PrightTriple = T;

end