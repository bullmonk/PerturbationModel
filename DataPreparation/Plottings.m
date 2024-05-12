function[] = Plottings()

%load data.
data = readtable("../data/satellite_100.csv");


%% plot default: 2 mins window 10 points
[windowIdx] = plotPerturbation(windowIdx, satellite1.perturbation, satellite1.normalized_perturbation, satellite1.rho, "2 mins 10 points");


%% key data
time = satellite1.time;
density = satellite1.density;
rho = satellite1.rho;

%% generate different perturbations for satellite1
for mins = 1:6
    [perturbation, background] = calcPerturbation(density, time, minutes(mins), 10);
    normalized_perturbation = perturbation./background;
    [windowIdx] = plotPerturbation(windowIdx, perturbation(idx), normalized_perturbation(idx), rho(idx), [num2str(mins) ' mins 10 points' ]);
end