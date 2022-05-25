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

% subjectID = input('Subject ID (0 for debug): ');

%% PARAMETERS

% Resolution Parameters
param.viewDist = 50; % viewing distance in cm
param.degperSquare = 0.5; % degrees per square

% Stimulus Parameters
param.left = 0; % 0 = right, 1 = left
param.div = 0; % 0 = converging, 1 = diverging
param.par = 1; % parity

% Temporal Parameters
param.stimDuration = 1; % duration of stimulus in seconds
param.framesPerSec = 20; % number of frames per second
param.preStimWait = 2; % waiting time before stimulus in seconds % !!!NOT YET USED!!!

% Fixation Point Parameters
param.fpColor = [255,0,0,255]; % !!!NOT YET USED!!!
param.fpSize = 0.3; % in degrees % !!!NOT YET USED!!!

% Background and Text Luminance
param.bgLum = 127; % grey % !!!NOT YET USED!!!
param.textLum = 0; % black % !!!NOT YET USED!!!

% Question Message
param.question = 'Left(<-) or Right(->)?'; % !!!NOT YET USED!!!

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
[w, rect] = Screen('OpenWindow', screenNumber, 0, [0, 0, screenWidthpx/2, screenHeightpx/2]); % quadrant of screen only

% ListenChar(2); % enable listening, suppress output keypresses to command window

% Stimulus X Axis, Y Axis, and Z Axis
numSquaresX = ceil(degperWidth/param.degperSquare); % round up to make sure we cover the whole screen
numSquaresY = ceil(degperHeight/param.degperSquare); % round up to make sure we cover the whole screen
numFrames = param.stimDuration*param.framesPerSec*2;
% frame > param.stimDuration*param.framesPerSec (something weird is happening... multiplying by 2 for now... need to fix timing issues)

% For Simplicity
x = numSquaresX;
y = numSquaresY;
z = numFrames;

% Create Stimulus
mt = triple(param, x, y, z);
mt = 255*(mt+1)/2; % turn all negative ones into zeroes, multiply by 255 for luminance
mt = repelem(mt,ceil(screenHeightpx/numSquaresY),ceil(screenWidthpx/numSquaresX)); % repeat elements according to degPerSquare

mp = pairwise(param, x, y, z);
mp = 255*(mp+1)/2; % turn all negative ones into zeroes, multiply by 255 for luminance
mp = repelem(mp,ceil(screenHeightpx/numSquaresY),ceil(screenWidthpx/numSquaresX)); % repeat elements according to degPerSqaure

% Center of Screen
[center(1), center(2)] = RectCenter(rect);

% Refresh Rate
ifi = Screen('GetFlipInterval', w);

% Wait Frames
waitFrames = round(1/ifi/param.framesPerSec);

% Present Stimulus
frame = 1;
newvbl = GetSecs;
start = GetSecs;

while GetSecs < start+param.stimDuration
    oldvbl = newvbl;
    pattern = Screen('MakeTexture', w, mt(:,:,frame));
    Screen('DrawTexture', w, pattern);
    newvbl = Screen('Flip', w, oldvbl + (waitFrames-0.5)*ifi);
    if newvbl ~= oldvbl
        frame = frame+1;
    end
end

Screen('Closeall');

% 3D Matrix for Triple Patterns
% z axis = time
function mt = triple(param, x, y, z)

    % first frame
    mt(:,:,1) = (zeros(y,x)-1).^(randi([0 1],[y,x]));
    
    % right, converging
    for t = 2:z
        mt(:,1,t) = (-1)^(randi(2)-1);
        mt(:,2:x,t) = param.par*mt(:,1:x-1,t-1).*mt(:,2:x,t-1);
    end
    % right, diverging
    if (param.left == 0) && (param.div == 1)
        mt = flip(flip(mt, 2), 3);
    % left, converging
    elseif (param.left == 1) && (param.div == 0)
        mt = flip(mt, 2);
    % left, diverging
    elseif (param.left == 1) && (param.div == 1)
        mt = flip(mt, 3);
    end

end

% 3D Matrix for Pairwise Patterns
% z axis = time
function mp = pairwise(param, x, y, z)

    % first frame
    mp(:,:,1) = (zeros(y,x)-1).^(randi([0 1],[y,x]));

    % right
    for t = 2:z
        mp(:,1,t) = (-1)^(randi(2)-1);
        mp(:,2:x, t) = param.par*mp(:,1:x-1,t-1);
    end
    %left
    if param.left == 1
        mp = flip(mp, 2);
    end

end