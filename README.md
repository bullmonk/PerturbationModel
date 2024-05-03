### Build Neural Network Model for Electron Density in Magnetosphere

#### Folder Structure
```
PerturbationModel
│
├── CondaEnv
│   └── environment.yml: the file used to build dependency for pytorch computation
│
└── DataPreparation: original electron density data and matlab code to calculate density perturbation
│    └── TaskRunner.m: the GUI to run expected data processing
│
└── ModelTraining: the pytorch code to train and run neural network model
    ├── ANN-ModelParameterTuning.ipynb: code to train model with subset of data
    └── ANN-FinalModelRun.ipynb: with trained model parameters, run prediction on full input data
```

#### File Explanation
- `OriginalData2Satellites.m` is a collection of procedure that read satellite data and omni data from `data/` folder, and calculate self-defined perturbation, ae index and sym-H cadance. And eventually build a ready for training data csv file.
- `OriginalData2SatellitesHelper.m` is a helper function that used to do repeating data manipulation, including filtering. This helper function is coupled with the process script because it assumes all the fields in data packet, the change to `OriginalData2Satellites.m` might make this function not work.
    - input field `original_data`: the data packet to manipulate
    - input field `operation`: a enum value to suggest the operation wanted. see `OriginalData2SatellitesHelperOperation.m`
    - input field `filtered_index`: an optional argument, used when `operation=Filter`, the selected index expected to be applied to data packet.
    - input field `satellite_id`: an optional argument, used when `operation=GetSatellite`. Fetch a specified satellite data from original data packet.
- `OriginalData2SatellitesHelperOperation`: an enum that be used by `OriginalData2SatellitesHelper.m`
- `buildHistoryVariables.m`: it is a helper function that build cadance for ae index and sym-H. For example, it can take a vector of ae index and give back 60 vectors, each of which a some 5mins lagged from input vector
    - input field `name`: the name of the variable to be operated `ae_index` or `sym_h`. `lagged_by_xx_mins` will be added to extended vectors.
    - input field `array`: the original `ae_index` or `sym_h` vector.
    - input field `array_time`: the time array that matches the original `ae_index` or `sym_h`.
    - input field `target_time`: the expected output time.
- `calcPerturbation.m`: this is the function to calculate our self-defined density perturbation.
    - input field `density`: the original data of electron density.
    - input field `time`: the time vector that match `density`.
    - input field `windowSize`: the length of window where each perturbation is calculated. for example, if we specify this to 2 mins. the purturbation for a data at t0 will be std of density data in the window [t0 - 1min, t0 + 1min]
    - input field `validGroupCount`: this is a limit that specify when number of density data within a specified window is under which, that will make the calculation result to be invalid.