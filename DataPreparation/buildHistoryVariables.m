function [names, arrays] = buildHistoryVariables(name, array, array_time, target_time)
    % build 60 new arraies and build a n x 61 2d array that, n = length of
    % target_time
    n = length(target_time);
    arrays = zeros(n, 61);
    
    % build lagged variables
    for lag = 0:60
        arrays(:, lag + 1) = interp1(array_time, array, target_time - minutes(5 * lag), 'linear');
    end

    % build names for each array
    lags = 1:60;
    toAppend = arrayfun(@(x) sprintf('%s-lagged-by-%d-minutes', name, x), lags * 5, 'UniformOutput', false);
    names = string([name, toAppend]);

end