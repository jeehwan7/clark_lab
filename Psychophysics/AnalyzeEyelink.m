% COPY AND PASTE FILE NAME BELOW ('... .mat')
load('.mat','results');

numTrials = height(struct2table(results));

%{

% check for unreadable edf files
errors = [];

for f = 1:numTrials
    try
        Edf2Mat(['Trial',num2str(f),'.edf']);
    catch
        warning(['Trial ',num2str(f),' will be excluded from the results.']);
        errors = [errors, f];
    end
end

%}

% the y axis represents coherence (1st row = 0 ... 11th row = 1)
% the z axis represents direction (1st layer = left, 2nd layer = right)
trialNumbers = zeros(11,numTrials/22,2);

coherences = vertcat(results.coherence);
directions = vertcat(results.direction);

% categorize trials according to their coherences and directions
for i = 1:11
    trialNumbers(i,:,1) = intersect(find(coherences == round((i-1)*0.1,1)), find(directions == -1)); % left
    trialNumbers(i,:,2) = intersect(find(coherences == round((i-1)*0.1,1)), find(directions == 1)); % right
end

% plot x vs. t and dx/dt vs. t
for j = 1:11
    
    %% LEFT
    figure;
    tiledlayout(2,1)
    nexttile

    % x vs. t
    for k = 1:size(trialNumbers,2)

        if isfile(['Trial',num2str(trialNumbers(j,k,1)),'.mat'])

            load(['Trial',num2str(trialNumbers(j,k,1)),'.mat']);
            stimulusStartTime = data.Events.Messages.time(find(strcmp(data.Events.Messages.info,'STIMULUS_START')));
            stimulusEndTime = data.Events.Messages.time(find(strcmp(data.Events.Messages.info,'STIMULUS_END')));
            normalizedTime = data.Samples.time-stimulusStartTime;
            if stimulusEndTime-stimulusStartTime > 1000
                normalizedEnd = 1000;
            else
                normalizedEnd = stimulusEndTime-stimulusStartTime;
            end
            plot(normalizedTime(find(normalizedTime == 0):find(normalizedTime == normalizedEnd)),data.Samples.posX(find(normalizedTime == 0):find(normalizedTime == normalizedEnd)));
            hold on       

        end

    end

    title(['Coherence = ',num2str(round((j-1)*0.1,1)),', LEFT']);
    % xline(0,'--');
    % xline(1000,'--');
    xlabel('t (ms)');
    ylabel('x')
    hold off
    nexttile

    % dx/dt vs. t
    for k = 1:size(trialNumbers,2)

        if isfile(['Trial',num2str(trialNumbers(j,k,1)),'.mat'])

            load(['Trial',num2str(trialNumbers(j,k,1)),'.mat']);
            stimulusStartTime = data.Events.Messages.time(find(strcmp(data.Events.Messages.info,'STIMULUS_START')));
            stimulusEndTime = data.Events.Messages.time(find(strcmp(data.Events.Messages.info,'STIMULUS_END')));
            normalizedTime = data.Samples.time-stimulusStartTime;
            if stimulusEndTime-stimulusStartTime > 1000
                normalizedEnd = 1000;
            else
                normalizedEnd = stimulusEndTime-stimulusStartTime;
            end
            plot(normalizedTime(find(normalizedTime == 0):find(normalizedTime == normalizedEnd)),diff(data.Samples.posX(find(normalizedTime == -1):find(normalizedTime == normalizedEnd))));
            hold on

        end

    end
    
    % xline(0,'--');
    % xline(1000,'--');
    xlabel('t (ms)');
    ylabel('dx/dt')
    hold off

    %% RIGHT
    figure;
    tiledlayout(2,1)
    nexttile

    % x vs. t
    for k = 1:size(trialNumbers,2)

        if isfile(['Trial',num2str(trialNumbers(j,k,2)),'.mat'])

            load(['Trial',num2str(trialNumbers(j,k,2)),'.mat']);
            stimulusStartTime = data.Events.Messages.time(find(strcmp(data.Events.Messages.info,'STIMULUS_START')));
            stimulusEndTime = data.Events.Messages.time(find(strcmp(data.Events.Messages.info,'STIMULUS_END')));
            normalizedTime = data.Samples.time-stimulusStartTime;
            if stimulusEndTime-stimulusStartTime > 1000
                normalizedEnd = 1000;
            else
                normalizedEnd = stimulusEndTime-stimulusStartTime;
            end
            plot(normalizedTime(find(normalizedTime == 0):find(normalizedTime == normalizedEnd)),data.Samples.posX(find(normalizedTime == 0):find(normalizedTime == normalizedEnd)));
            hold on

        end

    end

    title(['Coherence = ',num2str(round((j-1)*0.1,1)),', RIGHT']);
    % xline(0,'--');
    % xline(1000,'--');
    xlabel('t (ms)');
    ylabel('x')
    hold off
    nexttile

    % dx/dt vs. t
    for k = 1:size(trialNumbers,2)

        if isfile(['Trial',num2str(trialNumbers(j,k,2)),'.mat'])

            load(['Trial',num2str(trialNumbers(j,k,2)),'.mat']);
            stimulusStartTime = data.Events.Messages.time(find(strcmp(data.Events.Messages.info,'STIMULUS_START')));
            stimulusEndTime = data.Events.Messages.time(find(strcmp(data.Events.Messages.info,'STIMULUS_END')));
            normalizedTime = data.Samples.time - stimulusStartTime;
            if stimulusEndTime-stimulusStartTime > 1000
                normalizedEnd = 1000;
            else
                normalizedEnd = stimulusEndTime-stimulusStartTime;
            end
            plot(normalizedTime(find(normalizedTime == 0):find(normalizedTime == normalizedEnd)),diff(data.Samples.posX(find(normalizedTime == -1):find(normalizedTime == normalizedEnd))));
            hold on

        end

    end
    
    % xline(0,'--');
    % xline(1000,'--');
    xlabel('t (ms)');
    ylabel('dx/dt')
    hold off

end