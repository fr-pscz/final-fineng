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

%% Plot
plotCurve([PD; P])

%% Save output
scriptOutputs = {'PD', 'P', 'zD', 'z'};
save('data/curves.mat', scriptOutputs{:})
