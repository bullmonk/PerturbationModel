function[left, bottom, width, height] = get_window_panel(i)
row = mod(i - 1, 3);
col = mod(fix((i - 1)/3), 3);
screen_size = get(groot, 'ScreenSize');
width = screen_size(3)/3;
height = screen_size(4)/3;
left = 1 + width * row;
bottom = 1 + height * col;
end