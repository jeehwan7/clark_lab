function result = runExperiment

%% Created by RT (last updated for annotation: Mar 21 2020)
%% IMPORTANT: You need PTB3 to run this function.
%% GET PTB here: http://psychtoolbox.org/
% This function runs 2AFC motion nulling experiment for Fraser-Wilcox
% illusion pattern with or without bi-directional, polarity specific edge
% adaptors.
% To minimize the experiment time, this script estimates subjects' nulling
% velocity and slope parameters online using a Bayesian adaptive method
% (Psi method, Kontsevich & Taylor, 1999) based on a logistic psychometric
% function. The Bayesian adaptive subroutine is based on QUEST code
% developed by D. Pelli and provided as a part of PTB3.
% (http://psychtoolbox.org/docs/Quest)

%% Preparation of experiment
% Add paths to utility functions
addpath('./myQuest');
addpath('./utils');

AssertOpenGL;

% Find out key config
KbName('UnifyKeyNames');
if ismac
    fjescape = [9,13,41];
elseif IsWin
    fjescape = [70,74,27];
elseif isunix
    fjescape = [42,45,10];
else
    error('Unidentified OS!');
end

% Load the latest gamma correction parameter - the experiment wouldn't run
% without gamma correction
gammafiles = dir('./gamma*.mat');
if isempty(gammafiles)
    error('Please run gammaCorrection script first!');
end
load(gammafiles(end).name,'ghat');
disp(['Loaded the latest gamma correction file. Using g = ',num2str(ghat)]);

% register subjects
subID = input('Input Subject ID (0 for debug): ');


%% Define experiment parameters
% Resolution related
param.viewDist = 43.2; % Viewing distance in cm

% Background & text colors
param.bgLum  = 127; % gray background
param.msgLum = 0;   % black letters

% Adaptor parameters
param.adptypes = 3;   % #adapter types
param.adpDur   = 60;  % duration of long adaptation in sec
param.adpFreq  = 2;   % adaptor phase velocity in Hz
param.adpLambda = 10; % angular size of each adaptor segment in deg (central angle)
param.topUpDur = 3;   % duration for topup adaptation in sec 

% Illusion pattern parameters
param.stEcc    = 11;     % eccentricity of the middle of the ring (in degree visual angle)
param.stThick  = 2;      % thickness of the ring shaped pattern (in degree visual angle)
param.stLambda = 10;     % wavelength of the sawtooth pattern (in degree central angle)
param.stblurfwhm = 0.05; % fwhm of gaussian filter on the pattern (in degree visual angle) 

% Fixation point parameters
param.fpColor = [255,0,0,255]; % color of the fixation point (red)
param.fpSize  = 0.3;           % size of the fixation point in degree visual angle

% Question message (2AFC) 
param.qmsg = 'CCW(F) or CW(J)?';

% Detailed temporal parameters
param.preAdpWait  = 1.0;  % waiting time before adaptors (sec)
param.postAdpWait = 0.5;  % waiting time after adaptros (sec) 
param.prestimWait = 0.25; % waiting time illusion presentation (sec)
param.stimDur     = 0.5;  % duration of the illusion pattern (sec)

% Prior distribution for Bayesian inference
param.tGuess = -0.3;          % prior mean nulling velocity (deg/s)
param.tGuessSd = 1;           % SEM of prior distribution of nulling velocity
param.log2BetaGuess = 3.5;    % prior mean log2 slope
param.log2BetaGuessSd = 3;    % SEM of prior distribution of log2 slope
param.maxTrialPerBlock = 100; % #trial per block

% Generate combinatorial array for adaptor types
adpTrain = randperm(param.adptypes);
param.adpTrain = adpTrain;
param.Nblock = param.adptypes;

% We choose adaptor type based on "adpTrain", and for each adaptor
% presentation, we execute "Ntiralperadp" trials. Trial parameters (i.e.
% direction of the sawtooth ring & rotational velocity) are chosen from
% "byAdpParamList".

% Create table for storing results
result = table(nan,nan,nan,nan,nan,nan,nan,nan);
result.Properties.VariableNames = {'TrialID','BlockID','AdaptorType','TrialIDPerAdaptor','Direction','Velocity','Choice','RT'};
trialID = 0;

%% Running experiment!
% If subID==0, run as a debug mode
if subID~=0
    ListenChar(0); % disable key input into command line
    rng('shuffle');
else
    rng(1); % for debug mode
end
try
    %% Prepare QUEST structures
    q = cell(param.Nblock,1);
    for qq = 1:param.Nblock
        q{qq} = QuestCreateLogistic(param.tGuess,param.tGuessSd,0.5,1,0,0);
    end
    
    %% Prepare Screens
    screens = Screen('screens'); % get available screens
    scrnum  = max(screens);      % use screen with largest ID
    % obtain screen dimensions
    [scrWpx,scrHpx] = Screen('WindowSize',scrnum);  % pixel counts
    [scrWmm,scrHmm] = Screen('DisplaySize',scrnum); % physical dimensions
    % store screen dimensions in the parameter structure
    param.scrWpx = scrWpx; param.scrWmm = scrWmm;
    param.scrHpx = scrHpx; param.scrHmm = scrHmm;
    
    % calculate pixel/visual angle correspondence[1,2]
    pxpercm  = scrWpx/scrWmm*10;
    pxperdeg = pxpercm*param.viewDist*tand(1); % this is only true at the center
                                         % but we ignore the distortion and
                                         % tile
                                         
    % open windows
    if subID~=0 % for real experiments
        [w, rect] = Screen('OpenWindow', scrnum, param.bgLum); % use full screen
        HideCursor;
        ListenChar(2);
    else % for debug mode -- use only a quadrant of the screen
        [w, rect] = Screen('OpenWindow', scrnum, param.bgLum, [0, 0, scrWpx/2,scrHpx/2]);
    end
    
    % obtain center location of the screen
    [center(1), center(2)] = RectCenter(rect);
    % define blending mode
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    % get refresh rate
    ifi=Screen('GetFlipInterval', w);
    fps = round(1/ifi);
    
    %% Prepare stimuli
    %% generate sawtooth (illusion) array
    matSize = round((param.stEcc + param.stThick)*pxperdeg*2) + 11;
    if matSize>scrHpx || matSize>scrWpx
        error('Stimulus too large to fit in the screen!');
    end
    [X,Y] = meshgrid((1:matSize)-matSize/2);
    T = atan2d(X,Y); % T is CCW increasing!
    R = sqrt(X.^2 + Y.^2)/pxperdeg; % in deg (VA)
    donutMask = +(R>param.stEcc-param.stThick/2 & R<param.stEcc+param.stThick/2);
    sawtooth  = mod(T,param.stLambda)/param.stLambda; % CCW increasing
    gausssigpx = param.stblurfwhm/2.355*pxperdeg; % sigma of gaussian blur in px
    
    sawtooth  = imgaussfilt(sawtooth,gausssigpx,'FilterSize',4*ceil(2*gausssigpx)+1);
    donutMask = imgaussfilt(donutMask,gausssigpx,'FilterSize',4*ceil(2*gausssigpx)+1);
    stArray(:,:,1) = sawtooth.^(1/ghat); % gamma correction
    stArray(:,:,2) = sawtooth.^(1/ghat); % gamma correction;
    stArray(:,:,3) = sawtooth.^(1/ghat); % gamma correction;
    stArray(:,:,4) = donutMask; % alpha channel
    
    % Store the pattern as PTB texture
    stPtrCCW = Screen('MakeTexture',w,255*stArray);
    stPtrCW  = Screen('MakeTexture',w,fliplr(255*stArray));
    
    %% Pre-render adaptor array & store as PTB texture
    adpMask = +(R>param.stEcc-param.stThick & R<param.stEcc+param.stThick);
    adpMask = imgaussfilt(adpMask,gausssigpx,'FilterSize',4*ceil(2*gausssigpx)+1);
    param.adpNFrame = fps/param.adpFreq;
    if mod(param.adpNFrame,1)~=0; error('adaptor frequency must be a divisor of fps/2'); end
    adpSawtooth = mod(T,param.adpLambda)/param.adpLambda;
    thresholds  = linspace(0,1,param.adpNFrame/2);
    adpPtrArray = cell(param.adpNFrame+1,1); 
    for ii = 1:param.adpNFrame/2
        thisAdpFrame = imgaussfilt(+(adpSawtooth>=thresholds(ii)),gausssigpx,'FilterSize',4*ceil(2*gausssigpx)+1);
        thisAdpFrame = repmat(thisAdpFrame,1,1,3).^(1/ghat); % gamma correction
        thisAdpFrame(:,:,4) = adpMask; % alpha channel
        adpPtrArray{2*ii-1} = Screen('MakeTexture',w,255*thisAdpFrame);
        thisAdpFrame(:,:,1:3) = 1-thisAdpFrame(:,:,1:3).^(1/ghat); % gamma correction;
        adpPtrArray{2*ii} = Screen('MakeTexture',w,255*thisAdpFrame);
    end
    % for "Null" adaptor
    thisAdpFrame = imgaussfilt(0.5*ones(matSize),gausssigpx,'FilterSize',4*ceil(2*gausssigpx)+1);
    thisAdpFrame = repmat(thisAdpFrame,1,1,3).^(1/ghat); % gamma correction;
    thisAdpFrame(:,:,4) = adpMask; % alpha channel
    adpPtrArray{end} = Screen('MakeTexture',w,255*thisAdpFrame);
    
    %% Show the initial screen & instructions
    % Start screen
    msg = 'Press any key to start';
    instructionscreenandwait(w,msg,param.msgLum,30,0.5);
    
    % Instruction
    msg = ['Fixate on the red dot\n\n',...
           'When asked, answer if the pattern rotated\n\n',...
           'CCW or CW by pressing F(CCW) or J(CW)\n\n',...
           'Press any key to continue'];
    instructionscreenandwait(w,msg,param.msgLum,30,0.5);

    %% Start blocks
    abortFlag = 0;
    for bb = 1:param.Nblock
        % block start screen
        msg = ['Block #',num2str(bb),'/',num2str(param.Nblock),'\n\nPress any key to continue'];
        instructionscreenandwait(w,msg,param.msgLum,30,3);
        %% Start adaptor presentation
        % prepare background texture
        bgTx  = 255*(randi(2,scrHpx,scrWpx)-1);
        bgPtr = Screen('MakeTexture',w,bgTx);
        % pick adaptor type
        thisAdpType = adpTrain(bb);
        % show adaptor
        trialPrepStart = showAdaptor(w,thisAdpType,center,param.adpDur,param,pxperdeg,ifi,bgPtr,adpPtrArray);
        %% Do trials
        for tt = 1:param.maxTrialPerBlock
            %% Show top ups
            if tt~=1 && param.topUpDur>0
                trialPrepStart = showAdaptor(w,thisAdpType,center,param.topUpDur,param,pxperdeg,ifi,bgPtr,adpPtrArray);
            end

            %% Pick parameter from QUEST struct
            % Response is Yes (1) if seen the motion in the direction of
            % upward gradient. Positive "thisSpeed" indicates rotation in
            % the same direction as upward gradient. Estimating only one
            % PMF for CW/CCW stimulus (folded)
            
             % calculate full 2d pdf of two parameters
            [~,~,pdf2d,T,log2k] = QuestBetaAnalysisLogistic(q{adpTrain(bb)},0,param.log2BetaGuess,param.log2BetaGuessSd);
            % Do expected entropy minimization according to psi method
            % See Kontsevich and Tyler 1999 for details
            % Briefly, this calculates, for a range of stimulus
            % probability, posterior distribution of one step in the
            % future p(T,log2k|x,r), where r = 0 or 1.
            
            % Step 1: build L = p(r|x,T,log2k), which is exactly the
            % psychometric function.
            % 1st dim: log2k, 2nd dim: T, 3rd dim: x
            if tt==1&&bb==1 % no nead to repeat this
                [T2,log2k2,x2] = meshgrid(T,log2k,T);
                L = 1./(1+exp(-(2.^log2k2).*(x2-T2))); % likelihood
            end
            pdf2d = pdf2d/sum(pdf2d(:));
            pdf3d = repmat(pdf2d,[1,1,length(T)]); % prior
            
            % Step 2: estimate bunch of distributions to estimate expected entropy.
            LPriY = L.*pdf3d; % product of prior and likelihood
            LPriN = (1-L).*pdf3d;
            % Rate of 'Yes' by x (This is the denominator of posterior)
            PY = sum(sum(LPriY,1),2); 
            % Posterior distribution
            PostY = LPriY./repmat(PY,[size(pdf2d),1]);
            PostN = LPriN./repmat(1-PY,[size(pdf2d),1]);
            
            % Expected Entropy
            HY = -nansum(nansum(PostY.*log(PostY),1),2);
            HN = -nansum(nansum(PostN.*log(PostN),1),2);
            HE = squeeze(HY.*PY + HN.*(1-PY));
            [~,minHind] = min(HE);
            
            thisSpeed = T(minHind);
            thisDirection = 2*randi(2)-3;
            
            if thisDirection==1
                stPtr = stPtrCW;  %  1: default - CW
            else
                stPtr = stPtrCCW; % -1: flipped - CCW
            end

            %% Show background and fixation point
            while GetSecs-trialPrepStart<param.prestimWait; end 

            %% Present stimulus
            trialStart = GetSecs;
            initPhase = randi(360); % randomly initialize phase
            phaseNow = initPhase;
            vbl = GetSecs;
            while GetSecs-trialStart<param.stimDur
                Screen('DrawTexture',w,bgPtr);
                Screen('DrawTexture',w,stPtr,[],[],phaseNow);
                % update phase according to rotational velocity (positive
                % is CW)
                phaseNow = phaseNow + ifi * thisSpeed * thisDirection;
                Screen('DrawDots',w,[0,0],round(param.fpSize*pxperdeg),param.fpColor,center); % fixation point
                vbl = Screen('Flip', w, vbl + ifi*0.5);
            end

            %% Get response
            DrawFormattedText(w,param.qmsg,'center','center',param.msgLum);
            respStart = Screen('Flip', w);
            resp = nan; RT = nan; % initialize response as nan (nan remains when no answer given)
            while 1
                [~,~,kC] = KbCheck;
                if kC(fjescape(1))==1 && kC(fjescape(2))~=1
                    resp = -1; % CCW
                    Screen('Flip', w); % erase instruction once answered
                    break
                elseif kC(fjescape(1))~=1 && kC(fjescape(2))==1
                    resp = 1; %CW
                    Screen('Flip', w);
                    break
                elseif kC(fjescape(3))==1 % escape
                    abortFlag = 1;
                    break
                end
            end
            if abortFlag==1; break; end
            RT = GetSecs - respStart;
            
            %% Record response in quest structure
            q{adpTrain(bb)} = QuestUpdate(q{adpTrain(bb)},thisSpeed,(resp*thisDirection + 1)/2);
            
            %% Record response and params to the output structure
            trialID = trialID + 1;
            result{trialID,:} = [trialID,bb,thisAdpType,tt,thisDirection,thisSpeed,resp,RT];
            
        end
        if abortFlag==1; break; end
    end
    if abortFlag==1; disp('Aborting experiment'); end
    % save the result
    if ~isdir('newresults'); mkdir('newresults'); end
    save(['./newresults/','Sub',num2str(subID),'_',datestr(now,'yyyymmddHHMMSS')],'subID','result','abortFlag','param','ghat','q');
    % endroll
    msg = 'Thank You! Please call the experimenter.';
    ListenChar(0);
    instructionscreenandwait(w,msg,param.msgLum,30,0.5);
    sca;
catch
    disp('Aborting experiment');
    psychrethrow(psychlasterror);
    ListenChar(0);
    sca;

end
end

function lastFlipTime = showAdaptor(w,adptype,center,duration,param,pxperdeg,ifi,bgPtr,adpPtrArray)
    %% This subroutine presents adaptors
    fps = round(1/ifi);
    NadpFramesPerCycle = fps/param.adpFreq;
    NallFrame = length(adpPtrArray);
    adpStart = Screen('Flip',w);
    v = adpStart;
    kk = 1;
    phi = rand*360;
    while 1
        % realize different adaptors by reordering prerendered frames
        if adptype == 1 % Null
            adpSeq = ones(1,NadpFramesPerCycle)*NallFrame;
        elseif adptype==2 % ON edge
            adpSeq = [2:2:(NallFrame-1),(NallFrame-2):-2:1];
        elseif adptype==3 % OFF edge
            adpSeq = [1:2:(NallFrame-2),(NallFrame-1):-2:2];
        end
           
        Screen('DrawTexture',w,bgPtr);
        Screen('DrawTexture',w,adpPtrArray{adpSeq(kk)},[],[],phi);
        Screen('DrawDots',w,[0,0],round(param.fpSize*pxperdeg),param.fpColor,center); % fixation point
        v = Screen('Flip',w,v+ifi*0.5);
        elapsed = v - adpStart;
        kk = mod(kk,NadpFramesPerCycle)+1;
        if kk==1 && adptype~=1; phi = rand*360; end
        if elapsed>duration 
            Screen('DrawTexture',w,bgPtr);
            Screen('DrawDots',w,[0,0],round(param.fpSize*pxperdeg),param.fpColor,center);
            lastFlipTime = Screen('Flip',w,v+ifi*0.5);
            break; 
        end
    end
end