function price = priceSwaption(MKTSWAPTION, DISCOUNT, PSEUDODISCOUNT)
% function that computes the price of a swaption using the Bachelier
% formula
%
% INPUTS: 
%        MKTSWAPTION: struct of the swaption containing valuedate,
%        settledate, optionmaturity, swapmaturity, impliedvol
%        DISCOUNT: struct containing dates and the discount curve where the
%        first element is the settlement date
%        PSEUDODISCOUNT: struct containing dates and the pseudodiscount
%        curve where the first element is the settlement date
%
% OUTPUTS:
%        MKTSWAPTION: same struct as the one in input but with the
%        additional field px relative to the market price of the swaption
% 
% FUNCTIONS: 
%        paymentDates: it computes payment dates at regular intervals
%        findDiscount: computes the discounts of an array of dates given the
%        discount curve and its corresponding dates


% daycount conventions and tenor of the swaption
act365 = 3;
tenor = yearfrac(MKTSWAPTION.optionmaturity,MKTSWAPTION.swapmaturity,act365);

sRate = swapRate(MKTSWAPTION, DISCOUNT, PSEUDODISCOUNT);

%% Swaption Price
freqFixed = 1;
fixedDates = paymentDates(MKTSWAPTION.optionmaturity, MKTSWAPTION.swapmaturity, freqFixed, 'follow');
fixedDiscounts = findDiscount(fixedDates,DISCOUNT);

c = @(m,s) 1./s*(1 - 1/(1+s./m)^(tenor));
strikeATM = sRate; 

ttm = yearfrac(MKTSWAPTION.settledate,MKTSWAPTION.optionmaturity,act365); % time to maturity
d = (sRate - strikeATM)/(MKTSWAPTION.impliedvol*sqrt(ttm));
m = 1; % in the EUR market

% swaption price
% MKTSWAPTION.px = fixedDiscounts(end)*c(m,swapRate)*((strikeATM - swapRate)*normcdf(-d) + MKTSWAPTION.impliedvol*sqrt(ttm)*normpdf(d));
price = fixedDiscounts(end)*c(m,sRate)*((strikeATM - sRate)*normcdf(-d) + MKTSWAPTION.impliedvol*sqrt(ttm)*normpdf(d));


end % priceSwaption
