function [] = OriginalData2Satellites(dataBalance, saveSubset, fractionDenominator)
    ip = inputParser;
    addRequired(ip, 'saveSubset');
    addRequired(ip, 'dataBalance');
    addOptional(ip, 'fractionDenominator', 100);

    data_path = '../data/';

    % load and complete satellite data.
    data = load([data_path 'ab_den_envelope.mat'], "-mat");
    data.datetime = data.datetime_den;
    data = rmfield(data, "datetime_den"); % change field name from datetime_den to datetime.
    
    % initial data cleaning.
    data = OriginalData2SatellitesHelper(data, OriginalData2SatellitesHelperOperation.Cleanup);
    data = OriginalData2SatellitesHelper(data, OriginalData2SatellitesHelperOperation.GetSatellite, satellite_id=1);
    theta = (data.mlt / 24) * 2 * pi;
    data.cos = cos(theta);
    data.sin = sin(theta);
    
    clear theta

    % Calculate complementory variables for machine learning model.
    data.density_log10 = log10(data.density);
    [data.perturbation, data.background] = calcPerturbation(data.density, data.datetime, minutes(2), 10);
    data.normalized_perturbation = data.perturbation ./ data.background;

    % fetch omni data: ae_index and sym_h, fetched and interpolated
    omni = load([data_path 'original-data.mat'], "-mat", "original_data").original_data;
    omni_t = omni.partial_epoches;
    omni_time = datetime(omni_t, 'convertfrom', 'datenum', 'Format', 'MM/dd/yy HH:mm:ss.SSSSSSSSS');
    ae_index = omni.partial_ae_index;
    sym_h = omni.partial_sym_h;
    clear omni omni_t

    % lag data by 5 hours to create 60 new variables for sym_h and ae_index
    [ae_names, data.ae_variables] = buildHistoryVariables('ae\_index', ae_index, omni_time, data.datetime);
    [symh_names, data.symh_variables] = buildHistoryVariables('sym\_h', sym_h, omni_time, data.datetime);
    data.variable_names = ["mlat", "cos", "sin", "lshell", ae_names, symh_names, "density", "density_log10", "perturbation", "perturbation_norm"];

    clear ae_names symh_names omni_time sym_h ae_index

    % build table
    matrix = [data.mlat', data.cos', data.sin', data.lshell',...
        data.ae_variables, data.symh_variables, ...
        data.density', data.density_log10', data.perturbation', ...
        data.normalized_perturbation'];
    if dataBalance
        idx = data.normalized_perturbation >= 0.02 & data.normalized_perturbation <= 0.3;
        matrix = matrix(idx, :);
    end
    nanRows = any(isnan(matrix), 2);
    matrix = matrix(~nanRows, :);
    tbl = array2table(matrix, 'VariableNames', data.variable_names);

    if saveSubset
        sz = size(matrix, 1);
        row_indexes = randperm(sz, int32(sz/fractionDenominator));
        subtable = tbl(row_indexes, :);
        tbl = subtable;
        clear sz row_indexes subtable
    end

    file = [data_path 'satellite_density_' num2str(fractionDenominator) '.csv'];
    writetable(tbl, file, 'WriteVariableNames', true);

    % Create feature data for model validation plot.
    lshell = 2:0.1:6.5;
    mlt = 0:1:24;
    coord = combvec(lshell, mlt);
    len = length(coord); % total number of rows in our test input.
    M = median(tbl, 1); % median of all columns.
    test_input = repmat(M, len, 1);
    test_input.lshell = coord(1,:)';
    test_input.cos = cos(coord(2,:) / 24 * 2 * pi)';
    test_input.sin = sin(coord(2,:) / 24 * 2 * pi)';
    
    file = [data_path 'featuresForModelPlot.csv'];
    writetable(test_input, file, 'WriteRowNames', true);

end