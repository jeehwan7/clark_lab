close all
clear

params = [0 17 33 50 100 200 400]; % correlation time or standard deviation

fileNames = cell(length(params),1);
legNames = cell(length(params),1);

for ii = 1:length(params)

    fileNames{ii} = [num2str(params(ii)),'ms.fig']; % ms or dps
    legNames{ii} = [num2str(params(ii)),' ms']; % ms or deg/s

end

for ii = 1:length(params)

    openfig(fileNames{ii});

    Q(ii).param = params(ii);

    Q(ii).x = findobj('Type','Scatter').XData;
    Q(ii).y = findobj('Type','Scatter').YData;

    close

end

figure;
color = colormap(cool(length(params)));
leg = cell(2*length(params),1);

for ii = 1:length(params)

    plot(Q(ii).x,Q(ii).y,'Color',color(ii,:));
    hold on
    scatter(Q(ii).x,Q(ii).y,[],color(ii,:),'filled');
    hold on
    leg{2*ii-1} = '';
    leg{2*ii} = legNames{ii};

end
    
xlim([-max(abs(xlim)) max(abs(xlim))]);
xline(0,':');
yline(0,':');
xlabel('f * s');
ylabel('actual velocity (deg/s)');
legend(leg,'Location','northwest');
