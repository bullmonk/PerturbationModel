function[fig, window_idx] = get_next_figure(window_idx, name)
    [left, bottom, width, height] = get_window_panel(window_idx);
    fig = figure('Name', name, 'Position', [left bottom width height]);
    window_idx = window_idx + 1;
end