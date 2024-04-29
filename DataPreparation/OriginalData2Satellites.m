close all; clear;

%% run param
% do we plot?
doPlot = true;
window_idx = 1;

% do we save?
doSave = true;

% save subset?
saveSubset = true;
fractionDenominator = 100;

%% load satellite data
data = load('./data/ab_den_envelope.mat', "-mat");
data.datetime = data.datetime_den;
data = rmfield(data, "datetime_den");

data = OriginalData2SatellitesHelper(data, OriginalData2SatellitesHelperOperation.Cleanup);
data = OriginalData2SatellitesHelper(data, OriginalData2SatellitesHelperOperation.GetSatellite, satellite_id=1);

%% Complementory variables for machine learning model.
data.density_log10 = log10(data.density);
[data.perturbation, data.background] = calcPerturbation(data.density, data.datetime, minutes(2), 10);
data.normalized_perturbation = data.perturbation ./ data.background;

%% plot time and density data.
if doPlot
    plot_name = "given time series for density data";
    [fig, window_idx] = getNextFigure(window_idx, plot_name);
    figure(fig)
    tiledlayout(2, 1)
    ax1 = nexttile;
    plot(data.datetime, '.', 'MarkerSize', 3);
    title(ax1, 'original time data');
    xlabel(ax1, 'index');
    ylabel(ax1, 'time');
    ax1 = nexttile;
    plot(data.datetime, log10(data.density), '.', 'MarkerSize', 3);
    title(ax1, 'log_{10} density data - time plot');
    xlabel(ax1, 'time');
    ylabel(ax1,'density');
end

%% plot complementory variable - perturbation.
if doPlot
    plot_name = "perturbation plots";
    [fig, window_idx] = getNextFigure(window_idx, plot_name);
    figure(fig)
    plot(data.datetime, data.normalized_perturbation, '.', 'MarkerSize', 3);
    title('density perturbation (windowed standard deviation) - time');
    xlabel('time');
    ylabel('density perturbation');
end

%% fetch omni data: ae_index and sym_h, fetched and interpolated
omni = load('./data/original-data.mat', "-mat", "original_data").original_data;
omni_t = omni.partial_epoches;
omni_time = datetime(omni_t, 'convertfrom', 'datenum', 'Format', 'MM/dd/yy HH:mm:ss.SSSSSSSSS');
ae_index = omni.partial_ae_index;
sym_h = omni.partial_sym_h;
clear omni

%% plot and check omini data time
if doPlot
    plot_name = "omni data time";
    [fig, window_idx] = getNextFigure(window_idx, plot_name);
    figure(fig)
    tiledlayout(3, 1)
    ax1 = nexttile;
    plot(omni_time, '.', 'MarkerSize', 3);
    title(ax1, 'time series from original omni data');
    xlabel(ax1, 'index');
    ylabel(ax1, 'time');
    ax1 = nexttile;
    plot(omni_time, ae_index, '.', 'MarkerSize', 3);
    title(ax1, 'ae\_index data align with original time series');
    xlabel(ax1, 'time');
    ylabel(ax1, 'ae\_index');   
    ax2 = nexttile;
    plot(omni_time, sym_h, '.', 'MarkerSize', 3);
    title(ax2, 'sym\_h data align with original time series');
    xlabel(ax2, 'time');
    ylabel(ax2, 'sym\_h');
    % looks like it's in time order already
end

%% lag data by 60 days to create 60 new variables for sym_h and ae_index
[ae_names, data.ae_variables] = buildHistoryVariables('ae\_index', ae_index, omni_time, data.datetime);
[symh_names, data.symh_variables] = buildHistoryVariables('sym\_h', sym_h, omni_time, data.datetime);
data.variable_names = ["mlat", "mlt", "lshell", "rrr", ae_names, symh_names, "density", "density_log10", "perturbation", "perturbation_norm"];

clear ae_names symh_names

%% plot and check lagged data correctness.
if doPlot
    % symh plot
    plot_name = "first 3 lagged sym_h data";
    [fig, ~] = getNextFigure(window_idx, plot_name);
    figure(fig)
    tiledlayout(3, 1)
    ax1 = nexttile;
    plot(data.datetime, data.symh_variables(:, 2)', '.', 'MarkerSize', 3);
    title(ax1, 'sym\_h data lagged by 5 mins and align with density data');
    xlabel(ax1, 'index');
    xlim([data.datetime(1) data.datetime(1) + minutes(60)]);
    ylim([-20 -10]);
    ylabel(ax1, 'sym\_h');   
    ax2 = nexttile;
    plot(data.datetime, data.symh_variables(:, 3)', '.', 'MarkerSize', 3);
    title(ax2, 'sym\_h data lagged by 10 mins and align with density data');
    xlabel(ax2, 'index');
    xlim([data.datetime(1) data.datetime(1) + minutes(60)]);
    ylabel(ax2, 'sym\_h');
    ylim([-20 -10]);
    ax3 = nexttile;
    plot(data.datetime, data.symh_variables(:, 4)', '.', 'MarkerSize', 3);
    title(ax3, 'sym\_h data lagged by 15 mins and align with density data');
    xlabel(ax3, 'index');
    xlim([data.datetime(1) data.datetime(1) + minutes(60)]);
    ylim([-20 -10]);
    ylabel(ax3, 'sym\_h');
end

%% build table
matrix = [data.mlat', data.mlt', data.lshell', data.rrr',...
    data.ae_variables, data.symh_variables, ...
    data.density', data.density_log10', data.perturbation', ...
    data.normalized_perturbation'];
idx = find(data.normalized_perturbation >= 0.02 & data.normalized_perturbation <= 0.3);
matrix = matrix(idx, :);
nanRows = any(isnan(matrix), 2);
matrix = matrix(~nanRows, :);
tbl = array2table(matrix, 'VariableNames', data.variable_names);

%% subset
if saveSubset
    sz = size(matrix, 1);
    row_indexes = randperm(sz, int32(sz/fractionDenominator));
    subtable = tbl(row_indexes, :);
    tbl = subtable;
    clear sz row_indexes subtable
end

%% save
if doSave
    save_path = '../ModelTraining/data/';
    file = [save_path 'satellite_' num2str(fractionDenominator) '.csv'];
    writetable(tbl, file, 'WriteVariableNames', true);
end