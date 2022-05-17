left = 0; % 0: right, 1: left
div = 0; % 0: converging, 1: diverging
par = 1; % parity
c = 72; % column
r = 100; % row

figure; % plot up all 8 of the 3 point patterns

mt = triple(left, div, par, c, r);
subplot(2,4,1);
imagesc(mt);
title('pos, right, conv');

div = 1;
mt = triple(left, div, par, c, r);
subplot(2,4,2);
imagesc(mt);
title('pos, right, div');

left = 1; div = 0;
mt = triple(left, div, par, c, r);
subplot(2,4,3);
imagesc(mt);
title('pos, left, conv');

left = 1; div = 1;
mt = triple(left, div, par, c, r);
subplot(2,4,4);
imagesc(mt);
title('pos, left, div');

par = -1; left = 0; div = 0;
mt = triple(left, div, par, c, r);
subplot(2,4,5);
imagesc(mt);
title('neg, right, conv');

div = 1;
mt = triple(left, div, par, c, r);
subplot(2,4,6);
imagesc(mt);
title('neg, right, div');

left = 1; div = 0;
mt = triple(left, div, par, c, r);
subplot(2,4,7);
imagesc(mt);
title('neg, left, conv');

left = 1; div = 1;
mt = triple(left, div, par, c, r);
subplot(2,4,8);
imagesc(mt);
title('neg, left, div');

figure; % plot up all 4 of the 2 point patterns

par = 1; left = 0;
mp = pairwise(left, par, c, r);
subplot(2,2,1);
imagesc(mp);
title('pos, right')

left = 1;
mp = pairwise(left, par, c, r);
subplot(2,2,2);
imagesc(mp);
title('pos, left')

par = -1; left = 0;
mp = pairwise(left, par, c, r);
subplot(2,2,3);
imagesc(mp);
title('neg, right')

left = 1;
mp = pairwise(left, par, c, r);
subplot(2,2,4);
imagesc(mp);
title('neg, left')

function mt = triple(left, div, par, c, r)

    % first row
    mt(1,:) = (zeros(1,c)-1).^(randi([0 1],[1,c]));
    
    % right, converging
    for t = 2:r
        mt(t,1) = (-1)^(randi(2)-1);
        mt(t,2:c) = par*mt(t-1,1:c-1).*mt(t-1,2:c);
    end
    
    % other conditions
    if (left == 0) && (div == 1)
        mt = fliplr(flipud(mt));
    elseif (left == 1) && (div == 0)
        mt = fliplr(mt);
    elseif (left == 1) && (div == 1)
        mt = flipud(mt);
    end

end

function mp = pairwise(left, par, c, r)

    % first row
    mp(1,:) = (zeros(1,c)-1).^(randi([0 1],[1,c]));
    
    % right
    for t = 2:r
        mp(t,1) = (-1)^(randi(2)-1);
        mp(t,2:c) = par*mp(t-1,1:c-1);
    end
    
    % other conditions
    if left == 1
        mp = fliplr(mp);
    end

end
