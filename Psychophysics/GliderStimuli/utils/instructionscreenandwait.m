function instructionscreenandwait(windowptr,msg,color,size,waitdur)

%% This is just a subroutine for the experiment program to show messages

if nargin<5
    waitdur = 1;
elseif nargin<4
    size = 30;
elseif nargin<3
    color = 0;
end
Screen('TextSize',windowptr,size);
DrawFormattedText(windowptr,msg,'center','center',color);
% Screen('DrawingFinished', windowptr);
Screen('Flip', windowptr);
WaitSecs(waitdur); KbWait; 
end