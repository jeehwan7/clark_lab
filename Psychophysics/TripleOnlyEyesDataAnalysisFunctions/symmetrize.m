function Q = symmetrize(Q)

    % eyeVelocity
    Q.symmetrizedEyeVelocity = Q.eyeVelocity;
    Q.symmetrizedEyeVelocity(Q.directions==-1) = -Q.symmetrizedEyeVelocity(Q.directions==-1);

    % eyeVelocityWithoutSaccades
    Q.symmetrizedEyeVelocityWithoutSaccades = Q.eyeVelocityWithoutSaccades;
    Q.symmetrizedEyeVelocityWithoutSaccades(Q.directions==-1) = -Q.symmetrizedEyeVelocityWithoutSaccades(Q.directions==-1);
    
    % coherences
    Q.symmetrizedCoherences = Q.coherences;
    Q.symmetrizedCoherences(Q.directions==-1) = -Q.symmetrizedCoherences(Q.directions==-1);

end