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

%% CREATE MATRICES for EYE TRACKER DATA
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
% according to the EyeLink settings and my own measurements
viewDistmm = 560;
screenWidthpx = 1920;
screenWidthmm = 600;
% trigonometry
thetabyTrial = atan((posXbyTrial-960)/screenWidthpx*screenWidthmm/viewDistmm);
dThetabyTrial = diff(thetabyTrial,1,2); % diff(X,n,dim);

%% REMOVE SACCADES
param.threshold = 0.001;
param.cutTime = 15;
removesaccades = dThetabyTrial;

for aa = 1:size(removesaccades,1)
    % find all local minima and maxima
    index = find(or(islocalmax(removesaccades(aa,:),'FlatSelection','all'),(islocalmin(removesaccades(aa,:),'FlatSelection','all'))));
    % find the ones whose absolute values exceed the threshold
    index = index(find(abs(removesaccades(aa,index))>param.threshold));
    % remove all the values from cut time to the left to cut time to the right
    for pp = -param.cutTime:param.cutTime
        newIndex = index+pp;
        newIndex(newIndex<1) = 1;
        newIndex(newIndex>1000) = 1000;
        removesaccades(aa,newIndex) = NaN(1,size(newIndex,2));
    end
    % in case there is a discontinuous spike at the start or the end
    if abs(removesaccades(aa,1))>param.threshold
        removesaccades(aa,1:param.cutTime) = NaN(1,param.cutTime);
    end
    if abs(removesaccades(aa,1000))>param.threshold
        removesaccades(aa,1001-param.cutTime:1000) = NaN(1,param.cutTime);
    end
end

%{
%% PLOT DTHETA
for c = 0:0.1:1
    figure;
    index = find((directions==-1).*(coherences==round(c,1)));
    for z = 1:size(index)
        plot(1:1000,dThetabyTrial(index(z),1:1000));
        hold on
    end
    title(['Coherence = ',num2str(-round(c,1))]);
    xlabel('t (ms)');
    ylabel('d\theta');
    hold off
    figure;
    index = find((directions==1).*(coherences==round(c,1)));
    for z = 1:size(index)
        plot(1:1000,dThetabyTrial(index(z),1:1000));
        hold on
    end
    title(['Coherence = ',num2str(round(c,1))]);
    xlabel('t (ms)');
    ylabel('d\theta');
    hold off
end
%}

%% CALCULATE and PLOT DELTATHETA by COHERENCE
deltaThetabyCoherence = zeros(numTrials,2); % deltatheta, coherence (in that order)
for ii = 1:size(deltaThetabyCoherence,1)
    % sum dtheta to get deltatheta
    deltaThetabyCoherence(ii,1) = sum(removesaccades(ii,:),'omitnan');
    % render the sum NaN if it was from an unreadable edf file
    % (i.e. if all of the values were NaN because the sum comes out as zero)
    if sum(~isnan(removesaccades(ii,1))) == 0
        deltaThetabyCoherence(ii,1) = NaN;
    end
    % if it was a left trial, multiply the coherence by -1
    if paramsbyTrial(ii,1) == 1
        deltaThetabyCoherence(ii,2) = paramsbyTrial(ii,2);
    elseif paramsbyTrial(ii,1) == -1
        deltaThetabyCoherence(ii,2) = -paramsbyTrial(ii,2);
    end
end
% banger of a scatter plot
figure;
scatter(deltaThetabyCoherence(:,2),deltaThetabyCoherence(:,1));
title('\Delta\theta');
yline(0,'--');
xlabel('Coherence');
ylabel('\Delta\theta (excluding saccades)');

%% CALCULATE and PLOT P(right) by COHERENCE
% turn all -1's and NaN's into 0's
responsesEdited = responses;
responsesEdited(responsesEdited == -1) = 0;
responsesEdited(isnan(responsesEdited)) = 0;

prightbyCoherence = zeros(21,2);
prightbyCoherence(:,2) = -1.0:0.1:1.0;

nn = 1; % MATLAB sucks when dealing with decimals
for k = -1:0.1:1
    if k ~= 0
        indexDirection = find(directions == sign(k));
        indexCoherence = find(coherences == abs(round(k,1)));
        indexFinal = intersect(indexDirection,indexCoherence);
    elseif k == 0
        indexFinal = find(coherences == 0);
    end
    prightbyCoherence(nn,1) = mean(responsesEdited(indexFinal));
    nn = nn+1;
end

figure;
scatter(prightbyCoherence(:,2),prightbyCoherence(:,1));
title('P(right)');
yline(0.5,'--');
xlabel('Coherence');
ylabel('P(right)');

%% CALCULATE and PLOT SKEWNESS by COHERENCE
skewnessbyCoherence = zeros(numTrials,2);
for ii = 1:size(skewnessbyCoherence)
    skewnessbyCoherence(ii,1) = skewness(dThetabyTrial(ii,:));
    % if it was a left trial, multiply the coherence by -1
    if paramsbyTrial(ii,1) == 1
        skewnessbyCoherence(ii,2) = paramsbyTrial(ii,2);
    elseif paramsbyTrial(ii,1) == -1
        skewnessbyCoherence(ii,2) = -paramsbyTrial(ii,2);
    end
end

figure;
scatter(skewnessbyCoherence(:,2),skewnessbyCoherence(:,1));
title('Skewness');
yline(0,'--');
xlabel('Coherence');
ylabel('Skewness');