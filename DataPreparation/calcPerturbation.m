function [perturbation, background] = calcPerturbation(density, time, windowSize, validGroupCount)
    delta = min(diff(time));
    neighborRange = ceil((windowSize / delta + 1) / 2);

    dgrp = zeros(2 * neighborRange + 1, length(density));
    dgrp(1,:) = density;
    dleft = density;
    dright = density;

    tgrp = NaT(2 * neighborRange + 1, length(density));
    tgrp(1,:) = time;
    tleft = time;
    tright = time;

    for i = 1:neighborRange
        dleft = [NaN dleft(1:end - 1)];
        dright = [dright(2:end) NaN];
        dgrp(2 * i, :) = dleft;
        dgrp(2 * i + 1, :) = dright;

        tleft = [NaT tleft(1:end - 1)];
        tright = [tright(2:end) NaT];
        tgrp(2 * i, :) = tleft;
        tgrp(2 * i + 1, :) = tright;
    end

    tgrpDif = tgrp - tgrp(1,:);
    toDelete = isnan(tgrpDif) | abs(tgrpDif) > windowSize / 2;
    dgrp(toDelete) = NaN;


    perturbation = std(dgrp, 0, 1, "omitmissing");
    background = mean(dgrp, 1, "omitmissing");
    % apply valid group count, only window with more than validGroupCount
    % data will get perturbation calculated.
    omitted = sum(~isnan(perturbation), 1) > validGroupCount;
    perturbation(omitted) = NaN;
    background(omitted) = NaN;
end