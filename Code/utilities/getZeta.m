function Z = getZeta(MKTBOND, PD, Z)

% GETZETA Updates the bootstrap of the Zspreads up to the given bond maturity. 
%
% INPUTS: 
% MKTBOND: struct containing the infromation of the bond in the following fields
%                       - settledate:   settlement date 
%                       - paymentdates: array of payment dates of the coupons of the bond, considering next-buisness date convenction
%                       - coupon:       array of coupons in percentage
%                       - daycount:     daycount convenction used for the coupons
%                       - px:           clean price of the bond
% PD:      struct with dates and discounts of OIS rate
%
% Z:       Zspread curve already bootstrapped: struct with the following fields:
%                       - t: dates
%                       - y: Z-spreads  
%
% OUTPUTS: 
% Z:       Zspread curve updated up to the given bond maturity.
%
% FUNCTIONS: 
% findDiscount

convSpreads = 3; % Act/365
% compute payment periods and coupons+notional
deltas   = yearfrac(MKTBOND.paymentdates(1:end-1),MKTBOND.paymentdates(2:end),MKTBOND.daycount);
payments = MKTBOND.coupon.*100.*ones(numel(deltas),1).*deltas;
payments(end) = payments(end) + 100;
discounts = findDiscount(MKTBOND.paymentdates(2:end), PD);
dirtyPX = MKTBOND.px + MKTBOND.coupon.*100.*yearfrac(MKTBOND.paymentdates(1),MKTBOND.settledate,MKTBOND.daycount);

if nargin < 3
    %% First bond
    f = @(z) sum(...
        payments.*discounts.*exp(-z.*yearfrac(MKTBOND.settledate, MKTBOND.paymentdates(2:end),convSpreads))...
        );
    
    % find Z-Spread up to first maturity
    zSpread = fzero(@(z) f(z) - dirtyPX, 0);
    
    Z.y = [zSpread;zSpread];
    Z.t = [MKTBOND.settledate; MKTBOND.maturity];
else
    %% Following bonds
    idxPrev = find(MKTBOND.paymentdates(2:end) <= Z.t(end), 1, 'last');
    discounts(1:idxPrev) = ...
        discounts(1:idxPrev).*exp(...
            -interp1(Z.t, Z.y, MKTBOND.paymentdates(2:idxPrev+1))...
            .*yearfrac(MKTBOND.settledate, MKTBOND.paymentdates(2:idxPrev+1),convSpreads));
    f = @(z) sum(...
        payments(idxPrev+1:end).*discounts(idxPrev+1:end).*...
        exp(...
           -interp1([Z.t(end);MKTBOND.maturity], [Z.y(end); z], MKTBOND.paymentdates(idxPrev+2:end)).*...
           yearfrac(MKTBOND.settledate, MKTBOND.paymentdates(idxPrev+2:end),convSpreads)...
        ));
    
    Z.y(end+1) = fzero(@(z) f(z) - dirtyPX + sum(payments(1:idxPrev).*discounts(1:idxPrev)), 0);
    Z.t(end+1) = MKTBOND.maturity;
end

end % getZeta
