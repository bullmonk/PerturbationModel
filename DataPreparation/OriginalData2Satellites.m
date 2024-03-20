close all; clear;

%% do we plot?
doPlot = true;
window_idx = 1;

%% load original data
original_data = load('./data/original-data.mat', "-mat", "original_data").original_data;

%% original data densities
log_density = original_data.full_log_den;
density = 10.^(log_density);
density_lower_bond = 10.^(original_data.full_log_den_down);
density_upper_bond = 10.^(original_data.full_log_den_upper);


% original data time and coordinates that matching the densities
t = original_data.full_epoches; % time in epoch units
time = datetime(t, 'convertfrom', 'datenum', 'Format', 'MM/dd/yy HH:mm:ss.SSSSSSSSS');
mlat = original_data.full_mlat;
xeq = original_data.full_xeq;
yeq = original_data.full_yeq;

% coordinates converted to polar coordinate
[theta, rho] = cart2pol(xeq, yeq);
cs = cos(theta);
sn = sin(theta);

%% plot time and its corresponding density data
if doPlot
    plot_name = "given time series for density data";
    [fig, window_idx] = getNextFigure(window_idx, plot_name);
    figure(fig)
    tiledlayout(2, 1)
    ax1 = nexttile;
    plot(time, '.', 'MarkerSize', 3);
    title(ax1, 'original time data');
    xlabel(ax1, 'index');
    ylabel(ax1, 'time');
    ax2 = nexttile;
    plot(time, log_density, '.', 'MarkerSize', 3);
    title(ax2, 'density data - time plot');
    xlabel(ax2, 'time');
    ylabel(ax2,'density');
end

%% not sorted by time
% find the time of last data from 1st satellite.
idx = find(diff(time) < 0);

% split 2 satellites
satellite1.t = t(1:idx);
satellite1.time = time(1:idx);
satellite1.mlat = mlat(1:idx);
satellite1.xeq = xeq(1:idx);
satellite1.yeq = yeq(1:idx);
satellite1.cs = cs(1:idx);
satellite1.sn = sn(1:idx);
satellite1.log_density = log_density(1:idx);
satellite1.density = density(1:idx);
satellite1.density_lower_bond = density_lower_bond(1:idx);
satellite1.density_upper_bond = density_upper_bond(1:idx);

satellite2.t = t(idx+1:end);
satellite2.time = time(idx+1:end);
satellite2.mlat = mlat(idx+1:end);
satellite2.xeq = xeq(idx+1:end);
satellite2.yeq = yeq(idx+1:end);
satellite2.cs = cs(idx+1:end);
satellite2.sn = sn(idx+1:end);
satellite2.log_density = log_density(idx+1:end);
satellite2.density = density(idx+1:end);
satellite2.density_lower_bond = density_lower_bond(idx+1:end);
satellite2.density_upper_bond = density_upper_bond(idx+1:end);

%% check separated result
if doPlot
    plot_name = "sorted time series and density for satellite 1";
    [fig, window_idx] = getNextFigure(window_idx, plot_name);
    figure(fig)
    tiledlayout(2, 1)
    ax1 = nexttile;
    plot(satellite1.time, '.', 'MarkerSize', 3);
    title(ax1, 'sorted time series from original time data');
    xlabel(ax1, 'index');
    ylabel(ax1, 'time');
    ax2 = nexttile;
    plot(satellite1.time, satellite1.log_density, '.', 'MarkerSize', 3);
    title(ax2, 'density data - time plot to make sure same relative order');
    xlabel(ax2, 'time');
    ylabel(ax2,'density');
    
    plot_name = "sorted time series and density for satellite 2";
    [fig, window_idx] = getNextFigure(window_idx, plot_name);
    figure(fig)
    tiledlayout(2, 1)
    ax1 = nexttile;
    plot(satellite2.time, '.', 'MarkerSize', 3);
    title(ax1, 'sorted time series from original time data');
    xlabel(ax1, 'index');
    ylabel(ax1, 'time');
    ax2 = nexttile;
    plot(satellite2.time, satellite2.log_density, '.', 'MarkerSize', 3);
    title(ax2, 'density data - time plot to make sure same relative order');
    xlabel(ax2, 'time');
    ylabel(ax2,'density');
end

%% save
save("./data/satellite1.mat", "satellite1", "-v7.3");
save("./data/satellite2.mat", "satellite2", "-v7.3");