x = 100; % width
y = 100; % height
z = 50; % number of frames
fracCoherence = 0.5;

figure; % plot up all 4 of the 2 point patterns / first n slices across z axis

n = 2;

mp = pairwise(0, x, y, z, fracCoherence);
A = permute(mp, [3 2 1]);
for i=1:n
    subplot(4,n,i);
    imagesc(A(:,:,i));
    title(strcat("pos, right: y = ", num2str(i)))
end

mp = pairwise(1, x, y, z, fracCoherence);
A = permute(mp, [3 2 1]);
for i=1:n
    subplot(4,n,i+n);
    imagesc(A(:,:,i));
    title(strcat("pos, left: y = ", num2str(i)))
end

function mp = pairwise(left, x, y, z, fracCoherence)

    % first frame
    mp(:,:,1) = (zeros(y,x)-1).^(randi([0 1],[y,x]));

    % right
    for t = 2:z
        mp(:,1,t) = (zeros(y,1)-1).^(randi([0 1],[y,1]));
        mp(:,2:x,t) = mp(:,1:x-1,t-1);
        indexRandom = randperm(x*y,x*y-round(x*y*fracCoherence));
        mp(x*y*(t-1)+indexRandom) = 2*(rand(1,size(indexRandom,2))>0.5)-1;
    end
    %left
    if left == 1
        mp = flip(mp, 2);
    end

end
