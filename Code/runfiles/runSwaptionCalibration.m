clear
clc
addpath('utilities')
addpath('calibration')
addpath('pricing')
addpath('data')

%% Load data
load('market.mat')
load('curves.mat')

%% Get market prices
for ii = 1:numel(mktSwaption)
    mktSwaption(ii).strike = swapRate(mktSwaption(ii), PD, P);
    mktSwaption(ii).px     = priceSwaption(mktSwaption(ii), PD, P);
end

%% Minimize error
params = calibrateMHW(mktSwaption, PD, P);

%% Get model prices
priceMHW = priceSwaptionMHW(mktSwaption,PD, P, params);

%% Plot
figure
plot(1:numel(mktSwaption), [mktSwaption.px])
hold on
plot(1:numel(mktSwaption), priceMHW)