function Q = plotTypeMeanEyeVelocity(Q)

    x = cellstr(Q.typeMeanEyeVelocityTriple.Type);
    y = Q.typeMeanEyeVelocityTriple.("Mean Eye Velocity");

    sem = Q.typeMeanEyeVelocityTriple.SEM;

    figure;
    bar(y);
    title('Triple');
    xlabel('type');
    ylabel('mean eye velocity per type (deg/s)');
    xticklabels(x);
    hold on
    er = errorbar(y,sem);
    er.Color = [0 0 0];
    er.LineStyle = 'none';
    hold off

end