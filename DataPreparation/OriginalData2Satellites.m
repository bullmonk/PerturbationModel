close all; clear;

%% run param
% do we plot?
doPlot = true;
window_idx = 1;

% do we save?
doSave = false;

% save subset?
saveSubset = true;
fractionDenominator = 1000;

%% load original data
data = load('./data/ab_den_envelope.mat', "-mat");
data.datetime = data.datetime_den;
data = rmfield(data, "datetime_den");

data = OriginalData2SatellitesHelper(data, OriginalData2SatellitesHelperOperation.Cleanup);
data = OriginalData2SatellitesHelper(data, OriginalData2SatellitesHelperOperation.GetSatellite, satellite_id=1);

%% original data densities
% density = 10.^(log_density);


%% basic analytic check
% plot time and its corresponding density data
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
    ax2 = nexttile;
    plot(data.datetime, log10(data.density), '.', 'MarkerSize', 3);
    title(ax2, 'density data - time plot');
    xlabel(ax2, 'time');
    ylabel(ax2,'density');
end

%% 2 satellites' data found
% find the time of last data from 1st satellite.
idx = find(diff(time) < 0);

% split 2 satellites
satellite1.t = t(1:idx);
satellite1.time = time(1:idx);
satellite1.mlat = mlat(1:idx);
satellite1.xeq = xeq(1:idx);
satellite1.yeq = yeq(1:idx);
satellite1.cos = cs(1:idx);
satellite1.sin = sn(1:idx);
satellite1.rho = rho(1:idx);
satellite1.theta = theta(1:idx);
satellite1.log_density = log_density(1:idx);
satellite1.density = density(1:idx);
satellite1.density_lower_bond = density_lower_bond(1:idx);
satellite1.density_upper_bond = density_upper_bond(1:idx);
[satellite1.perturbation, satellite1.background] = calcPerturbation(satellite1.density, satellite1.time, minutes(2), 10);
satellite1.normalized_perturbation = satellite1.perturbation ./ satellite1.background;

satellite2.t = t(idx+1:end);
satellite2.time = time(idx+1:end);
satellite2.mlat = mlat(idx+1:end);
satellite2.xeq = xeq(idx+1:end);
satellite2.yeq = yeq(idx+1:end);
satellite2.rho = rho(idx+1:end);
satellite2.theta = theta(idx+1:end);
satellite2.cos = cs(idx+1:end);
satellite2.sin = sn(idx+1:end);
satellite2.log_density = log_density(idx+1:end);
satellite2.density = density(idx+1:end);
satellite2.density_lower_bond = density_lower_bond(idx+1:end);
satellite2.density_upper_bond = density_upper_bond(idx+1:end);
[satellite2.perturbation, satellite2.background] = calcPerturbation(satellite2.density, satellite2.time, minutes(2), 10);
satellite2.normalized_perturbation = satellite2.perturbation ./ satellite2.background;

clear t time mlat xeq yeq cs sn log_density density density_lower_bond density_upper_bond

if doPlot
    plot_name = "satellite 1";
    [fig, window_idx] = getNextFigure(window_idx, plot_name);
    figure(fig)
    tiledlayout(3, 1)
    ax1 = nexttile;
    plot(satellite1.time, '.', 'MarkerSize', 3);
    title(ax1, 'time');
    xlabel(ax1, 'index');
    ylabel(ax1, 'time');
    ax2 = nexttile;
    plot(satellite1.time, satellite1.log_density, '.', 'MarkerSize', 3);
    title(ax2, 'log density - time');
    xlabel(ax2, 'time');
    ylabel(ax2,'log density');
    ax3 = nexttile;
    plot(satellite1.time, satellite1.normalized_perturbation, '.', 'MarkerSize', 3);
    title(ax3, 'density perturbation (windowed standard deviation) - time');
    xlabel(ax3, 'time');
    ylabel(ax3,'density perturbation');
    
    plot_name = "satellite 2";
    [fig, window_idx] = getNextFigure(window_idx, plot_name);
    figure(fig)
    tiledlayout(3, 1)
    ax1 = nexttile;
    plot(satellite2.time, '.', 'MarkerSize', 3);
    title(ax1, 'time');
    xlabel(ax1, 'index');
    ylabel(ax1, 'time');
    ax2 = nexttile;
    plot(satellite2.time, satellite2.log_density, '.', 'MarkerSize', 3);
    title(ax2, 'log density - time');
    xlabel(ax2, 'time');
    ylabel(ax2,'log density');
    ax3 = nexttile;
    plot(satellite2.time, satellite2.normalized_perturbation, '.', 'MarkerSize', 3);
    title(ax3, 'density perturbation (windowed standard deviation) - time');
    xlabel(ax3, 'time');
    ylabel(ax3,'density perturbation');
end

%% fetch omni data: ae_index and sym_h, fetched and interpolated
omni_t = data.partial_epoches;
omni_time = datetime(omni_t, 'convertfrom', 'datenum', 'Format', 'MM/dd/yy HH:mm:ss.SSSSSSSSS');
ae_index = data.partial_ae_index;
sym_h = data.partial_sym_h;

% plot and check omini data time
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
end

%% lag data by 60 days to create 60 new variables for sym_h and ae_index
[ae_names, satellite1.ae_variables] = buildHistoryVariables('ae\_index', ae_index, omni_time, satellite1.time);
[symh_names, satellite1.symh_variables] = buildHistoryVariables('sym\_h', sym_h, omni_time, satellite1.time);
satellite1.variable_names = ["mlat", "cos", "sin", "rho", "theta", ae_names, symh_names, "density", "log_density", "perturbation", "norm_perturbation"];

[ae_names, satellite2.ae_variables] = buildHistoryVariables('ae_index', ae_index, omni_time, satellite2.time);
[symh_names, satellite2.symh_variables] = buildHistoryVariables('sym_h', sym_h, omni_time, satellite2.time);
satellite2.variable_names = ["mlat", "cos", "sin", "rho", "theta", ae_names, symh_names, "density", "log_density", "perturbation", "norm_perturbation"];

clear ae_names symh_names

% plot and check lagged data correctness.
if doPlot
    % satellite 1 sym_h
    plot_name = "first 3 lagged sym_h data";
    [fig, ~] = getNextFigure(window_idx, plot_name);
    figure(fig)
    tiledlayout(3, 1)
    ax1 = nexttile;
    plot(satellite1.time, satellite1.symh_variables(:, 2)', '.', 'MarkerSize', 3);
    title(ax1, 'sym\_h data lagged by 5 mins and align with density data');
    xlabel(ax1, 'index');
    xlim([satellite1.time(1) satellite1.time(1) + minutes(60)]);
    ylabel(ax1, 'sym\_h');   
    ax2 = nexttile;
    plot(satellite1.time, satellite1.symh_variables(:, 3)', '.', 'MarkerSize', 3);
    title(ax2, 'sym\_h data lagged by 10 mins and align with density data');
    xlabel(ax2, 'index');
    xlim([satellite1.time(1) satellite1.time(1) + minutes(60)]);
    ylabel(ax2, 'sym\_h');
    ax3 = nexttile;
    plot(satellite1.time, satellite1.symh_variables(:, 4)', '.', 'MarkerSize', 3);
    title(ax3, 'sym\_h data lagged by 15 mins and align with density data');
    xlabel(ax3, 'index');
    xlim([satellite1.time(1) satellite1.time(1) + minutes(60)]);
    ylabel(ax3, 'sym\_h');

    % satellite 2 sym_h
    plot_name = "first 3 lagged sym_h data";
    [fig, ~] = getNextFigure(window_idx, plot_name);
    figure(fig)
    tiledlayout(3, 1)
    ax1 = nexttile;
    plot(satellite1.time, satellite1.symh_variables(:, 2)', '.', 'MarkerSize', 3);
    title(ax1, 'sym\_h data lagged by 5 mins and align with density data');
    xlabel(ax1, 'index');
    xlim([satellite1.time(1) satellite1.time(1) + minutes(60)]);
    ylabel(ax1, 'sym\_h');   
    ax2 = nexttile;
    plot(satellite1.time, satellite1.symh_variables(:, 3)', '.', 'MarkerSize', 3);
    title(ax2, 'sym\_h data lagged by 10 mins and align with density data');
    xlabel(ax2, 'index');
    xlim([satellite1.time(1) satellite1.time(1) + minutes(60)]);
    ylabel(ax2, 'sym\_h');
    ax3 = nexttile;
    plot(satellite1.time, satellite1.symh_variables(:, 4)', '.', 'MarkerSize', 3);
    title(ax3, 'sym\_h data lagged by 15 mins and align with density data');
    xlabel(ax3, 'index');
    xlim([satellite1.time(1) satellite1.time(1) + minutes(60)]);
    ylabel(ax3, 'sym\_h');
end

matrix1 = [satellite1.mlat', satellite1.cos', satellite1.sin', satellite1.rho',...
    satellite1.theta', satellite1.ae_variables, satellite1.symh_variables, ...
    satellite1.density', satellite1.log_density', satellite1.perturbation', ...
    satellite1.normalized_perturbation'];
idx = find(satellite1.normalized_perturbation >= 0.01 & satellite1.normalized_perturbation <= 0.3);
matrix1 = matrix1(idx, :);
nanRows = any(isnan(matrix1), 2);
matrix1 = matrix1(~nanRows, :);
satellite1_table = array2table(matrix1, 'VariableNames', satellite1.variable_names);

matrix2 = [satellite2.mlat', satellite2.cos', satellite2.sin', satellite2.rho', ...
    satellite2.theta', satellite2.ae_variables, satellite2.symh_variables, ...
    satellite2.density', satellite2.log_density', satellite2.perturbation', ...
    satellite2.normalized_perturbation'];
nanRows = any(isnan(matrix2), 2);
matrix2 = matrix2(~nanRows, :);
satellite2_table = array2table(matrix2, 'VariableNames', satellite2.variable_names);

if saveSubset
    sz = size(matrix1, 1);
    row_indexes = randperm(sz, int32(sz/fractionDenominator));
    subtable = satellite1_table(row_indexes, :);
    satellite1_table = subtable;
    clear sz row_indexes subtable

    sz = size(matrix2, 1);
    row_indexes = randperm(sz, int32(sz/fractionDenominator));
    subtable = satellite2_table(row_indexes, :);
    satellite2_table = subtable;
    clear sz row_indexes subtable

end

%% save
if doSave
    save_path = '../ModelTraining/data/';
    file1 = [save_path 'satellite1_' num2str(fractionDenominator) '.csv'];
    file2 = [save_path 'satellite2_' num2str(fractionDenominator) '.csv'];

    writetable(satellite1_table, file1, 'WriteVariableNames', true);
    writetable(satellite2_table, file2, 'WriteVariableNames', true);
end