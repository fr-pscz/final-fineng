function PX = priceBond(MKTBOND, DISCCURVE)

% PRICEBOND computes the clean price of the given Bond
%
% INPUTS: 
% MKTBOND: struct containing the infromation of the bond in the following fields
%                       - settledate:   settlement date 
%                       - paymentdates: array of payment dates of the coupons of the bond, considering next-buisness date convenction
%                       - coupon:       array of coupons in percentage
%                       - daycount:     daycount convenction used for the coupons
%
% OUTPUTS: 
% PX:      clean price of the given bond.
%
% FUNCTIONS:
% findDiscount

deltas   = yearfrac(MKTBOND.paymentdates(1:end-1),MKTBOND.paymentdates(2:end),MKTBOND.daycount);
payments = MKTBOND.coupon.*100.*ones(numel(deltas),1).*deltas;
payments(end) = payments(end) + 100;

discounts = findDiscount(MKTBOND.paymentdates(2:end),DISCCURVE);

PX = sum(payments.*discounts);
end
