clear
clc
addpath('utilities')
addpath('calibration')
addpath('pricing')
addpath('data.mat')
load('market.mat')
load('curves.mat')

F = fun(mktSwaption(1), PD, P);
N = 10;

a = linspace(0.222,0.224, N);
s = linspace(1.1,1.3, N);
g = 0;

xplot = linspace(3,10,1000);

oldDistance = 4000;
for aii = 1:N
    for sii = 1:N
        yplot = F(xplot, [a(aii), s(sii), g]);
        distance = abs(yplot(1) + 1.00099) + abs(yplot(end) + 1.001145);
        if distance < oldDistance
            params = [a(aii),s(sii),g];
            oldDistance = distance;
        end
    end
end

plot(xplot, F(xplot, params)+1);
ylim([-1.20 -0.95].*1e-3)
title(['a = ' num2str(params(1)) ',σ = ' num2str(params(2)) ',γ = ' num2str(params(3))])
