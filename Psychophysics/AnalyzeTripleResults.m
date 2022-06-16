% COPY AND PASTE FILE NAME BELOW ('... .mat')
fileName = '.mat';
actualName = ['./tripleresults/','Subject',num2str(subjectID),'_',startTime,'/',fileName];

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
writetable(struct2table(results),['./tripleresults/','Subject',num2str(subjectID),'_',startTime,'/',erase(fileName,'.mat'),'.xlsx']);