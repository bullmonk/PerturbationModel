# Current Progress
- [x] use the density data to calculate perturbation data: $(t, m_{lat}, x_{eq}, y_{eq}) -> perturbation$
- [x] interpolation on omni data and make density and omni matched on epoch(time) axis.
- [ ] combine purterbation and density data, train regression model that use other variables to predict perturbation variable.

# Brief Introduction

## Quick Set Up
1. clone repo
2. create `data` folder under cloned folder `perturbation`.
    ```
    cd /your/path/to/perturbation
    mkdir data
    ```
3. put `original-data.mat` files into `perturbation/data` folder.
4. run the `prepare.m` script with matlab run button.

## Assumed Conditions
- Users need to use the given of original-data.mat

## Folder Structure
- All `.dat` files should go to `./data`
- Other non-script files go to `./others`
- Scripts can be put under current directory
- All results will be dumped into `./results` folder.

## Scripts
- `prepare.m`

    the script that fisnish first 2 task, calculate perturbation, and interpolate omni data.