AssertOpenGL;

Screen('Preference', 'SkipSyncTests', 0);

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
param.degPerSquare = 0.1; % degrees per square

% Temporal Parameters
param.stimDuration = 1; % duration of stimulus in seconds
param.updateRate = 30; % number of frames we want per second
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
% LINE 1 / Coherence / Column 1: left, Column 2: fracCoherence, Column 3 = 2
% LINE 2 / Triple / Column 1: par, Column 2: left, Column 3: div
stimulusSettings = [0 1 2; 1 1 2; 0 0.2 2; 1 0.2 2; 0 0 2;
                    1 0 0; 1 0 1; 1 1 0; 1 1 1; -1 0 0; -1 0 1; -1 1 0; -1 1 1];

%% RUN EXPERIMENT

% REGISTER SUBJECT
subjectID = input('SUBJECT ID: ');

% Save Results File
if ~isfolder('tripleresults'); mkdir('tripleresults'); end
startTime = datestr(now,'yyyy.mm.dd_HHMM');
mkdir(['./tripleresults/','Subject',num2str(subjectID),'_',startTime]);
save(['./tripleresults/','Subject',num2str(subjectID),'_',startTime,'/','Subject',num2str(subjectID),'_',startTime,'.mat'],'subjectID','startTime');

% Create Eyelink Data Folder (Optional)
if ~isfolder(['./tripleresults/','Subject',num2str(subjectID),'_',startTime,'/eyelink'])
    mkdir(['./tripleresults/','Subject',num2str(subjectID),'_',startTime,'/eyelink']);
end

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
numFrames = param.stimDuration*param.updateRate;

% Center of Screen
[center(1), center(2)] = RectCenter(rect);

% Blending Mode
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Refresh Rate
ifi = Screen('GetFlipInterval', w);

% Provide Eyelink with details about the graphics environment and perform some initializations.
% The information is returned in a structure that also contains useful defaults and control codes
% (e.g. tracker state bit and Eyelink key values).
el = EyelinkInitDefaults(w);

% Switch the background color to white to match the stimlus background color.
% el.backgroundcolour = WhiteIndex(w);
% EyelinkUpdateDefaults(el);

% Enable listening and suppress output to MATLAB command window.
ListenChar(2);

dummymode = 0; % Set to 1 to initialize in dummymode.

% Initialize connection with the Eyelink Gazetracker.
% Exit program if this fails.
if ~EyelinkInit(dummymode,1)
    fprintf('Eyelink Init aborted.\n');
    cleanup;
    return;
end

[v, vs] = Eyelink('GetTrackerVersion');
fprintf('Running experiment on a ''%s'' tracker.\n',vs);

% EYELINK CALIBRATION
EyelinkDoTrackerSetup(el,13);

% Wait Frames
waitFrames = round(1/ifi/param.updateRate);

% WELCOME
msg = [
    'Welcome!\n\n',...
    'Press any key to continue...'
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
    % BLOCK NUMBER
    msg = ['Block ',num2str(ii),'/',num2str(param.numBlocks)];
    % Screen('Textsize',w,30);
    DrawFormattedText(w,msg,'center','center',param.textLum);
    Screen('Flip',w);
    start = GetSecs;
    while GetSecs < start + 1.5; end
    
    % Randomize Order of Stimulus Settings
    stimulusSettings = stimulusSettings(randperm(size(stimulusSettings,1)),:);

    % EYELINK DRIFT CORRECTION
    EyelinkDoDriftCorrection(el);

    for ss = 1:size(stimulusSettings,1)
      
        % Open edf File
        edfFile = ['Trial',num2str((ii-1)*size(stimulusSettings,1)+ss),'.edf'];
        Eyelink('Openfile',edfFile);
      
        % PRESENT FIXATION POINT
        Screen('DrawDots',w,[0,0],round(param.fpSize*pxperdeg),param.fpColor,center,1);
        Screen('Flip',w);
        start = GetSecs;
        while GetSecs < start + param.preStimWait - 0.5; end  % - 0.5 to allow Eyelink to start recording before stimulus presentation
        
        if stimulusSettings(ss,3) == 2

            % Start Recording Eye Movement
            Eyelink('StartRecording');
            startRecordTime = GetSecs;

            % Create Pairwise Pattern with Varying Coherence
            pc = pairwise(stimulusSettings(ss,1), numSquaresX, numSquaresY, numFrames, stimulusSettings(ss,2));
            pc = 255*(pc+1)/2; % turn all negative ones into zeroes, multiply by 255 for luminance
            pc = repelem(pc,ceil(screenHeightpx/numSquaresY),ceil(screenWidthpx/numSquaresX)); % zoom in according to degPerSquare

            % PRESENT PAIRWISE PATTERN

            % Draw First Frame before Flipping
            pattern = Screen('MakeTexture', w, pc(:,:,1));
            Screen('DrawTexture', w, pattern);

            if GetSecs >= startRecordTime + 0.5
                stimulusStartTime = Screen('Flip', w);
                vbl = stimulusStartTime;
            else
                while GetSecs < startRecordTime + 0.5; end
                stimulusStartTime = Screen('Flip', w);
                vbl = stimulusStartTime;
            end

            Eyelink('Message','STIMULUS_START'); % mark stimulus start
            for frame = 2:numFrames
                pattern = Screen('MakeTexture', w, pc(:,:,frame));
                Screen('DrawTexture', w, pattern);
                vbl = Screen('Flip', w, vbl + (waitFrames-0.5)*ifi);
            end
        else

            % Start Recording Eye Movement
            Eyelink('StartRecording');

            % Create Triple Pattern
            t = triple(stimulusSettings(ss,1), stimulusSettings(ss,2), stimulusSettings(ss,3), numSquaresX, numSquaresY, numFrames);
            t = 255*(t+1)/2; % turn all negative ones into zeroes, multiply by 255 for luminance
            t = repelem(t,ceil(screenHeightpx/numSquaresY),ceil(screenWidthpx/numSquaresX)); % zoom in according to degPerSquare
            
            % PRESENT TRIPLE PATTERN

            % Draw First frame before Flipping
            pattern = Screen('MakeTexture', w, t(:,:,1));
            Screen('DrawTexture', w, pattern);

            if GetSecs >= startRecordTime + 0.5
                stimulusStartTime = Screen('Flip', w);
                vbl = stimulusStartTime;
            else
                while GetSecs < startRecordTime + 0.5; end
                stimulusStartTime = Screen('Flip', w);
                vbl = stimulusStartTime;
            end

            Eyelink('Message','STIMULUS_START'); % mark stimulus start

            for frame = 2:numFrames
                pattern = Screen('MakeTexture', w, t(:,:,frame));
                Screen('DrawTexture', w, pattern);
                vbl = Screen('Flip', w, vbl + (waitFrames-0.5)*ifi);
            end
        end
        
        % RESPONSE
        % Screen('Textsize',w,30);
        DrawFormattedText(w,param.question,'center','center',param.textLum);
        responseStart = Screen('Flip', w, vbl + (waitFrames-0.5)*ifi);

        Eyelink('Message','STIMULUS_END'); % mark stimulus end     
        % Stop Recording Eye Movement
        Eyelink('StopRecording');
        Eyelink('CloseFile');

        while 1
            if GetSecs - responseStart >= 2
                response = 0;
                break % answer within 2 seconds
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
        
        % Download edf file
        try
            fprintf('Receiving data file ''%s''\n',edfFile);
            status = Eyelink('ReceiveFile');
            if status > 0
                fprintf('ReceiveFile status %d\n',status);
            end
            if 2 == exist(edfFile,'file')
                fprintf('Data file ''%s'' can be found in ''%s''\n',edfFile,pwd);
            end
            movefile('test.edf',fullfile(curr_sub_dir,['run' num2str(run_num) '.edf']));
        catch rdf
            fprintf('Problem receiving data file ''%s''\n',edfFile);
            rdf;
        end
        
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
    'Press any key to close...'];
% Screen('Textsize',w,30);
DrawFormattedText(w,msg,'center','center',param.textLum);
Screen('Flip',w);
WaitSecs(0.5);
KbWait;
cleanup;

% 3D Matrix for Triple Patterns
function triple = triple(par, left, div, x, y, z)

    % first frame
    triple(:,:,1) = (zeros(y,x)-1).^(randi([0 1],[y,x]));
    
    % right, converging
    for t = 2:z
        triple(:,1,t) = (zeros(y,1)-1).^(randi([0 1],[y,1]));
        triple(:,2:x,t) = par*triple(:,1:x-1,t-1).*triple(:,2:x,t-1);
    end
    % right, diverging
    if (left == 0) && (div == 1)
        triple = flip(flip(triple, 2), 3);
    % left, converging
    elseif (left == 1) && (div == 0)
        triple = flip(triple, 2);
    % left, diverging
    elseif (left == 1) && (div == 1)
        triple = flip(triple, 3);
    end

end

% 3D Matrix for Pairwise Patterns with Varying Coherence
function pairwise = pairwise(left, x, y, z, fracCoherence)

    % first frame
    pairwise(:,:,1) = (zeros(y,x)-1).^(randi([0 1],[y,x]));

    % right
    for t = 2:z
        pairwise(:,1,t) = (zeros(y,1)-1).^(randi([0 1],[y,1]));
        pairwise(:,2:x,t) = pairwise(:,1:x-1,t-1);
        indexRandom = randperm(x*y,x*y-round(x*y*fracCoherence));
        pairwise(x*y*(t-1)+indexRandom) = 2*(rand(1,size(indexRandom,2))>0.5)-1;
    end
    %left
    if left == 1
        pairwise = flip(pairwise, 2);
    end

end

function cleanup

    % Shutdown Eyelink
    Eyelink('Shutdown');
    sca;
    ListenChar(0);
    
end