% COPY AND PASTE FILE NAME BELOW ('... .mat')
fileName = '.mat';
actualName = ['./coherenceresults/',erase(fileName,'.mat'),'/',fileName];

load(actualName,'results');

% Symmetrize
for ii = 1:max([results.trialNumber])
    if ~isnan(results(ii).response)
        if results(ii).direction == -1
            results(ii).direction = 1;
            results(ii).response = -results(ii).response;
        end
    end
end

% Create Excel Sheet
writetable(struct2table(results),['./coherenceresults/',erase(fileName,'.mat'),'/',erase(fileName,'.mat'),'.xlsx']);