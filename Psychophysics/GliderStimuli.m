AssertOpenGL;

Screen('Preference', 'SkipSyncTests', 2);

% Key Configuration
KbName('UnifyKeyNames');
if ismac % Mac
    lresc = [80,82,41];
elseif ispc % Windows
    lresc = [37,39,27];
else
    error('PLATFORM NOT SUPPORTED, MAC OR WINDOWS ONLY');
end

%% PARAMETERS

% Resolution Parameters
param.viewDist = 50; % viewing distance in cm
param.degPerSquare = 0.5; %  degrees per square

%{
% Stimulus Parameters
param.left = 0; % 0 = right, 1 = left
param.div = 0; % 0 = converging, 1 = diverging
param.par = 1; % parity
%}

% Temporal Parameters
param.stimDuration = 2; % duration of stimulus in seconds
param.framesPerSec = 30; % number of frames per second
param.preStimWait = 2; % waiting time before stimulus in seconds

% Fixation Point Parameters
param.fpColor = [255,0,0,255];
param.fpSize = 0.3; % in degrees

% Background and Text Luminance
param.bgLum = 255; % white
param.textLum = 0; % black

% Blocks
param.numBlocks = 2;

% Question Message
param.question = 'Left or Right?';

%%  PAIRWISE AND TRIPLE SETTINGS

% Column 1: par, Column 2: left, Column 3: div
pairwiseSettings = [1 0; 1 1; -1 0; -1 1];
tripleSettings = [1 0 0; 1 0 1; 1 1 0; 1 1 1; -1 0 0; -1 0 1; -1 1 0; -1 1 1];

%% RESULTS

%% RUN EXPERIMENT

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

% Open Window
[w, rect] = Screen('OpenWindow', screenNumber, param.bgLum, [0, 0, screenWidthpx, screenHeightpx]);

ListenChar(2); % enable listening, suppress output to MATLAB command window

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

%% WELCOME SCREEN
msg = [
    'Welcome!\n\n',...
    'Press any key to continue...'
    ];
Screen('TextSize',w,30);
DrawFormattedText(w,msg,'center','center',param.textLum);
Screen('Flip',w);
WaitSecs(0.5);
KbWait;

%% INSRUCTIONS SCREEN
msg = [
    'INSTRUCTIONS:\n\n',...
    'A red dot will appear in the center of the screen.\n',...
    'Fixate on that dot until the stimulus appears.\n',...
    'When the stimulus disappears, indicate your\n',...
    'perceived direction of motion by pressing on the\n',...
    'left arrow key or right arrow key.\n\n',...
    'Press any key to begin the experiment...'
    ];
% Screen('Textsize',w,30);
DrawFormattedText(w,msg,'center','center',param.textLum);
Screen('Flip',w);
WaitSecs(0.5);
KbWait;

abortFlag = 0;
for ii = 1:param.numBlocks
    %% BLOCK NUMBER SCREEN
    msg = ['Block ',num2str(ii),'/',num2str(param.numBlocks)];
    % Screen('Textsize',w,30);
    DrawFormattedText(w,msg,'center','center',param.textLum);
    Screen('Flip',w);
    start = GetSecs;
    while GetSecs < start + 1.5; end
    
    %% PAIRWISE STIMULI
    for pp = 1:4
        % Create Stimulus
        mp = pairwise(pairwiseSettings(pp,1), pairwiseSettings(pp,2), numSquaresX, numSquaresY, numFrames);
        mp = 255*(mp+1)/2; % turn all negative ones into zeroes, multiply by 255 for luminance
        mp = repelem(mp,ceil(screenHeightpx/numSquaresY),ceil(screenWidthpx/numSquaresX)); % zoom in according to degPerSquare
        
        % Present Fixation Point
        Screen('DrawDots',w,[0,0],round(param.fpSize*pxperdeg),param.fpColor,center,1);
        Screen('Flip',w);
        start = GetSecs;
        while GetSecs < start + param.preStimWait; end
        
        % Present Stimulus
        frame = 1;
        newvbl = GetSecs;
        start = GetSecs;
        
        while GetSecs < start+param.stimDuration
            oldvbl = newvbl;
            pattern = Screen('MakeTexture', w, mp(:,:,frame));
            Screen('DrawTexture', w, pattern);
            newvbl = Screen('Flip', w, oldvbl + 1/param.framesPerSec);
            if newvbl ~= oldvbl
                frame = frame+1;
            end
        end
        
        % Response
        % Screen('Textsize',w,30);
        DrawFormattedText(w,param.question,'center','center',param.textLum);
        responseStart = Screen('Flip',w);
        while 1
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
        
        %% RECORD RESOPNSE
        
    end
    
    if abortFlag == 1; break; end
    
    %% TRIPLE STIMULI
    
    % Randomize Row Order of "tripleSettings"
    tripleSettings = tripleSettings(randperm(size(tripleSettings,1)),:);
    
    for tt = 1:8
        % Create Stimulus
        mt = triple(tripleSettings(tt,1), tripleSettings(tt,2), tripleSettings(tt,3), numSquaresX, numSquaresY, numFrames);
        mt = 255*(mt+1)/2; % turn all negative ones into zeroes, multiply by 255 for luminance
        mt = repelem(mt,ceil(screenHeightpx/numSquaresY),ceil(screenWidthpx/numSquaresX)); % zoom in according to degPerSquare
        
        % Present Fixation Point
        Screen('DrawDots',w,[0,0],round(param.fpSize*pxperdeg),param.fpColor,center,1);
        Screen('Flip',w);
        start = GetSecs;
        while GetSecs < start + param.preStimWait; end
        
        % Present Stimulus
        frame = 1;
        newvbl = GetSecs;
        start = GetSecs;
        
        while GetSecs < start+param.stimDuration
            oldvbl = newvbl;
            pattern = Screen('MakeTexture', w, mt(:,:,frame));
            Screen('DrawTexture', w, pattern);
            newvbl = Screen('Flip', w, oldvbl + 1/param.framesPerSec);
            if newvbl ~= oldvbl
                frame = frame+1;
            end
        end
        
        % Response
        % Screen('Textsize',w,30);
        DrawFormattedText(w,param.question,'center','center',param.textLum);
        responseStart = Screen('Flip',w);
        while 1
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
        
        %% RECORD RESOPNSE
        
    end
    
    if abortFlag == 1; break; end
    
end

if abortFlag == 1; disp('ABORTING EXPERIMENT...'); end

%% SAVE RESULT

%% END SCREEN
msg = [
    'Thank you for participating!\n\n',...
    'Press any key to close...'];
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