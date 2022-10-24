function Q = plotTrialMeanEyeVelocity(Q)

    pc = Q.trialMeanEyeVelocityPairwiseCoherenceNaNLimit;
    t = Q.trialMeanEyeVelocityTripleNaNLimit;
    tType = categorical(t.Type);

    % Pairwise Coherence
    figure;
    scatter(pc.Coherence(pc.Response==1),pc.("Mean Eye Velocity")(pc.Response==1));
    hold on
    scatter(pc.Coherence(pc.Response==-1),pc.("Mean Eye Velocity")(pc.Response==-1));
    hold off
    yline(0,'--');
    xlabel('coherence');
    ylabel('mean velocity per trial (deg/s)');
    title('Pairwise Coherence');
    legend({'response = right','response = left'},'Location','southeast');

    % Triple
    figure;
    scatter(tType(t.Response==1),t.("Mean Eye Velocity")(t.Response==1));
    hold on
    scatter(tType(t.Response==-1),t.("Mean Eye Velocity")(t.Response==-1));
    hold off
    yline(0,'--');
    xlabel('type');
    ylabel('mean velocity per trial (deg/s)');
    title('Triple');
    legend({'response = right','response = left'},'Location','southeast');

end