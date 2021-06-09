function [] = plotCurve(CURVES)
    figure
    hold on
    for ii = 1:numel(CURVES)
        plot(CURVES(ii).t, CURVES(ii).y, '.-', 'LineWidth', 2, 'MarkerSize', 10)
        if ~isempty(CURVES(ii).name)
            legendText{ii} = CURVES(ii).name;
        else
            legendText{ii} = ["Discount curve " num2str(ii)];
        end
    end
    legend(legendText, 'Location', 'southwest')
    title(['Discounts at settle date: ' datestr(CURVES(1).t(1))])
    datetick
    ylabel('B(t,T)')
    xlabel('T')
    set(gca, 'FontSize', 15)
    box on
    grid on
end