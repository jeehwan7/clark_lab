function Q = createEyeVelocity(Q,viewDist,screenWidthpx,pxPermm)

    viewDistmm = viewDist*10;
    
    % trigonometry
    theta = atan((Q.eyePosition-screenWidthpx/2)/pxPermm/viewDistmm);

    Q.eyeVelocity = diff(theta,1,2)/pi*180*1000; % dtheta/dt = deg/s

end