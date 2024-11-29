par = 1; % parity
left = 0; % 0: right, 1: left
div = 0; % 0: converging, 1: diverging
x = 72; % width
y = 100; % number of rows

figure; % plot up all 8 of the 3 point patterns

mt = triple(1, 0, 0, x, y);
subplot(2,4,1);
imagesc(mt);
title('pos, right, conv');

mt = triple(1, 0, 1, x, y);
subplot(2,4,2);
imagesc(mt);
title('pos, right, div');

mt = triple(1, 1, 0, x, y);
subplot(2,4,3);
imagesc(mt);
title('pos, left, conv');

mt = triple(1, 1, 1, x, y);
subplot(2,4,4);
imagesc(mt);
title('pos, left, div');

mt = triple(-1, 0, 0, x, y);
subplot(2,4,5);
imagesc(mt);
title('neg, right, conv');

mt = triple(-1, 0, 1, x, y);
subplot(2,4,6);
imagesc(mt);
title('neg, right, div');

mt = triple(-1, 1, 0, x, y);
subplot(2,4,7);
imagesc(mt);
title('neg, left, conv');

mt = triple(-1, 1, 1, x, y);
subplot(2,4,8);
imagesc(mt);
title('neg, left, div');

figure; % plot up all 4 of the 2 point patterns

mp = pairwise(1, 0, x, y);
subplot(2,2,1);
imagesc(mp);
title('pos, right')

mp = pairwise(1, 1, x, y);
subplot(2,2,2);
imagesc(mp);
title('pos, left')

mp = pairwise(-1, 0, x, y);
subplot(2,2,3);
imagesc(mp);
title('neg, right')

mp = pairwise(-1, 1, x, y);
subplot(2,2,4);
imagesc(mp);
title('neg, left')

function mt = triple(par, left, div, x, y)

    % first row
    mt(1,:) = (zeros(1,x)-1).^(randi([0 1],[1,x]));
    
    % right, converging
    for t = 2:y
        mt(t,1) = (-1)^(randi(2)-1);
        mt(t,2:x) = par*mt(t-1,1:x-1).*mt(t-1,2:x);
    end
    % right, diverging
    if (left == 0) && (div == 1)
        mt = fliplr(flipud(mt));
    % left, converging
    elseif (left == 1) && (div == 0)
        mt = fliplr(mt);
    % left, diverging
    elseif (left == 1) && (div == 1)
        mt = flipud(mt);
    end

end

function mp = pairwise(par, left, x, y)

    % first row
    mp(1,:) = (zeros(1,x)-1).^(randi([0 1],[1,x]));
    
    % right
    for t = 2:y
        mp(t,1) = (-1)^(randi(2)-1);
        mp(t,2:x) = par*mp(t-1,1:x-1);
    end 
    % left
    if left == 1
        mp = fliplr(mp);
    end

end
