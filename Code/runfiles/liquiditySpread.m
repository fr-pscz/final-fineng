function [] = liquiditySpread(TTL, ISSUERNAME, ISSUERBONDS, PD, PARAMS)

% Compute payment dates given maturity
for ii = 1:numel(ISSUERBONDS)
    ISSUERBONDS(ii).paymentdates = bondPaymentDates(ISSUERBONDS(ii).settledate, ISSUERBONDS(ii).maturity, 1, 'modifiedfollow');
    ISSUERBONDS(ii).yield        = getYield(ISSUERBONDS(ii));
end

% Initialize plot
figure
hold on
plot([ISSUERBONDS.maturity], 1e4.*[ISSUERBONDS.yield], '.-', 'LineWidth', 2, 'MarkerSize', 10)
legendText{1} = 'Liquid bonds';

% Bootstrap Z-Spreads to obtain the issuer-specific discount curve
zSpreads  = bootstrapZspreads(ISSUERBONDS, PD); 
discounts = buildIssuerCurve(ISSUERBONDS, PD, zSpreads);

for tt = 1:numel(TTL)
    % The upper bound is independent of which specific bond is being priced
    illiquidDiscUpper = illiquidityCorrection(TTL(tt), discounts, zSpreads, PARAMS);

    for ii = 1:numel(ISSUERBONDS)
        tmpIlliquidBond = ISSUERBONDS(ii);
        tmpIlliquidBond.invoice = priceBond(ISSUERBONDS(ii), illiquidDiscUpper);
        yieldIlliquid(ii)   = getYield(tmpIlliquidBond);
    end
    
    %% Plot
    plot([ISSUERBONDS.maturity]', 1e4.*yieldIlliquid, '.-', 'LineWidth', 2, 'MarkerSize', 10)
    
    % prepare legend
    tau           = cellstr(TTL(tt));
    legendText{tt+1} = ['τ = ' tau{1}];
end

%% Plot
title([ISSUERNAME ' yields'])
legend(legendText, 'Location', 'northwest')
datetick
ylabel('Yield (bps)')
xlabel('Maturity')
box on
grid on
end
