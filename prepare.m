close all; clear; clc;

load('/Users/xliu/UTD/perturbation/data/original-data.mat');

% get density value.
density = 10.^(original_data.full_log_den);
density_lower_bond = 10.^(original_data.full_log_den_down);
density_upper_bond = 10.^(original_data.full_log_den_upper);

% original data
t = original_data.full_epoches;
mlat = original_data.full_mlat;
xeq = original_data.full_xeq;
yeq = original_data.full_yeq;

% coordinates
[theta, rho] = cart2pol(xeq, yeq);
cs = cos(theta);
sn = sin(theta);

% calculate the perturbation.
 perturbation = 2 * (density_upper_bond - density_lower_bond)./(density_upper_bond + density_lower_bond);

% interporlation on the omni data.
ae_index = interp1(original_data.partial_epoches, ...
    original_data.partial_ae_index, ...
    original_data.full_epoches);

sym_h = interp1(original_data.partial_epoches, ...
    original_data.partial_sym_h, ...
    original_data.full_epoches);

% lag data by 60 days to create 60 new variables for sym_h and ae_index
[ae_names, ae_variables] = buildTimeSeries('ae_index', ae_index);
[symh_names, symh_variables] = buildTimeSeries('sym_h', sym_h);

% cut 60 rows for all other input variables
t = t(1: end - 60);
mlat = mlat(1: end - 60);
cs = cs(1: end - 60);
sn = sn(1: end - 60);
rho = rho(1: end - 60);
den = original_data.full_log_den(1: end - 60);


% build variable names
variable_names = ["time", "mlat", "cos", "sin", "rho", ae_names, symh_names, "density"];
variable_name_cells = cellstr(variable_names);

% put into table
matrix = [t', mlat', cs', sn', rho', ae_variables, symh_variables, den'];
table = array2table(matrix, 'VariableNames', variable_name_cells);

% use sub selected data to reduce data size.
selection_rate = 1/1000;
sz = length(t);
row_indexes = randperm(sz, int32(sz*selection_rate));
subtable = table(row_indexes, :);

% save data
writetable(subtable, 'den_dataf1000.csv', 'WriteVariableNames', true);