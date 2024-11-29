function Q = plotPright(Q)

    %% Pairwise

    A = Q.PrightPairwiseCoherence;

    figure;
    scatter(A,"Coherence","P(Right)");
    yline(0.5,'--');
    xlabel('coherence');
    ylabel('P(Right)');
    title('Pairwise Correlation P(Right)');

    hold on

    x = Q.PrightPairwiseCoherence.("Coherence");
    y = Q.PrightPairwiseCoherence.("P(Right)");
    err = Q.PrightPairwiseCoherence.("Standard Error");
    errbar = errorbar(x,y,err);
    errbar.Color = [0 0 0];
    errbar.LineStyle = 'none';

    hold off

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

    y = Q.PrightTriple.("P(Right)");

    figure;
    b = bar(y);
    b.BaseValue = 0.5;
    b.BaseLine.LineStyle = '--';
    ylim([0 1])
    title('Triple Correlation P(Right)');
    xlabel('type');
    ylabel('P(Right)');
    
    x = cellstr(Q.PrightTriple.Type);
    xticklabels(x);

    hold on

    err = Q.PrightTriple.("Standard Error");
    errbar = errorbar(y,err);
    errbar.Color = [0 0 0];
    errbar.LineStyle = 'none';

    hold off

end