clear
clc
addpath('utilities')
addpath('calibration')
addpath('pricing')
addpath('data')


%% Load data
load('market.mat')

PD = bootstrapEONIA(mktOIS);
zD = disc2zero(PD.y(2:end), PD.t(2:end), PD.t(1), -1, 3);

P  = bootstrapEUR6M(mktFRA, mktSwap, PD);
z  = disc2zero(P.y(2:end), P.t(2:end), P.t(1), -1, 3);