function Y = getYield(MKTBOND)

% GETYIELD computes the yield of a given Bond
%
% INPUTS: 
% MKTBOND: struct containing the infromation of the bond in the following fields
%                       - settledate: settlement date 
%                       - paymentdates: array of payment dates of the coupons of the bond, considering next-buisness date convenction
%                       - coupon: array of coupons in percentage
%                       - daycount: daycount convenction used for the coupons
%                       - invoice: dirty price of the bond (if not present the function computes the clean price)
%
%
% OUTPUTS
% Y: Yield of the given bond 


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
try MKTBOND.invoice; % already have dirty price
    Y = fzero(@(y) f(y) - MKTBOND.invoice, 0);
catch % only have clean price
    Y = fzero(@(y)...
        f(y) - MKTBOND.px - MKTBOND.coupon.*100.*yearfrac(...
        MKTBOND.paymentdates(1),MKTBOND.settledate,MKTBOND.daycount)...
        , 0);
end
end % getYield
