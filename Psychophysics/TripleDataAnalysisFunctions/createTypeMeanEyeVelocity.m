function Q = createTypeMeanEyeVelocity(Q)

    t = Q.trialMeanEyeVelocityTripleNaNLimit;
    
    cp = t.("Mean Eye Velocity")(strcmp(t.Type,"con,+"));
    cn = t.("Mean Eye Velocity")(strcmp(t.Type,"con,-"));
    dp = t.("Mean Eye Velocity")(strcmp(t.Type,"div,+"));
    dn = t.("Mean Eye Velocity")(strcmp(t.Type,"div,-"));

    cpMean = mean(cp);
    cpSEM = std(cp)/sqrt(length(cp));

    cnMean = mean(cn);
    cnSEM = std(cn)/sqrt(length(cn));

    dpMean = mean(dp);
    dpSEM = std(dp)/sqrt(length(dp));
    
    dnMean = mean(dn);
    dnSEM = std(dn)/sqrt(length(dn));

    types = ["con,+";"con,-";"div,+";"div,-"];
    means = {cpMean; cnMean; dpMean; dnMean};
    SEMs = {cpSEM; cnSEM; dpSEM; dnSEM};

    varTypes = {'string','double','double'};
    varNames = {'Type','Mean Eye Velocity','SEM'};

    T = table('Size',[4,3],'VariableTypes',varTypes,'VariableNames',varNames);
    T(:,1) = cellstr(types);
    T(:,2) = means;
    T(:,3) = SEMs;

    Q.typeMeanEyeVelocityTriple = T;

end