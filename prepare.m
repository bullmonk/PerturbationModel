close all; clear; clc;

load('/Users/xliu/UTD/perturbation/data/original-data.mat');

% get density value.
density = 10.^(original_data.full_log_den);
density_lower_bond = 10.^(original_data.full_log_den_down);
density_upper_bond = 10.^(original_data.full_log_den_upper);

% calculate the perturbation.
perturbation = density_upper_bond - density_lower_bond;

% interporlation on the omni data.
ae_index = interp1(original_data.partial_epoches, ...
    original_data.partial_ae_index, ...
    original_data.full_epoches);

sym_h = interp1(original_data.partial_epoches, ...
    original_data.partial_sym_h, ...
    original_data.full_epoches);