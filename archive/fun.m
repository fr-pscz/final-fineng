function F = fun(MKTSWAPTION, DISCOUNT, PSEUDODISCOUNT)
%
%
%
%

act365 = 3;
act360 = 2;
eu30 = 6;

%% Payment dates

% generate an array containing the dates of the floating payments and the
% corresponding discounts
freqFloating = 2;
% floatingDates = paymentDates(MKTSWAPTION.optionmaturity, MKTSWAPTION.swapmaturity, freqFloating, 'follow');
floatingDates = paymentDatesSwaption(MKTSWAPTION, freqFloating);
floatingDiscounts = findDiscount(floatingDates,DISCOUNT);

% generate an array containing the dates of the fixed payments and the
% corresponding discounts
freqFixed = 1;
% fixedDates = paymentDates(MKTSWAPTION.optionmaturity, MKTSWAPTION.swapmaturity, freqFixed, 'follow');
fixedDates = paymentDatesSwaption(MKTSWAPTION, freqFixed);
fixedDiscounts = findDiscount(fixedDates,DISCOUNT); % ok


% forward fixed discount wrt option maturity
fwdFixedDiscountsAlfa = fixedDiscounts(2:end)/fixedDiscounts(1);  % fwd rispetto a alfa % num starts from alfa+1
% forward floating discount wrt option maturity
fwdFloatingDiscountsAlfa = floatingDiscounts(2:end-1)/floatingDiscounts(1);  % fwd rispetto a alfa % num starts from alfa+1

% array of delta between all fixed payment dates
delta = yearfrac(fixedDates(1:end-1),fixedDates(2:end),eu30);


K = swapRate(MKTSWAPTION, DISCOUNT, PSEUDODISCOUNT);
c = delta(1:end-1)*K;
c = [c; 1 + delta(end)*K];  % ok 

% p = [a; sigma; gamma];
% p = [p(1); p(2); p(3)];

%% f(x)
ttm = yearfrac(MKTSWAPTION.settledate,MKTSWAPTION.optionmaturity,act365); % time to maturity

xi = @(p) (sqrt(p(2).^2*(1 - exp(-2*p(1).*ttm))/(2*p(1)))).*(p(1)~=0) + sqrt(p(2).^2.*ttm).*(p(1)==0);  % ok

dFixed = yearfrac(MKTSWAPTION.optionmaturity, fixedDates(2:end), act365);
vFixed = @(p) xi(p).*(1 - exp(-p(1).*dFixed))./p(1);
zetaFixed = @(p) (1 - p(3)).*vFixed(p); %ok 

dFloating = yearfrac(MKTSWAPTION.optionmaturity, floatingDates(2:end-1), act365);
vFloating = @(p) xi(p).*(1 - exp(-p(1).*dFloating))./p(1);
zetaFloating = @(p) (1 - p(3)).*vFloating(p); % ok


fwdFloatingDiscountsSumAlfa = [1; fwdFloatingDiscountsAlfa];  % num starts from alfa

%% Spread

% floating forward discounts
fwdFloatingDiscounts = floatingDiscounts(2:end)./floatingDiscounts(1:end-1);

% pseudodiscounts and forward pseudodiscounts at floating dates
floatingPseudoDiscounts = findDiscount(floatingDates,PSEUDODISCOUNT);
fwdFloatingPseudoDiscounts = floatingPseudoDiscounts(2:end)./floatingPseudoDiscounts(1:end-1);

spread = fwdFloatingDiscounts./fwdFloatingPseudoDiscounts;  % ok 


dFloatingAlfa = yearfrac(MKTSWAPTION.optionmaturity, floatingDates(1:end-1), act365);
vFloatingAlfa = @(p) xi(p).*(1 - exp(-p(1).*dFloatingAlfa))./p(1);

dFloatingAlfaShift = yearfrac(MKTSWAPTION.optionmaturity, floatingDates(2:end), act365);
vFloatingAlfaShift = @(p) xi(p)*(1 - exp(-p(1).*dFloatingAlfaShift))./p(1);

nu = @(p)  vFloatingAlfa(p) - p(3).*vFloatingAlfaShift(p);

F = @(x,p) sum(c.*fwdFixedDiscountsAlfa.*exp(-zetaFixed(p)*x - (zetaFixed(p).^2)/2)) ...
    + sum(fwdFloatingDiscountsAlfa.*exp(-zetaFloating(p)*x - (zetaFloating(p).^2)/2)) ...
    - sum(spread.*fwdFloatingDiscountsSumAlfa.*exp(-nu(p)*x - (nu(p).^2)/2));


end % fun
