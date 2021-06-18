function PX = priceBond(MKTBOND, DISCCURVE)

% PRICEBOND computes the dirty price of a bond given a discount curve
%
% INPUTS: 
% MKTBOND: struct with the following fields:
%             - coupon
%             - payment dates
%             - daycount
%
% DISCCURVE:  struct containing the dates and discounts of the discounting curve  
%
%
%
% OUTPUTS: 
% PX:         dirty price of the given bond
%
% FUNCTIONS:
% findDiscount

deltas   = yearfrac(MKTBOND.paymentdates(1:end-1),MKTBOND.paymentdates(2:end),MKTBOND.daycount);
payments = MKTBOND.coupon.*100.*ones(numel(deltas),1).*deltas;
payments(end) = payments(end) + 100;

discounts = findDiscount(MKTBOND.paymentdates(2:end),DISCCURVE);

PX = sum(payments.*discounts);
end
