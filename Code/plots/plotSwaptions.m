function [] = plotSwaptions(MKT, MHW)
    plot(1:numel(MKT), 100.*MKT, '.-', 'LineWidth', 2, 'MarkerSize', 20)
    hold on
    plot(1:numel(MHW), 100.*MHW, '.-', 'LineWidth', 2, 'MarkerSize', 20)
    legend('Market prices','Multi-Hull-White prices', 'Location', 'southwest')
    title('Diagonal receiver swaption prices')
    ylabel('CSS prices')
    xlabel('Option tenor')
    set(gca, 'FontSize', 15)
    xlim([1 numel(MKT)])
    ytickformat('percentage')
    ylim([0 3.5])
    box on
    grid on
end
