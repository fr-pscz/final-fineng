clear
clc
addpath('utilities')
addpath('calibration')
addpath('pricing')
addpath('data')
addpath('plots')


%% Load data
load('market.mat')

PD      = bootstrapEONIA(mktOIS);
PD.name = 'EONIA';
zD = disc2zero(PD.y(2:end), PD.t(2:end), PD.t(1), -1, 3);

P  = bootstrapEUR6M(mktFRA, mktSwap, PD);
P.name = 'Euribor 6M';
z  = disc2zero(P.y(2:end), P.t(2:end), P.t(1), -1, 3);

figure
%% Plot
plotCurve([PD; P])


%% Save output
scriptOutputs = {'PD', 'P', 'zD', 'z'};
save('data/curves.mat', scriptOutputs{:})

%% Alternative interpolation
figure
P  = bootstrapAlternativeEUR6M(mktFRA, mktSwap, PD);
plot(P.t, P.y, '-', 'LineWidth', 2);

for ii = 1:3
    hold on
     P1  = bootstrapAlternativeEUR6M(mktFRA, mktSwap, PD, ii); 
     plot(P1.t, P1.y, '-', 'LineWidth', 2);
     fprintf('Max interpolation error using FLAG = %d is %e \n ', [ii; max(abs(P.y - P1.y))] )
end
grid on
datetick
legend('Linear on zero rates', 'Spline on zero rates', 'Spline on discounts', 'Log-linear on discounts');
