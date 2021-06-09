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

%% Minimize error
params = calibrateMHW(mktSwaption, PD, P);

%% Get model prices
priceMHW = priceSwaptionMHW(mktSwaption,PD, P, params);

%% Plot
plotSwaptions([mktSwaption.px], priceMHW)
disp('Parameters:')
disp(['   > a = ' num2str(params(1))])
disp(['   > σ = ' num2str(params(2))])
disp(['   > γ = ' num2str(params(3))])
%% Save output
save('data/params.mat', 'params')
