function BBAR = buildIssuerCurve(MKTBOND,PD,ZSPREAD)

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
