%% LOAD RESULTS
% COPY AND PASTE FILE NAME BELOW ('... .mat')
load('Subject0_2022.06.28_1406.mat','results');

numTrials = height(struct2table(results));

%{
%% CONVERT EDF FILES TO MAT FILES
mkdir MatFiles;

edf2matFail = [];

for f = 1:numTrials
    try
        data = Edf2Mat(['Trial',num2str(f),'.edf']);
        save(['MatFiles/Trial',num2str(f),'.mat'],'data');
    catch % if edf file is unreadable
        warning(['Trial ',num2str(f),' will be excluded from the results.']);
        edf2matFail = [edf2matFail, f];
    end
end
%}

%% CREATE MATRICES FOR DATA
posXbyTrial = nan(numTrials,1004);

for ii = 1:numTrials
    if isfile(['Trial',num2str(ii),'.mat'])
        load(['Trial',num2str(ii),'.mat']);
        stimulusStartTime = data.Events.Messages.time(find(strcmp(data.Events.Messages.info,'STIMULUS_START')));
        stimulusEndTime = data.Events.Messages.time(find(strcmp(data.Events.Messages.info,'STIMULUS_END')));
        posXbyTrial(ii,1:1+stimulusEndTime-stimulusStartTime) = data.Samples.posX(find(data.Samples.time == stimulusStartTime):find(data.Samples.time == stimulusEndTime));
    end
end

paramsbyTrial = zeros(numTrials,4);

coherences = vertcat(results.coherence);
directions = vertcat(results.direction);
responses = vertcat(results.response);
responseTimes = vertcat(results.responseTime);

paramsbyTrial(:,1) = directions;
paramsbyTrial(:,2) = coherences;
paramsbyTrial(:,3) = responses;
paramsbyTrial(:,4) = responseTimes;

%% CALCULCATE DTHETA
viewDistmm = 560;
screenWidthpx = 1920;
screenWidthmm = 600;

thetabyTrial = atan((posXbyTrial-960)/screenWidthpx*screenWidthmm/viewDistmm);
dthetabyTrial = diff(thetabyTrial,1,2);


%% REMOVE SACCADES
param.threshold = 0.0008;
param.cutTime = 12;

for aa = 1:size(dthetabyTrial,1)
    index = find(or(islocalmax(dthetabyTrial(aa,:),'FlatSelection','all'),(islocalmin(dthetabyTrial(aa,:),'FlatSelection','all'))));
    index = index(find(abs(dthetabyTrial(aa,index))>param.threshold));
    for pp = -param.cutTime:param.cutTime
        newIndex = index+pp;
        newIndex(newIndex<1) = 1;
        newIndex(newIndex>1000) = 1000;
        dthetabyTrial(aa,newIndex) = NaN(1,size(newIndex,2));
    end
end


%% PLOT DTHETA
for c = 0:0.1:1
    figure;
    index = find((paramsbyTrial(:,1)==-1).*(paramsbyTrial(:,2)==round(c,1)));
    for z = 1:size(index)
        plot(1:1000,dthetabyTrial(index(z),1:1000));
        hold on
    end
    title(['Coherence = ',num2str(-round(c,1))]);
    xlabel('t (ms)');
    ylabel('d\theta');
    hold off
    figure;
    index = find((paramsbyTrial(:,1)==1).*(paramsbyTrial(:,2)==round(c,1)));
    for z = 1:size(index)
        plot(1:1000,dthetabyTrial(index(z),1:1000));
        hold on
    end
    title(['Coherence = ',num2str(round(c,1))]);
    xlabel('t (ms)');
    ylabel('d\theta');
    hold off
end