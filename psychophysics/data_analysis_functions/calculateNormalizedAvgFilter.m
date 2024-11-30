clear

F = struct();

ii = 1;
for corrTime = [0 17 33 50 100 200 400]

    fileName = ['Q/',num2str(corrTime),'ms.mat'];
    load(fileName,'Q');

    F(ii).corrTime = corrTime;
    F(ii).filter = Q.coefficients;

    ii = ii + 1;

end

f = sum([F(:).filter],2)/length(F); % mean filter
f = f/norm(f); % normalized mean filter

