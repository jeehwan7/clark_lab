% COPY AND PASTE FILE NAME BELOW ('... .mat')
fileName = '.mat';
actualName = ['./gliderstimuliresults/',fileName];

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
writetable(struct2table(results),['./gliderstimuliresults/',erase(fileName,'.mat'),'.xlsx']);