x = 100; % width
t = 100; % number of rows

figure; % plot up all 8 of the triple correlation patterns

counter = 1;
for div = [0 1] % 0: converging, 1: diverging
    for par = [1 -1] % parity
        for left = [0 1] % 0: right, 1: left
            T = triple(par, left, div, x, t);
            subplot(2,4,counter);
            imagesc(T);
            
            if div == 0
                type = 'conv';
            else
                type = 'div';
            end
            
            if par == 1
                parity = '+';
            else
                parity = '-';
            end

            if left == 0
                direction = 'right';
            else
                direction = 'left';
            end

            title([type,', ',parity,', ',direction]);

            counter = counter + 1;
        end
    end
end

sgtitle('Triple Correlation Stimuli (x vs. t)');

figure; % plot up all 4 of the pairwise correlation patterns

P = pairwise(1, 0, x, t);
subplot(2,2,1);
imagesc(P);
title('+, right')

P = pairwise(1, 1, x, t);
subplot(2,2,2);
imagesc(P);
title('+, left')

P = pairwise(-1, 0, x, t);
subplot(2,2,3);
imagesc(P);
title('-, right')

P = pairwise(-1, 1, x, t);
subplot(2,2,4);
imagesc(P);
title('-, left')

sgtitle('Pairwise Correlation Stimuli (x vs. t)')

function T = triple(par, left, div, x, y)

    % first row
    T(1,:) = (zeros(1,x)-1).^(randi([0 1],[1,x]));
    
    % right, converging
    for t = 2:y
        T(t,1) = (-1)^(randi(2)-1);
        T(t,2:x) = par*T(t-1,1:x-1).*T(t-1,2:x);
    end
    % right, diverging
    if (left == 0) && (div == 1)
        T = fliplr(flipud(T));
    % left, converging
    elseif (left == 1) && (div == 0)
        T = fliplr(T);
    % left, diverging
    elseif (left == 1) && (div == 1)
        T = flipud(T);
    end

end

function P = pairwise(par, left, x, y)

    % first row
    P(1,:) = (zeros(1,x)-1).^(randi([0 1],[1,x]));
    
    % right
    for t = 2:y
        P(t,1) = (-1)^(randi(2)-1);
        P(t,2:x) = par*P(t-1,1:x-1);
    end 
    % left
    if left == 1
        P = fliplr(P);
    end

end
