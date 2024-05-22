function[] = workflow(varargin)
    addpath('DataPreparation/');


    ip = inputParser;

    addParameter(ip, 'dataBalance', true);
    addParameter(ip, 'saveSubset', true);
    addParameter(ip, 'fractionDenominator', 10000);

    addParameter(ip, 'dataFolder', 'data');
    addParameter(ip, 'dumpFolder', 'dump');
    addParameter(ip, 'plotFolder', 'plot');
    addParameter(ip, 'target', 'density_log10');
    addParameter(ip, 'iIndicies', '0:125');
    addParameter(ip, 'disableTargetStand', false);
    addParameter(ip, 'lshell', '2:0.1:6.5');
    addParameter(ip, 'mlt', '0:1:24');
    addParameter(ip, 'fid', 1);

    % workflow set up.
    addParameter(ip, 'prepareTrainingData', false);
    addParameter(ip, 'train', false);
    addParameter(ip, 'plotTrainingPerf', false);
    addParameter(ip, 'plotFeatureRank', false);
    addParameter(ip, 'prepareTestInput', false);
    addParameter(ip, 'predict', false);
    addParameter(ip, 'plotPredicted', false);

    % special usage
    addParameter(ip, 'valueRow', -1);

    parse(ip, varargin{:});

    dataFolder = ip.Results.dataFolder;
    dumpFolder = ip.Results.dumpFolder;
    plotFolder = ip.Results.plotFolder;
    fractionDenominator = ip.Results.fractionDenominator;
    target = ip.Results.target;
    fid = num2str(ip.Results.fid);

    % default variables.
    training_data = fullfile(dataFolder, ['satellite_' num2str(fractionDenominator) '_' fid '.csv']);
    model_perf_data = fullfile(dataFolder, [target '_cmp_plot_data_' fid '.csv']);
    feature_importance_data = fullfile(dataFolder, [target '_cmp_plot_data_' fid '.csv']);
    test_input_data = fullfile(dataFolder, [target '_feature_for_test_' fid '.csv']);
    test_result_data = fullfile(dataFolder, ['predicted_' target '_' fid '.csv']);
    xscaler = fullfile(dumpFolder, [target '_xscaler_' fid '.joblib']);
    yscaler = fullfile(dumpFolder, [target '_yscaler_' fid '.joblib']);
    regressor = fullfile(dumpFolder, [target '_netRegressor_' fid '.joblib']);
    
    % arguments
    dataBalance = ip.Results.dataBalance;
    saveSubset = ip.Results.saveSubset;
    iIndicies = ip.Results.iIndicies;

    disableTargetStandClause = '';
    if ip.Results.disableTargetStand
        disableTargetStandClause = ' --disableTargetStand';
    end
    saveModelPerformanceClause = '';
    if ip.Results.plotTrainingPerf
        saveModelPerformanceClause= '--saveModelPerformance';
    end
    saveFeatureImportanceClause = '';
    if ip.Results.plotFeatureRank
        saveFeatureImportanceClause= ' --saveFeatureImportances';
    end
    
    lshell = eval(ip.Results.lshell);
    mlt = eval(ip.Results.mlt);

    % workflow start.
    if ip.Results.prepareTrainingData
        disp('preparing training data...');
        prepareTrainingData(dataBalance, saveSubset, 'fractionDenominator', fractionDenominator, 'fid', fid);
        disp(['training data ready as: ' training_data]);
    end

    if ip.Results.train
        disp('train model...');
        system(['python3 ModelTraining/train.py --iData=' training_data ' --iIndicies=' iIndicies ' --target=' target ...
            disableTargetStandClause saveModelPerformanceClause saveFeatureImportanceClause ...
            ' --xscaler=' xscaler ' --yscaler=' yscaler ' --model=' regressor ...
            ' --featureImp=' feature_importance_data])
        disp(['trained model dumped into: ' regressor]);
    end

    if ip.Results.plotTrainingPerf
        disp('plotting model performance scatter plot...');
        plotting(1, plottingOption.modelComparison, 'cmpData', model_perf_data, 'output', ...
            fullfile(plotFolder, [target '_scatter_plot_' fid '.png']));
        disp(['scatter plot saved as: ' target '_scatter_plot.png']);
    end

    if ip.Results.plotFeatureRank
        disp('plotting feature importance rank...');
        plotting(1, plottingOption.featureRank, 'featureImportancesData', feature_importance_data, 'output', ...
            fullfile(plotFolder, [target '_feature_rank_' fid '.png']));
        disp(['feature importance rank saved as: ' target '_feature_rank.png']);
    end

    if ip.Results.prepareTestInput
        disp('preparing test input...');
        prepareTestInput(lshell, mlt, 'iFile', training_data, 'oFile', test_input_data, 'valueRow', ip.Results.valueRow);
        disp(['test input saved as: ' test_input_data]);
    end

    if ip.Results.predict
        disp('calculating model output using test input...');
        system(['python3 ModelTraining/predict.py --iData=' test_input_data ' --oData=' test_result_data ' --iIndicies=' iIndicies ...
            ' --target=' target disableTargetStandClause ' --xscaler=' xscaler ' --yscaler=' yscaler ' --model=' regressor]);
        disp(['model output saved as: ' test_result_data]);
    end

    if ip.Results.plotPredicted
        disp('plotting test output over mlt-lshell...');
        plotting(1, plottingOption.colormap, 'predictedData', test_result_data, 'zName', target, 'output', ...
            fullfile(plotFolder, [target '_predicted_' fid '.png']));
        disp(['plot saved as: ' target '_predicted.png']);
    end

end