function[wIndex] = plotting(wIndex, pOption, varargin)
    % input definition.
    ip = inputParser;
    addRequired(ip, 'wIndex');
    addRequired(ip, 'pOption');
    addParameter(ip, 'zName', 'log_{10} density');
    addParameter(ip, 'trainingData', 'satellite_100.csv');
    addParameter(ip, 'predictedData', 'predicted_density_log10.csv');
    addParameter(ip, 'cmpData', 'density_log10_cmp_plot_data.csv');
    addParameter(ip, 'featureImportancesData', 'density_log10_features_rank.csv');
    parse(ip, wIndex, pOption, varargin{:});
    
    %load data.
    predicted = nan;
    data = nan;
    cmp = nan;
    
    if pOption == plottingOption.colormap
        predicted = readtable(['../data/' ip.Results.predictedData]);
    elseif pOption == plottingOption.modelComparison
        cmp = readtable(['../data/' ip.Results.cmpData]);
    elseif pOption == plottingOption.featureRank
        featureImpotances = readtable(['../data/' ip.Results.featureImportancesData]);
    else
        data = readtable(['../data/' ip.Results.trainingData]);
    end
    
    switch pOption
        case plottingOption.densityTime
            plot_name = "given time series for density data";
            [fig, ~] = getNextFigure(wIndex, plot_name, 'wCut', 2, 'hCut', 2);
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
        case plottingOption.perturbationTime
            plot_name = "perturbation plots";
            [fig, ~] = getNextFigure(wIndex, plot_name, 'wCut', 2, 'hCut', 2);
            figure(fig)
            plot(data.datetime, data.normalized_perturbation, '.', 'MarkerSize', 3);
            title('density perturbation (windowed standard deviation) - time');
            xlabel('time');
            ylabel('density perturbation');
        case plottingOption.omni
            plot_name = "omni data time";
            [fig, ~] = getNextFigure(wIndex, plot_name, 'wCut', 2, 'hCut', 2);
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
        case plottingOption.cadence
            plot_name = "first 3 lagged sym_h data";
            [fig, ~] = getNextFigure(window_idx, plot_name, 'wCut', 2, 'hCut', 2);
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
        case plottingOption.colormap
            lshell = 2:0.1:6.5;
            mlt = 0:1:24;
            % coord = combvec(lshell, mlt);
            % X = reshape(coord(1,:), length(lshell), length(mlt));
            % Y = reshape(coord(2,:), length(lshell), length(mlt));
            Z = reshape(predicted{2:end,1}, length(lshell), length(mlt));
            [fig, ~] = getNextFigure(wIndex, [ip.Results.zName ' - mlt - lshell'], 'wCut', 2, 'hCut', 2);
            figure(fig)
            imagesc(mlt, lshell, Z);
            xlabel('mlt');
            ylabel('lshell');
            c = colorbar;
            c.Label.FontSize = 30;
            c.Label.String = ip.Results.zName;
            clim([min(Z, [], "all") max(Z, [], "all")]);
            colormap("jet");
        case plottingOption.modelComparison
            plot_name = 'Model Output Comparison';
            [fig, ~] = getNextFigure(wIndex, plot_name, 'wCut', 2, 'hCut', 2);
            figure(fig)
            plot(cmp.actual, cmp.predicted, '.', 'MarkerSize', 3);
            xlabel('actual', 'FontSize', 30);
            ylabel('predicted', 'FontSize', 30);
            hold on
            x = min(cmp.actual): 0.1: max(cmp.actual);
            plot(x, x, '-r');
            hold off
        case plottingOption.featureRank
            featureImpotances(featureImpotances{:, 2} < 0, :) = [];
            sorted = sortrows(featureImpotances, 2);
            plot_name = 'Feature Importance Rank';
            [fig, ~] = getNextFigure(wIndex, plot_name, 'wCut', 2, 'hCut', 1);
            figure(fig)
            barh(sorted.features, sorted.importances);
     end
saveeps('test.png')
end