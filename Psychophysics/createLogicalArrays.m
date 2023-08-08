function Q = createLogicalArrays(Q)

    % Types
    Q.isPairwise = strcmpi(Q.types,'pairwise');
    Q.isConverging = strcmpi(Q.types,'converging');
    Q.isDiverging = strcmpi(Q.types,'diverging');

    % Parities
    Q.isPositive = Q.parities==1;
    Q.isNegative = Q.parities==-1;

    % Type x Parity
    Q.isConvergingPositive = logical(Q.isConverging.*Q.isPositive);
    Q.isConvergingNegative = logical(Q.isConverging.*Q.isNegative);
    Q.isDivergingPositive = logical(Q.isDiverging.*Q.isPositive);
    Q.isDivergingNegative = logical(Q.isDiverging.*Q.isNegative);

    % Responses
    Q.responseIsRight = Q.responses==1;
    Q.symmetrizedResponseIsRight = Q.symmetrizedResponses==1;

end