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