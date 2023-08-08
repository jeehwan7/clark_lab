function Q = plotPright(Q)

    %% Pairwise

    A = Q.PrightPairwiseCoherence;

    figure;
    scatter(A,"Coherence","P(Right)");
    yline(0.5,'--');
    xlabel('coherence');
    ylabel('P(Right)');
    title('Pairwise Correlation P(Right)');

    %{
    % GLM Fit
    figure;
    x = Q.PrightPairwiseCoherence.Coherence;
    n = Q.PrightPairwiseCoherence.("Trial Frequency");
    y = Q.PrightPairwiseCoherence.("Right Frequency");
    b = glmfit(x,[y n],'binomial','Link','probit');
    yfit = glmval(b,x,'probit','Size',n);
    plot(x,y./n,'o',x,yfit./n,'-');
    yline(0.5,'--');
    xlabel('coherence');
    ylabel('P(Right)');
    title('Pairwise Correlation P(Right)');
    %}

    %% Triple

    x = cellstr(Q.PrightTriple.Type);
    y = Q.PrightTriple.("P(Right)");

    figure;
    bar(y);
    yline(0.5,'--');
    title('Triple Correlation P(Right)');
    xlabel('type');
    ylabel('P(Right)');
    xticklabels(x);

end