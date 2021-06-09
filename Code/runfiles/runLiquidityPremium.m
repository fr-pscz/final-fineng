clear
clc
addpath('utilities')
addpath('calibration')
addpath('pricing')
addpath('data')
addpath('plots')

%% Load data
load('market.mat')
load('curves.mat')
load('bondsBNPP.mat')
load('bondsSantander.mat')
load('params.mat')

%% Tau
ttl = [calweeks(2); calmonths(2)];

%% BNPP
sheerLiquidityPremium(ttl, 'BNPP', mktBondBNPP, PD, params);

%% Santander
sheerLiquidityPremium(ttl, 'Santander', mktBondSantander, PD, params);