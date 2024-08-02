function Q = calculateFWHM(Q)

    x = (1:Q.numCoefficients)*1000/Q.updateRate; % get x axis (-t in ms)
    Q.coefficientsFilteredNormalized = Q.coefficientsFiltered/max(Q.coefficientsFiltered); % filtered then normalized coefficients
    Q.coefficientsNormalized = Q.coefficients/max(Q.coefficients); % just normalized coefficients

    Q.fwhmFilteredNormalized = calculate(x,Q.coefficientsFilteredNormalized);
    Q.fwhmNormalized = calculate(x,Q.coefficientsNormalized);

end

function fwhm = calculate(x,coefficients)

    % interpolate
    index1 = find(coefficients > 0.5,1)-1;
    index2 = find(coefficients > 0.5,1,'last');

    % first intersection
    p = polyfit([x(index1) x(index1+1)],[coefficients(index1) coefficients(index1+1)],1);
    x1 = (0.5 - p(2))/p(1);

    % second intersection
    p = polyfit([x(index2) x(index2+1)],[coefficients(index2) coefficients(index2+1)],1);
    x2 = (0.5 - p(2))/p(1);

   fwhm = x2-x1;

end