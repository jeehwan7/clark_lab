% quick thing to try to make correlated Gaussian fields

h = 100;
w = 100;
T = 100;
theta = pi/4; % set theta; 1/2*sin(2*theta) = correlation strength; pi/4 and -pi/4 are useful

G = randn(h,w,T);
c = cos(theta)*G + sin(theta)*circshift(G,[0 5 1]);

figure;
for tt = 1:T
    imagesc(c(:,:,tt));
    colormap('gray');
    set(gca,'clim',[-2 2]);
    drawnow;
    pause(.05);
end
