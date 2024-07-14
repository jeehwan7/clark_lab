function Q = runTTest(Q)

    types = ["div,+";"div,-";"con,+";"con,-"];
    ttests = NaN(4,1);

    figure;
    subplot(2,2,1);
    [Q,ttests(1)] = plotLocalDataTriple(Q,'Diverging',1);
    subplot(2,2,2);
    [Q,ttests(2)] = plotLocalDataTriple(Q,'Diverging',-1);
    subplot(2,2,3);
    [Q,ttests(3)] = plotLocalDataTriple(Q,'Converging',1);
    subplot(2,2,4);
    [Q,ttests(4)] = plotLocalDataTriple(Q,'Converging',-1);
    sgtitle('Triple Correlation Eye Displacement');

    % table
    varTypes = {'string','double'};
    varNames = {'Type','T-Test'};
    T = table('Size',[4, 2],'VariableTypes',varTypes,'VariableNames',varNames);

    T(:,1) = cellstr(types);
    T(:,2) = num2cell(ttests);

    Q.ttests = T;

end

function [Q,ttest] = plotLocalDataTriple(Q,type,parity)

    % pick out relevant trials
    v = Q.NaNlessEyeVelocityWithoutSaccades(logical(strcmpi(Q.types,type).*(Q.parities==parity)),:); % velocities
    r = Q.symmetrizedResponses(logical(strcmpi(Q.types,type).*(Q.parities==parity)),:); % responses

    % cumsum for each trial
    d = cumsum(v,2)/1000; % divide by 1000 to convert from deg/s to deg/ms
    d = d(:,250); % only want cumsum at certain point in time

    % t-test
    pos = d(r==1);
    neg = d(r==-1);
    ttest = ttest2(pos,neg);

    if ttest == 1
        color = [0.8500 0.3250 0.0980];
    else
        color = [0 0.4470 0.7410];
    end

    meancolor = [0.4940 0.1840 0.5560];

    % plot when conscious percept agrees with direction of centroid
    pos_x = ones(length(r(r==1)));
    scatter(pos_x,pos,'o','MarkerEdgeColor',color);
    hold on
    % mean
    scatter(1,mean(pos),'d','filled','MarkerFaceColor',meancolor);
    hold on

    % plot when conscious percept disagrees with direction of centroid
    neg_x = 2*ones(length(r(r==-1)));
    scatter(neg_x,neg,'o','MarkerEdgeColor',color);
    hold on
    % mean
    scatter(2,mean(neg),'d','filled','MarkerFaceColor',meancolor);
    hold off

    xlim([0 3]);

    % x axis label
    ax = gca;
    ax.XTick = [1, 2];
    ax.XTickLabels = {'+','-'};

    if parity==1
        sign = '+';
    elseif parity==-1
        sign = '-';
    end

    yline(0,'--');
    title([type,',',sign']);
    xlabel('conscious percept');
    ylabel('eye displacement (deg)');

end