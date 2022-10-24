function Q = plotPright(Q)

    %% PAIRWISE

    pc = Q.PrightPairwiseCoherence;

    figure;
    scatter(pc,"Coherence","P(Right)");
    yline(0.5,'--');
    xlabel('coherence');
    ylabel('P(Right)');
    title('Pairwise Coherence');

    %% TRIPLE

    x = cellstr(Q.PrightTriple.Type);
    y = Q.PrightTriple.("P(Right)");

    figure;
    bar(y);
    yline(0.5,'--');
    title('Triple');
    xlabel('type');
    ylabel('P(Right)');
    xticklabels(x);

end