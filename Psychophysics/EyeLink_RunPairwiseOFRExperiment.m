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
param.degPerSquare = 1; % degrees per check

% Temporal Parameters
param.stimDuration = 0.25; % duration of stimulus in seconds
param.framesPerSec = 60; % number of frames we want per second
                         % Set this to a factor of the screen frame rate.
                         % Otherwise glitching will occur

% Number of Blocks
param.numBlocks = 15;

% Fixation Dot Parameters
param.fpColor = [255,0,0,255]; % red 
param.fpSize = 0.5; % in degrees

% Background and Text Parameters
param.bgLum = 255/2; % grey
param.textSize = 30;
param.textLum = 0; % black

% Fixation Window
fixWinSize = 100; % in pixels
fixateTime1 = 500; % in ms (first fixation dot)
fixateTime2 = 50; % in ms (second fixation dot)

%% STIMULUS SETTINGS
% Column 1: left (0 means right, 1 means left), Column 2: fracCoherence (between 0 and 1)
stimulusSettings = [0 0;
                    0 1; 0 1; 0 1; 0 1; 0 1; 0 1; 0 1; 0 1; 0 1; 0 1;
                    1 1; 1 1; 1 1; 1 1; 1 1; 1 1; 1 1; 1 1; 1 1; 1 1;
                    ];

%% RUN EXPERIMENT

% REGISTER SUBJECT
subjectID = input('SUBJECT ID: ');

% Select Screen
screens = Screen('Screens');
screenNumber = max(screens);

% Screen Dimensions
[screenWidthpx,screenHeightpx] = Screen('WindowSize',screenNumber);
[screenWidthmm,screenHeightmm] = Screen('DisplaySize',screenNumber);

xLeftLimit = screenWidthpx/2 - fixWinSize;
xRightLimit = screenWidthpx/2 + fixWinSize;

yBottomLimit2 = screenHeightpx/2 - fixWinSize;
yTopLimit2 = screenHeightpx/2 + fixWinSize;

% Degree / Pixel Correspondence
pxPermm = mean([screenWidthpx/screenWidthmm, screenHeightpx/screenHeightmm]); % taking the average (almost identical)

fpmm = tand(param.fpSize)*param.viewDist*10;
fppx = round(pxPermm*fpmm); % number of pixels for fixation point

mmPerSquare = tand(param.degPerSquare)*param.viewDist*10;
pxPerSquare = round(pxPermm*mmPerSquare); % number of pixels per check

numSquaresX = ceil(screenWidthpx/pxPerSquare); % round up to ensure we cover the whole screen
numSquaresY = ceil(screenHeightpx/pxPerSquare); % round up to ensure we cover the whole screen
numFrames = ceil(param.stimDuration*param.framesPerSec);

% Save Results File
if ~isfolder('./pairwiseOFRresults'); mkdir('./pairwiseOFRresults'); end
startTime = datestr(now,'yyyy.mm.dd_HHMM');
mkdir(['./pairwiseOFRresults/','Subject',num2str(subjectID),'_',startTime]);
save(['./pairwiseOFRresults/','Subject',num2str(subjectID),'_',startTime,'/','Subject',num2str(subjectID),'_',startTime,'.mat'],'subjectID','startTime','param','pxPermm','screenWidthpx');

% Create EyeLink Data Folder (edf files)
if ~isfolder(['./pairwiseOFRresults/','Subject',num2str(subjectID),'_',startTime,'/EdfFiles'])
    mkdir(['./pairwiseOFRresults/','Subject',num2str(subjectID),'_',startTime,'/EdfFiles']);
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

% Select which events are saved in the EDF file. Include everything just in case
Eyelink('Command','file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
% Select which events are available online for gaze-contingent experiments. Include everything just in case
Eyelink('Command','link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,BUTTON,FIXUPDATE,INPUT');

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

% INSTRUCTIONS
msg = [
    'INSTRUCTIONS:\n\n',...
    'Whenever a red dot appears, saccade to it and fixate on it.\n',...
    'The dot will disappear once the stimulus begins.\n',...
    'Press any key to begin'
    ];
drawText(w,msg,param.textSize,param.textLum);
Screen('Flip',w);
WaitSecs(0.5);
KbWait;

abortFlag = 0;

stimuli = cell(1,numFrames); % to save all the frames for each trial (1 or -1 for each check)
results = struct;

for ii = 1:param.numBlocks

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
    squares = cell(size(stimulusSettings,1),numFrames); % for storing matrices
    textures = cell(size(stimulusSettings,1),numFrames); % for storing texture indices

    for jj = 1:size(stimulusSettings,1)
        pairwiseSquares = pairwise(stimulusSettings(jj,1),numSquaresX, numSquaresY, numFrames, stimulusSettings(jj,2));
        pairwiseMatrix = 255*(pairwiseSquares+1)/2; % turn all negative ones into zeroes, multiply by 255 for luminance (black or white)
        pairwiseMatrix = repelem(pairwiseMatrix,pxPerSquare,pxPerSquare); % "zoom in" according to degPerSquare

        for kk = 1:numFrames
            squares{jj,kk} = pairwiseSquares(:,:,kk);
            textures{jj,kk} = Screen('MakeTexture',w,pairwiseMatrix(:,:,kk));
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
        
        % EYELINK DRIFT CORRECTION
        EyelinkDoDriftCorrection(el);

        msg = ['Drift correction complete\n\n',...
            'Press any key to start'
            ];
        drawText(w,msg,param.textSize,param.textLum);
        Screen('Flip',w);
        WaitSecs(0.5);
        KbWait;
    end
    
    % Randomize Order of Stimulus Settings
    randomizedIndex = randperm(size(stimulusSettings,1));
    randomizedStimulusSettings = stimulusSettings(randomizedIndex,:);

    for ss = 1:size(stimulusSettings,1)

        % Open edf file
        edfFile = ['Trial',num2str((ii-1)*size(stimulusSettings,1)+ss),'.edf'];
        Eyelink('Openfile',edfFile);
        
        % columns for indivFrameInfo table
        frame = permute(1:numFrames,[2 1]);
        onsetTime = NaN(numFrames,1); % onset time of frame
        duration = NaN(numFrames,1); % duration of frame
        timeElapsed = NaN(numFrames,1); % time elapsed since stimulus onset (frame 1 onset)

        Eyelink('StartRecording'); % Start tracker recording
        WaitSecs(0.1); % Allow some time to record a few samples before presenting first stimulus

        eyeUsed = Eyelink('EyeAvailable');
        % Get events from right eye if binocular
        if eyeUsed == 2
            eyeUsed = 1;
        end

        % PRESENT FIRST FIXATION DOT
        % First fixation dot appears either in the top half or bottom half
        if rand > 0.5
            dotY = screenHeightpx/4;
            yTopLimit1 = screenHeightpx*3/4 + fixWinSize;
            yBottomLimit1 = screenHeightpx*3/4 - fixWinSize;
        else
            dotY = -screenHeightpx/4;
            yTopLimit1 = screenHeightpx/4 + fixWinSize;
            yBottomLimit1 = screenHeightpx/4 - fixWinSize;
        end

        Screen('DrawDots', w, [0,dotY], fppx, param.fpColor, center, 1);
        [~,gazeWinStart] = Screen('Flip', w);

        Eyelink('Message','FIRST_DOT');

        while 1
            if Eyelink('NewFloatSampleAvailable') > 0 % Check if a new sample is available online via the link        
                evt = Eyelink('NewestFloatSample'); % Get sample data in MATLAB structure
                x_gaze = evt.gx(eyeUsed+1); % [left eye gaze x, right eye gaze x] +1 as we're accessing an array
                y_gaze = evt.gy(eyeUsed+1); % [left eye gaze y, right eye gaze y]
                
                % If gaze sample is within fixation window
                if x_gaze > xLeftLimit && x_gaze < xRightLimit && ...
                        y_gaze > yBottomLimit1 && y_gaze < yTopLimit1
                    if (GetSecs - gazeWinStart)*1000 >= fixateTime1
                        break;
                    end
                % If gaze sample is out
                elseif x_gaze <= xLeftLimit || x_gaze >= xRightLimit || ...
                        y_gaze <= yBottomLimit1 || y_gaze >= yTopLimit1
                    gazeWinStart = GetSecs; % Reset fixation window timer
                end
            end
        end

        % PRESENT SECOND FIXATION DOT
        % Second fixation dot appears in the center on top of first frame
        Screen('DrawTexture', w, textures{randomizedIndex(ss),1}); % frame 1
        Screen('DrawDots', w, [0,0], fppx, param.fpColor, center, 1);

        [~,gazeWinStart] = Screen('Flip', w);

        Eyelink('Message','SECOND_DOT');

        while 1
            if Eyelink('NewFloatSampleAvailable') > 0 % Check if a new sample is available online via the link        
                evt = Eyelink('NewestFloatSample'); % Get sample data in MATLAB structure
                x_gaze = evt.gx(eyeUsed+1); % [left eye gaze x, right eye gaze x] +1 as we're accessing an array
                y_gaze = evt.gy(eyeUsed+1); % [left eye gaze y, right eye gaze y]
                
                % If gaze sample is within fixation window
                if x_gaze > xLeftLimit && x_gaze < xRightLimit && ...
                        y_gaze > yBottomLimit2 && y_gaze < yTopLimit2
                    if (GetSecs - gazeWinStart)*1000 >= fixateTime2
                        break;
                    end
                % If gaze sample is out
                elseif x_gaze <= xLeftLimit || x_gaze >= xRightLimit || ...
                        y_gaze <= yBottomLimit2 || y_gaze >= yTopLimit2
                    gazeWinStart = GetSecs; % Reset fixation window timer
                end
            end
        end

        % PRESENT STIMULUS
        Screen('DrawTexture', w, textures{randomizedIndex(ss),1}); % frame 1
        vbl = Screen('Flip', w); % frame 1 without fixation dot
        
        Eyelink('Message','STIMULUS_START');

        onsetTime(1) = vbl;

        for qq = 2:numFrames % frames 2 to last
            vblPrevious = vbl;
            Screen('DrawTexture', w, textures{randomizedIndex(ss),qq});
            vbl = Screen('Flip', w, vbl + (waitFrames-0.5)*ifi);

            onsetTime(qq) = vbl;
            timeElapsed(qq) = vbl-onsetTime(1);
            duration(qq-1) = vbl-vblPrevious;
        end

        stimulusEndTime = Screen('Flip', w, vbl + (waitFrames-0.5)*ifi);

        Eyelink('Message','STIMULUS_END');

        duration(numFrames) = stimulusEndTime-vbl;
        
        for aa = 1:numFrames
            Screen('Close',textures{randomizedIndex(ss),aa});
        end

        Screen('Flip', w);

        % Stop recording eye position
        WaitSecs(0.1);
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
        stimuli((ii-1)*size(randomizedStimulusSettings,1)+ss,:) = squares(randomizedIndex(ss),:);
        
        %% UPDATE 'results' structure

        % Trial Number
        results((ii-1)*size(randomizedStimulusSettings,1)+ss).trialNumber = (ii-1)*size(randomizedStimulusSettings,1)+ss;
        
        % Direction
        if randomizedStimulusSettings(ss,1) == 0
            results((ii-1)*size(randomizedStimulusSettings,1)+ss).direction = 1;
        elseif randomizedStimulusSettings(ss,1) == 1
            results((ii-1)*size(randomizedStimulusSettings,1)+ss).direction = -1;
        end
        
        % Coherence
        results((ii-1)*size(randomizedStimulusSettings,1)+ss).coherence = randomizedStimulusSettings(ss,2);

%         % Stimulus Start Time
%         results((ii-1)*size(randomizedStimulusSettings,1)+ss).stimulusStartTime = onsetTime(1);
%         % Stimulus End Time
%         results((ii-1)*size(randomizedStimulusSettings,1)+ss).stimulusEndTime = stimulusEndTime;

        % Stimulus Duration
        results((ii-1)*size(randomizedStimulusSettings,1)+ss).stimulusDuration = stimulusEndTime-onsetTime(1);

        % Individual Frame Information
        results((ii-1)*size(randomizedStimulusSettings,1)+ss).indivFrameInfo = table(frame,onsetTime,duration,timeElapsed);
        
        WaitSecs(0.5);
    end
    
end

if abortFlag == 1; disp('ABORTING EXPERIMENT...'); end

% SAVING RESULTS
msg = 'Saving results...';
drawText(w,msg,param.textSize,param.textLum);
Screen('Flip',w);
WaitSecs(1);

% Append 'stimuli' and 'results'
save(['./pairwiseOFRresults/','Subject',num2str(subjectID),'_',startTime,'/','Subject',num2str(subjectID),'_',startTime,'.mat'],'stimuli','results','-append');

% END
msg = [
    'Thank you for participating!\n\n',...
    'Press any key to close'];
drawText(w,msg,param.textSize,param.textLum);
Screen('Flip',w);
WaitSecs(0.5);
KbWait;
cleanup;

% 3D Matrix for Pairwise Patterns with Varying Coherence
function mp = pairwise(left, x, y, z, fracCoherence)

    % first frame
    mp(:,:,1) = (zeros(y,x)-1).^(randi([0 1],[y,x]));

    % right
    for t = 2:z
        mp(:,1,t) = (zeros(y,1)-1).^(randi([0 1],[y,1]));
        mp(:,2:x,t) = mp(:,1:x-1,t-1);
        indexRandom = randperm(x*y,x*y-round(x*y*fracCoherence));
        mp(x*y*(t-1)+indexRandom) = 2*(rand(1,size(indexRandom,2))>0.5)-1;
    end
    % left
    if left == 1
        mp = flip(mp, 2);
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