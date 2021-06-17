clear
clc
addpath('utilities')
addpath('calibration')
addpath('pricing')
addpath('data')
addpath('plots')

%% Load data
load('market.mat')
load('curvesConvexity.mat')
load('bondsBNPP.mat')
load('bondsSantander.mat')
load('paramsConvexity.mat')

%% Tau
ttl = [calweeks(2); calmonths(2)];

%% BNPP
liquiditySpread(ttl, 'BNPP', mktBondBNPP, PD, params);

%% Santander
liquiditySpread(ttl, 'Santander', mktBondSantander, PD, params);