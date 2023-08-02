function Q = createEyeVelocity(Q,viewDist,screenWidthpx,pxpermm)

    viewDistmm = viewDist*10;
    
    % trigonometry
    theta = atan((Q.eyePosition-screenWidthpx/2)/pxpermm/viewDistmm);

    Q.eyeVelocity = diff(theta,1,2)/pi*180*1000; % dtheta/dt = deg/s

end