Screen('Preference', 'SkipSyncTests', 2);

% Select Screen
screens = Screen('Screens');
screenNumber = max(screens);

% Screen Dimensions
[screenWidthpx,screenHeightpx] = Screen('WindowSize',screenNumber); % in pixels
[screenWidthmm,screenHeightmm] = Screen('DisplaySize',screenNumber); % in millimeters

% Pixels, Degrees
viewDist = 50; % in cm % !!!!!PARAMETER!!!!!
pxpercm  = screenWidthpx/screenWidthmm*10; % pixels per cm
pxperdeg = pxpercm*viewDist*tand(1); % pixels per degree (from the focus, so increasingly inaccurate as we move peripherally)
degperWidth = screenWidthpx/pxperdeg; % degrees per width
degperHeight = screenHeightpx/pxperdeg; % degrees per height
degperSquare = 0.5; % degrees per square % !!!!!PARAMETER!!!!!
numSquaresX = ceil(degperWidth/degperSquare); % number of squares on X axis, round up to make sure we cover the whole screen
numSquaresY = ceil(degperHeight/degperSquare); % number of squares on Y axis, round up to make sure we cover the whole screen

%{
% ONLY TO SEE IF THE DISPLAY WORKS; NOT FOR ACTUAL EXPERIMENT
mt = permute(mt, [3 2 1]);
mp = permute(mp, [3 2 1]);
%}

% Open Window
[w, rect] = Screen('OpenWindow', screenNumber, 0, [0, 0, screenWidthpx/2, screenHeightpx/2]); % quadrant of screen only

% Refresh Rate
ifi = Screen('GetFlipInterval', w); % inter frame interval

% Calculate Wait Frames
duration = 2; % duration of presentation in seconds % !!!!!PARAMETER!!!!!
framesPerSec = 15; % frames per second % !!!!!PARAMETER!!!!!
waitFrames = round(1/ifi/framesPerSec);

% Stimulus Settings
left = 0; % 0: right, 1: left % !!!!!PARAMETER!!!!!
div = 0; % 0: converging, 1: diverging % !!!!!PARAMETER!!!!!
par = 1; % parity % !!!!!PARAMETER!!!!!
x = numSquaresX; % width
y = numSquaresY; % height
z = duration*framesPerSec*1.5; % number of frames % frame > duration*framesPerSec WHY? (multiply by 1.5 at the end)

% Create Stimulus
mt = triple(left, div, par, x, y, z);
mt = 255*(mt+1)/2; % turn all negative ones into zeroes, multiply by 255 for luminance
mt = repelem(mt,ceil(screenHeightpx/numSquaresY),ceil(screenWidthpx/numSquaresX));
mp = pairwise(left, par, x, y, z);
mp = 255*(mp+1)/2; % turn all negative ones into zeroes, multiply by 255 for luminance
mp = repelem(mp,ceil(screenHeightpx/numSquaresY),ceil(screenWidthpx/numSquaresX));

% Present Stimulus
start = GetSecs;
newvbl = start;
frame = 1;

while GetSecs<start+duration
    oldvbl = newvbl;
    pattern = Screen('MakeTexture', w, mt(:,:,frame));
    Screen('DrawTexture', w, pattern);
    newvbl = Screen('Flip', w, oldvbl + (waitFrames - 0.5) * ifi);
    if newvbl ~= oldvbl
        frame = frame+1;
    end
end

Screen('Closeall');

% 3D Matrix for Triple Patterns
% z axis = time
function mt = triple(left, div, par, x, y, z)

    % first frame
    mt(:,:,1) = (zeros(y,x)-1).^(randi([0 1],[y,x]));
    
    % right, converging
    for t = 2:z
        mt(:,1,t) = (-1)^(randi(2)-1);
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
% z axis = time
function mp = pairwise(left, par, x, y, z)

    % first frame
    mp(:,:,1) = (zeros(y,x)-1).^(randi([0 1],[y,x]));

    % right
    for t = 2:z
        mp(:,1,t) = (-1)^(randi(2)-1);
        mp(:,2:x, t) = par*mp(:,1:x-1,t-1);
    end
    %left
    if left == 1
        mp = flip(mp, 2);
    end

end