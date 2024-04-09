%% load data from csv.
input = readmatrix('data/inputs.csv');
o_perturbation = readmatrix('data/original_output.csv');
p_perturbation = readmatrix('data/predicted_output.csv');

satellite1 = load('./data/satellite1.mat', "-mat", "satellite1").satellite1;

cols = satellite1.variable_names(1:end-4);
cols = [cols 'original' 'predicted'];
matrix = [input o_perturbation p_perturbation];
table = array2table(matrix, 'VariableNames', cols);
clear input o_perturbation p_perturbation satellite1

%% plot heatmap
figure
surf(table.mlat, table.rho, table.predicted);