clear all
N = 20;
gridA = linspace(11/100, 20/100, N);
gridS = linspace(1/100, 1.7/100, N);

[A,S] = meshgrid(gridA,gridS);

figure

for n = 1:6
    load(['err' num2str(n) '.mat'])
    subplot(2,3,n)
    surf(A,S,E, 'EdgeAlpha', 0.4)
    xlabel('a')
    ylabel('σ')
    zlabel('Error')
    idxs = find(E<1e-5);

    hold on

    for ii = 1:numel(idxs)
        plot3(A(idxs(ii)),S(idxs(ii)),E(idxs(ii)), 'r.', 'MarkerSize', 30)
    end

    minIdx = find(E == min(min(E)));
    plot3(A(minIdx),S(minIdx),E(minIdx), 'g.', 'MarkerSize', 30)
    title(['Minimum error = ' num2str(E(minIdx))])
end