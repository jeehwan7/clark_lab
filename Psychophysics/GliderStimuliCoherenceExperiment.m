AssertOpenGL;

Screen('Preference', 'SkipSyncTests', 2);

% Key Configuration
KbName('UnifyKeyNames');
if ismac || isunix
    lresc = [80,82,41];
elseif ispc
    lresc = [37,39,27];
else
    error('PLATFORM NOT SUPPORTED; MAC OS X, WINDOWS, OR LINUX ONLY');
end

%% PARAMETERS

% Resolution Parameters
param.viewDist = 50; % viewing distance in cm
param.degPerSquare = 0.5; % degrees per square

% Temporal Parameters
param.stimDuration = 1; % duration of stimulus in seconds
param.framesPerSec = 30; % number of frames we want per second
                         % IMPORTANT! We want to set this to a factor of the frame rate
                         %            Otherwise glitching will occur
param.preStimWait = 2; % duration of fixation point in seconds

% Blocks
param.numBlocks = 2;

% Fixation Point Parameters
param.fpColor = [255,0,0,255];
param.fpSize = 0.3; % in degrees

% Background and Text Luminance
param.bgLum = 255; % white
param.textLum = 0; % black

% Question Message
param.question = 'Left or Right?';

%% RUN EXPERIMENT

% Register Subject
subjectID = input('SUBJECT ID: ');

% Save Results File
if ~isfolder('./gliderstimuliresults/coherenceresults'); mkdir('./gliderstimuliresults/coherenceresults'); end
startTime = datestr(now,'yyyy.mm.dd_HHMM');
save(['./gliderstimuliresults/coherenceresults/','Subject',num2str(subjectID),'_',startTime,'.mat'],'subjectID','startTime');

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
    'After the stimulus disappears, indicate your\n',...
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

% Stimulus Settings
stimulusSettings = [0 0; 0 0.1; 0 0.2; 0 0.3; 0 0.4; 0 0.5; 0 0.6; 0 0.7; 0 0.8; 0 0.9; 0 1; 1 0; 1 0.1; 1 0.2; 1 0.3; 1 0.4; 1 0.5; 1 0.6; 1 0.7; 1 0.8; 1 0.9; 1 1];

for ii = 1:param.numBlocks
    
    % Randomize Order of Stimulus Settings
    stimulusSettings = stimulusSettings(randperm(size(stimulusSettings,1)),:);

    for ss = 1:size(stimulusSettings,1)

        % Present Fixation Point
        Screen('DrawDots',w,[0,0],round(param.fpSize*pxperdeg),param.fpColor,center,1);
        Screen('Flip',w);
        start = GetSecs;
        while GetSecs < start + param.preStimWait; end

        % Create Pairwise Pattern
        mp = pairwise(stimulusSettings(ss,1), numSquaresX, numSquaresY, numFrames, stimulusSettings(ss,2));
        mp = 255*(mp+1)/2; % turn all negative ones into zeroes, multiply by 255 for luminance
        mp = repelem(mp,ceil(screenHeightpx/numSquaresY),ceil(screenWidthpx/numSquaresX)); % zoom in according to degPerSquare

        % Present Pairwise Pattern
        start = GetSecs;
        pattern = Screen('MakeTexture', w, mp(:,:,1));
        Screen('DrawTexture', w, pattern);
        vbl = Screen('Flip', w);
        startPresent = vbl;
        frame = 1;
        while GetSecs < start+param.stimDuration
            pattern = Screen('MakeTexture', w, mp(:,:,frame+1));
            Screen('DrawTexture', w, pattern);
            Screen('Flip', w, vbl + frame/param.framesPerSec - 0.5*ifi);
            frame = frame+1;
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
        % Direction
        if stimulusSettings(ss,1) == 0
            results((ii-1)*size(stimulusSettings,1)+ss).direction = 1;
        elseif stimulusSettings(ss,1) == 1
            results((ii-1)*size(stimulusSettings,1)+ss).direction = -1;
        end
        % Coherence
        results((ii-1)*size(stimulusSettings,1)+ss).coherence = stimulusSettings(ss,2);
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
        % Start Present
        results((ii-1)*size(stimulusSettings,1)+ss).startPresent = startPresent;
        % Finish Present
        results((ii-1)*size(stimulusSettings,1)+ss).finishPresent = responseStart;
        
        %% APPPEND RESULTS
        save(['./gliderstimuliresults/coherenceresults/','Subject',num2str(subjectID),'_',startTime,'.mat'],'results','abortFlag','-append');

    end
    
    if abortFlag == 1; break; end
    
end

if abortFlag == 1; disp('ABORTING EXPERIMENT...'); end

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

% 3D Matrix for Pairwise Patterns with Varying Coherence
function mp = pairwise(left, x, y, z, fracCoherence)

    % first frame
    mp(:,:,1) = (zeros(y,x)-1).^(randi([0 1],[y,x]));

    % right
    for t = 2:z
        mp(:,1,t) = (zeros(y,1)-1).^(randi([0 1],[y,1]));
        mp(:,2:x,t) = mp(:,1:x-1,t-1);
        indexRandom = randperm(x*y,x*y-round(x*y*fracCoherence));
        mp(x*y*(t-1)+indexRandom) = 2*(rand(1,size(indexRandom,2))>0.5)-1;
    end
    %left
    if left == 1
        mp = flip(mp, 2);
    end

end