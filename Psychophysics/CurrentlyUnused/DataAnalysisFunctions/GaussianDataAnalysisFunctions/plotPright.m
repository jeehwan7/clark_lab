function Q = plotPright(Q)

    %{
    % Scatter Plot
    A = Q.Pright;

    figure;
    scatter(A,"Correlation","P(Right)");
    yline(0.5,'--');
    xlabel('correlation');
    ylabel('P(Right)');
    title('Gaussian Field P(Right)');
    %}

    % GLM Fit
    figure;
    x = Q.Pright.Correlation;
    n = Q.Pright.("Trial Frequency");
    y = Q.Pright.("Right Frequency");
    b = glmfit(x,[y n],'binomial','Link','probit');
    yfit = glmval(b,x,'probit','Size',n);
    plot(x,y./n,'o',x,yfit./n,'-');
    yline(0.5,'--');
    xlabel('correlation');
    ylabel('P(Right)');
    title('Gaussian Field P(Right)');

end