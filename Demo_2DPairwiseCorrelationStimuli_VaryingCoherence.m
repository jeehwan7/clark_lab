x = 100; % width
t = 100; % number of rows (time)

figure;

counter = 1;
for coherence = 0.25:0.25:1
    P = pairwise(0, x, t, coherence);
    subplot(2,2,counter);
    imagesc(P);
    title(['coherence: ',num2str(coherence)]);
    counter = counter + 1;
end

sgtitle('Pairwise Correlation Stimuli with Varying Coherence (x vs. t)')

function P = pairwise(left, x, y, coherence)
    
    % first row
    P(1,:) = (zeros(1,x)-1).^(randi([0 1],[1,x]));
    
    % right
    for t = 2:y
        P(t,1) = (-1)^(randi(2)-1);
        P(t,2:x) = P(t-1,1:x-1);
        indexRandom = randperm(x-1,x-1-round((x-1)*coherence))+1;
        P(t,indexRandom) = 2*(rand(1,size(indexRandom,2))>0.5)-1;
    end
    
    % left
    if left == 1
        P = fliplr(P);
    end

end
