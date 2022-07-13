function prightbyType = createPrightbyType(responses, directions, types, parities)

    responsesEdited = responses;
    % symmetrize
    responsesEdited(directions == -1) = -responsesEdited(directions == -1);
    % turn all -1's and NaN's into 0's
    responsesEdited(responsesEdited == -1) = 0;
    responsesEdited(isnan(responsesEdited)) = 0;

    cp = mean(responsesEdited(intersect(find(convertCharsToStrings(types) == "converging"),find(parities == 1))));
    cn = mean(responsesEdited(intersect(find(convertCharsToStrings(types) == "converging"),find(parities == -1))));
    dp = mean(responsesEdited(intersect(find(convertCharsToStrings(types) == "diverging"),find(parities == 1))));
    dn = mean(responsesEdited(intersect(find(convertCharsToStrings(types) == "diverging"),find(parities == -1))));
    
    x = {'conv, +','conv, -','div, +','div, -'};
    y = [cp cn dp dn];

    figure;
    bar(y);
    title('P(right)');
    yline(0.5,'--');
    xlabel('Type');
    ylabel('P(right)');
    xticklabels(x);

    prightbyType = strings(2,4);
    prightbyType(1,:) = convertCharsToStrings(x);
    prightbyType(2,:) = string(y);

end