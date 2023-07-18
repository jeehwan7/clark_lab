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
                         % Otherwise glitching will occur
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
% Column 1: left (0 means right, 1 means left), Column 2: fracCoherence (between 0 and 1)
stimulusSettings = [0 0; 0 0.1; 0 0.2; 0 0.3; 0 0.4; 0 0.5; 0 0.6; 0 0.7; 0 0.8; 0 0.9; 0 1; 1 0.1; 1 0.2; 1 0.3; 1 0.4; 1 0.5; 1 0.6; 1 0.7; 1 0.8; 1 0.9; 1 1];

%% RUN EXPERIMENT

% REGISTER SUBJECT
subjectID = input('SUBJECT ID: ');

% Save Results File
if ~isfolder('./pairwisecoherenceresults'); mkdir('./pairwisecoherenceresults'); end
startTime = datestr(now,'yyyy.mm.dd_HHMM');
mkdir(['./pairwisecoherenceresults/','Subject',num2str(subjectID),'_',startTime]);
save(['./pairwisecoherenceresults/','Subject',num2str(subjectID),'_',startTime,'/','Subject',num2str(subjectID),'_',startTime,'.mat'],'subjectID','startTime');

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

stimuli = cell(param.numBlocks*size(stimulusSettings,1),1);
results = struct;

for ii = 1:param.numBlocks
    % BLOCK NUMBER
    msg = ['Block ',num2str(ii),' of ',num2str(param.numBlocks)];
    % Screen('Textsize',w,30);
    DrawFormattedText(w,msg,'center','center',param.textLum);
    Screen('Flip',w);
    start = GetSecs;
    while GetSecs < start + 1.5; end

    % PREPARING TEXTURES
    msg = ['Preparing textures...\n\n',...
        'Please be patient'
        ];
    DrawFormattedText(w,msg,'center','center',param.textLum);
    Screen('Flip',w);

    % Create All Textures for This Block
    squares = cell(size(stimulusSettings,1),1);
    textures = cell(size(stimulusSettings,1),1);

    for jj = 1:size(stimulusSettings,1)
        pairwiseSquares = pairwise(stimulusSettings(jj,1),numSquaresX, numSquaresY, numFrames, stimulusSettings(jj,2));
        pairwiseMatrix = 255*(pairwiseSquares+1)/2; % turn all negative ones into zeroes, multiply by 255 for luminance (black or white)
        pairwiseMatrix = repelem(pairwiseMatrix,ceil(screenHeightpx/numSquaresY),ceil(screenWidthpx/numSquaresX)); % "zoom in" according to degPerSquare

        for kk = 1:numFrames
            squares{jj}{kk} = pairwiseSquares(:,:,kk);
            textures{jj}{kk} = Screen('MakeTexture',w,pairwiseMatrix(:,:,kk));
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
    
    % Randomize Order of Stimulus Settings
    randomizedIndex = randperm(size(stimulusSettings,1));
    randomizedStimulusSettings = stimulusSettings(randomizedIndex,:);

    for ss = 1:size(stimulusSettings,1)

        % PRESENT FIXATION POINT
        Screen('DrawDots', w, [0,0], round(param.fpSize*pxperdeg), param.fpColor, center, 1);
        vbl = Screen('Flip', w);

        % PRESENT STIMULUS
        Screen('DrawTexture', w, textures{randomizedIndex(ss)}{1});
        stimulusStartTime = Screen('Flip', w, vbl + param.preStimWait); % duration of dot presentation utilized here
        Screen('DrawTexture', w, textures{randomizedIndex(ss)}{2});
        vbl = Screen('Flip', w, stimulusStartTime + (waitFrames-0.5)*ifi);

        for qq = 3:numFrames
            Screen('DrawTexture', w, textures{randomizedIndex(ss)}{qq});
            vbl = Screen('Flip', w, vbl + (waitFrames-0.5)*ifi);
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

        %% SAVE STIMULUS
        stimuli{(ii-1)*size(randomizedStimulusSettings,1)+ss} = squares{randomizedIndex(ss)};
        
        %% RESULTS

        % Trial Number
        results((ii-1)*size(randomizedStimulusSettings,1)+ss).trialNumber = (ii-1)*size(randomizedStimulusSettings,1)+ss;
        % Direction
        if randomizedStimulusSettings(ss,1) == 0
            results((ii-1)*size(randomizedStimulusSettings,1)+ss).direction = 1;
        elseif randomizedStimulusSettings(ss,1) == 1
            results((ii-1)*size(randomizedStimulusSettings,1)+ss).direction = -1;
        end
        % Coherence
        results((ii-1)*size(randomizedStimulusSettings,1)+ss).coherence = randomizedStimulusSettings(ss,2);
        % Response
        if response == 1
            results((ii-1)*size(randomizedStimulusSettings,1)+ss).response = 1;
        elseif response == -1
            results((ii-1)*size(randomizedStimulusSettings,1)+ss).response = -1;
        elseif response == 0
            results((ii-1)*size(randomizedStimulusSettings,1)+ss).response = NaN;
        end
        % ResponseTime
        if response == 0
            results((ii-1)*size(randomizedStimulusSettings,1)+ss).responseTime = NaN;
        else
            results((ii-1)*size(randomizedStimulusSettings,1)+ss).responseTime = responseTime;
        end
        % Stimulus Start Time
        results((ii-1)*size(randomizedStimulusSettings,1)+ss).stimulusStartTime = stimulusStartTime;
        % Stimulus End Time
        results((ii-1)*size(randomizedStimulusSettings,1)+ss).stimulusEndTime = responseStart;
        
        % Append Results
        save(['./pairwisecoherenceresults/','Subject',num2str(subjectID),'_',startTime,'/','Subject',num2str(subjectID),'_',startTime,'.mat'],'results','abortFlag','-append');

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
