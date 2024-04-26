%% load data from csv.
input = readmatrix('data/inputs.csv');
o_perturbation = readmatrix('data/original_output.csv');
p_perturbation = readmatrix('data/predicted_output.csv');

satellite1 = load('./data/satellite1.mat', "-mat", "satellite1").satellite1;

cols = satellite1.variable_names(1:end-4);
cols = [cols 'original' 'predicted'];
matrix = [input o_perturbation p_perturbation];
table = array2table(matrix, 'VariableNames', cols);
clear input o_perturbation p_perturbation satellite1 matrix

%% plot heatmap
figure
scatter(table.theta/pi*180, table.rho, 20, table.original, 'filled');
colorbar;
clim([0 200]);
xlabel("theta");
xlim([-180 180]);
ylabel("rho");
title("original predicted normalized perturbation");
figure
scatter(table.theta/pi*180, table.rho, 20, table.predicted, 'filled');
colorbar;
clim([0 200]);
xlabel("theta");
xlim([-180 180]);
ylabel("rho");
title("predicted predicted normalized perturbation");