par = 1; % parity: 1 or -1
dir = 1; % direction: 1 or -1
cor = 0.5; % correlation
jump = 5;

theta = asin(2*cor)/2; % calculate theta based on correlation

x = 100;
y = 100;
z = 100;

G = randn(y,x,z);
c = cos(theta)*G + par*sin(theta)*circshift(G,[0 dir*jump 1]);

figure;
for t = 1:z
    imagesc(c(:,:,t));
    colormap('gray');
    set(gca,'clim',[-1 1]);
    drawnow;
    pause(.05);
end