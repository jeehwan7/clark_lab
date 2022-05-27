left = 0; % 0: right, 1: left
div = 0; % 0: converging, 1: diverging
par = 1; % parity
x = 1000; % width
y = 1000; % height
z = 120; % number of frames

figure; % plot up all 8 of the 3 point patterns / first n slices across z axis

n = 2;

mt = triple(left, div, par, x, y, z);
A = permute(mt, [3 2 1]);
for i=1:n
    subplot(8,n,i);
    imagesc(A(:,:,i));
    title(strcat("pos, right, conv: y = ", num2str(i)))
end

div = 1;
mt = triple(left, div, par, x, y, z);
A = permute(mt, [3 2 1]);
for i=1:n
    subplot(8,n,i+n);
    imagesc(A(:,:,i));
    title(strcat("pos, right, div: y = ", num2str(i)))
end

left = 1; div = 0;
mt = triple(left, div, par, x, y, z);
A = permute(mt, [3 2 1]);
for i=1:n
    subplot(8,n,i+2*n);
    imagesc(A(:,:,i));
    title(strcat("pos, left, conv: y = ", num2str(i)))
end

left = 1; div = 1;
mt = triple(left, div, par, x, y, z);
A = permute(mt, [3 2 1]);
for i=1:n
    subplot(8,n,i+3*n);
    imagesc(A(:,:,i));
    title(strcat("pos, left, div: y = ", num2str(i)))
end

left = 0; div = 0; par = -1;
mt = triple(left, div, par, x, y, z);
A = permute(mt, [3 2 1]);
for i=1:n
    subplot(8,n,i+4*n);
    imagesc(A(:,:,i));
    title(strcat("neg, right, conv: y = ", num2str(i)))
end

div = 1;
mt = triple(left, div, par, x, y, z);
A = permute(mt, [3 2 1]);
for i=1:n
    subplot(8,n,i+5*n);
    imagesc(A(:,:,i));
    title(strcat("neg, right, div: y = ", num2str(i)))
end

left = 1; div = 0;
mt = triple(left, div, par, x, y, z);
A = permute(mt, [3 2 1]);
for i=1:n
    subplot(8,n,i+6*n);
    imagesc(A(:,:,i));
    title(strcat("neg, left, conv: y = ", num2str(i)))
end

left = 1; div = 1;
mt = triple(left, div, par, x, y, z);
A = permute(mt, [3 2 1]);
for i=1:n
    subplot(8,n,i+7*n);
    imagesc(A(:,:,i));
    title(strcat("neg, left, div: y = ", num2str(i)))
end

figure; % plot up all 4 of the 2 point patterns / first n slices across z axis

left = 0; par = 1;
mp = pairwise(left, par, x, y, z);
B = permute(mp, [3 2 1]);
for i=1:n
    subplot(4,n,i);
    imagesc(B(:,:,i));
    title(strcat("pos, right: y = ", num2str(i)))
end

left = 1;
mp = pairwise(left, par, x, y, z);
B = permute(mp, [3 2 1]);
for i=1:n
    subplot(4,n,i+n);
    imagesc(B(:,:,i));
    title(strcat("pos, left: y = ", num2str(i)))
end

left = 0; par = -1;
mp = pairwise(left, par, x, y, z);
B = permute(mp, [3 2 1]);
for i=1:n
    subplot(4,n,i+2*n);
    imagesc(B(:,:,i));
    title(strcat("neg, right: y = ", num2str(i)))
end

left = 1;
mp = pairwise(left, par, x, y, z);
B = permute(mp, [3 2 1]);
for i=1:n
    subplot(4,n,i+3*n);
    imagesc(B(:,:,i));
    title(strcat("neg, left: y = ", num2str(i)))
end

function mt = triple(left, div, par, x, y, z)

    % first frame
    mt(:,:,1) = (zeros(y,x)-1).^(randi([0 1],[y,x]));
    
    % right, converging
    for t = 2:z
        mt(:,1,t) = (zeros(y,1)-1).^(randi([0 1],[y,1]));
        mt(:,2:x,t) = par*mt(:,1:x-1,t-1).*mt(:,2:x,t-1);
    end
    % right, diverging
    if (left == 0) && (div == 1)
        mt = flip(flip(mt, 2), 3);
    % left, converging
    elseif (left == 1) && (div == 0)
        mt = flip(mt, 2);
    % left, diverging
    elseif (left == 1) && (div == 1)
        mt = flip(mt, 3);
    end

end

function mp = pairwise(left, par, x, y, z)

    % first frame
    mp(:,:,1) = (zeros(y,x)-1).^(randi([0 1],[y,x]));

    % right
    for t = 2:z
        mp(:,1,t) = (zeros(y,1)-1).^(randi([0 1],[y,1]));
        mp(:,2:x, t) = par*mp(:,1:x-1,t-1);
    end
    %left
    if left == 1
        mp = flip(mp, 2);
    end

end