function S = computeS(MKTSWAPTION, DISCOUNT, PSEUDODISCOUNT);
%
%
%
%
%

act365 = 3;
act360 = 2;

%% Payment dates

% generate an array containing the dates of the floating payments and the
% corresponding discounts
freqFloating = 2;
floatingDates = paymentDates(MKTSWAPTION.optionmaturity, MKTSWAPTION.swapmaturity, freqFloating, 'follow');
floatingDiscounts = findDiscount(floatingDates,DISCOUNT);

% generate an array containing the dates of the fixed payments and the
% corresponding discounts
freqFixed = 1;
fixedDates = paymentDates(MKTSWAPTION.optionmaturity, MKTSWAPTION.swapmaturity, freqFixed, 'follow');
fixedDiscounts = findDiscount(fixedDates,DISCOUNT);


% forward fixed discount wrt option maturity
fwdFixedDiscountsAlfa = fixedDiscounts(2:end)./fixedDiscounts(1); 
% forward floating discount wrt option maturity
fwdFloatingDiscountsAlfa = floatingDiscounts/floatingDiscounts(1);


ttm = yearfrac(MKTSWAPTION.settledate,MKTSWAPTION.optionmaturity,act365); % time to maturity
xi = @(p) (sqrt(p(2).^2*(1 - exp(-2*p(1).*ttm))/(2*p(1)))).*(p(1)~=0) + sqrt(p(2).*ttm).*(p(1)==0);

dFixed = yearfrac(MKTSWAPTION.optionmaturity, fixedDates(2:end), act365);
vFixed = @(p) xi(p).*(1 - exp(-p(1).*dFixed))./p(1);
zetaFixed = @(p) (1 - p(3)).*vFixed(p);

dFloating = yearfrac(MKTSWAPTION.optionmaturity, floatingDates(2:end), act365);
vFloating = @(p) xi(p).*(1 - exp(-p(1).*dFloating))./p(1);
zetaFloating = @(p) (1 - p(3)).*vFloating(p);


dFloatingAlfa = yearfrac(MKTSWAPTION.optionmaturity, floatingDates(1:end-1), act365);
vFloatingAlfa = @(p) xi(p).*(1 - exp(-p(1).*dFloatingAlfa))./p(1);

dFloatingAlfaShift = yearfrac(MKTSWAPTION.optionmaturity, floatingDates(2:end), act365);
vFloatingAlfaShift = @(p) xi(p)*(1 - exp(-p(1).*dFloatingAlfaShift))./p(1);

nu = @(p)  vFloatingAlfa(p) - vFloatingAlfaShift(p);


%% Spread
% floating forward discounts
fwdFloatingDiscounts = floatingDiscounts(2:end)./floatingDiscounts(1:end-1);

% pseudodiscounts and forward pseudodiscounts at floating dates
floatingPseudoDiscounts = findDiscount(floatingDates,PSEUDODISCOUNT);
fwdFloatingPseudoDiscounts = floatingPseudoDiscounts(2:end)./floatingPseudoDiscounts(1:end-1);

spread = fwdFloatingDiscounts./fwdFloatingPseudoDiscounts;

delta = yearfrac(fixedDates(1:end-1),fixedDates(2:end),act360);


S = @(x,p) (sum(fwdFloatingDiscountsAlfa(1:end-1).*spread.*exp(-nu(p).*x - nu(p).^2/2)) ...
            - sum(fwdFloatingDiscountsAlfa(2:end).*exp(-zetaFloating(p).*x - zetaFloating(p).^2/2))) ...
            /sum(delta.*fwdFixedDiscountsAlfa.*exp(-zetaFixed(p).*x - zetaFixed(p).^2/2));
        
end

