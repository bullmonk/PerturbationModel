function [names, arrays] = buildTimeSeries(name, array)
    arrays = zeros(length(array), 61);
    for lag = 0:60
        arrays(:, lag + 1) = circshift(array, -1 * lag);
    end
    arrays = arrays(1:end-60, :);

    lags = 1:60;
    toAppend = arrayfun(@(x) sprintf('%s_lagged_by_%d_days', name, x), lags, 'UniformOutput', false);
    names = string([name, toAppend]);

end