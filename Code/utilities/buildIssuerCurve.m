function BBAR = buildIssuerCurve(MKTBOND,PD,ZSPREAD)

% BUILDISSUERCURVE builds the discounting curve for the considered issuer taking into account the credit risk. 
%
% INPUTS: 
% MKTBOND: array of the avaiable liquid bonds of some issuer. Each bond is a struct with the following fields:
%                - maturity
%                - valuedate
%                - settledate
%                - px
%                - coupon
%                - yield
%                - payment dates
%                - daycount
%
% PD:      struct with dates and OIS-adjusted discounts
% 
% ZSPREAD: struct with the following fields:
%               - t: dates
%               - y: Z-spreads
%
% OUTPUTS:
% BBAR: credit-risk adjusted discounting curve for the considered issuer.
%
% FUNCTIONS:
% findDiscount

convSpreads = 3; % Act/365

dates = [];
for ii = 1:numel(MKTBOND)
    dates = [dates; MKTBOND(ii).paymentdates(2:end)];
end

dates = sort(dates,'ascend');
dates = unique(dates);

BBAR.y = findDiscount(dates, PD).*exp(...
            -interp1(ZSPREAD.t, ZSPREAD.y, dates)...
            .*yearfrac(MKTBOND(1).settledate, dates, convSpreads));
BBAR.t = dates;
        

if dates(1) ~= MKTBOND(1).settledate
    BBAR.y = [1; BBAR.y];
    BBAR.t = [MKTBOND(1).settledate; BBAR.t];
end
end
