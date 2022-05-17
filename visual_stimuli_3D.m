% left = 0;
% div = 0;
par = 1;
x = 1000;
y = 1000;
z = 120;

mt = triple(par, x, y, z);

figure; % slices across z axis

A = permute(mt, [3 2 1]);

for i=1:3
    subplot(3,1,i);
    imagesc(A(:,:,i));
    title(strcat('y = ', num2str(i)))
end


function mt = triple(par, x, y, z)

    % first frame
    mt(:,:,1) = (zeros(y,x)-1).^(randi([0 1],[y,x]));
    
    % right, converging
    for t = 2:z
        mt(:,1,t) = (-1)^(randi(2)-1);
        mt(:,2:x,t) = par*mt(:,1:x-1,t-1).*mt(:,2:x,t-1);
    end

end