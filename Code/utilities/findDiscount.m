function B = findDiscount(DATES, DISCOUNT)
%FINDDISCOUNT function that computes the discounts of an array of dates given the
% discount curve and its corresponding dates
%
% INPUTS:
%        DATES:    array containing dates of interest in datenum format
%        DISCOUNT: struct containing dates and the discount curve where the first one is the settlement date
%
% OUTPUTS:
%        B: array containing the discounts of interest

zRatesConv = 3;    % Act/365
compoundConv = -1; % Continuous

zRates = disc2zero(DISCOUNT.y(2:end),DISCOUNT.t(2:end),DISCOUNT.t(1),compoundConv,zRatesConv);
zRateDate = interp1(DISCOUNT.t,[zRates(1);zRates],DATES);
B = zero2disc(zRateDate,DATES,DISCOUNT.t(1),compoundConv,zRatesConv);

end % findDiscount
