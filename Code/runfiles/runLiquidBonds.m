clear
clc
addpath('utilities')
addpath('calibration')
addpath('pricing')
addpath('data')

%% Load data
load('market.mat')
load('curves.mat')
load('bondsBNPP.mat')
load('bondsSantander.mat')
load('params.mat')

ttl = [calweeks(2); calmonths(2)];

%% BNPP
%issuerLiquidityAdj(ttl(2), 'BNPP', mktBondBNPP, PD, params);
sheerLiquidityPremium(ttl, 'BNPP', mktBondBNPP, PD, params);
%% Santander
%issuerLiquidityAdj(ttl(2), 'Santander', mktBondSantander, PD, params);
sheerLiquidityPremium(ttl, 'Santander', mktBondSantander, PD, params);
