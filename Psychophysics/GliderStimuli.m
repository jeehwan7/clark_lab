Screen('Preference', 'SkipSyncTests', 2);

% Select Screen
screens = Screen('Screens');
screenNumber = max(screens);

% Screen Dimensions
[screenWidthpx,screenHeightpx] = Screen('WindowSize',screenNumber); % in pixels
[screenWidthmm,screenHeightmm] = Screen('DisplaySize',screenNumber); % in millimeters

%{
% Pixel / Visual Angle Correspondence
viewDist = 50;
pxpercm  = screenWidthpx/screenWidthmm*10;
pxperdeg = pxpercm*viewDist*tand(1);
%}

% ------------------------------

% Variables for Creating Stimuli
left = 0; % 0: right, 1: left
div = 0; % 0: converging, 1: diverging
par = 1; % parity
x = screenWidthpx; % width / set to the width of the screen
y = screenHeightpx; % height / set to the height of the screen
z = 120; % number of frames

% Create Frames for Triple and Pairwise Patterns
mt = triple(left, div, par, x, y, z);
mt = 100*(mt+1)/2; % turn all negative ones into zeroes and multiply by 255 for luminance
mp = pairwise(left, par, x, y, z);
mp = 100*(mp+1)/2; % turn all negative ones into zeroes and multiply by 255 for luminance

%{
% ONLY TO SEE IF THE DISPLAY IS CORRECT; NOT FOR THE ACTUAL EXPERIMENT
mt = permute(mt, [3 2 1]);
mp = permute(mp, [3 2 1]);
%}

mt1 = mt(:,:,1);
mp1 = mp(:,:,1);

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

%{
% Refresh Rate
ifi = Screen('GetFlipInterval', w); % inter frame interval
fps = round(1/ifi); % frames per second
%}

% Create Textures
triplePattern = Screen('MakeTexture', w, mt1);
pairwisePattern = Screen('MakeTexture', w, mp1);

% Draw Textures
Screen('DrawTexture', w, triplePattern);

Screen('Flip', w);

% 3D Matrix for Triple Patterns
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