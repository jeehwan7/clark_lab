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
param.stimDuration = 1; % duration of stimulus in seconds
param.framesPerSec = 30; % number of frames we want per second
                         % Set this to a factor of the screen frame rate.
                         % Otherwise glitching will occur
param.preStimWait = 2; % duration of fixation point in seconds

% Number of Blocks
param.numBlocks = 10;

% Fixation Point Parameters
param.fpColor = [255,0,0,255]; % red
param.fpSize = 0.3; % in degrees

% Background and Text Parameters
param.bgLum = 255/2; % grey
param.textSize = 30;
param.textLum = 0; % black

%% STIMULUS SETTINGS
% Column 1: direction (1 means right, -1 means left), Column 2: fracCoherence (between 0 and 1)
stimulusSettings = [1 0; 1 0.1; 1 0.2; 1 0.3; 1 0.4; 1 0.5; 1 0.6; 1 0.7; 1 0.8; 1 0.9; 1 1; -1 0.1; -1 0.2; -1 0.3; -1 0.4; -1 0.5; -1 0.6; -1 0.7; -1 0.8; -1 0.9; -1 1];

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
if ~isfolder('./pairwisecoherenceresults'); mkdir('./pairwisecoherenceresults'); end
startTime = datestr(now,'yyyy.mm.dd_HHMM');
mkdir(['./pairwisecoherenceresults/','Subject',num2str(subjectID),'_',startTime]);
save(['./pairwisecoherenceresults/','Subject',num2str(subjectID),'_',startTime,'/','Subject',num2str(subjectID),'_',startTime,'.mat'],'subjectID','startTime','param','pxPermm','screenWidthpx');

% Create EyeLink Data Folder (edf files)
if ~isfolder(['./pairwisecoherenceresults/','Subject',num2str(subjectID),'_',startTime,'/EdfFiles'])
    mkdir(['./pairwisecoherenceresults/','Subject',num2str(subjectID),'_',startTime,'/EdfFiles']);
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
    'Fixate on that dot until the stimulus appears.\n',...
    'After the stimulus disappears, indicate your\n',...
    'perceived direction of motion by pressing on the\n',...
    'left arrow key or right arrow key.\n\n',...
    'You will have 2 seconds to answer.\n\n',...
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
            textures{jj,kk} = Screen('MakeTexture', w, pairwiseMatrix(:,:,kk));
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

        % Start recording eye position
        Eyelink('StartRecording');

        % PRESENT FIXATION POINT
        Screen('DrawDots', w, [0,0], fppx, param.fpColor, center, 1);
        vbl = Screen('Flip', w);

        % PRESENT STIMULUS
        Screen('DrawTexture', w, textures{randomizedIndex(ss),1}); % frame 1
        vbl = Screen('Flip', w, vbl + param.preStimWait-0.5*ifi); % duration of dot presentation utilized here

        Eyelink('Message', 'STIMULUS_START');

        onsetTime(1) = vbl;

        for qq = 2:numFrames % frames 2 to last
            vblPrevious = vbl;
            Screen('Drawtexture', w, textures{randomizedIndex(ss),qq});
            vbl = Screen('Flip', w, vbl + (waitFrames-0.5)*ifi);

            onsetTime(qq) = vbl;
            timeElapsed(qq) = vbl-onsetTime(1);
            duration(qq-1) = vbl-vblPrevious;
        end

        % RESPONSE
        question = 'Left or Right?';
        drawText(w,question,param.textSize,param.textLum);
        responseStart = Screen('Flip', w, vbl + (waitFrames-0.5)*ifi);

        Eyelink('Message','STIMULUS_END'); % mark stimulus end

        while 1
            if GetSecs - responseStart >= 2
                response = 0;
                Screen('Flip',w);
                break  % answer within 2 seconds
            end
            [~,~,keyCode] = KbCheck;
            if keyCode(lresc(1)) == 1 && keyCode(lresc(2)) ~= 1
                responseTime = GetSecs - responseStart;
                response = -1; % left
                Screen('Flip',w);
                break
            elseif keyCode(lresc(1)) ~= 1 && keyCode(lresc(2)) == 1
                responseTime = GetSecs - responseStart;
                response = 1; % right
                Screen('Flip',w);
                break
            elseif keyCode(lresc(3)) == 1
                abortFlag = 1;
                break
            end
        end

        duration(numFrames) = responseStart-vbl;

        for aa = 1:numrames
            Screen('Close',textures{randomizedIndex(ss),aa});
        end

        % Stop recording eye position
        Eyelink('StopRecording');
        Eyelink('CloseFile');

        if abortFlag == 1; break; end

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
        results((ii-1)*size(randomizedStimulusSettings,1)+ss).direction = randomizedStimulusSettings(ss,1);
        
        % Coherence
        results((ii-1)*size(randomizedStimulusSettings,1)+ss).coherence = randomizedStimulusSettings(ss,2);
        
        % Response
        if response == 1
            results((ii-1)*size(randomizedStimulusSettings,1)+ss).response = 1;
        elseif response == -1
            results((ii-1)*size(randomizedStimulusSettings,1)+ss).response = -1;
        elseif response == 0
            results((ii-1)*size(randomizedStimulusSettings,1)+ss).response = NaN;
        end
        
        % Response Time
        if response == 0
            results((ii-1)*size(randomizedStimulusSettings,1)+ss).responseTime = NaN;
        else
            results((ii-1)*size(randomizedStimulusSettings,1)+ss).responseTime = responseTime;
        end

%         % Stimulus Start Time
%         results((ii-1)*size(randomizedStimulusSettings,1)+ss).stimulusStartTime = onsetTime(1);
%         % Stimulus End Time
%         results((ii-1)*size(randomizedStimulusSettings,1)+ss).stimulusEndTime = responseStart;

        % Stimulus Duration
        results((ii-1)*size(randomizedStimulusSettings,1)+ss).stimulusDuration = responseStart-onsetTime(1);

        % Individual Frame Information
        results((ii-1)*size(randomizedStimulusSettings,1)+ss).indivFrameInfo = table(frame,onsetTime,duration,timeElapsed);
        
    end
    
    if abortFlag == 1; break; end
    
end

if abortFlag == 1; disp('ABORTING EXPERIMENT...'); end

% SAVING RESULTS
msg = 'Saving results...';
drawText(w,msg,param.textSize,param.textLum);
Screen('Flip',w);
WaitSecs(1);

% Append 'stimuli' and 'results'
save(['./pairwisecoherenceresults/','Subject',num2str(subjectID),'_',startTime,'/','Subject',num2str(subjectID),'_',startTime,'.mat'],'stimuli','results','-append');

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
function mp = pairwise(direction, x, y, z, fracCoherence)

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
    if direction == -1
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