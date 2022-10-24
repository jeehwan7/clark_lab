function Q = createPright(Q)

    %% PAIRWISE

    % List of Coherences
    c = [-1; -0.2; 0; 0.2; 1];
    
    % List of Frequencies at which the Respective Coherences Appear
    f = NaN(length(c),1);

    % Logical Array for Type = 'Pairwise'
    logicPairwise = reshape(strcmp(Q.types,'pairwise'),length(strcmp(Q.types,'pairwise')),1);
    
    for ii = 1:length(c)  
        % Logical Array for Symmetrized Coherence = c(ii)
        logicCoherence = Q.symmetrizedCoherences==c(ii);

        f(ii) = sum(logical(logicPairwise.*logicCoherence));
    end

    % List of Frequencies at which the Respective Responses are Right
    r = NaN(length(c),1);    
    
    % Logical Array for Response = Right
    logicRight = Q.responses==1;

    for ii = 1:length(c)
        % Logical Array for Symmetrized Coherence = c(ii)
        logicCoherence = Q.symmetrizedCoherences==c(ii);

        r(ii) = sum(logical(logicPairwise.*logicCoherence.*logicRight));
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


    %% TRIPLE

    % List of Types
    t = ["con,+";"con,-";"div,+";"div,-"];

    % List of Frequencies at which the Respective Types Appear
    f = NaN(4,1);

    % Logical Array for Converging
    logicConverging = reshape(strcmp(Q.types,'converging'),length(strcmp(Q.types,'converging')),1);
    % Logical Array for Diverging
    logicDiverging = reshape(strcmp(Q.types,'diverging'),length(strcmp(Q.types,'diverging')),1);
    % Logical Array for Parity = 1
    logicPositive = Q.parities==1;
    % Logical Array for Parity == -1
    logicNegative = Q.parities==-1;

    f(1) = sum(logical(logicConverging.*logicPositive));
    f(2) = sum(logical(logicConverging.*logicNegative));
    f(3) = sum(logical(logicDiverging.*logicPositive));
    f(4) = sum(logical(logicDiverging.*logicNegative));

    % List of Frequencies at which the Respective SYMMETRIZED Responses are Right
    r = NaN(4,1);

    % Logical Array for SYMMETRIZED Response = Right
    logicRight = Q.symmetrizedResponses==1;

    r(1) = sum(logical(logicConverging.*logicPositive.*logicRight));
    r(2) = sum(logical(logicConverging.*logicNegative.*logicRight));
    r(3) = sum(logical(logicDiverging.*logicPositive.*logicRight));
    r(4) = sum(logical(logicDiverging.*logicNegative.*logicRight));

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