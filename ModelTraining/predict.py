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
from joblib import load

def main():
    # fetch system arguements.
    parser = argparse.ArgumentParser(description="Train a Neural Network Regressor.")

    parser.add_argument("--iData", type=str, help="The file name of input data, .csv or .parquet, only feature data will be used.")
    parser.add_argument("--iIndicies", type=str, default="0:9", help="Numerical Array, referencing the indicies of columns for trainning input.")
    parser.add_argument("--target", type=str, default="norm_perturbation", help="Name of the target variable column in the original data.")
    parser.add_argument("--disableTargetStand", action='store_false', help="Disable target standardization before and after training.")

    args = parser.parse_args()

    
    # Parse the arguments from the command line.
    original_data = args.iData
    [s, e] = args.iIndicies.split(':')
    feature_column_indicies = range(int(s), int(e) + 1)
    target_variable_name = args.target
    target_standardization_enabled = args.disableTargetStand

    # load input data.
    input = pd.read_csv(original_data)
    mdl = load(f'''{target_variable_name}_netRegressor.joblib''')
    xscaler = load(f'''{target_variable_name}_xscaler.joblib''')
    yscaler = None
    if target_standardization_enabled:
        yscaler = load(f'''{target_variable_name}_yscaler.joblib''')

    # extract features
    X = input[input.columns[feature_column_indicies]]
    names = X.columns
    d = xscaler.fit_transform(X)
    X = pd.DataFrame(d, columns=names)

    # predict
    y_out = mdl.predict(torch.tensor(X.values, dtype=torch.float32))
    if target_standardization_enabled:
        y_out = yscaler.inverse_transform(y_out).flatten()

    # dump result
    pd.DataFrame(y_out).to_csv(f'''predicted_{target_variable_name}.csv''', index=False)

    return

if __name__ == "__main__":
    main()
