AssertOpenGL;

Screen('Preference', 'SkipSyncTests', 0);

%% KEY CONFIGURATION

KbName('UnifyKeyNames');
if ismac
    lresc = [80,82,41];
elseif isunix
    lresc = [KbName('LeftArrow'),KbName('RightArrow'),KbName('ESCAPE')];
elseif ispc
    lresc = [37,39,27];
else
    error('PLATFORM NOT SUPPORTED; MAC OS X, WINDOWS, OR LINUX ONLY');
end

%% PARAMETERS

% Resolution Parameters
param.viewDist = 52; % viewing distance in cm
param.degPerSquare = 0.5; % degrees per check

% Temporal Parameters
param.stimDuration = 10; % duration of stimulus in seconds
param.framesPerSec = 60; % number of frames we want per second
                         % Set this to a factor of the screen frame rate.
                         % Otherwise glitching will occur
param.preStimWait = 2; % duration of fixation point in seconds

% option 1: set param.corrTime then calculate corrFrames
param.corrTime = 400; % in ms % 0,17,33,50,100,200,400
corrFrames = round(param.corrTime/1000*param.framesPerSec);

%{
% option 2: set corrFrames then calculate corrTime
corrFrames = 0;
param.corrTime = round(corrFrames*1000/param.framesPerSec);
%}

param.std = 60; % in deg/s

% Number of Blocks
param.numBlocks = 1;
param.numTrialsPerBlock = 10;

% Fixation Point Parameters
param.fpColor = [255,0,0,255]; % red
param.fpSize = 0.3; % in degrees

% Background and Text Parameters
param.bgLum = 255/2; % grey
param.textSize = 30;
param.textLum = 0; % black

%% RUN EXPERIMENT

% REGISTER SUBJECT
subjectID = input('SUBJECT ID: ');

% Select Screen
screens = Screen('Screens');
screenNumber = max(screens);

% Screen Dimensions
[screenWidthpx,screenHeightpx] = Screen('WindowSize',screenNumber);
[screenWidthmm,screenHeightmm] = Screen('DisplaySize',screenNumber);

% Degree / Pixel Correspondence
pxPermm = mean([screenWidthpx/screenWidthmm, screenHeightpx/screenHeightmm]); % taking the average (almost identical)

fpmm = tand(param.fpSize)*param.viewDist*10;
fppx = round(pxPermm*fpmm); % number of pixels for fixation point

mmPerSquare = tand(param.degPerSquare)*param.viewDist*10;
pxPerSquare = round(pxPermm*mmPerSquare); % number of pixels per check

numSquaresX = ceil(screenWidthpx/pxPerSquare); % round up to ensure we cover the whole screen
numSquaresY = ceil(screenHeightpx/pxPerSquare); % round up to ensure we cover the whole screen
numFrames = param.stimDuration*param.framesPerSec;

% Save Results File
if ~isfolder('./correlatedTernaryAutocorrelatedGaussianresults'); mkdir('./correlatedTernaryAutocorrelatedGaussianresults'); end
startTime = datestr(now,'yyyy.mm.dd_HHMM');
mkdir(['./correlatedTernaryAutocorrelatedGaussianresults/','Subject',num2str(subjectID),'_',startTime]);
save(['./correlatedTernaryAutocorrelatedGaussianresults/','Subject',num2str(subjectID),'_',startTime,'/','Subject',num2str(subjectID),'_',startTime,'.mat'],'subjectID','startTime','param','pxPermm','screenWidthpx');

% Create EyeLink Data Folder (edf files)
if ~isfolder(['./correlatedTernaryAutocorrelatedGaussianresults/','Subject',num2str(subjectID),'_',startTime,'/EdfFiles'])
    mkdir(['./correlatedTernaryAutocorrelatedGaussianresults/','Subject',num2str(subjectID),'_',startTime,'/EdfFiles']);
end

% OPEN WINDOW
[w, rect] = Screen('OpenWindow', screenNumber, param.bgLum, [0, 0, screenWidthpx, screenHeightpx]);

% Center of Screen
[center(1), center(2)] = RectCenter(rect);

% Blending Mode
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Refresh Rate
ifi = Screen('GetFlipInterval', w);

% Wait Frames
waitFrames = round(1/ifi/param.framesPerSec);

% Provide Eyelink with details about the graphics environment and perform some initializations.
% The information is returned in a structure that also contains useful defaults and control codes
% (e.g. tracker state bit and Eyelink key values).
el = EyelinkInitDefaults(w);
el.targetbeep = 0;
el.feedbackbeep = 0;
EyelinkUpdateDefaults(el);

ListenChar(2); % enable listening, suppress output to MATLAB command window

dummymode = 0; % Set to 1 to initialize in dummymode.

% Initialize connection with the Eyelink Gazetracker.
% Exit program if this fails.
if ~EyelinkInit(dummymode,1)
    fprintf('Eyelink Init aborted.\n');
    cleanup;
    return;
end

[v, vs] = Eyelink('GetTrackerVersion');
fprintf('Running experiment on a ''%s'' tracker.\n',vs);

% EYELINK CALIBRATION
EyelinkDoTrackerSetup(el,13);

% WELCOME
msg = [
    'Welcome!\n\n',...
    'Press any key to continue'
    ];
drawText(w,msg,param.textSize,param.textLum);
Screen('Flip',w);
WaitSecs(0.5);
KbWait;

% INSRUCTIONS
msg = [
    'INSTRUCTIONS:\n\n',...
    'A red dot will appear in the center of the screen.\n',...
    'Fixate on that dot until the stimulus appears.\n\n',...
    'Press any key to begin'
    ];
drawText(w,msg,param.textSize,param.textLum);
Screen('Flip',w);
WaitSecs(0.5);
KbWait;

abortFlag = 0;

% stimuli = cell(1,numFrames); % to save all the frames for each trial (1 or -1 for each check)
                               % number of rows to be increased as you go
stimVelocity = NaN(1,numFrames); % column: trial number, row: frame number
results = struct;

for ii = 1:param.numBlocks
    
    %{
    if ii ~= 1
        % DO YOU WISH TO CONTINUE
        msg = ['Do you wish to continue?\n\n',...
            'YES: right arrow key\n\n' ...
            'NO: escape key'];
        drawText(w,msg,param.textSize,param.textLum);
        Screen('Flip',w);
        WaitSecs(0.5);
        while 1
            [~,keyCode] = KbWait;
            if keyCode(lresc(2)) == 1
                break
            elseif keyCode(lresc(3)) == 1
                abortFlag = 1;
                break
            end
        end
    end
    %}

    if abortFlag == 1; break; end
    
    % BLOCK NUMBER
    msg = ['Block ',num2str(ii),' of ',num2str(param.numBlocks)];
    drawText(w,msg,param.textSize,param.textLum);
    Screen('Flip',w);
    WaitSecs(1.5);

    % PREPARING TEXTURES
    msg = ['Preparing textures...\n\n',...
        'Please be patient'
        ];
    drawText(w,msg,param.textSize,param.textLum);
    Screen('Flip',w);

    % Create All Textures for This Block
    % pixels = cell(param.numTrialsPerBlock,numFrames); % for storing matrices
    textures = cell(param.numTrialsPerBlock,numFrames); % for storing texture indices

    for jj = 1:param.numTrialsPerBlock

        % discrete autocorrelated gaussian stimulus velocities
        g = correlatedGaussian(numFrames-1,corrFrames); % deg/s
        g = g*param.std/param.framesPerSec/param.degPerSquare; % checks/frame
        g = round(g); % whole number of checks/frame
        g = [NaN; g];

        stimVelocity((ii-1)*param.numTrialsPerBlock+jj,:) = param.framesPerSec*param.degPerSquare*g; % deg/s

        stim = NaN(numSquaresY,numSquaresX,numFrames);

        init = rand(numSquaresY,numSquaresX,numFrames);
        init = (init>0.5)*2-1;
        
        stim(:,:,1) = 1/2*init(:,:,end) + 1/2*init(:,:,1);

        for kk = 2:numFrames
            prev = init(:,:,kk-1);
            stim(:,:,kk) = 1/2*init(:,:,kk) + 1/2*circshift(prev,g(kk),2);
        end

        % scale for luminance
        stim = 255*(stim+1)/2;

        % magnify
        stim = repelem(stim,pxPerSquare,pxPerSquare);

        for t = 1:numFrames
            % pixels{jj,t} = stim(:,:,t);
            textures{jj,t} = Screen('MakeTexture',w,stim(:,:,t));
        end
    end

    % PREPARATION COMPLETE
    if ii == 1
        msg = ['Preparation complete\n\n',...
            'Press any key to start'
            ];
        drawText(w,msg,param.textSize,param.textLum);
        Screen('Flip',w);
        WaitSecs(0.5);
        KbWait;
    else
        msg = ['Preparation complete\n\n',...
            'Moving onto drift correction...'
            ];
        drawText(w,msg,param.textSize,param.textLum);
        Screen('Flip',w);
        WaitSecs(2);
        
        %{
        % EYELINK DRIFT CORRECTION
        EyelinkDoDriftCorrection(el);

        msg = ['Drift correction complete\n\n',...
            'Press any key to start'
            ];
        drawText(w,msg,param.textSize,param.textLum);
        Screen('Flip',w);
        WaitSecs(0.5);
        KbWait;
        %}
    end

    for ss = 1:param.numTrialsPerBlock
        
        % Open edf file
        edfFile = ['Trial',num2str((ii-1)*param.numTrialsPerBlock+ss),'.edf'];
        Eyelink('Openfile',edfFile);

        % columns for durationInfo table
        frame = permute(1:numFrames,[2 1]);
        onsetTime = NaN(numFrames,1); % onset time of frame
        duration = NaN(numFrames,1); % duration of frame
        timeElapsed = NaN(numFrames,1); % time elapsed since stimulus onset (frame 1 onset)

        % Start recording eye position
        Eyelink('StartRecording');

        % PRESENT FIXATION POINT
        Screen('DrawDots', w, [0,0], fppx, param.fpColor, center, 1);
        vbl = Screen('Flip', w);

        % PRESENT STIMULUS
        Screen('DrawTexture', w, textures{ss,1}); % frame 1
        vbl = Screen('Flip', w, vbl + param.preStimWait-0.5*ifi); % duration of dot presentation utilized here

        Eyelink('Message','STIMULUS_START'); % mark stimulus start

        onsetTime(1) = vbl;

        for qq = 2:numFrames % frames 2 to last
            vblPrevious = vbl;
            Screen('Drawtexture', w, textures{ss,qq});
            vbl = Screen('Flip', w, vbl + (waitFrames-0.5)*ifi);

            onsetTime(qq) = vbl;
            timeElapsed(qq) = vbl-onsetTime(1);
            duration(qq-1) = vbl-vblPrevious;
        end

        stimulusEndTime = Screen('Flip', w, vbl + (waitFrames-0.5)*ifi);

        Eyelink('Message','STIMULUS_END'); % mark stimulus end

        duration(numFrames) = stimulusEndTime-vbl;

        for aa = 1:numFrames
            Screen('Close',textures{ss,aa});
        end

        % Stop recording eye position
        Eyelink('StopRecording');
        Eyelink('CloseFile');

        % Download edf file
        try
            fprintf('Receiving data file ''%s''\n',edfFile);
            status = Eyelink('ReceiveFile');
            if status > 0
                fprintf('ReceiveFile status %d\n',status);
            end
            if 2 == exist(edfFile,'file')
                fprintf('Data file ''%s'' can be found in ''%s''\n',edfFile,pwd);
            end
            movefile('test.edf',fullfile(curr_sub_dir,['run' num2str(run_num) '.edf']));
        catch rdf
            fprintf('Problem receiving data file ''%s''\n',edfFile);
            rdf;
        end

        %% UPDATE 'stimuli' cell
        % stimuli((ii-1)*param.numTrialsPerBlock+ss,:) = pixels(ss,:);
        
        %% UPDATE 'results' structure

        % Trial Number
        results((ii-1)*param.numTrialsPerBlock+ss).trialNumber = (ii-1)*param.numTrialsPerBlock+ss;

%         % Stimulus Start Time
%         results((ii-1)*param.numTrialsPerBlock+ss).stimulusStartTime = onsetTime(1);
%         % Stimulus End Time
%         results((ii-1)*param.numTrialsPerBlock+ss).stimulusEndTime = stimulusEndTime;

        % Stimulus Duration
        results((ii-1)*param.numTrialsPerBlock+ss).stimulusDuration = stimulusEndTime-onsetTime(1);

        % Duration Info
        results((ii-1)*param.numTrialsPerBlock+ss).durationInfo = table(frame,onsetTime,duration,timeElapsed);

    end
    
end

if abortFlag == 1; disp('ABORTING EXPERIMENT...'); end

% SAVING RESULTS
msg = 'Saving results...';
drawText(w,msg,param.textSize,param.textLum);
Screen('Flip',w);
WaitSecs(1);

% Append 'stimVelocity', and 'results'
save(['./correlatedTernaryAutocorrelatedGaussianresults/','Subject',num2str(subjectID),'_',startTime,'/','Subject',num2str(subjectID),'_',startTime,'.mat'],'stimVelocity','results','-append');

% END
msg = [
    'Thank you for participating!\n\n',...
    'Press any key to close'];
drawText(w,msg,param.textSize,param.textLum);
Screen('Flip',w);
WaitSecs(0.5);
KbWait;
cleanup;

% Autocorrelated Gaussian
function g = correlatedGaussian(numFrames,corrFrames) % actually numFrames-1

    if length(corrFrames) == 1 % if corrT is scalar
        if corrFrames == 0
            g = randn(numFrames,1);
        else
            A = 1;
            B = exp(-(0:corrFrames*5)/corrFrames);
            x = randn(2*numFrames,1);
            x = filter(B,A,x);
            g = x(end/2+1:end);
            g = g - mean(g);
            g = g/std(g); % set variance correctly (1)
        end
    else % if vector given, then filter with vector
            x = randn(2*numFrames,1);
            x = filter(corrFrames,1,x);
            g = x(end/2+1:end);
            g = g-mean(g);
            g = g/std(g); % set variance correctly (1)
    end

end

% Draw Text
function drawText(window,text,textSize,textLum)
    Screen('Textsize',window,textSize);
    DrawFormattedText(window,text,'center','center',textLum);
end

function cleanup
    % Shutdown Eyelink
    Eyelink('Shutdown');
    sca;
    ListenChar(0);
end