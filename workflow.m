function[] = workflow(varargin)
    addpath('DataPreparation/');


    ip = inputParser;

    % common/fixture.
    addParameter(ip, 'dataFolder', 'data');
    addParameter(ip, 'dumpFolder', 'dump');
    addParameter(ip, 'plotFolder', 'plot');
    addParameter(ip, 'ifid', 1);
    addParameter(ip, 'ofid', 1);

    % prepare training data.
    addParameter(ip, 'dataBalance', true);
    addParameter(ip, 'saveSubset', true);
    addParameter(ip, 'fractionDenominator', 10000);
    addParameter(ip, 'perturbationWindow', 2);
    addParameter(ip, 'windowPopulation', 10);

    % train model.
    addParameter(ip, 'target', 'density_log10');
    addParameter(ip, 'iIndicies', '0:125');
    addParameter(ip, 'disableFeatureStand', false);
    addParameter(ip, 'disableTargetStand', false);

    % prepare testing data.
    addParameter(ip, 'lshell', '2:0.1:6.5');
    addParameter(ip, 'mlt', '0:1:24');
    addParameter(ip, 's', '24-Apr-2018 02:23:31');
    addParameter(ip, 'e', '25-Apr-2018 02:23:31');
    addParameter(ip, 'sampleNum', 100);
    
    % workflow tasks.
    addParameter(ip, 'prepareTrainingData', false);
    addParameter(ip, 'train', false);
    addParameter(ip, 'plotTrainingPerf', false);
    addParameter(ip, 'plotFeatureRank', false);
    addParameter(ip, 'prepareTestInput', false);
    addParameter(ip, 'predict', false);
    addParameter(ip, 'plotPredicted', false);

    % fetch parameters.
    parse(ip, varargin{:});

    % set up variables.
    dataFolder = ip.Results.dataFolder;
    dumpFolder = ip.Results.dumpFolder;
    plotFolder = ip.Results.plotFolder;
    ifid = num2str(ip.Results.ifid);
    ofid = num2str(ip.Results.ofid);
    iIndicies = ip.Results.iIndicies;
    target = ip.Results.target;
    sampleNum = ip.Results.sampleNum;
    lshell = eval(ip.Results.lshell);
    mlt = eval(ip.Results.mlt);

    disableFeatureStandClause = '';
    if ip.Results.disableFeatureStand
        disableFeatureStandClause = ' --disableFeatureStand';
    end
    disableTargetStandClause = '';
    if ip.Results.disableTargetStand
        disableTargetStandClause = ' --disableTargetStand';
    end

    % workflow start.
    if ip.Results.prepareTrainingData
        disp('preparing training data...');

        fractionDenominator = ip.Results.fractionDenominator;
        fid = num2str(ip.Results.ofid);
        training_data_file_name = ['training_data_' ofid '.csv'];
        perturbationWindow = ip.Results.perturbationWindow;
        windowPopulation = ip.Results.windowPopulation;

        prepareTrainingData(ip.Results.dataBalance, ip.Results.saveSubset, ...
            'fractionDenominator', fractionDenominator, ...
            'perturbationWindow', perturbationWindow, ...
            'windowPopulation', windowPopulation, ...
            'dataFolder', dataFolder, ...
            'filename', training_data_file_name);
        
        disp(['training data ready as: ' training_data_file_name]);
    end

    if ip.Results.train
        disp('train model...');

        saveModelPerformanceClause = '';
        if ip.Results.plotTrainingPerf
            saveModelPerformanceClause= '--saveModelPerformance';
        end
        saveFeatureImportanceClause = '';
        if ip.Results.plotFeatureRank
            saveFeatureImportanceClause= ' --saveFeatureImportances';
        end
        training_data_file_name = fullfile(dataFolder, ['training_data_' ifid '.csv']);
        % comes with saveFeatureImportanceClause.
        feature_importance_data = fullfile(dataFolder, [target '_cmp_plot_data_' ofid '.csv']);
        xscaler = fullfile(dumpFolder, [target '_xscaler_' ofid '.joblib']);
        yscaler = fullfile(dumpFolder, [target '_yscaler_' ofid '.joblib']);
        regressor = fullfile(dumpFolder, [target '_netRegressor_' ofid '.joblib']);

        system(['python3 ModelTraining/train.py --iData=' training_data_file_name ...
            ' --iIndicies=' iIndicies ' --target=' target ...
            disableFeatureStandClause disableTargetStandClause saveModelPerformanceClause saveFeatureImportanceClause ...
            ' --xscaler=' xscaler ' --yscaler=' yscaler ' --model=' regressor ...
            ' --featureImp=' feature_importance_data])

        disp(['trained model dumped into: ' regressor]);
    end

    if ip.Results.plotTrainingPerf
        disp('plotting model performance scatter plot...');

        model_perf_data = fullfile(dataFolder, [target '_cmp_plot_data_' fid '.csv']);
        performance_plot_file = fullfile(plotFolder, [target '_scatter_plot_' fid '.png']);

        plotting(1, plottingOption.modelComparison, 'cmpData', model_perf_data, ...
            'output', performance_plot_file);

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

        s = ip.Results.s;
        e = ip.Results.e;
        training_data_file_name = fullfile(dataFolder, ['training_data_' ifid '.csv']);
        test_input_data_file = fullfile(dataFolder, ['model_input_' ofid '.csv']);

        prepareTestInput(lshell, mlt, ...
            'iFile', training_data_file_name, ...
            'oFile', test_input_data_file, ...
            's', s, ...
            'e', e, ...
            'sampleNum', sampleNum);

        disp(['test input saved as: ' test_input_data_file]);
    end

    if ip.Results.predict
        disp('calculating model output using test input...');

        xscaler = fullfile(dumpFolder, [target '_xscaler_' num2str(ifid) '.joblib']);
        yscaler = fullfile(dumpFolder, [target '_yscaler_' num2str(ifid) '.joblib']);
        regressor = fullfile(dumpFolder, [target '_netRegressor_' num2str(ifid) '.joblib']);
        test_input_data = fullfile(dataFolder, ['model_input_' num2str(ifid) '.csv']);
        test_result_data = fullfile(dataFolder, ['predicted_' num2str(ofid) '.csv']);

        system(['python3 ModelTraining/predict.py --iData=' test_input_data ...
            ' --oData=' test_result_data ...
            ' --iIndicies=' iIndicies ...
        ' --target=' target disableFeatureStandClause disableTargetStandClause ...
        ' --xscaler=' xscaler ' --yscaler=' yscaler ' --model=' regressor]);
        
        disp(['model output saved as: ' test_result_data]);
    end

    if ip.Results.plotPredicted
        disp('plotting test output over mlt-lshell...');

        test_result_data = ['predicted_' num2str(ifid) '.csv'];
        plot_name_prefix = ['splt_predicted_' num2str(ifid)];
        splitted_predictions = cutPrediction(dataFolder, test_result_data, plot_name_prefix, sampleNum);

        for i = 1:sampleNum
            test_result_data = splitted_predictions{i};
            plotting(1, plottingOption.colormap, ...
                'predictedData', fullfile(dataFolder, test_result_data), ...
                'zName', target, ...
                'lshell', lshell, ...
                'mlt', mlt, ...
                'output', fullfile(plotFolder, strrep(test_result_data, 'csv', 'png')));
        end

        disp('plotting done.');
    end

end