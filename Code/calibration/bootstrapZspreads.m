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

% Z-spread for the first market bond
Z = getZeta(MKTBOND(1), PD);

% cycle on all the available bonds from the market
for ii = 2:numel(MKTBOND)
    Z = getZeta(MKTBOND(ii), PD, Z);
end 

end %bootstrapZspreads
