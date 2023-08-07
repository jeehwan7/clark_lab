function Q = createPright(Q)

    % list of coherences
    c = Q.coherenceVals;
    
    % list of frequencies at which the respective coherences appear
    f = NaN(length(c),1);
    
    for ii = 1:length(c)
        isSymmetrizedCoherence = Q.symmetrizedCoherences==c(ii);

        f(ii) = sum(isSymmetrizedCoherence);
    end

    % List of Frequencies at which the Respective Responses are Right
    r = NaN(length(c),1);    

    for ii = 1:length(c)
        isSymmetrizedCoherence = Q.symmetrizedCoherences==c(ii);

        r(ii) = sum(isSymmetrizedCoherence.*Q.responseIsRight);
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

    Q.Pright = T;

end