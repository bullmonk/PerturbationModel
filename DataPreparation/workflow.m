
%% Data Preparation.
% this will create 2 files under PerturbationModel/data/ folder.
% (1) satellite_###.csv, where ### stand for the fraction to total data.
% (2) featuresForModelPlot.csv, which is used for ploting density or
% perturbation versus mlt and lshell.
prepareTrainingData(true, true);

%% plot actual vs predicted.
plotting(1, plottingOption.modelComparison, 'cmpData', 'density_log10_cmp_plot_data.csv');

%% plot feature importance rank.
plotting(1, plottingOption.featureRank, 'featureImportancesData', 'density_log10_features_rank.csv');

%% Run Model Training.

% install dependencies.
%system('conda init; conda activate jpt');
% run model training.

if 1
%[~, cmdout] = system('cd ../ModelTraining; ./train.sh')
%system('cd ../ModelTraining; ./train.sh')
%fprintf('The model performance is %f on test data.', cmdout);
system('cd ../ModelTraining;python3 train.py --iData=satellite_100.csv --iIndicies=0:125 --target=density_log10 --disableTargetStand')
%cd ../DataPreparation 

% generate files in dump folder
% dump/density_log10_*.joblib
%return
end

if 1
%% Predict output with trained model and manuscripted feature inputs.
system('cd ../ModelTraining;python3 predict.py --iData=featuresForModelPlot.csv --iIndicies=0:125 --target=density_log10 --disableTargetStand');
% generate data/predicted_density_log10.csv
%return
end

%% Plot output vs lshell vs mlt.
plotting(1, plottingOption.densityLshellMlt, 'predictedData', 'predicted_density_log10.csv');