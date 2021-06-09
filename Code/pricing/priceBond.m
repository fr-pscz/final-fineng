function PX = priceBond(MKTBOND, DISCCURVE)

deltas   = yearfrac(MKTBOND.paymentdates(1:end-1),MKTBOND.paymentdates(2:end),MKTBOND.daycount);
payments = MKTBOND.coupon.*100.*ones(numel(deltas),1).*deltas;
payments(end) = payments(end) + 100;

discounts = findDiscount(MKTBOND.paymentdates(2:end),DISCCURVE);

PX = sum(payments.*discounts);
end
