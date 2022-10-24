function Q = createEyeVelocity(Q)

    % according to EyeLink settings and my own measurements
    viewDistmm = 560; % viewing distance
    screenWidthpx = 1920; % screen width px
    screenWidthmm = 600; % screen width mm
    
    % trigonometry
    theta = atan((Q.eyePosition-960)/screenWidthpx*screenWidthmm/viewDistmm);

    Q.eyeVelocity = diff(theta,1,2)/pi*180*1000; % diff(X,n,dim); % dtheta/dt = deg/s

end