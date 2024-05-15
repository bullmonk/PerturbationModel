function[fig, window_idx] = getNextFigure(window_idx, name, varargin)
    ip = inputParser;
    addRequired(ip, 'window_idx');
    addRequired(ip, 'name');
    addParameter(ip, 'wCut', 3);
    addParameter(ip, 'hCut', 3);
    parse(ip, window_idx, name, varargin{:});

    [left, bottom, width, height] = getWindowPanel(window_idx, 'wCut', ip.Results.wCut, 'hCut', ip.Results.hCut);
    fig = figure('Name', name, 'Position', [left bottom width height]);
    window_idx = window_idx + 1;
end