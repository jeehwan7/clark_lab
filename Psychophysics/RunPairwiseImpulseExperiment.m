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
param.stimDuration = 3; % duration of stimulus in seconds
param.framesPerSec = 30; % number of frames we want per second
                         % Set this to a factor of the frame rate.
                         % Otherwise glitching will occur
param.preStimWait = 2; % duration of fixation point in seconds

% Number of Blocks
param.numBlocks = 10;
param.numTrialsPerBlock = 5;

% Fixation Point Parameters
param.fpColor = [255,0,0,255]; % red
param.fpSize = 0.3; % in degrees

% Background and Text Luminance
param.bgLum = 255; % white
param.textLum = 0; % black

%% RUN EXPERIMENT

% REGISTER SUBJECT
subjectID = input('SUBJECT ID: ');

% Save Results File
if ~isfolder('./pairwiseimpulseresults'); mkdir('./pairwiseimpulseresults'); end
startTime = datestr(now,'yyyy.mm.dd_HHMM');
mkdir(['./pairwiseimpulseresults/','Subject',num2str(subjectID),'_',startTime]);
save(['./pairwiseimpulseresults/','Subject',num2str(subjectID),'_',startTime,'/','Subject',num2str(subjectID),'_',startTime,'.mat'],'subjectID','startTime','param');

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
waitFrames = round(1/ifi/param.framesPerSec);

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

% INSRUCTIONS
msg = [
    'INSTRUCTIONS:\n\n',...
    'A red dot will appear in the center of the screen.\n',...
    'Fixate on that dot until the stimulus appears.\n\n',...
    'Press any key to begin'
    ];
% Screen('Textsize',w,30);
DrawFormattedText(w,msg,'center','center',param.textLum);
Screen('Flip',w);
WaitSecs(0.5);
KbWait;

abortFlag = 0;

stimuli = cell(param.numBlocks*param.numTrialsPerBlock,numFrames); % to save all the frames for each trial (1 or -1 for each check)
directions = NaN(param.numBlocks*param.numTrialsPerBlock,numFrames); % column: trial number, row: frame number
results = struct;

for ii = 1:param.numBlocks
    
    if ii ~= 1
        % DO YOU WISH TO CONTINUE
        msg = ['Do you wish to continue?\n\n',...
            'YES: right arrow key\n\n' ...
            'NO: escape key'];
        DrawFormattedText(w,msg,'center','center',param.textLum);
        Screen('Flip',w);
        WaitSecs(0.5);
        while 1
            [~,keyCode] = KbWait;
            if keyCode(lresc(2)) == 1
                Screen('Flip',w);
                break
            elseif keyCode(lresc(3)) == 1
                abortFlag = 1;
                break
            end
        end
    end

    if abortFlag == 1; break; end

    % PREPARING TEXTURES
    msg = ['Preparing textures...\n\n',...
        'Please be patient'
        ];
    DrawFormattedText(w,msg,'center','center',param.textLum);
    Screen('Flip',w);

    % Create All Textures for This Block
    squares = cell(param.numTrialsPerBlock,numFrames); % for storing matrices
    textures = cell(param.numTrialsPerBlock,numFrames); % for storing texture indices

    for jj = 1:param.numTrialsPerBlock
        [pairwiseSquares, dir] = pairwise(numSquaresX, numSquaresY, numFrames);
        pairwiseMatrix = 255*(pairwiseSquares+1)/2; % turn all negative ones into zeroes, multiply by 255 for luminance (black or white)
        pairwiseMatrix = repelem(pairwiseMatrix,ceil(screenHeightpx/numSquaresY),ceil(screenWidthpx/numSquaresX)); % "zoom in" according to degPerSquare

        directions((ii-1)*param.numTrialsPerBlock+jj,:) = dir;

        for kk = 1:numFrames
            squares{jj,kk} = pairwiseSquares(:,:,kk);
            textures{jj,kk} = Screen('MakeTexture',w,pairwiseMatrix(:,:,kk));
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

    for ss = 1:param.numTrialsPerBlock

        % columns for indivFrameDurations table
        frame = permute(1:numFrames,[2 1]);
        duration = NaN(numFrames,1);

        % PRESENT FIXATION POINT
        Screen('DrawDots', w, [0,0], round(param.fpSize*pxperdeg), param.fpColor, center, 1);
        vbl = Screen('Flip', w);

        % PRESENT STIMULUS
        Screen('DrawTexture', w, textures{ss,1});
        stimulusStartTime = Screen('Flip', w, vbl + param.preStimWait); % duration of dot presentation utilized here
        Screen('DrawTexture', w, textures{ss,2});
        vbl = Screen('Flip', w, stimulusStartTime + (waitFrames-0.5)*ifi);

        duration(1) = vbl - stimulusStartTime;

        for qq = 3:numFrames
            vblPrevious = vbl;
            Screen('DrawTexture', w, textures{ss,qq});
            vbl = Screen('Flip', w, vbl + (waitFrames-0.5)*ifi);
            duration(qq-1) = vbl-vblPrevious; % duration of 2nd to penultimate frames
        end

        stimulusEndTime = Screen('Flip',w, vbl + 1/param.framesPerSec - 0.5*ifi);

        duration(numFrames) = stimulusEndTime-vbl; % duration of last frame

        %% SAVE STIMULUS
        stimuli((ii-1)*param.numTrialsPerBlock+ss,:) = squares(ss,:);
        
        %% RESULTS

        % Trial Number
        results((ii-1)*param.numTrialsPerBlock+ss).trialNumber = (ii-1)*param.numTrialsPerBlock+ss;

%         % Stimulus Start Time
%         results((ii-1)*param.numTrialsPerBlock+ss).stimulusStartTime = stimulusStartTime;
%         % Stimulus End Time
%         results((ii-1)*param.numTrialsPerBlock+ss).stimulusEndTime = stimulusEndTime;

        % Stimulus Duration
        results((ii-1)*param.numTrialsPerBlock+ss).stimulusDuration = stimulusEndTime-stimulusStartTime;

        % Individual Frame Durations
        results((ii-1)*param.numTrialsPerBlock+ss).indivFrameDurations = table(frame,duration);
        
        % Append Results
        save(['./pairwiseimpulseresults/','Subject',num2str(subjectID),'_',startTime,'/','Subject',num2str(subjectID),'_',startTime,'.mat'],'stimuli','directions','results','-append');

    end
    
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

% 3D Matrix for Pairwise Pattern with Randomly Switching Directions
function [mp, dir] = pairwise(x, y, z)
    
    dir = 2*randi([0 1],[1 z-1])-1;
    dir = [NaN, dir];
    
    % first frame
    mp(:,:,1) = (zeros(y,x)-1).^(randi([0 1],[y x]));
    
    % rest of the frames
    for t = 2:z
        if dir(1,t) == 1 % right
            mp(:,1,t) = (zeros(y,1)-1).^(randi([0 1],[y 1])); % leftmost column is random
            mp(:,2:x,t) = mp(:,1:x-1,t-1); % rightward translation
        elseif dir(1,t) == -1 % left
            mp(:,end,t) = (zeros(y,1)-1).^(randi([0 1],[y 1])); % rightmost column is random
            mp(:,1:x-1,t) = mp(:,2:x,t-1); % leftward translation
        end
    end

end