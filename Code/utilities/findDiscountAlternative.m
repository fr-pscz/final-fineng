function B = findDiscountAlternative(DATES, DISCOUNT, FLAG)
% function that computes the discounts of an array of dates given the
% discount curve and its corresponding dates and the chosen interpolation
% rule
%
% INPUTS:
%        DATES:    array containing dates of interest in datenum format
%        DISCOUNT: struct containing dates and the discount curve where the first one is the settlement date
%        FLAG: select interpolation rule 
%              - if no flag is given, uses linear on zero rates 
%              - 1 spline on zero rates
%              - 2 spline on discounts
%              - 3 log linear on discounts                   
%
%
% OUTPUTS:
%        B: array containing the discounts of interest

zRatesConv = 3;    % Act/365
compoundConv = -1; % Continuous

if nargin < 3

    zRates = disc2zero(DISCOUNT.y(2:end),DISCOUNT.t(2:end),DISCOUNT.t(1),compoundConv,zRatesConv);
    zRateDate = interp1(DISCOUNT.t,[zRates(1);zRates],DATES);
    B = zero2disc(zRateDate,DATES,DISCOUNT.t(1),compoundConv,zRatesConv);

elseif FLAG == 1 % spline on zero rates

    zRates = disc2zero(DISCOUNT.y(2:end),DISCOUNT.t(2:end),DISCOUNT.t(1),compoundConv,zRatesConv);
    zRateDate = interp1(DISCOUNT.t,[zRates(1);zRates],DATES, 'spline');
    B = zero2disc(zRateDate,DATES,DISCOUNT.t(1),compoundConv,zRatesConv);

elseif FLAG == 2 % spline on discounts

    B = interp1(DISCOUNT.t, DISCOUNT.y, DATES, 'spline');

else 
    logDisc = log(DISCOUNT.y);
    logDiscDates = interp1(DISCOUNT.t ,logDisc ,DATES);
    B = exp(logDiscDates);

end










end % findDiscount