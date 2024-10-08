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

#### Case 1: Build training data using randomized subset of all satellite data
```
workflow('prepareTrainingData', true, 'dataBalance', true, 'saveFractionalSubset', true, 'saveTimelineSubset', false, 'fractionDenominator', 1000, 'ofid', 0, 'perturbationWindow', 2, 'windowPopulation', 10);
```
- `prepareTrainingData` - set true to enable first procedure.
- `dataBalance` - set true to delete some close to 0 data to achieve balanced input.
- `saveFractionalSubset` - set true to use only subset of data.
- `saveTimelineSubset` - set true to use only subset of data.
- `fractionDenominator` - come with `saveFractionalSubset`, the fractional size of used data.
- `ofid` - the output data file ID. manually set to distinguish each run.
- `perturbationWindow` - the perturbation window length in minutes.
- `windowPopulation` - the perturbation window population lower bond.

#### Case 2: Build training data using subset of all satellite data within a period of time
```
workflow('prepareTrainingData', true, 'dataBalance', true, 'saveFractionalSubset', false, 'saveTimelineSubset', true, 's', '28-May-2013 00:00:00', 'e', '07-Jun-2013 00:00:00', 'ofid', 3, 'perturbationWindow', 2, 'windowPopulation', 10);
```
- `prepareTrainingData` - set true to enable first procedure.
- `dataBalance` - set true to delete some close to 0 data to achieve balanced input.
- `saveFractionalSubset` - set true to use only subset of data.
- `saveTimelineSubset` - set true to use only subset of data.
- `s` - come with `saveTimelineSubset`, the starting time of subset period.
- `e` - come with `saveTimelineSubset`, the ending time of subset period.
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
workflow('prepareTestInput', true, 'ifid', 3, 'ofid', 0, 'lshell', '2:0.1:6.5', 'mlt', '0:1:24', 's', '30-May-2013 00:00:00', 'e', '06-Jun-2013 00:00:00', 'sampleNum', 132);
```
- `prepareTestInput` - set true to enable this procedure.
- `ifid` - input file id. To pick a result from a specific run.
- `ofid` - output file id. Manual set to distinguish different run results.
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
workflow('plotPredicted', true, 'target', 'density_log10', 'ifid', 0, 'sampleNum', 132);
```
- `plotPredicted` - set true to enable this procedure.
- `target` - target variable name, inherited from train procedure.
- `ifid` - file id to pick from which run.
- `sampleNum` - sample number from previous Model Input Process.

## Example Frequently Usage Routines

#### Train Model using a randomly fractional data

- a training dataset with 1/100 datasize will be created, `training_data_0`, which won't be used further. So that I will change this suffix to make it a backup instead of active pipeline data. 
- TODO: optimize this flow to remove this manual procedure.
- a model will be saved in `/dump` folder with file id suffix `_0`, which will be referenced later.
```
workflow('prepareTrainingData', true, 'dataBalance', true, 'saveFractionalSubset', true, 'saveTimelineSubset', false, 'fractionDenominator', 100, 'ofid', 0, 'perturbationWindow', 2, 'windowPopulation', 10, 'train', true, 'ifid', 0, 'ofid', 0, 'iIndicies', '1:126', 'target', 'density_log10', 'disableTargetStand', true);
```

#### Create a test data of a time period and plot using the prediction result
- note the `sampleNum` here is set to be the total number of hours between 30-May-2013 00:00:00 and 06-Jun-2013 00:00:00, so that we can have a sample for each hour.

```
workflow('prepareTrainingData', true, 'dataBalance', true, 'saveFractionalSubset', false,'saveTimelineSubset', true, 's', '28-May-2013 00:00:00', 'e', '07-Jun-2013 00:00:00', 'ofid', 0,'perturbationWindow', 2, 'windowPopulation', 10, 'prepareTestInput', true, 'ifid', 0, 'ofid', 0,'lshell', '2:0.1:6.5', 'mlt', '0:1:24', 's', '30-May-2013 00:00:00', 'e', '06-Jun-2013 00:00:00', 'sampleNum', 132, 'predict', true, 'iIndicies', '1:126', 'target', 'density_log10','disableTargetStand', true, 'ifid', 0, 'ofid', 0, 'plotPredicted', true, 'target','density_log10', 'ifid', 0, 'sampleNum', 132);
```