function [] = issuerLiquidityAdj(TTL, ISSUERNAME, ISSUERBONDS, PD, PARAMS)

for ii = 1:numel(ISSUERBONDS)
    ISSUERBONDS(ii).paymentdates = bondPaymentDates(ISSUERBONDS(ii).settledate, ISSUERBONDS(ii).maturity, 1, 'modifiedfollow');
    ISSUERBONDS(ii).yield        = getYield(ISSUERBONDS(ii));
end

figure
zSpreads = bootstrapZspreads(ISSUERBONDS, PD);
plot(datetime(zSpreads.t, 'ConvertFrom', 'datenum'), zSpreads.y)
title(ISSUERNAME)

discounts     = buildIssuerCurve(ISSUERBONDS, PD, zSpreads);
illiquidDisc  = illiquidityCorrection(TTL, discounts, zSpreads, PARAMS);
figure
plot(datetime(discounts.t, 'ConvertFrom', 'datenum'), discounts.y)
title(ISSUERNAME)

figure
plot(datetime(discounts.t, 'ConvertFrom', 'datenum'), discounts.y, '-o')
hold on
plot(datetime(illiquidDisc.t, 'ConvertFrom', 'datenum'), illiquidDisc.y, '-o')
legend('Liquid', 'Illiquid')
title(ISSUERNAME)
end
