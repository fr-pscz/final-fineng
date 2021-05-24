function B = findDiscount(DATES, DISCOUNT)
% function that computes the discounts of an array of dates given the
% discount curve and its corresponding dates
%
% INPUTS:
%        DATES:    array containing dates of interest in datenum format
%        DISCOUNT: struct containing dates and the discount curve where the first one is the settlement date
%
% OUTPUTS:
%        B: array containing the discounts of interest

zRates = disc2zero(DISCOUNT.y(2:end),DISCOUNT.t(2:end),DISCOUNT.t(1));
zRateDate = interp1(DISCOUNT.t(2:end),zRates,DATES);
B = zero2disc(zRateDate,DATES,DISCOUNT.t(1));

end % findDiscount

