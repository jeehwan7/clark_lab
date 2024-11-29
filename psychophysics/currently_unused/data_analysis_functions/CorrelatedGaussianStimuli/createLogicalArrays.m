function Q = createLogicalArrays(Q)

    % Responses
    Q.responseIsRight = Q.responses==1;
    Q.symmetrizedResponseIsRight = Q.symmetrizedResponses==1;

end