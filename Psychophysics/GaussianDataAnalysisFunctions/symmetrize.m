function Q = symmetrize(Q)

    % responses
    Q.symmetrizedResponses = Q.responses;
    Q.symmetrizedResponses(Q.directions==-1) = -Q.symmetrizedResponses(Q.directions==-1);
    
    % eyeVelocity
    Q.symmetrizedEyeVelocity = Q.eyeVelocity;
    Q.symmetrizedEyeVelocity(Q.directions==-1) = -Q.symmetrizedEyeVelocity(Q.directions==-1);

    % eyeVelocityWithoutSaccades
    Q.symmetrizedEyeVelocityWithoutSaccades = Q.eyeVelocityWithoutSaccades;
    Q.symmetrizedEyeVelocityWithoutSaccades(Q.directions==-1) = -Q.symmetrizedEyeVelocityWithoutSaccades(Q.directions==-1);
    
    % correlations
    Q.symmetrizedCorrelations = Q.correlations;
    Q.symmetrizedCorrelations(Q.directions==-1) = -Q.symmetrizedCorrelations(Q.directions==-1);

end