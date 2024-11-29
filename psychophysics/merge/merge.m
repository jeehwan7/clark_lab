% file names (without the '.fig' at the end)
figNames = {};

% figure title
figTitle = '';
% figure axis labels
figX = '';
figY = '';
% figure legend
legNames = {};

% no need to touch anything below this point

numFigs = size(figNames,2);

Q = struct([]); % stores patches' and lines' xdata and ydata
leg = cell(numFigs*2,1); % actual legend names (including patches: '')

% extract xdata and ydata
for i = 1:numFigs
    Q = grabData(Q,figNames{i},i);
end

% plot
figure;
color = colormap(cool(numFigs));
% plot patches
for i = 1:numFigs
    [Q,leg] = plotPatches(Q,i,color,leg);
end
% plot lines
for i = 1:numFigs
    [Q,leg] = plotLines(Q,i,color,leg,legNames,numFigs);
end

yline(0,'--');
legend(leg);
title(figTitle);
xlabel(figX);
ylabel(figY);

function Q = grabData(Q,figname,i)

    fig = openfig([figname,'.fig']);

    l = findobj(gca,'Type','line');
    Q(i).lx = get(l,'XData');
    Q(i).ly = get(l,'YData');
    
    p = findobj(gca,'Type','patch');
    Q(i).px = get(p,'XData');
    Q(i).py = get(p,'YData');
    
    close(fig);

end

function [Q,leg] = plotPatches(Q,i,color,leg)

    patch(Q(i).px,Q(i).py,color(i,:),'FaceAlpha',0.2,'EdgeColor','none');
    hold on
    leg{i} = '';

end

function [Q,leg] = plotLines(Q,i,color,leg,legNames,numFigs)

    plot(Q(i).lx,Q(i).ly,'Color',color(i,:),'LineWidth',2);
    hold on
    leg{numFigs+i} = legNames{i};

end