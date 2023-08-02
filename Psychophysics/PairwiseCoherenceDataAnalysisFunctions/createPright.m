function Q = createPright(Q)

    % List of Coherences
    c = [-1;-0.9;-0.8;-0.7;-0.6;-0.5;-0.4;-0.3;-0.2;-0.1;0;0.1;0.2;0.3;0.4;0.5;0.6;0.7;0.8;0.9;1];
    
    % List of Frequencies at which the Respective Coherences Appear
    f = NaN(length(c),1);
    
    for ii = 1:length(c)  
        % Logical Array for Symmetrized Coherence = c(ii)
        isSymmetrizedCoherence = Q.symmetrizedCoherences==c(ii);

        f(ii) = sum(isSymmetrizedCoherence);
    end

    % List of Frequencies at which the Respective Responses are Right
    r = NaN(length(c),1);    

    for ii = 1:length(c)
        % Logical Array for Symmetrized Coherence = c(ii)
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