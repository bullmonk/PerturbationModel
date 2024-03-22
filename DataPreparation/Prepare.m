close all; clear;

%% do we plot?
doPlot = false;
window_idx = 1;

%% which satellite?
which_satellite = 1;

%% randome subset?
doSubset = true;
fractionDenominator = 1000;


%% load density data
satellite1 = load('./data/satellite1.mat', "-mat", "satellite1").satellite1;
satellite2 = load('./data/satellite2.mat', "-mat", "satellite2").satellite2;

satellites = [satellite1 satellite2];
clear satellite1 satellite2
satellite = satellites(which_satellite);
clear satellites which_satellite

%% unpack satellite data
t = satellite.t;
time = satellite.time;
mlat = satellite.mlat;
xeq = satellite.xeq;
yeq = satellite.yeq;
cosin = satellite.cs;
sin = satellite.sn;
log_density = satellite.log_density;
density = satellite.density;
density_lower_bond = satellite.density_lower_bond;
density_upper_bond = satellite.density_upper_bond;
perturbation = satellite.normalized_perturbation;

%% fetch omni data: ae_index and sym_h, fetched and interpolated
% omni_t = original_data.partial_epoches;
% omni_time = datetime(omni_t, 'convertfrom', 'datenum', 'Format', 'MM/dd/yy HH:mm:ss.SSSSSSSSS');
% ae_index = original_data.partial_ae_index;
% sym_h = original_data.partial_sym_h;
% 
% % plot and check omini data time
% if doPlot
%     plot_name = "omni data time";
%     [fig, window_idx] = get_next_figure(window_idx, plot_name);
%     figure(fig)
%     tiledlayout(3, 1)
%     ax1 = nexttile;
%     plot(omni_time, '.', 'MarkerSize', 3);
%     title(ax1, 'time series from original omni data');
%     xlabel(ax1, 'index');
%     ylabel(ax1, 'time');
%     ax2 = nexttile;
%     plot(omni_time, ae_index, '.', 'MarkerSize', 3);
%     title(ax2, 'ae\_index data align with original time series');
%     xlabel(ax2, 'time');
%     ylabel(ax2, 'ae\_index');   
%     ax3 = nexttile;
%     plot(omni_time, sym_h, '.', 'MarkerSize', 3);
%     title(ax3, 'sym\_h data align with original time series');
%     xlabel(ax3, 'time');
%     ylabel(ax3, 'sym\_h');
%     % looks like it's in time order already
% end


% %% lag data by 60 days to create 60 new variables for sym_h and ae_index
% [ae_names, ae_variables] = buildHistoryVariables('ae_index', ae_index, omni_time, time);
% [symh_names, symh_variables] = buildHistoryVariables('sym_h', sym_h, omni_time, time);
% 
% % plot and check lagged data correctness.
% if doPlot
%     plot_name = "first 3 lagged sym_h data";
%     [fig, ~] = get_next_figure(window_idx, plot_name);
%     figure(fig)
%     tiledlayout(3, 1)
%     ax1 = nexttile;
%     plot(time, symh_variables(:, 2)', '.', 'MarkerSize', 3);
%     title(ax1, 'sym\_h data lagged by 5 mins and align with density data');
%     xlabel(ax1, 'index');
%     xlim([time(1) time(1) + minutes(60)]);
%     ylabel(ax1, 'sym\_h');
%     ax2 = nexttile;
%     plot(time, symh_variables(:, 3)', '.', 'MarkerSize', 3);
%     title(ax2, 'sym\_h data lagged by 10 mins and align with density data');
%     xlabel(ax2, 'index');
%     xlim([time(1) time(1) + minutes(60)]);
%     ylabel(ax2, 'sym\_h');
%     ax3 = nexttile;
%     plot(time, symh_variables(:, 4)', '.', 'MarkerSize', 3);
%     title(ax3, 'sym\_h data lagged by 15 mins and align with density data');
%     xlabel(ax3, 'index');
%     xlim([time(1) time(1) + minutes(60)]);
%     ylabel(ax3, 'sym\_h');
% end

% build variable names
variable_names = ["time", "mlat", "cos", "sin", "rho", ae_names, symh_names, "density", "log_density", "perturbation"];
variable_name_cells = cellstr(variable_names);
matrix = [t', mlat', cs', sn', rho', ae_variables, symh_variables, density', log_density', perturbation'];
% delete rows with NaN
nanRows = any(isnan(matrix), 2);
matrix = matrix(~nanRows, :);
% write results into table
table = array2table(matrix, 'VariableNames', variable_name_cells);

%% use sub selected data to reduce data size.
if doSubset
    sz = size(matrix, 1);
    row_indexes = randperm(sz, int32(sz/fractionDenominator));
    subtable = table(row_indexes, :);
    table = subtable;
    clear subtable;
end

%% save data
filename = ['../ModelTraining/data/data' num2str(fractionDenominator) '.csv'];
writetable(table, filename, 'WriteVariableNames', true);