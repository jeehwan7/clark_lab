function dThetabyTrial = createDThetabyTrial(posXbyTrial)

    % according to the EyeLink settings and my own measurements
    viewDistmm = 560;
    screenWidthpx = 1920;
    screenWidthmm = 600;
    % trigonometry
    thetabyTrial = atan((posXbyTrial-960)/screenWidthpx*screenWidthmm/viewDistmm);
    dThetabyTrial = diff(thetabyTrial,1,2)/pi*180*1000; % diff(X,n,dim); % dTheta/dt = deg/s

end