param.framesPerSec = 60;
param.degPerCheck = 0.5;

numSquaresY = 64;
numSquaresX = 64;
numFrames = 600;

% discrete autocorrelated Gaussian stimulus velocity
param.std = 60;
param.corrFrames = 24;

g = autocorrelatedGaussian(numFrames-1,param.corrFrames); % deg/s
g = g*param.std/param.framesPerSec/param.degPerCheck; % checks/frame
g = round(g); % whole number of checks/frame
g = [NaN; g];

% correlated noise
contrast = 1/2;
covariance = 1/8;

theta = asin(2*covariance/contrast^2)/2; % covariance therefore ranges from -1/8 to 1/8
alpha = contrast*cos(theta);
beta = contrast*sin(theta);

init = randn(numSquaresY,numSquaresX,numFrames);

stim = NaN(numSquaresY,numSquaresX,numFrames);

stim(:,:,1) = alpha*init(:,:,end) + beta*init(:,:,1);
for ii = 2:numFrames
    prev = init(:,:,ii-1);
    stim(:,:,ii) = alpha*init(:,:,ii) + beta*circshift(prev,g(ii),2);
end

% calculate covariances
covariances = NaN(numFrames,2); % column 1: variance
                                % column 2: covariance with appropriately circshifted previous frame
for ii = 1:numFrames
    if ii == 1
        C = cov(stim(:,:,ii),stim(:,:,ii));
        covariances(ii,1) = C(1,1);
    else
        C = cov(circshift(stim(:,:,ii-1),g(ii),2),stim(:,:,ii));
        covariances(ii,1) = C(1,1);
        covariances(ii,2) = C(1,2);
    end
end

% clip
stim(stim>1) = 1;
stim(stim<-1) = -1;

% movie
for ii = 1:numFrames
    imshow(stim(:,:,ii),[-1 1],'InitialMagnification',1000);
    drawnow();
    pause(0.001);
end

function g = autocorrelatedGaussian(numFrames,corrFrames) % actually numFrames-1

    if length(corrFrames) == 1 % if corrT is scalar
        if corrFrames == 0
            g = randn(numFrames,1);
        else
            A = 1;
            B = exp(-(0:corrFrames*5)/corrFrames);
            x = randn(2*numFrames,1);
            x = filter(B,A,x);
            g = x(end/2+1:end);
            g = g - mean(g);
            g = g/std(g); % set variance correctly (1)
        end
    else % if vector is given, then filter with vector
            x = randn(2*numFrames,1);
            x = filter(corrFrames,1,x);
            g = x(end/2+1:end);
            g = g-mean(g);
            g = g/std(g); % set variance correctly (1)
    end

end