function Y = getYield(MKTBOND)

convYield = 3; % Act/365
% compute payment periods and coupons+notional
deltas   = yearfrac(MKTBOND.paymentdates(1:end-1),MKTBOND.paymentdates(2:end),MKTBOND.daycount);
payments = MKTBOND.coupon.*100.*ones(numel(deltas),1).*deltas;
payments(end) = payments(end) + 100;
% function handle for dirty price
f = @(y) sum(...
    payments.*exp(-y.*yearfrac(MKTBOND.settledate, MKTBOND.paymentdates(2:end),convYield))...
    );
% find yield
Y = fzero(@(y)...
    f(y) - MKTBOND.px - MKTBOND.coupon.*yearfrac(...
    MKTBOND.paymentdates(1),MKTBOND.settledate,MKTBOND.daycount)...
    , 0);
end % getYield
