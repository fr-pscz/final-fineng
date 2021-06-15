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

%% Get market prices
for ii = 1:numel(mktSwaption)
    mktSwaption(ii).strike = swapRate(mktSwaption(ii), PD, P);
    mktSwaption(ii).px     = priceSwaption(mktSwaption(ii), PD, P);
end

%% Inspect error
calibrateMHWtest(mktSwaption, PD, P);
