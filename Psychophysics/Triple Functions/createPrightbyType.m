function prightbyType = createPrightbyType(responses, directions, types, parities)

    responsesSymmetrized = responses;
    % symmetrize
    responsesSymmetrized(directions == -1) = -responsesSymmetrized(directions == -1);
    % turn all -1's and NaN's into 0's
    responsesSymmetrized(responsesSymmetrized == -1) = 0;
    responsesSymmetrized(isnan(responsesSymmetrized)) = 0;

    cp = mean(responsesSymmetrized(intersect(find(convertCharsToStrings(types) == "converging"),find(parities == 1))));
    cn = mean(responsesSymmetrized(intersect(find(convertCharsToStrings(types) == "converging"),find(parities == -1))));
    dp = mean(responsesSymmetrized(intersect(find(convertCharsToStrings(types) == "diverging"),find(parities == 1))));
    dn = mean(responsesSymmetrized(intersect(find(convertCharsToStrings(types) == "diverging"),find(parities == -1))));
    
    x = {'conv, +','conv, -','div, +','div, -'};
    y = [cp cn dp dn];

    figure;
    bar(y);
    title('P(right) (Symmetrized)');
    yline(0.5,'--');
    xlabel('Type');
    ylabel('P(right)');
    xticklabels(x);
    ylim([0 1]);

    prightbyType = strings(2,4);
    prightbyType(1,:) = convertCharsToStrings(x);
    prightbyType(2,:) = string(y);

end