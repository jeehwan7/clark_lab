function edf2matError = convertFile(fileName)
    
    load(fileName,'subjectID');

    % Convert edf file to mat file
    mkdir MatFiles;    
    edf2matError = false;
    
    try
        data = Edf2Mat(['EdfFiles/','sub',num2str(subjectID),'.edf']);
        save(['MatFiles/','sub',num2str(subjectID),'.mat'],'data');
    catch % if edf file is unreadable
        warning('Error while converting from edf to mat');
        edf2matError = true;
    end

end