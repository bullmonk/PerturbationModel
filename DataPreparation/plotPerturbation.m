function [windowIdx] = plotPerturbation(windowIdx, perturbation, normPerturbation, rho, plot_name)
    [fig, windowIdx] = getNextFigure(windowIdx, plot_name);
    figure(fig)
    tiledlayout(3, 1)
    ax1 = nexttile;
    histogram(perturbation);
    xlim([0 120])
    title(ax1, 'histogram of perturbation');
    xlabel(ax1, 'perturbation vlaue');
    ylabel(ax1, 'bin count');
    ax2 = nexttile;
    histogram(normPerturbation);
    xlim([0 0.3])
    title(ax2, 'histogram of normalized perturbation');
    xlabel(ax2, 'normalized perturbation vlaue');
    ylabel(ax2, 'bin count');    
    ax3 = nexttile;
    plot(rho, normPerturbation, '.', 'MarkerSize', 3);
    title(ax3, 'normalized perturbation - rho');
    xlabel(ax3, 'rho');
    ylabel(ax3,'normalized perturbation');
end