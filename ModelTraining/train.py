import os
import pandas as pd
import numpy as np
import copy
import argparse
import torch
import matplotlib.pyplot as plt

from torch import nn, optim
from torch.utils.data import DataLoader
from torchvision import datasets, transforms
from joblib import dump
from sklearn import preprocessing
from skorch import NeuralNetRegressor

from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split, validation_curve, GridSearchCV, learning_curve
from sklearn.metrics import mean_squared_error,r2_score
from sklearn.inspection import permutation_importance

def main():

    # fetch system arguements.
    parser = argparse.ArgumentParser(description="Train a Neural Network Regressor.")

    parser.add_argument("--iData", type=str, help="The file name of input data, .csv or .parquet.")
    parser.add_argument("--iIndicies", type=str, default="0:9", help="Numerical Array, referencing the indicies of columns for trainning input.")
    parser.add_argument("--target", type=str, default="norm_perturbation", help="Name of the target variable column in the original data.")
    parser.add_argument("--disableFeatureStand", action='store_false', help="Disable feature standardization before and after training.")
    parser.add_argument("--disableTargetStand", action='store_false', help="Disable target standardization before and after training.")
    parser.add_argument("--saveModelPerformance", action='store_true', help="save predicted vs actual training data in a csv file.")
    parser.add_argument("--saveFeatureImportances", action='store_true', help="save feature importance in a csv file.")
    parser.add_argument("--model", type=str, default="dump/netRegressor.joblib", help="file name of the dumped model.")
    parser.add_argument("--xscaler", type=str, default="dump/xscaler.joblib", help="file name of the dumped xscaler.")
    parser.add_argument("--yscaler", type=str, default="dump/yscaler.joblib", help="file name of the dumped yscaler.")
    parser.add_argument("--modelPerf", type=str, default="data/perturbation_cmp_plot_data.csv", help="actual and predicted training target data.")
    parser.add_argument("--featureImp", type=str, default="data/density_log10_features_rank.csv", help="feature importance data.")

    args = parser.parse_args()

    
    # Parse the arguments from the command line
    [s, e] = args.iIndicies.split(':')
    feature_column_indicies = range(int(s), int(e) + 1)
    target_variable_name = args.target
    feature_standardization_enabled = args.disableFeatureStand
    target_standardization_enabled = args.disableTargetStand
    calculate_model_performance = args.saveModelPerformance
    calculate_feature_importances = args.saveFeatureImportances

    # load data
    df = pd.read_csv(args.iData)
    df.replace([np.inf, -np.inf], np.nan, inplace=True)
    df=df.dropna()

    # get target variable
    target = df[target_variable_name]

    # standardization on feature variables    
    X = df[df.columns[feature_column_indicies]]
    xscaler = None
    if feature_standardization_enabled:
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
    dump(netRegressor, args.model)
    if feature_standardization_enabled:
        dump(xscaler, args.xscaler)
    if target_standardization_enabled:
        dump(yscaler, args.yscaler)

    r2 = r2_score(y_test, y_out)
    print(f'''model r2 score on test data is: {r2}''')

    # save data for comparison plot
    if calculate_model_performance:
        cmp = pd.DataFrame({'actual': y_test.numpy().flatten(), 'predicted': y_out.flatten()})
        cmp.to_csv(args.modelPerf, index=False)

    # save feature importances data, conditional
    if calculate_feature_importances:
        r = permutation_importance(netRegressor, X_test, y_test,
                            n_repeats=30,
                            random_state=0)
        feature_importances = r.importances_mean
        pd.DataFrame({'features': names, 'importances': feature_importances}).to_csv(args.featureImp, index=False)
    
    return

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
