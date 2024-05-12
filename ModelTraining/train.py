import os
import pandas as pd
import numpy as np
import copy

import torch
from torch import nn, optim
from torch.utils.data import DataLoader
from torchvision import datasets, transforms

import matplotlib.pyplot as plt
from sklearn import preprocessing
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split, validation_curve, GridSearchCV, learning_curve
from sklearn.metrics import mean_squared_error,r2_score
from skorch import NeuralNetRegressor
import argparse
from joblib import dump

def main():

    # fetch system arguements.
    parser = argparse.ArgumentParser(description="Train a Neural Network Regressor.")

    parser.add_argument("--iData", type=str, help="The file name of input data, .csv or .parquet, with first part of columns of input data, and last few columns of target data.")
    parser.add_argument("--iIndicies", type=str, default="0:9", help="Numerical Array, referencing the indicies of columns for trainning input.")
    parser.add_argument("--target", type=str, default="norm_perturbation", help="Name of the target variable column in the original data.")
    parser.add_argument("--disableTargetStand", action='store_false', help="Disable target standardization before and after training.")

    args = parser.parse_args()

    
    # Parse the arguments from the command line
    original_data = args.iData
    [s, e] = args.iIndicies.split(':')
    feature_column_indicies = range(int(s), int(e) + 1)
    target_variable_name = args.target
    target_standardization_enabled = args.disableTargetStand

    # load data
    df = pd.read_csv(f'''../data/{original_data}''')
    df.replace([np.inf, -np.inf], np.nan, inplace=True)
    df=df.dropna()

    # get target variable
    target = df[target_variable_name]

    # standardization on feature variables
    X = df[df.columns[feature_column_indicies]]
    xscaler = preprocessing.MinMaxScaler()
    names = X.columns
    d = xscaler.fit_transform(X)
    X = pd.DataFrame(d, columns=names)

    y = target
    yscaler = None

    # conditional standardization on the target varible
    if target_standardization_enabled:
        yscaler = preprocessing.MinMaxScaler()
        d = yscaler.fit_transform(target.values.reshape(-1, 1))
        y = pd.DataFrame(d, columns=[target_variable_name])

    # train/test split
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.4, random_state = 628)
    X_train = torch.tensor(X_train.values, dtype=torch.float32)
    y_train = torch.tensor(y_train.values, dtype=torch.float32).reshape(-1, 1)
    X_test = torch.tensor(X_test.values, dtype=torch.float32)
    y_test = torch.tensor(y_test.values, dtype=torch.float32).reshape(-1, 1)

    netRegressor = set_device_and_nn(len(feature_column_indicies))

    # train model
    netRegressor.fit(X_train, y_train)
    y_out = netRegressor.predict(X_test)

    # dump model
    dump(netRegressor, f'''../dump/{target_variable_name}_netRegressor.joblib''')
    dump(xscaler, f'''../dump/{target_variable_name}_xscaler.joblib''')
    if target_standardization_enabled:
        dump(yscaler, f'''../dump/{target_variable_name}_yscaler.joblib''')

    r2 = r2_score(y_test, y_out)
    print(f'''model r2 score on test data is: {r2}''')
    return r2

def set_device_and_nn(feature_num):
    device = (
        "cuda"
        if torch.cuda.is_available()
        else "mps"
        if torch.backends.mps.is_available()
        else "cpu"
    )
    print(f"Using {device} device")
    
    # define neural network model
    model = nn.Sequential(
        nn.Linear(feature_num, 10),
        nn.ReLU(),
        nn.Linear(10, 20),
        nn.ReLU(),
        nn.Linear(20, 1)
    )
    
    # create skorch wrapper for a regressor.
    netRegressor = NeuralNetRegressor(
        module=model,
        criterion=nn.MSELoss,
        optimizer=optim.Adam,
        max_epochs=32,
        batch_size=128,
        device=device
    )

    return netRegressor

if __name__ == "__main__":
    main()
