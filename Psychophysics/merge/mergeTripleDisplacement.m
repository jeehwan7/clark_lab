param = '(? Hz, ? deg)';

t1 = grabData('trace1000');
t2 = grabData('trace250');

color1 = [0 0.4470 0.7410];
color2 = [0.8500 0.3250 0.0980];

figure;

for position = 1:4
    subplot(2,2,position);
    plotLocalData(t1,t2,position,color1,color2);
end

sgtitle(['Triple Correlation Eye Displacement ',param]);

function t = grabData(figname)

    fig = openfig(figname);

    for position = 1:4
        l = findobj(subplot(2,2,position),'Type','line');
        t(position).lx = get(l,'XData');
        t(position).ly = get(l,'YData');
        
        p = findobj(subplot(2,2,position),'Type','patch');
        t(position).px = get(p,'XData');
        t(position).py = get(p,'YData');
    end
    
    close(fig);

end

function plotLocalData(t1,t2,position,color1,color2)

    plot(t1(position).lx,t1(position).ly,'Color',color1,'LineWidth',2);
    hold on
    plot(t2(position).lx,t2(position).ly,'Color',color2,'LineWidth',2);
    hold on
    
    patch(t1(position).px,t1(position).py,color1,'FaceAlpha',0.2,'EdgeColor','none');
    hold on
    patch(t2(position).px,t2(position).py,color2,'FaceAlpha',0.2,'EdgeColor','none');
    hold off
    
    yline(0,'--');

    if position == 1
        title('Diverging,+');
    elseif position == 2
        title('Diverging,-');
    elseif position == 3
        title('Converging,+');
    elseif position == 4
        title('Converging,-');
    end

    xlabel('t (ms)');
    ylabel('eye displacement (deg)');

end
