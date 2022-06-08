x = 100; % width
y = 100; % number of rows
fracCoherence = 0.5; % fraction of coherence

figure; % plot up all 4 of the 2 point patterns

mp = pairwise(0, x, y, fracCoherence);
subplot(2,2,1);
imagesc(mp);
title('pos, right')

mp = pairwise(1, x, y, fracCoherence);
subplot(2,2,2);
imagesc(mp);
title('pos, left')

function mp = pairwise(left, x, y, fracCoherence)
    
    % first row
    mp(1,:) = (zeros(1,x)-1).^(randi([0 1],[1,x]));
    
    % right
    for t = 2:y
        mp(t,1) = (-1)^(randi(2)-1);
        mp(t,2:x) = mp(t-1,1:x-1);
        xRandom = randperm(x-1,x-1-round((x-1)*fracCoherence))+1;
        mp(t,xRandom) = 2*(rand(1,size(xRandom,2))>0.5)-1;
    end
    
    % left
    if left == 1
        mp = fliplr(mp);
    end

end