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
import seaborn as sns
import argparse

def main():

    # fetch system arguements.
    parser = argparse.ArgumentParser(description="Train a Neural Network Regressor.")

    parser.add_argument("--iData", type=str, help="The file name of input data, .csv or .parquet, with first part of columns of input data, and last few columns of target data.")
    parser.add_argument("--iIndicies", type=str, default="0:9", help="Numerical Array, referencing the indicies of columns for trainning input.")
    parser.add_argument("--oIndex", type=int, default=-1, help="Int, suggesting the index of the column which will be used as regression target.")
    parser.add_argument("--oData", type=str, default="model.sav", help="The file name of dumped model.")

    args = parser.parse_args()

    
    # Parse the arguments from the command line
    original_data_file_name = args.iData
    [s, e] = args.iIndicies.split(':')
    feature_column_indicies = range(int(s), int(e) + 1)
    target_column_index = args.oIndex
    dumped_model_file_name = args.oData

    # load data

if __name__ == "__main__":
    main()
