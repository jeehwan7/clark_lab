function Q = createEyeVelocity(Q,viewDist,screenWidthpx,pxPermm)

    viewDistmm = viewDist*10;
    
    % trigonometry
    Q.adapEyeXDisp = atan((Q.adapEyeXPos-screenWidthpx/2)/pxPermm/viewDistmm)/pi*180; % deg
    Q.stimEyeXDisp = atan((Q.stimEyeXPos-screenWidthpx/2)/pxPermm/viewDistmm)/pi*180; % deg

    Q.adapEyeXVel = diff(adapEyeXDisp,1,2)*1000; % deg/s
    Q.stimEyeXVel = diff(stimEyeXDisp,1,2)*1000; % deg/s

end