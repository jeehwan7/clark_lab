Screen('Preference', 'SkipSyncTests', 2);

% Select Screen
screens = Screen('Screens');
screenNumber = max(screens);

% Screen Dimensions
[screenWidthpx,screenHeightpx] = Screen('WindowSize',screenNumber); % in pixels
[screenWidthmm,screenHeightmm] = Screen('DisplaySize',screenNumber); % in millimeters

%{
% Pixel / Visual Angle Correspondence
viewDist = 50; % in cm
pxpercm  = screenWidthpx/screenWidthmm*10;
pxperdeg = pxpercm*viewDist*tand(1);
%}

% ------------------------------

% Stimulus Parameters
left = 0; % 0: right, 1: left
div = 0; % 0: converging, 1: diverging
par = 1; % parity
x = screenWidthpx; % width / set to the width of the screen
y = screenHeightpx; % height / set to the height of the screen
z = 120; % number of frames

% Create Stimulus
mt = triple(left, div, par, x, y, z);
mt = 255*(mt+1)/2; % turn all negative ones into zeroes, multiply by 255 for luminance
mp = pairwise(left, par, x, y, z);
mp = 255*(mp+1)/2; % turn all negative ones into zeroes, multiply by 255 for luminance

%{
% ONLY TO SEE IF THE DISPLAY IS CORRECT; NOT FOR ACTUAL EXPERIMENT
mt = permute(mt, [3 2 1]);
mp = permute(mp, [3 2 1]);
%}

% ------------------------------

% Open Window
[w, rect] = Screen('OpenWindow', screenNumber, 0, [0, 0, screenWidthpx/2, screenHeightpx/2]); % quadrant of screen only

%{
% Center of Screen
[center(1), center(2)] = RectCenter(rect);
%}

%{
% Blending Mode
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
%}

% Refresh Rate
ifi = Screen('GetFlipInterval', w); % inter frame interval

% Calculate Wait Frames
numSecs = 2; % duration of presentation in seconds
numFramesTotal = round(numSecs/ifi);
numFramesPerSec = 60; % frames per second
waitFrames = round(1/ifi/numFramesPerSec);

%{
% Create Textures
triplePattern = Screen('MakeTexture', w, mt(:,:,1));
% pairwisePattern = Screen('MakeTexture', w, mp(:,:,1));

% Draw Textures
Screen('DrawTexture', w, triplePattern);
%}

vbl = Screen('Flip', w);
for frame = 1:numFramesTotal
    pattern = Screen('MakeTexture', w, mp(:,:,frame));
    Screen('DrawTexture', w, pattern);
    vbl = Screen('Flip', w, vbl + (waitFrames - 0.5) * ifi);
    Screen('Close', pattern);
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