## Build Neural Network Model for Electron Density in Magnetosphere

### Folder Structure
```
PerturbationModel
│
├── workflow.m: matlab script that control the workflow of train-predict-plot.
│
├── CondaEnv
│   └── environment.yml: the file used to build dependency for pytorch computation
│
└── DataPreparation: Code related to prepare training data in table format.
│    ├── preapareTrainingData.m: function that produce table formatted training data.
│    └── plotting.m: function that handle different plotting jobs.
│
└── ModelTraining: the pytorch code to train and run neural network model
    ├── train.py: python script that dump trained model by consuming training data.
    └── predit.py: python script that dump predicted result (.csv) by using dumped model.
```

## Core Usage
**The major usage of this repo is to operate the `workflow.m` file to achieve entire model training/test flow, or repeat a specific precedure.**

#### Procedures within workflow
1. Prepare Training Data: transfer original satellite data into usable table as model feed.
2. Train Model: Comes with 2 optional precedures
    ```
    Train Model
        ├── plot trained model performance
        └── plot feature importance rank
    ```
3. Prepare Test Input: Build some test input, or other input to use the trained model.
4. Predict: use model to predict on scripted input.
5. Plot predicted data.

## code example to use each procedure
- each ex uses all possible arguements.
- note that simpily putting all arguements from wanted individual procedure together will make it a full workflow. Order doesn't matter.

### Prepare Training Data
```
workflow('prepareTrainingData', true, 'dataBalance', true, 'saveSubset', true, 'fractionDenominator', 1000, 'ofid', 0);
```
-  `prepareTrainingData` - set true to enables first procedure.
- `dataBalance` - set true to delete some close to 0 data to achieve balanced input.
- `saveSubset` - set true to use only subset of data. (TODO: enable whole data procedure)
- `fractionDenominator` - come with `saveSubset`, the fractional size of used data.
- `ofid` - the output data file ID. manually set to distinguish each run.