function Z = bootstrapZspreads(MKTBOND,PD)
% BOOTSTRAPZSPREADS function that bootstraps the Z spreads
%
% INPUTS:
% MKTBOND: struct with the following fields:
%             - maturity
%             - valuedate
%             - settledate
%             - px
%             - coupon
%             - yield
%             - payment dates
%             - daycount
%
% PD: struct with dates and OIS-adjusted discounts 
%
% OUTPUTS: 
% Z: struct with the following fields:
%             - t: dates
%             - y: Z-spreads
%
% FUNCTIONS:
% getZeta

Z = getZeta(MKTBOND(1), PD);

for ii = 2:numel(MKTBOND)
    Z = getZeta(MKTBOND(ii), PD, Z);
end % cycle on all the available bonds from the market

end %bootstrapZspreads
