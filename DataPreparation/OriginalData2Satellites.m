close all;

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
window_idx = 1;
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
plot_name = "sorted time series and density for density data";
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

%% fetch omni data: ae_index and sym_h, fetched and interpolated
omni_t = original_data.partial_epoches;
omni_time = datetime(omni_t, 'convertfrom', 'datenum', 'Format', 'MM/dd/yy HH:mm:ss.SSSSSSSSS');
ae_index = original_data.partial_ae_index;
sym_h = original_data.partial_sym_h;

% plot and check omini data time
plot_name = "omni data time";
[fig, window_idx] = get_next_figure(window_idx, plot_name);
figure(fig)
tiledlayout(3, 1)
ax1 = nexttile;
plot(omni_time, '.', 'MarkerSize', 3);
title(ax1, 'time series from original omni data');
xlabel(ax1, 'index');
ylabel(ax1, 'time');
ax2 = nexttile;
plot(omni_time, ae_index, '.', 'MarkerSize', 3);
title(ax2, 'ae\_index data align with original time series');
xlabel(ax2, 'time');
ylabel(ax2, 'ae\_index');   
ax3 = nexttile;
plot(omni_time, sym_h, '.', 'MarkerSize', 3);
title(ax3, 'sym\_h data align with original time series');
xlabel(ax3, 'time');
ylabel(ax3, 'sym\_h');
% looks like it's in time order already


% lag data by 60 days to create 60 new variables for sym_h and ae_index
[ae_names, ae_variables] = build_history_variables('ae_index', ae_index, omni_time, time);
[symh_names, symh_variables] = build_history_variables('sym_h', sym_h, omni_time, time);

% plot and check lagged data correctness.
plot_name = "first 3 lagged sym_h data";
[fig, ~] = get_next_figure(window_idx, plot_name);
figure(fig)
tiledlayout(3, 1)
ax1 = nexttile;
plot(time, symh_variables(:, 2)', '.', 'MarkerSize', 3);
title(ax1, 'sym\_h data lagged by 5 mins and align with density data');
xlabel(ax1, 'index');
xlim([time(1) time(1) + minutes(60)]);
ylabel(ax1, 'sym\_h');
ax2 = nexttile;
plot(time, symh_variables(:, 3)', '.', 'MarkerSize', 3);
title(ax2, 'sym\_h data lagged by 10 mins and align with density data');
xlabel(ax2, 'index');
xlim([time(1) time(1) + minutes(60)]);
ylabel(ax2, 'sym\_h');
ax3 = nexttile;
plot(time, symh_variables(:, 4)', '.', 'MarkerSize', 3);
title(ax3, 'sym\_h data lagged by 15 mins and align with density data');
xlabel(ax3, 'index');
xlim([time(1) time(1) + minutes(60)]);
ylabel(ax3, 'sym\_h');

% build variable names
variable_names = ["time", "mlat", "cos", "sin", "rho", ae_names, symh_names, "density", "log_density", "perturbation"];
variable_name_cells = cellstr(variable_names);
matrix = [t', mlat', cs', sn', rho', ae_variables, symh_variables, density', log_density', perturbation'];
% delete rows with NaN
nanRows = any(isnan(matrix), 2);
matrix = matrix(~nanRows, :);
% write results into table
table = array2table(matrix, 'VariableNames', variable_name_cells);

% use sub selected data to reduce data size.
selection_rate = 1/1000;
sz = size(matrix, 1);
row_indexes = randperm(sz, int32(sz*selection_rate));
subtable = table(row_indexes, :);

% save data
writetable(subtable, 'dataf1000.csv', 'WriteVariableNames', true);