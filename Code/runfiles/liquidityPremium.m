function [] = liquidityPremium(TTL, ISSUERNAME, ISSUERBONDS, PD, PARAMS)

% Initialize plot
figure
hold on

% Compute payment dates given maturity
for ii = 1:numel(ISSUERBONDS)
    ISSUERBONDS(ii).paymentdates = bondPaymentDates(ISSUERBONDS(ii).settledate, ISSUERBONDS(ii).maturity, 1, 'modifiedfollow');
    ISSUERBONDS(ii).yield        = getYield(ISSUERBONDS(ii));
end

% Bootstrap Z-Spreads to obtain the issuer-specific discount curve
zSpreads  = bootstrapZspreads(ISSUERBONDS, PD); 
discounts = buildIssuerCurve(ISSUERBONDS, PD, zSpreads);

for tt = 1:numel(TTL)
    % The upper bound is independent of which specific bond is being priced
    illiquidDiscUpper = illiquidityCorrection(TTL(tt), discounts, zSpreads, PARAMS);

    for ii = 1:numel(ISSUERBONDS)
        % The lower bound liquidity premium is different for each bond, even
        % when payments fall on the same date
        illiquidDiscLower = illiquidityCorrection(TTL(tt), buildIssuerCurve(ISSUERBONDS(ii), PD, zSpreads), zSpreads, PARAMS, 'lower');
    
        priceUpper(ii)   = priceBond(ISSUERBONDS(ii), illiquidDiscUpper);
        priceLower(ii)   = priceBond(ISSUERBONDS(ii), illiquidDiscLower);
        pricingError(ii) = priceLower(ii) - priceUpper(ii);
    end
    
    %% Plot
    plot([ISSUERBONDS.maturity]', pricingError./100, '.-', 'LineWidth', 2, 'MarkerSize', 10)
    
    % prepare legend
    tau           = cellstr(TTL(tt));
    legendText{tt} = ['τ = ' tau{1}];
end

%% Plot
title([ISSUERNAME ' price difference between upper and lower bounds'])
legend(legendText, 'Location', 'northwest')
datetick
ylabel('Difference')
xlabel('Maturity')
set(gca, 'FontSize', 12)
box on
grid on
end
