
%% Data Preparation.
% this will create 2 files under PerturbationModel/data/ folder.
% (1) satellite_###.csv, where ### stand for the fraction to total data.
% (2) featuresForModelPlot.csv, which is used for ploting density or
% perturbation versus mlt and lshell.
prepareTrainingData(true, true, 10000);

%% Run Model Training.

% install dependencies.
system('conda activate jpt');
% run model training.
[~, cmdout] = system('python3 train.py --iData=satellite_100.csv --iIndicies=0:125 --target=density_log10 --disableTargetStand');
fprintf('The model performance is %f on test data.', cmdout);

%% Predict output with trained model and manuscripted feature inputs.
system('python3 predict.py --iData=featuresForModelPlot.csv --iIndicies=0:125 --target=density_log10 --disableTargetStand');

%% Plot output vs lshell vs mlt.
plotting(1, plottingOption.densityLshellMlt, predictedData='predicted_density_log10.csv');