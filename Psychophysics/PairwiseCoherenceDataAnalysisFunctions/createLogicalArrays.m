function Q = createLogicalArrays(Q)

%     % Types
%     Q.isPairwise = logical(reshape(strcmp(Q.types,'pairwise'),length(strcmp(Q.types,'pairwise')),1));
%     Q.isConverging = logical(reshape(strcmp(Q.types,'converging'),length(strcmp(Q.types,'converging')),1));
%     Q.isDiverging = logical(reshape(strcmp(Q.types,'diverging'),length(strcmp(Q.types,'diverging')),1));

%     % Parities
%     Q.isPositive = Q.parities==1;
%     Q.isNegative = Q.parities==-1;

    % Responses
    Q.responseIsRight = Q.responses==1;
    Q.symmetrizedResponseIsRight = Q.symmetrizedResponses==1;

end