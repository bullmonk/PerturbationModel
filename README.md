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
- `prepareTrainingData` - set true to enable first procedure.
- `dataBalance` - set true to delete some close to 0 data to achieve balanced input.
- `saveSubset` - set true to use only subset of data. (TODO: enable whole data procedure)
- `fractionDenominator` - come with `saveSubset`, the fractional size of used data.
- `ofid` - the output data file ID. manually set to distinguish each run.

### Train
```
workflow('train', true, 'ifid', 0, 'ofid', 1, 'iIndicies', '1:126', 'target', 'density_log10', 'disableTargetStand', true);
```
- `train` - set true to enable 2nd procedure.
- `ifid` - input file id. To pick a result from a specific run.
- `ofid` - output file id. Manually set to distinguish each run.
- `iIndicies` - to choose column indicies of input feature columns.
- `target` - to choose the column name of the target variable.
- `disableTargetStand` - set true to disable target variable normalization.

### Prepare Model Input
```
workflow('prepareTestInput', true, 'ifid', 0, 'lshell', '2:0.1:6.5', 'mlt', '0:1:24', 's', '24-Apr-2015 12:23:31', 'e', '30-Apr-2015 12:23:31', 'lim', 10, 'startingIdx', 0);
```
- `prepareTestInput` - set true to enable this procedure.
- `ifid` - input file id. To pick a result from a specific run.
- `lshell` - lshell range.
- `mlt` - mlt range.
- `s` - starting of a time period, where ae_index and sym_h data should be chosen from.
- `e` - ending of a time period, where ae_index and sym_h data should be chosen from.
- `lim` - number of input files wanted. Will be evenly sliced.
- `startingIdx` - the output files will have same prefix, and a distinguishing idx as a suffix.

### Predict
```

```