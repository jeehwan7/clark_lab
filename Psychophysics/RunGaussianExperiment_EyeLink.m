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
param.viewDist = 56; % viewing distance in cm
param.degPerSquare = 0.5; % degrees per square

% Temporal Parameters
param.stimDuration = 1; % duration of stimulus in seconds
param.framesPerSec = 60; % number of frames we want per second
                         % Set this to a factor of the frame rate.
                         % Otherwise glitching will occur.
param.preStimWait = 2; % duration of fixation point in seconds

% Shift Parameters
param.shiftX = 3;
param.shiftZ = 1;

% Number of Blocks
param.numBlocks = 10;

% Fixation Point Parameters
param.fpColor = [255,0,0,255]; % red
param.fpSize = 0.3; % in degrees

% Background and Text Luminance
param.bgLum = 255; % white
param.textLum = 0; % black

% Question Message
question = 'Left or Right?';

%% STIMULUS SETTINGS
% Column 1: Column 1: cor (between -0.5 and 0.5), Column 2: dir (1 or -1), Column 3: shiftX, Column 4: shiftZ
stimulusSettings = [0.5 1 param.shiftX param.shiftZ; 0.4 1 param.shiftX param.shiftZ; 0.3 1 param.shiftX param.shiftZ; 0.2 1 param.shiftX param.shiftZ; 0.1 1 param.shiftX param.shiftZ;
                    0.5 -1 param.shiftX param.shiftZ; 0.4 -1 param.shiftX param.shiftZ; 0.3 -1 param.shiftX param.shiftZ; 0.2 -1 param.shiftX param.shiftZ; 0.1 -1 param.shiftX param.shiftZ;
                    % -0.5 1 param.shiftX param.shiftZ; -0.4 1 param.shiftX param.shiftZ; -0.3 1 param.shiftX param.shiftZ; -0.2 1 param.shiftX param.shiftZ; -0.1 1 param.shiftX param.shiftZ;
                    % -0.5 -1 param.shiftX param.shiftZ; -0.4 -1 param.shiftX param.shiftZ; -0.3 -1 param.shiftX param.shiftZ; -0.2 1 param.shiftX param.shiftZ; -0.1 -1 param.shiftX param.shiftZ;
                    0 1 param.shiftX param.shiftZ
                    ];

%% RUN EXPERIMENT

% REGISTER SUBJECT
subjectID = input('SUBJECT ID: ');

% Save Results File
if ~isfolder('gaussianresults'); mkdir('gaussianresults'); end
startTime = datestr(now,'yyyy.mm.dd_HHMM');
mkdir(['./gaussianresults/','Subject',num2str(subjectID),'_',startTime]);
save(['./gaussianresults/','Subject',num2str(subjectID),'_',startTime,'/','Subject',num2str(subjectID),'_',startTime,'.mat'],'subjectID','startTime','param');

% Create EyeLink Data Folder
if ~isfolder(['./gaussianresults/','Subject',num2str(subjectID),'_',startTime,'/eyelink'])
    mkdir(['./gaussianresults/','Subject',num2str(subjectID),'_',startTime,'/eyelink']);
end

% Select Screen
screens = Screen('Screens');
screenNumber = 1;

% Screen Dimensions
[screenWidthpx,screenHeightpx] = Screen('WindowSize',screenNumber);
[screenWidthmm,screenHeightmm] = Screen('DisplaySize',screenNumber);

% Pixel / Visual Angel Correspondence
pxpercm  = screenWidthpx/screenWidthmm*10; % pixels per cm
pxperdeg = pxpercm*param.viewDist*tand(1); % pixels per degree
degperWidth = screenWidthpx/pxperdeg; % degrees per width of display
degperHeight = screenHeightpx/pxperdeg; % degrees per height of display

% OPEN WINDOW
[w, rect] = Screen('OpenWindow', screenNumber, param.bgLum, [0, 0, screenWidthpx, screenHeightpx]);

% Stimulus X Axis, Y Axis, and Z Axis
numSquaresX = ceil(degperWidth/param.degPerSquare); % round up to make sure we cover the whole screen
numSquaresY = ceil(degperHeight/param.degPerSquare); % round up to make sure we cover the whole screen
numFrames = param.stimDuration*param.framesPerSec;

% Center of Screen
[center(1), center(2)] = RectCenter(rect);

% Blending Mode
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Refresh Rate
ifi = Screen('GetFlipInterval', w);

% Wait Frames
waitFrames = round(1/ifi/param.framesPerSec);

ListenChar(2); % enable listening, suppress output to MATLAB command window

% Provide Eyelink with details about the graphics environment and perform some initializations.
% The information is returned in a structure that also contains useful defaults and control codes
% (e.g. tracker state bit and Eyelink key values).
el = EyelinkInitDefaults(w);

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
Screen('TextSize',w,30);
DrawFormattedText(w,msg,'center','center',param.textLum);
Screen('Flip',w);
WaitSecs(0.5);
KbWait;

% INSTRUCTIONS
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
% Screen('Textsize',w,30);
DrawFormattedText(w,msg,'center','center',param.textLum);
Screen('Flip',w);
WaitSecs(0.5);
KbWait;

abortFlag = 0;

stimuli = cell(param.numBlocks*size(stimulusSettings,1),numFrames); % to save all the frames for each trial (1 or -1 for each check)
results = struct;

for ii = 1:param.numBlocks
    
    % BLOCK NUMBER
    msg = ['Block ',num2str(ii),' of ',num2str(param.numBlocks)];
    % Screen('Textsize',w,30);
    DrawFormattedText(w,msg,'center','center',param.textLum);
    Screen('Flip',w);
    WaitSecs(1.5);
    
    % PREPARING TEXTURES
    msg = ['Preparing textures...\n\n',...
        'Please be patient'
        ];
    DrawFormattedText(w,msg,'center','center',param.textLum);
    Screen('Flip',w);
    
    % Create All Textures for This Block
    squares = cell(size(stimulusSettings,1),numFrames); % for storing matrices
    textures = cell(size(stimulusSettings,1),numFrames); % for storing texture indices

    for jj = 1:size(stimulusSettings,1)
        gaussianSquares = gaussian(stimulusSettings(jj,1), stimulusSettings(jj,2), stimulusSettings(jj,3), stimulusSettings(jj,4), numSquaresX, numSquaresY, numFrames);
        gaussianMatrix = 127+63*gaussianSquares; % scale for luminance
        gaussianMatrix = repelem(gaussianMatrix,ceil(screenHeightpx/numSquaresY),ceil(screenWidthpx/numSquaresX)); % "zoom in" according to degPerSquare
        
        for kk = 1:numFrames
            squares{jj,kk} = gaussianSquares(:,:,kk);
            textures{jj,kk} = Screen('MakeTexture', w, gaussianMatrix(:,:,kk));
        end
    end

    % PREPARATION COMPLETE
    msg = ['Preparation complete\n\n',...
        'Press any key to start'
        ];
    DrawFormattedText(w,msg,'center','center',param.textLum);
    Screen('Flip',w);
    WaitSecs(0.5);
    KbWait;

    % EYELINK DRIFT CORRECTION
    EyelinkDoDriftCorrection(el);
    
    % Randomize Order of Stimulus Settings
    randomizedIndex = randperm(size(stimulusSettings,1));
    randomizedStimulusSettings = stimulusSettings(randomizedIndex,:);
    
    for ss = 1:size(stimulusSettings,1)
        
        % columns for indivFrameDurations table
        frame = permute(1:numFrames,[2 1]);
        duration = NaN(numFrames,1);

        % Start recording eye position
        Eyelink('StartRecording');

        % PRESENT FIXATION POINT
        Screen('DrawDots',w,[0,0],round(param.fpSize*pxperdeg),param.fpColor,center,1);
        vbl = Screen('Flip', w);
        
        % PRESENT STIMULUS
        Screen('DrawTexture', w, textures{randomizedIndex(ss),1}); % frame 1
        Screen('Close', textures{randomizedIndex(ss),1});
        stimulusStartTime = Screen('Flip', w, vbl + param.preStimWait-0.5*ifi); % duration of dot presentation utilized here

        Eyelink('Message','STIMULUS_START'); % mark stimulus start
        
        Screen('DrawTexture', w, textures{randomizedIndex(ss),2}); % frame 2
        Screen('Close', textures{randomizedIndex(ss),2});
        vbl = Screen('Flip', w, stimulusStartTime + (waitFrames-0.5)*ifi);
        
        duration(1) = vbl-stimulusStartTime; % duration of 1st frame

        for qq = 3:numFrames % frames 3 to last
            vblPrevious = vbl;
            Screen('DrawTexture', w, textures{randomizedIndex(ss),qq});
            Screen('Close',textures{randomizedIndex(ss),qq});
            vbl = Screen('Flip', w, vbl + (waitFrames-0.5)*ifi);
            duration(qq-1) = vbl-vblPrevious; % duration of 2nd to penultimate frames
        end
        
        % RESPONSE
        % Screen('Textsize',w,30);
        DrawFormattedText(w,question,'center','center',param.textLum);
        responseStart = Screen('Flip', w, vbl + (waitFrames-0.5)*ifi);

        Eyelink('Message','STIMULUS_END'); % mark stimulus end

        while 1
            if GetSecs - responseStart >= 2
                response = 0;
                break  % must answer within 2 seconds
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
        
        duration(numFrames) = responseStart-vbl; % duration of last frame

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

        %% SAVE STIMULUS
        stimuli((ii-1)*size(randomizedStimulusSettings,1)+ss,:) = squares(randomizedIndex(ss),:);

        %% SAVE RESULTS
        
        % Trial Number
        results((ii-1)*size(randomizedStimulusSettings,1)+ss).trialNumber = (ii-1)*size(randomizedStimulusSettings,1)+ss;

        % Correlation
        results((ii-1)*size(randomizedStimulusSettings,1)+ss).correlation = randomizedStimulusSettings(ss,1);

        % Direction
        results((ii-1)*size(randomizedStimulusSettings,1)+ss).direction = randomizedStimulusSettings(ss,2);

        % Shift X
        results((ii-1)*size(randomizedStimulusSettings,1)+ss).shiftX = randomizedStimulusSettings(ss,3);

        % Shift Z
        results((ii-1)*size(randomizedStimulusSettings,1)+ss).shiftZ = randomizedStimulusSettings(ss,4);

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
%         results((ii-1)*size(randomizedStimulusSettings,1)+ss).stimulusStartTime = stimulusStartTime;
%         % Stimulus End Time
%         results((ii-1)*size(randomizedStimulusSettings,1)+ss).stimulusEndTime = responseStart;
        
        % Stimulus Duration
        results((ii-1)*size(randomizedStimulusSettings,1)+ss).stimulusDuration = responseStart-stimulusStartTime;

        % Individual Frame Durations
        results((ii-1)*size(randomizedStimulusSettings,1)+ss).indivFrameDurations = table(frame,duration);
        
        % Append Results
        save(['./gaussianresults/','Subject',num2str(subjectID),'_',startTime,'/','Subject',num2str(subjectID),'_',startTime,'.mat'],'stimuli','results','-append');
        
    end
    
    if abortFlag == 1; break; end
    
end

if abortFlag == 1; disp('ABORTING EXPERIMENT...'); end

% END
msg = [
    'Thank you for participating!\n\n',...
    'Press any key to close'];
% Screen('Textsize',w,30);
DrawFormattedText(w,msg,'center','center',param.textLum);
Screen('Flip',w);
WaitSecs(0.5);
KbWait;
cleanup;

function gaussian = gaussian(cor, dir, shiftX, shiftZ, x, y, z)
    
    theta = asin(2*cor)/2; % correlation must be [-0.5,0.5]

    initial = randn(y,x,z);
    gaussian = cos(theta)*initial + sin(theta)*circshift(initial,[0 dir*shiftX shiftZ]);

end

function cleanup

    % Shutdown Eyelink
    Eyelink('Shutdown');
    sca;
    ListenChar(0);

end