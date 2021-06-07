function [] = sheerLiquidityPremium(TTL, ISSUERNAME, ISSUERBONDS, PD, PARAMS)
figure
hold on
for tt = 1:numel(TTL)
for ii = 1:numel(ISSUERBONDS)
    ISSUERBONDS(ii).paymentdates = bondPaymentDates(ISSUERBONDS(ii).settledate, ISSUERBONDS(ii).maturity, 1, 'modifiedfollow');
    ISSUERBONDS(ii).yield        = getYield(ISSUERBONDS(ii));
end

zSpreads = bootstrapZspreads(ISSUERBONDS, PD);
discounts          = buildIssuerCurve(ISSUERBONDS, PD, zSpreads);
illiquidDiscUpper  = illiquidityCorrection(TTL(tt), discounts, zSpreads, PARAMS);

for ii = 1:numel(ISSUERBONDS)
    illiquidDiscLower = illiquidityCorrection(TTL(tt), buildIssuerCurve(ISSUERBONDS(ii), PD, zSpreads), zSpreads, PARAMS, 'lower');
    priceUpper(ii)   = priceBond(ISSUERBONDS(ii), illiquidDiscUpper);
    priceLower(ii)   = priceBond(ISSUERBONDS(ii), illiquidDiscLower);
    pricingError(ii) = priceLower(ii) - priceUpper(ii);
end

plot([ISSUERBONDS.maturity]', pricingError, '-o')

tau           = cellstr(TTL(tt));
txtLegend{tt} = ['τ = ' tau{1}];
end
title(ISSUERNAME)
legend(txtLegend)
end