### Build Neural Network Model for Electron Density in Magnetosphere

#### Folder Structure
```
PerturbationModel
│
├── CondaEnv
│   └── environment.yml: the file used to build dependency for pytorch computation
│
└── DataPreparation: Code related to prepare training data in table format.
│    ├── workflow.m: matlab script that control the workflow of train-predict-plot.
│    ├── preapareTrainingData.m: function that produce table formatted training data.
│    └── plotting.m: function that handle different plotting jobs.
│
└── ModelTraining: the pytorch code to train and run neural network model
    ├── train.py: python script that dump trained model by consuming training data.
    └── predit.py: python script that dump predicted result (.csv) by using dumped model.
```

#### File Explanation
- `workflow.m:` Use by click the run button. Edit to achieve different flows.
- `prepareTrainingData.m:` 
    - A function:  `prepareTrainingData(dataBalance, saveSubset, fractionDenominator)`
    - `dataBalance`: boolean, true will discard part of close to zero density input data.
    - `saveSubset`: boolean, true will make train data a fractional of all original data.
    - `fractionDenominator`: optional arguement, int type, 1 over wihch as a fraction will this function save subset of original data as trainning input.
- `plotting.m:`
    - A function: `plotting(wIndex, pOption, trainingData, predictedData)`
    - `wIndex`: positive int, a window index that suggesting where you want to plot locate in screen. 1-9 will cover all available locations.
    - `pOption`: enum defined in `plottingOption.m`, set to plot different plots.
    - `trainingData`: optional arguement, will be used when `pOption != plottingOption.densityLshellMlt`, string, suggesting the file name of the training data. ex, `satellite_100.csv`.
    - `predictedData`: optional arguement, will be used when `pOption == plottingOption.densityLshellMlt`, string, suggesting the file name of the predicted output. ex, `predicted_density_log10.csv`
- `train.py:` run by `python3 train.py` with some arguements. Detailed example in `workflow.m`.
    - `--iData`, required, suggesting the training data file name.
    - `--iIndicies`, required, suggesting the columns used as features, ex, `0:9` means column 0 to column 9.
    - `--target`, required, suggesting the column of which is used as target.
    - `--disableTargetStand`, optional, when used, standardization on target variable will be disabled.
- `predict.py:` run by `python3 predict.py` with some arguements. Detailed example in `workflow.m`.
    - `--iData`, required, suggesting the feature input data file name.
    - `--iIndicies`, required, suggesting the columns used as features, ex, `0:9` means column 0 to column 9.
    - `--target`, required, suggesting the column of which is used as target.
    - `--disableTargetStand`, optional, when used, standardization on target variable will be disabled.

#### Remaining Anonymous Files
- They are helper functions used by above major scripts listed above.