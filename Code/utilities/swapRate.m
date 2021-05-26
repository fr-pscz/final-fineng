function RATE = swapRate(MKTSWAPTION, DISCOUNT, PSEUDODISCOUNT)
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


%% Fixed and floating forward discounts

% array of delta between all fixed payment dates. The first element is wrt
% the option maturity
delta = yearfrac(fixedDates(1:end-1),fixedDates(2:end),act360);

% forward fixed discount wrt option maturity
fwdFixedDiscountsAlfa = fixedDiscounts(2:end)/fixedDiscounts(1);  % fwd rispetto a alfa

% floating forward discounts wrt option maturity
fwdFloatingDiscountsAlfa = floatingDiscounts(1:end-1)/floatingDiscounts(1); % B alfa primo i (fwd rispetto ad alfa, mi fermo a omega-1)

%% Spread
% floating forward discounts
fwdFloatingDiscounts = floatingDiscounts(2:end)./floatingDiscounts(1:end-1);

% pseudodiscounts and forward pseudodiscounts at floating dates
floatingPseudoDiscounts = findDiscount(floatingDates,PSEUDODISCOUNT);
fwdFloatingPseudoDiscounts = floatingPseudoDiscounts(2:end)./floatingPseudoDiscounts(1:end-1);

spread = fwdFloatingDiscounts./fwdFloatingPseudoDiscounts;

%% Swap rate

% bpv relative to fixed dates
bpv = sum(delta.*fwdFixedDiscountsAlfa);

% swap rate
RATE = (1 - fwdFixedDiscountsAlfa(end) + sum(fwdFloatingDiscountsAlfa.*(spread - 1)))/bpv;

end % swapRate