close all
clear

for corrTime = [0 17 33 50 100 200 400]

    fileName = ['Q/',num2str(corrTime),'ms.mat'];
    load(fileName);

    figName = [num2str(corrTime),'ms.fig'];
    
    load('f.mat');
    Q.coefficients = f;
    Q = plotComparison(Q,param);
    savefig(figName);

    close all
    clear

end