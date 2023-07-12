AssertOpenGL;

Screen('Preference', 'SkipSyncTests', 2);

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
param.framesPerSec = 30; % number of frames we want per second
                         % Set this to a factor of the frame rate.
                         % Otherwise glitching will occur.
param.preStimWait = 2; % duration of fixation point in seconds

% Number of Blocks
param.numBlocks = 10;

% Fixation Point Parameters
param.fpColor = [255,0,0,255]; % red
param.fpSize = 0.3; % in degrees

% Background and Text Luminance
param.bgLum = 255; % white
param.textLum = 0; % black

% Question Message
param.question = 'Left or Right?';

%% STIMULUS SETTINGS
% LINE 1 / Pairwise Correlation (varying coherence) / Column 1: left (0 means right, 1 means left)
%          Column 2: fracCoherence (between 0 and 1), Column 3 = 2
% LINE 2 / Triple Correlation / Column 1: par (1 or -1), Column 2: left (0 means right, 1 means left)
%          Column 3: div (0 means converging, 1 means diverging)
stimulusSettings = [0 1 2; 1 1 2; 0 0.2 2; 1 0.2 2; 0 0 2;
                    1 0 0; 1 0 1; 1 1 0; 1 1 1; -1 0 0; -1 0 1; -1 1 0; -1 1 1];
param.numPairwiseSettings = 5;

%% RUN EXPERIMENT

% REGISTER SUBJECT
subjectID = input('SUBJECT ID: ');

% Save Results File
if ~isfolder('tripleresults'); mkdir('tripleresults'); end
startTime = datestr(now,'yyyy.mm.dd_HHMM');
mkdir(['./tripleresults/','Subject',num2str(subjectID),'_',startTime]);
save(['./tripleresults/','Subject',num2str(subjectID),'_',startTime,'/','Subject',num2str(subjectID),'_',startTime,'.mat'],'subjectID','startTime');

% Select Screen
screens = Screen('Screens');
screenNumber = max(screens);

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
% waitFrames = round(1/ifi/param.framesPerSec);

ListenChar(2); % enable listening, suppress output to MATLAB command window

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
    'Press any key to begin the experiment'
    ];
% Screen('Textsize',w,30);
DrawFormattedText(w,msg,'center','center',param.textLum);
Screen('Flip',w);
WaitSecs(0.5);
KbWait;

abortFlag = 0;

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
        'Please be patient...'
        ];
    DrawFormattedText(w,msg,'center','center',param.textLum);
    Screen('Flip',w);
    
    % Create All Textures for This Block
    textures = cell(size(stimulusSettings,1));

    % Pairwise Correlation Textures
    for jj = 1:param.numPairwiseSettings
        mp = pairwise(stimulusSettings(jj,1), stimulusSettings(jj,2), numSquaresX, numSquaresY, numFrames);
        mp = 255*(mp+1)/2; % turn all negative ones into zeroes, multiply by 255 for luminance
        mp = repelem(mp,ceil(screenHeightpx/numSquaresY),ceil(screenWidthpx/numSquaresX)); % zoom in according to degPerSquare
        
        for kk = 1:numFrames
            textures{jj}{kk} = Screen('MakeTexture', w, mp(:,:,kk));
        end
    end

    % Triple Correlation Textures
    for jj = param.numPairwiseSettings+1:size(stimulusSettings,1)
        mt = triple(stimulusSettings(ss,1), stimulusSettings(ss,2), stimulusSettings(ss,3), numSquaresX, numSquaresY, numFrames);
        mt = 255*(mt+1)/2; % turn all negative ones into zeroes, multiply by 255 for luminance
        mt = repelem(mt,ceil(screenHeightpx/numSquaresY),ceil(screenWidthpx/numSquaresX)); % zoom in according to degPerSquare

        for kk = 1:numFrames
                textures{jj}{kk} = Screen('MakeTexture', w, mt(:,:,kk));
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

    % ----------------------------------------
    % Start working here:
    % Need to: figure out how I'm going to randomize the
    % order of settings and draw textures
    % also need to fix the timing of displaying textures







    
    % Randomize Order of Stimulus Settings
    stimulusSettings = stimulusSettings(randperm(size(stimulusSettings,1)),:);
    
    for ss = 1:size(stimulusSettings,1)
        
        % PRESENT FIXATION POINT
        Screen('DrawDots',w,[0,0],round(param.fpSize*pxperdeg),param.fpColor,center,1);
        dotStartTime = Screen('Flip',w);
        while GetSecs < dotStartTime + param.preStimWait; end
        
        if stimulusSettings(ss,3) == 2
            % Create Pairwise Pattern
            mp = pairwise(stimulusSettings(ss,1), stimulusSettings(ss,2), numSquaresX, numSquaresY, numFrames);
            mp = 255*(mp+1)/2; % turn all negative ones into zeroes, multiply by 255 for luminance
            mp = repelem(mp,ceil(screenHeightpx/numSquaresY),ceil(screenWidthpx/numSquaresX)); % zoom in according to degPerSquare

            % PRESENT PAIRWISE PATTERN
            pattern = Screen('MakeTexture', w, mp(:,:,1));
            Screen('DrawTexture', w, pattern);
            stimulusStartTime = Screen('Flip', w);
            frame = 1;
            while frame < param.framesPerSec
                pattern = Screen('MakeTexture', w, mp(:,:,frame+1));
                Screen('DrawTexture', w, pattern);
                vbl = Screen('Flip', w, stimulusStartTime + frame/param.framesPerSec - 0.5*ifi);
                frame = frame+1;
            end
        else
            % Create Triple Pattern
            mt = triple(stimulusSettings(ss,1), stimulusSettings(ss,2), stimulusSettings(ss,3), numSquaresX, numSquaresY, numFrames);
            mt = 255*(mt+1)/2; % turn all negative ones into zeroes, multiply by 255 for luminance
            mt = repelem(mt,ceil(screenHeightpx/numSquaresY),ceil(screenWidthpx/numSquaresX)); % zoom in according to degPerSquare

            % PRESENT TRIPLE PATTERN
            pattern = Screen('MakeTexture', w, mt(:,:,1));
            Screen('DrawTexture', w, pattern);
            stimulusStartTime = Screen('Flip', w);
            frame = 1;
            while frame < param.framesPerSec
                pattern = Screen('MakeTexture', w, mt(:,:,frame+1));
                Screen('DrawTexture', w, pattern);
                vbl = Screen('Flip', w, stimulusStartTime + frame/param.framesPerSec - 0.5*ifi);
                frame = frame+1;
            end
        end
        
        % RESPONSE
        % Screen('Textsize',w,30);
        DrawFormattedText(w,param.question,'center','center',param.textLum);
        responseStart = Screen('Flip',w, vbl + 1/param.framesPerSec - 0.5*ifi);
        while 1
            if GetSecs - responseStart >= 2
                response = 0;
                break  % answer within 2 seconds
            end
            [~,~,keyCode] = KbCheck;
            if keyCode(lresc(1)) == 1 && keyCode(lresc(2)) ~= 1
                response = -1; % left
                Screen('Flip',w);
                break
            elseif keyCode(lresc(1)) ~= 1 && keyCode(lresc(2)) == 1
                response = 1; % right
                Screen('Flip',w);
                break
            elseif keyCode(lresc(3)) == 1
                abortFlag = 1;
                break
            end
        end
        
        if abortFlag == 1; break; end
        
        responseTime = GetSecs - responseStart;
        
        %% RESULTS
        
        % Trial Number
        results((ii-1)*size(stimulusSettings,1)+ss).trialNumber = (ii-1)*size(stimulusSettings,1)+ss;
        % Type (Pairwise, Converging, Diverging)
        if stimulusSettings(ss,3) == 2
            results((ii-1)*size(stimulusSettings,1)+ss).type = 'pairwise';
            results((ii-1)*size(stimulusSettings,1)+ss).coherence = stimulusSettings(ss,2);
        elseif stimulusSettings(ss,3) == 0
            results((ii-1)*size(stimulusSettings,1)+ss).type = 'converging';
            results((ii-1)*size(stimulusSettings,1)+ss).coherence = NaN;
        elseif stimulusSettings(ss,3) == 1
            results((ii-1)*size(stimulusSettings,1)+ss).type = 'diverging';
            results((ii-1)*size(stimulusSettings,1)+ss).coherence = NaN;
        end
        % Parity
        if stimulusSettings(ss,3) == 2
            results((ii-1)*size(stimulusSettings,1)+ss).parity = NaN;
        elseif stimulusSettings(ss,3) == 0 || stimulusSettings(ss,3) == 1
            results((ii-1)*size(stimulusSettings,1)+ss).parity = stimulusSettings(ss,1);
        end
        % Direction
        if stimulusSettings(ss,3) == 2
            if stimulusSettings(ss,1) == 0
                results((ii-1)*size(stimulusSettings,1)+ss).direction = 1;
            elseif stimulusSettings(ss,1) == 1
                results((ii-1)*size(stimulusSettings,1)+ss).direction = -1;
            end
        elseif stimulusSettings(ss,3) == 0 || stimulusSettings(ss,3) == 1
            if stimulusSettings(ss,2) == 0
                results((ii-1)*size(stimulusSettings,1)+ss).direction = 1;
            elseif stimulusSettings(ss,2) == 1
                results((ii-1)*size(stimulusSettings,1)+ss).direction = -1;
            end
        end
        % Response
        if response == 1
            results((ii-1)*size(stimulusSettings,1)+ss).response = 1;
        elseif response == -1
            results((ii-1)*size(stimulusSettings,1)+ss).response = -1;
        elseif response == 0
            results((ii-1)*size(stimulusSettings,1)+ss).response = NaN;
        end
        % Response Time
        if response == 0
            results((ii-1)*size(stimulusSettings,1)+ss).responseTime = NaN;
        else
            results((ii-1)*size(stimulusSettings,1)+ss).responseTime = responseTime;
        end
        % Stimulus Start Time
        results((ii-1)*size(stimulusSettings,1)+ss).stimulusStartTime = stimulusStartTime;
        % Stimulus End Time
        results((ii-1)*size(stimulusSettings,1)+ss).stimulusEndTime = responseStart;
        
        % Append Results
        save(['./tripleresults/','Subject',num2str(subjectID),'_',startTime,'/','Subject',num2str(subjectID),'_',startTime,'.mat'],'results','abortFlag','-append');
        
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
ListenChar(0);
sca;

% 3D Matrix for Triple Patterns
function mt = triple(par, left, div, x, y, z)

    % first frame
    mt(:,:,1) = (zeros(y,x)-1).^(randi([0 1],[y,x]));
    
    % right, converging
    for t = 2:z
        mt(:,1,t) = (zeros(y,1)-1).^(randi([0 1],[y,1]));
        mt(:,2:x,t) = par*mt(:,1:x-1,t-1).*mt(:,2:x,t-1);
    end
    % right, diverging
    if (left == 0) && (div == 1)
        mt = flip(flip(mt, 2), 3);
    % left, converging
    elseif (left == 1) && (div == 0)
        mt = flip(mt, 2);
    % left, diverging
    elseif (left == 1) && (div == 1)
        mt = flip(mt, 3);
    end

end

% 3D Matrix for Pairwise Patterns
function mp = pairwise(par, left, x, y, z)

    % first frame
    mp(:,:,1) = (zeros(y,x)-1).^(randi([0 1],[y,x]));

    % right
    for t = 2:z
        mp(:,1,t) = (zeros(y,1)-1).^(randi([0 1],[y,1]));
        mp(:,2:x,t) = par*mp(:,1:x-1,t-1);
    end
    % left
    if left == 1
        mp = flip(mp, 2);
    end

end