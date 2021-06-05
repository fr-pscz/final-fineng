% p1
% startPARAM = [0.13;0.001;0];

% p2
% startPARAM = [0.1;0.001;0];

% p3
% startPARAM = [0.1;0.01;0]; WARNING

% p4
% startPARAM = [0.01;0.001;0]; WARNING

% p5
% startPARAM = [1;0.1;0];
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
    mktSwaption(ii).MHWpricer = priceFunctionCSSMHW(mktSwaption(ii),PD, P);
end

%% Plot
figure
hold on
plot(1:numel(mktSwaption), [mktSwaption.px], '--d', 'LineWidth', 2)
paramLabel = {'Market'};
multipleSolutions = {'p1.mat','p2.mat','p3.mat','p4.mat','p5.mat','pPaper.mat'};
PX = NaN.*[mktSwaption.px];
for ii = 1:numel(multipleSolutions)
    load(multipleSolutions{ii});
    for jj = 1:numel(mktSwaption)
        PX(jj) = mktSwaption(jj).MHWpricer(params);
    end
    plot(1:numel(mktSwaption), PX, 'LineWidth', 2);
    paramLabel{ii+1} = ['a = ' num2str(params(1)) ',σ = ' num2str(params(2)) ',γ = ' num2str(params(3))];
end

title('Diagonal Swaptions prices')
ylim([0 0.035])
legend(paramLabel)
xlabel('Option expiry')
ylabel('Price')