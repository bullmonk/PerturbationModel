function[fig, window_idx] = getNextFigure(window_idx, name)
    [left, bottom, width, height] = getWindowPanel(window_idx);
    fig = figure('Name', name, 'Position', [left bottom width height]);
    window_idx = window_idx + 1;
end