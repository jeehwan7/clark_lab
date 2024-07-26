param = '(? Hz, ? deg)';

dp = grabData('div+.fig');
dn = grabData('div-.fig');
cp = grabData('con+.fig');
cn = grabData('con-.fig');

color1 = [0 0.4470 0.7410];
color2 = [0.8500 0.3250 0.0980];
color3 = [0.9290 0.6940 0.1250];
color4 = [0.4940 0.1840 0.5560];

figure;

plot(dp.lx,dp.ly,'Color',color1,'LineWidth',2);
hold on
plot(dn.lx,dn.ly,'Color',color2,'LineWidth',2);
hold on
plot(cp.lx,cp.ly,'Color',color3,'LineWidth',2);
hold on
plot(cn.lx,cn.ly,'Color',color4,'LineWidth',2);
hold on

patch(dp.px,dp.py,color1,'FaceAlpha',0.2,'EdgeColor','none');
hold on
patch(dn.px,dn.py,color2,'FaceAlpha',0.2,'EdgeColor','none')
hold on
patch(cp.px,cp.py,color3,'FaceAlpha',0.2,'EdgeColor','none');
hold on
patch(cn.px,cn.py,color4,'FaceAlpha',0.2,'EdgeColor','none')
hold off

yline(0,'--');

legend('div,+','div,-','con,+','con,-')
legend('Location','northeast')
title(['Triple Correlation Impulse Response ',param])
xlabel('t (ms)');
% ylabel('');

function Q = grabData(figname)

    fig = openfig(figname);

    l = findobj(gca,'Type','line');
    Q.lx = get(l,'XData');
    Q.ly = get(l,'YData');
    
    p = findobj(gca,'Type','patch');
    Q.px = get(p,'XData');
    Q.py = get(p,'YData');
    
    close(fig);

end
