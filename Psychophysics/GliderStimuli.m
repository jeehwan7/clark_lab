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
param.degPerSquare = 0.7; %  degrees per square

%{
% Stimulus Parameters
param.left = 0; % 0 = right, 1 = left
param.div = 0; % 0 = converging, 1 = diverging
param.par = 1; % parity
%}

% Temporal Parameters
param.stimDuration = 1; % duration of stimulus in seconds
param.framesPerSec = 30; % number of frames we want per second
                         % IMPORTANT! We want to set this to a factor of the frame rate
                         %            Otherwise glitching will occur
param.preStimWait = 2; % duration of fixation point in seconds

% Fixation Point Parameters
param.fpColor = [255,0,0,255];
param.fpSize = 0.3; % in degrees

% Background and Text Luminance
param.bgLum = 255; % white
param.textLum = 0; % black

% Blocks
param.numBlocks = 1;

% Question Message
param.question = 'Left or Right?';

%%  PAIRWISE AND TRIPLE SETTINGS

% Column 1: par, Column 2: left, Column 3: div
stimulusSettings = [1 0 2; 1 1 2; -1 0 2; -1 1 2; 1 0 0; 1 0 1; 1 1 0; 1 1 1; -1 0 0; -1 0 1; -1 1 0; -1 1 1];

%% RUN EXPERIMENT

% Register Subject
subjectID = input('SUBJECT ID: ');

% Save Results File
if ~isfolder('gliderstimuliresults'); mkdir('gliderstimuliresults'); end
time = datestr(now,'yyyy.mm.dd_HHMM');
save(['./gliderstimuliresults/','Subject',num2str(subjectID),'_',time,'.mat'],'subjectID');

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
numFrames = param.stimDuration*param.framesPerSec + 1;

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
    'You will have 2 seconds to answer.\n\n',...
    'Press any key to begin the experiment...'
    ];
% Screen('Textsize',w,30);
DrawFormattedText(w,msg,'center','center',param.textLum);
Screen('Flip',w);
WaitSecs(0.5);
KbWait;

abortFlag = 0;

results = struct;

for ii = 1:param.numBlocks
    %% BLOCK NUMBER SCREEN
    msg = ['Block ',num2str(ii),'/',num2str(param.numBlocks)];
    % Screen('Textsize',w,30);
    DrawFormattedText(w,msg,'center','center',param.textLum);
    Screen('Flip',w);
    start = GetSecs;
    while GetSecs < start + 1.5; end
    
    % Randomize Order of Stimulus Settings
    stimulusSettings = stimulusSettings(randperm(size(stimulusSettings,1)),:);
    
    for ss = 1:size(stimulusSettings,1)
        
        % Present Fixation Point
        Screen('DrawDots',w,[0,0],round(param.fpSize*pxperdeg),param.fpColor,center,1);
        Screen('Flip',w);
        start = GetSecs;
        while GetSecs < start + param.preStimWait; end
        
        if stimulusSettings(ss,3) == 2
            % Create Pairwise Pattern
            mp = pairwise(stimulusSettings(ss,1), stimulusSettings(ss,2), numSquaresX, numSquaresY, numFrames);
            mp = 255*(mp+1)/2; % turn all negative ones into zeroes, multiply by 255 for luminance
            mp = repelem(mp,ceil(screenHeightpx/numSquaresY),ceil(screenWidthpx/numSquaresX)); % zoom in according to degPerSquare

            % Present Pairwise Pattern
            start = GetSecs;
            pattern = Screen('MakeTexture', w, mp(:,:,1));
            Screen('DrawTexture', w, pattern);
            vbl = Screen('Flip', w);
            frame = 1;
            while GetSecs < start+param.stimDuration
                pattern = Screen('MakeTexture', w, mp(:,:,frame+1));
                Screen('DrawTexture', w, pattern);
                Screen('Flip', w, vbl + frame/param.framesPerSec - 0.5*ifi);
                frame = frame+1;
            end
        else
            % Create Triple Pattern
            mt = triple(stimulusSettings(ss,1), stimulusSettings(ss,2), stimulusSettings(ss,3), numSquaresX, numSquaresY, numFrames);
            mt = 255*(mt+1)/2; % turn all negative ones into zeroes, multiply by 255 for luminance
            mt = repelem(mt,ceil(screenHeightpx/numSquaresY),ceil(screenWidthpx/numSquaresX)); % zoom in according to degPerSquare

            % Present Triple Pattern
            start = GetSecs;
            pattern = Screen('MakeTexture', w, mt(:,:,1));
            Screen('DrawTexture', w, pattern);
            vbl = Screen('Flip', w);
            frame = 1;
            while GetSecs < start+param.stimDuration
                pattern = Screen('MakeTexture', w, mt(:,:,frame+1));
                Screen('DrawTexture', w, pattern);
                Screen('Flip', w, vbl + frame/param.framesPerSec - 0.5*ifi);
                frame = frame+1;
            end
        end
        
        % Response
        % Screen('Textsize',w,30);
        DrawFormattedText(w,param.question,'center','center',param.textLum);
        responseStart = Screen('Flip',w);
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
        elseif stimulusSettings(ss,3) == 0
            results((ii-1)*size(stimulusSettings,1)+ss).type = 'converging';
        elseif stimulusSettings(ss,3) == 1
            results((ii-1)*size(stimulusSettings,1)+ss).type = 'diverging';
        end
        % Parity
        results((ii-1)*size(stimulusSettings,1)+ss).parity = stimulusSettings(ss,1);
        % Direction
        if stimulusSettings(ss,2) == 0
            results((ii-1)*size(stimulusSettings,1)+ss).direction = 1;
        elseif stimulusSettings(ss,2) == 1
            results((ii-1)*size(stimulusSettings,1)+ss).direction = -1;
        end
        % Response
        if response == 1
            results((ii-1)*size(stimulusSettings,1)+ss).response = 1;
        elseif response == -1
            results((ii-1)*size(stimulusSettings,1)+ss).response = -1;
        elseif response == 0
            results((ii-1)*size(stimulusSettings,1)+ss).response = NaN;
        end
        % ResponseTime
        if response == 0
            results((ii-1)*size(stimulusSettings,1)+ss).responseTime = NaN;
        else
            results((ii-1)*size(stimulusSettings,1)+ss).responseTime = responseTime;
        end
        
        %% APPPEND RESULTS
        save(['./gliderstimuliresults/','Subject',num2str(subjectID),'_',time,'.mat'],'subjectID','results','abortFlag','-append');
        
    end
    
    if abortFlag == 1; break; end
    
end

if abortFlag == 1; disp('ABORTING EXPERIMENT...'); end

%% CREATE EXCEL SHEET
if abortFlag == 0

    % Symmetrize
    for jj = 1:param.numBlocks*size(stimulusSettings,1)
        if ~isnan(results(jj).response)
            if results(jj).direction == -1
                results(jj).direction = 1;
                results(jj).response = -results(jj).response;
            end
        end
    end
    
    resultsTable = struct2table(results);        
    writetable(resultsTable,['./gliderstimuliresults/','Subject',num2str(subjectID),'_',time,'.xlsx']);
end

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