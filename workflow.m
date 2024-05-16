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

    addParameter(ip, 'prepareTrainingData', true);
    addParameter(ip, 'train', true);
    addParameter(ip, 'plotTrainingPerf', false);
    addParameter(ip, 'plotFeatureRank', false);
    addParameter(ip, 'prepareTestInput', true);
    addParameter(ip, 'predict', true);
    addParameter(ip, 'plotPredicted', true);

    parse(ip, wIndex, pOption, varargin{:});

    dataFolder = ip.Results.dataFolder;
    dumpFolder = ip.Results.dumpFolder;
    plotFolder = ip.Results.plotFolder;
    fractionDenominator = ip.Results.fractionDenominator;
    target = ip.Results.target;

    % default variables.
    training_data = fullfile(dataFolder, ['satellite_' num2str(fractionDenominator) '.csv']);
    model_perf_data = fullfile(dataFolder, [target '_cmp_plot_data.csv']);
    feature_importance_data = fullfile(dataFolder, [target '_cmp_plot_data.csv']);
    test_input_data = fullfile(dataFolder, [target '_feature_for_test.csv']);
    test_result_data = fullfile(dataFolder, ['predicted_' target '.csv']);
    xscaler = fullfile(dumpFolder, [target '_xscaler.joblib']);
    yscaler = fullfile(dumpFolder, [target '_yscaler.joblib']);
    regressor = fullfile(dumpFolder, [target '_netRegressor.joblib']);
    
    % arguments
    dataBalance = ip.Results.dataBalance;
    saveSubset = ip.Results.saveSubset;
    iIndicies = ip.Results.iIndicies;

    disableTargetStandClause = '';
    if ip.Results.disableTargetStand
        disableTargetStandClause = ' --disableTargetStand';
    end
    saveFeatureImportanceClause = '';
    if ip.Results.plotFeatureRank
        saveFeatureImportanceClause= ' --saveFeatureImportances';
    end
    
    lshell = eval(ip.Results.lshell);
    mlt = eval(ip.Results.mlt);

    % workflow start.
    if ip.Results.prepareTrainingData
        prepareTrainingData(dataBalance, saveSubset, 'fractionDenominator', fractionDenominator);
    end

    if ip.Results.train
        system(['python3 ModelTraining/train.py --iData=' training_data ' --oData='  ' --iIndicies=' iIndicies ' --target=' target ...
            disableTargetStandClause saveFeatureImportanceClause ' --xscaler=' xscaler ' --yscaler=' yscaler ' --model=' regressor ...
            ' --featureImp=' feature_importance_data])
    end

    if ip.Results.plotTrainingPerf
        plotting(1, plottingOption.modelComparison, 'cmpData', model_perf_data, 'output', fullfile(plotFolder, [target '_scatter_plot.png']));
    end

    if ip.Results.plotFeatureRank
        plotting(1, plottingOption.featureRank, 'featureImportancesData', feature_importance_data, 'output', fullfile(plotFolder, [target '_feature_rank.png']));
    end

    if ip.Results.prepareTestInput
        prepareTestInput(lshell, mlt, 'iFile', training_data, 'oFile', test_input_data);
    end

    if ip.Results.predict
        system(['python3 ModelTraining/predict.py --iData=' test_input_data ' --oData=' test_result_data ' --iIndicies=' iIndicies ...
            ' --target=' target disableTargetStandClause ' --xscaler=' xscaler ' --yscaler=' yscaler ' --model=' regressor]);
    end

    if ip.Results.plotPredicted
        plotting(1, plottingOption.colormap, 'predictedData', test_result_data, 'zName', target, 'output', fullfile(plotFolder, [target '_predicted.png']));
    end

end