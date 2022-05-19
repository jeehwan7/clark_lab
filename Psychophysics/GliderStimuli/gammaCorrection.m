function [ghat,M,intensities] = gammaCorrection

%% Last updated on Mar 21 2020 by RT for annotation
% This function runs gamma correction on your monitor. Attach your power
% meter to the screen, and run this script. It will ask you to input the
% reading of power meter and will fit power-law function to the measured
% power, and store the fit parameter to be used in the experiment. 

AssertOpenGL;

screens = Screen('screens'); % get available screens
scrnum  = max(screens);      % use screen with largest ID
% obtain screen dimensions
[scrWpx,scrHpx] = Screen('WindowSize',scrnum);
[w, rect] = Screen('OpenWindow', scrnum,0, [0, 0, scrWpx/2,scrHpx/2]); % use only a quadrant
Screen('ColorRange',w,1);
Nstep = 11;
intval = linspace(0,1,Nstep);
lambdas = [660,520,450];
intensities = nan(Nstep,3);
for cc = 1:3
   col = zeros(3,1);
   col(cc) = 1;
   disp(['Change lambda to an appropriate value (e.g. ',num2str(lambdas(cc)),' nm']);
   WaitSecs(1); KbWait;
   for ii = 1:Nstep 
       Screen('FillRect',w,col*intval(ii));
       Screen('Flip',w); 
%        intensities(ii,cc) = input('Enter measured intensity in uW: ');
       intensities(ii,cc) = ii; % DOES NOT DO ANY GAMMA CORRECTION! CHANGE LATER.
       WaitSecs(0.5);
   end
end
sca;

% post processing
M = intensities - repmat(intensities(1,:),Nstep,1); 
M = M./repmat(M(end,:),Nstep,1);
model = fitnlm(intval',mean(M,2),@(g,x)(x.^g),2);
ghat = model.Coefficients.Estimate;

figure; hold on
plot(intval,M(:,1),'r');
plot(intval,M(:,2),'g');
plot(intval,M(:,3),'b');
plot(intval,intval.^ghat,'k--');
xlabel('Pixel intensity'); ylabel('Relative actual intensity');
save(['gamma',datestr(now,'yyyymmdd-HHMMSS'),'.mat'],'ghat','M','intensities');
end