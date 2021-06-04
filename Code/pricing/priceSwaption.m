function PX = priceSwaption(MKTSWAPTION, PD, P)
%PRICESWAPTION Computes the price of a swaption using the Bachelier model
%
% INPUTS:
% MKTSWAPTION: struct with following fields:
%             - settledate
%             - optionmaturity
%             - swapmaturity
%             - strike
%             - impliedvol
%
%          PD: struct with dates and OIS-adjusted discounts
%           P: struct with dates and EUR6M pseudodiscounts 
%
% OUTPUTS: 
%        PX: scalar price
%
% FUNCTIONS:
%  swapRate, paymentDates, findDiscount

% daycount conventions and tenor of the swaption
optionConv = 3;
tenor = round(yearfrac(MKTSWAPTION.optionmaturity,MKTSWAPTION.swapmaturity,optionConv));

sRate = swapRate(MKTSWAPTION, PD, P);

%% Swaption Price
payoffDiscount = findDiscount(MKTSWAPTION.optionmaturity,PD);
m = 1; % in the EUR market

c = @(s) 1./s*(1 - 1/(1+s./m)^(tenor));
K = MKTSWAPTION.strike; 

ttm = yearfrac(MKTSWAPTION.settledate,MKTSWAPTION.optionmaturity,optionConv); % time to maturity
d = (sRate - K)/(MKTSWAPTION.impliedvol*sqrt(ttm));

% swaption price
PX = payoffDiscount*c(sRate)*((K - sRate)*normcdf(-d) + MKTSWAPTION.impliedvol*sqrt(ttm)*normpdf(d));

end % priceSwaption
