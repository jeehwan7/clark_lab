function prightbyCoherence = prightbyCoherence(responses, coherences, directions)

    % turn all -1's and NaN's into 0's
    responsesEdited = responses;
    responsesEdited(responsesEdited == -1) = 0;
    responsesEdited(isnan(responsesEdited)) = 0;
    
    prightbyCoherence = zeros(21,2);
    prightbyCoherence(:,2) = -1.0:0.1:1.0;
    
    nn = 1; % MATLAB sucks when dealing with decimals
    for k = -1:0.1:1
        if k ~= 0
            indexDirection = find(directions == sign(k));
            indexCoherence = find(coherences == abs(round(k,1)));
            indexFinal = intersect(indexDirection,indexCoherence);
        elseif k == 0
            indexFinal = find(coherences == 0);
        end
        prightbyCoherence(nn,1) = mean(responsesEdited(indexFinal));
        nn = nn+1;
    end
    
    figure;
    scatter(prightbyCoherence(:,2),prightbyCoherence(:,1));
    title('P(right)');
    yline(0.5,'--');
    xlabel('Coherence');
    ylabel('P(right)');

end