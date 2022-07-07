function edf2matErrors = convertFiles(fileName)
    
    %% LOAD RESULTS
    load(fileName,'results');
    numTrials = height(struct2table(results));

    %% CONVERT EDF FILES TO MAT FILES
    mkdir MatFiles;    
    edf2matErrors = [];
    
    for f = 1:numTrials
        try
            data = Edf2Mat(['Trial',num2str(f),'.edf']);
            save(['MatFiles/Trial',num2str(f),'.mat'],'data');
        catch % if edf file is unreadable
            warning(['Trial ',num2str(f),' will be excluded from the results.']);
            edf2matErrors = [edf2matErrors, f];
        end
    end

end