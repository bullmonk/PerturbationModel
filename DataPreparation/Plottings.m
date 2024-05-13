function[wIndex] = Plottings(wIndex, pOption, predictedData)

ip = inputParser;
addRequired(ip, 'wIndex');
addRequired(ip, 'pOption');
addOptional(ip, 'predictedData');


%load data.
data = readtable("../data/satellite_100.csv");
if pOption == PlottingOption.densityLshellMlt
    predicted = readtable(['../data/' predictedData '.csv']);
end

switch pOption
    case PlottingOption.densityTime
        plot_name = "given time series for density data";
        [fig, ~] = getNextFigure(wIndex, plot_name);
        figure(fig)
        tiledlayout(2, 1)
        ax1 = nexttile;
        plot(data.datetime, '.', 'MarkerSize', 3);
        title(ax1, 'original time data');
        xlabel(ax1, 'index');
        ylabel(ax1, 'time');
        ax1 = nexttile;
        plot(data.datetime, log10(data.density), '.', 'MarkerSize', 3);
        title(ax1, 'log_{10} density data - time plot');
        xlabel(ax1, 'time');
        ylabel(ax1,'density');
    case PlottingOption.perturbationTime
        plot_name = "perturbation plots";
        [fig, ~] = getNextFigure(wIndex, plot_name);
        figure(fig)
        plot(data.datetime, data.normalized_perturbation, '.', 'MarkerSize', 3);
        title('density perturbation (windowed standard deviation) - time');
        xlabel('time');
        ylabel('density perturbation');
    case PlottingOption.omni
        plot_name = "omni data time";
        [fig, ~] = getNextFigure(wIndex, plot_name);
        figure(fig)
        tiledlayout(3, 1)
        ax1 = nexttile;
        plot(omni_time, '.', 'MarkerSize', 3);
        title(ax1, 'time series from original omni data');
        xlabel(ax1, 'index');
        ylabel(ax1, 'time');
        ax1 = nexttile;
        plot(omni_time, ae_index, '.', 'MarkerSize', 3);
        title(ax1, 'ae\_index data align with original time series');
        xlabel(ax1, 'time');
        ylabel(ax1, 'ae\_index');   
        ax2 = nexttile;
        plot(omni_time, sym_h, '.', 'MarkerSize', 3);
        title(ax2, 'sym\_h data align with original time series');
        xlabel(ax2, 'time');
        ylabel(ax2, 'sym\_h');
    case PlottingOption.cadence
        plot_name = "first 3 lagged sym_h data";
        [fig, ~] = getNextFigure(window_idx, plot_name);
        figure(fig)
        tiledlayout(3, 1)
        ax1 = nexttile;
        plot(data.datetime, data.symh_variables(:, 2)', '.', 'MarkerSize', 3);
        title(ax1, 'sym\_h data lagged by 5 mins and align with density data');
        xlabel(ax1, 'index');
        xlim([data.datetime(1) data.datetime(1) + minutes(60)]);
        ylim([-20 -10]);
        ylabel(ax1, 'sym\_h');   
        ax2 = nexttile;
        plot(data.datetime, data.symh_variables(:, 3)', '.', 'MarkerSize', 3);
        title(ax2, 'sym\_h data lagged by 10 mins and align with density data');
        xlabel(ax2, 'index');
        xlim([data.datetime(1) data.datetime(1) + minutes(60)]);
        ylabel(ax2, 'sym\_h');
        ylim([-20 -10]);
        ax3 = nexttile;
        plot(data.datetime, data.symh_variables(:, 4)', '.', 'MarkerSize', 3);
        title(ax3, 'sym\_h data lagged by 15 mins and align with density data');
        xlabel(ax3, 'index');
        xlim([data.datetime(1) data.datetime(1) + minutes(60)]);
        ylim([-20 -10]);
        ylabel(ax3, 'sym\_h');
    case PlottingOption.densityLshellMlt
        lshell = 2:0.1:6.5;
        mlt = 0:1:24;
        % coord = combvec(lshell, mlt);
        % X = reshape(coord(1,:), length(lshell), length(mlt));
        % Y = reshape(coord(2,:), length(lshell), length(mlt));
        Z = reshape(predicted(:,1), length(lshell), length(mlt));
        [fig, ~] = getNextFigure(window_idx, "value - mlt - lshell");
        figure(fig)
        imagesc(mlt, lshell, Z);
        xlabel('mlt');
        ylabel('lshell');
        c = colorbar;
        c.Label.FontSize = 30;
        c.Label.String = 'log_{10}(Density)';
        clim([0 4]);
        colormap("jet");
end