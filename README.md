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
workflow('prepareTrainingData', true, 'dataBalance', true, 'saveSubset', true, 'fractionDenominator', 1000, 'ofid', 0, 'perturbationWindow', 2, 'windowPopulation', 10);
```
- `prepareTrainingData` - set true to enable first procedure.
- `dataBalance` - set true to delete some close to 0 data to achieve balanced input.
- `saveSubset` - set true to use only subset of data. (TODO: enable whole data procedure)
- `fractionDenominator` - come with `saveSubset`, the fractional size of used data.
- `ofid` - the output data file ID. manually set to distinguish each run.
- `perturbationWindow` - the perturbation window length in minutes.
- `windowPopulation` - the perturbation window population lower bond.

### Train
```
workflow('train', true, 'ifid', 0, 'ofid', 0, 'iIndicies', '1:126', 'target', 'density_log10', 'disableTargetStand', true);
```
- `train` - set true to enable 2nd procedure.
- `ifid` - input file id. To pick a result from a specific run.
- `ofid` - output file id. Manually set to distinguish each run.
- `iIndicies` - to choose column indicies of input feature columns.
- `target` - to choose the column name of the target variable.
- `disableTargetStand` - set true to disable target variable normalization.

### Prepare Model Input
```
workflow('prepareTestInput', true, 'ifid', 1, 'ofid', 0, 'lshell', '2:0.1:6.5', 'mlt', '0:1:24', 's', '31-May-2013 12:00:00', 'e', '01-Jun-2013 20:00:00', 'sampleNum', 48);
```
- `prepareTestInput` - set true to enable this procedure.
- `ifid` - input file id. To pick a result from a specific run.
- `lshell` - lshell range.
- `mlt` - mlt range.
- `s` - starting of a time period, where ae_index and sym_h data should be chosen from.
- `e` - ending of a time period, where ae_index and sym_h data should be chosen from.
- `sampleNum` - number of samples captured from the period [s,e].

### Predict
```
workflow('predict', true, 'iIndicies', '1:126', 'target', 'density_log10', 'disableTargetStand', true, 'ifid', 0, 'ofid', 0);
```
- `predict` - set true to enable this procedure.
- `iIndicies` - indicies of input features, which is inherited from train procedure.
- `target` - target variable name, inherited from train procedure.
- `disableTargetStand` - disable normalization of the target variable.
- `ifid` - the input file id to select xscaler, yscaler, and regressor.
- `ofid` - output file index, manual set to distinguish different run.

### Plot Predicted
```
workflow('plotPredicted', true, 'target', 'density_log10', 'ifid', 0, 'sampleNum', 30);
```
- `plotPredicted` - set true to enable this procedure.
- `target` - target variable name, inherited from train procedure.
- `ifid` - file id to pick from which run.
- `sampleNum` - sample number from previous Model Input Process.

### A Complete Workflow
```
workflow('prepareTrainingData', true, 'dataBalance', true, 'saveSubset', true, 'fractionDenominator', 1000, 'ofid', 0, 'perturbationWindow', 2, 'windowPopulation', 10, 'train', true, 'ifid', 0, 'iIndicies', '1:126', 'target', 'density_log10', 'disableTargetStand', true, 'prepareTestInput', true, 'lshell', '2:0.1:6.5', 'mlt', '0:1:24', 's', '05-May-2015 12:23:31', 'e', '20-May-2015 12:23:31', 'lim', 30, 'startingIdx', 0, 'predict', true, 'plotPredicted', true, 'startingIdx', 0, 'endingIdx', 29);
```