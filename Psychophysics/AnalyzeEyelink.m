% COPY AND PASTE FILE NAME BELOW ('... .mat')
load('.mat','results');

numTrials = height(struct2table(results));

trialNumbers = zeros(11,numTrials/11);

coherences = vertcat(results.coherence);

for i = 1:11
    trialNumbers(i,:) = find(coherences == round((i-1)*0.1,1));
end

for j = 1:11
    
    figure;
    tiledlayout(2,1)
    nexttile

    % time vs. eye position

    for k = 1:size(trialNumbers,2)

        data = Edf2Mat(['Trial',num2str(trialNumbers(j,k)),'.edf']);
        
        index = find(strcmp(data.Events.Messages.info,'STIMULUS_START'));
        
        stimulusStartTime = data.Events.Messages.time(index);
        
        normalizedTime = data.Samples.time - stimulusStartTime;

        plot(normalizedTime,data.Samples.posX);
    
        hold on

    end
    
    xline(0,'--');
    title(['Coherence = ',num2str(round((j-1)*0.1,1))]);
    xlabel('t');
    ylabel('x')
    hold off
    
    nexttile

    % time vs. gradient

    for k = 1:size(trialNumbers,2)

        data = Edf2Mat(['Trial',num2str(trialNumbers(j,k)),'.edf']);
        
        index = find(strcmp(data.Events.Messages.info,'STIMULUS_START'));
        
        stimulusStartTime = data.Events.Messages.time(index);
        
        normalizedTime = data.Samples.time - stimulusStartTime;
    
        plot(normalizedTime(2:end),diff(data.Samples.posX));
    
        hold on

    end
    
    xline(0,'--');
    xlabel('t');
    ylabel('dx/dt')
    hold off

end