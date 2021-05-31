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

a = linspace(0.001,1, N);
s = linspace(0.1,10, N);
g = linspace(0,1,N);


xtest    = linspace(-15,15,3000);

oldDistance = 4000;
for aii = 1:N
    for sii = 1:N
        for gii = 1:N
            ytest = F(xtest, [a(aii),s(sii),g(gii)]);
            idx = find(ytest == min(ytest));
            if idx(1) == 1 || idx(end) == 3000
                continue
            else
                distance = abs(idx(1) - 2000);
                if distance < oldDistance
                    params = [a(aii),s(sii),g(gii)];
                    oldDistance = distance;
                end
            end
        end
    end
end


xplot = linspace(3,10,1000);
yplot = F(xplot, params);
plot(xplot,yplot, 'LineWidth', 1.5)
