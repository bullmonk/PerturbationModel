close all; clear; clc;

load('./data/original-data.mat');

% original data densities
density = 10.^(original_data.full_log_den);
density_lower_bond = 10.^(original_data.full_log_den_down);
density_upper_bond = 10.^(original_data.full_log_den_upper);

% original data time and coordinates that matching the densities
t = original_data.full_epoches; % time in epoch units
time = datetime(t, 'convertfrom', 'posixtime', 'Format', 'MM/dd/yy HH:mm:ss.SSSSSSSSS');
mlat = original_data.full_mlat;
xeq = original_data.full_xeq;
yeq = original_data.full_yeq;

% coordinates converted to polar coordinate
[theta, rho] = cart2pol(xeq, yeq);
cs = cos(theta);
sn = sin(theta);

% plot time and its corresponding density data
window_idx = 1;
plot_name = "given time series for density data";
[fig, window_idx] = get_next_figure(window_idx, plot_name);
figure(fig)
tiledlayout(2, 1)
nexttile;
plot(time);
nexttile;
plot(density);
% not sorted by time


% sort all variables above based on time
[~, sorted_order] = sort(time);
t = t(sorted_order);
mlat = mlat(sorted_order);
rho = rho(sorted_order);
cs = cs(sorted_order);
sn = sn(sorted_order);
time = time(sorted_order);
density = density(sorted_order);
density_lower_bond = density_lower_bond(sorted_order);
density_upper_bond = density_upper_bond(sorted_order);
clear sorted_order;

% check sort result
plot_name = "sorted time series and density for density data";
[fig, window_idx] = get_next_figure(window_idx, plot_name);
figure(fig)
tiledlayout(2, 1)
nexttile;
plot(time);
nexttile;
plot(density);


% calculate the perturbation
% perturbation = 2 * (density_upper_bond - density_lower_bond)./(density_upper_bond + density_lower_bond);

% fetch omni data: ae_index and sym_h, fetched and interpolated
omni_t = original_data.partial_epoches;
omni_time = datetime(omni_t, 'convertfrom', 'posixtime', 'Format', 'MM/dd/yy HH:mm:ss.SSSSSSSSS');
ae_index = original_data.partial_ae_index;
sym_h = original_data.partial_sym_h;

% plot and check omini data time
plot_name = "omni data time";
[fig, window_idx] = get_next_figure(window_idx, plot_name);
figure(fig)
tiledlayout(3, 1)
nexttile;
plot(omni_t);
nexttile;
plot(ae_index);
nexttile;
plot(sym_h);
% looks like it's in time order already


% lag data by 60 days to create 60 new variables for sym_h and ae_index
[ae_names, ae_variables] = build_history_variables('ae_index', ae_index, omni_time, time);
[symh_names, symh_variables] = build_history_variables('sym_h', sym_h, omni_time, time);

% plot and check lagged data correctness.
plot_name = "first 3 lagged sym_h data";
[fig, window_idx] = get_next_figure(window_idx, plot_name);
figure(fig)
tiledlayout(3, 1)
nexttile;
plot(symh_variables(:, 2)');
nexttile;
plot(symh_variables(:, 3)');
nexttile;
plot(symh_variables(:, 4)');

% build variable names
variable_names = ["time", "mlat", "cos", "sin", "rho", ae_names, symh_names, "density"];
variable_name_cells = cellstr(variable_names);
matrix = [t', mlat', cs', sn', rho', ae_variables, symh_variables, density'];
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
writetable(subtable, 'den_dataf1000.csv', 'WriteVariableNames', true);