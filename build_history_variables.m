function [names, arrays] = build_history_variables(name, array, times)
    % build 60 new arraies and build a n x 61 2d array that using original
    % array as the first column.
    arrays = zeros(length(array), 61);
    for lag = 0:60
        arrays(:, lag + 1) = circshift(array, -1 * lag);
    end
    arrays = arrays(1:end-60, :);

    % build names for each array
    lags = 1:60;
    toAppend = arrayfun(@(x) sprintf('%s_lagged_by_%d_days', name, x), lags, 'UniformOutput', false);
    names = string([name, toAppend]);

end