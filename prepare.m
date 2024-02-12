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

% calculate the perturbation.
 perturbation = 2 * (density_upper_bond - density_lower_bond)./(density_upper_bond + density_lower_bond);

% interporlation on the omni data.
ae_index = interp1(original_data.partial_epoches, ...
    original_data.partial_ae_index, ...
    original_data.full_epoches);

sym_h = interp1(original_data.partial_epoches, ...
    original_data.partial_sym_h, ...
    original_data.full_epoches);

% collect into table.
variable_names = {'time', 'mlat', 'cos', 'sin', 'rho', 'ae_index', 'sym_h', 'perturbation'};
[theta, rho] = cart2pol(xeq, yeq);
cs = cos(theta);
sn = sin(theta);

table = table(t', mlat', cs', sn', rho', ...
    ae_index', sym_h', ...
    perturbation', 'VariableNames', variable_names);

% use sub selected data to reduce data size.
selection_rate = 1/1000;
sz = length(t);
row_indexes = randperm(sz, int32(sz*selection_rate));
subtable = table(row_indexes, :);

% writetable(subtable, 'dataf1000.csv', 'WriteVariableNames', true);