function[left, bottom, width, height] = getWindowPanel(wIndex, varargin)

ip = inputParser;
addRequired(ip, 'wIndex');
addParameter(ip, 'wCut', 3);
addParameter(ip, 'hCut', 3);
parse(ip, wIndex, varargin{:});

row = mod(wIndex - 1, ip.Results.wCut);
col = mod(fix((wIndex - 1)/3), ip.Results.hCut);
screen_size = get(groot, 'ScreenSize');
width = screen_size(3)/ip.Results.wCut;
height = screen_size(4)/ip.Results.hCut;
left = 1 + width * row;
bottom = 1 + height * col;

end