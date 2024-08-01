function Q = createEyeVelocity(Q,viewDist,screenWidthpx,pxPermm)

    viewDistmm = viewDist*10;
    
    % trigonometry
    Q.eyeDisplacement = atan((Q.eyePosition-screenWidthpx/2)/pxPermm/viewDistmm)/pi*180; % deg

    Q.eyeVelocity = diff(Q.eyeDisplacement,1,2)*1000; % deg/s

end