function RATE = swapRate(MKTSWAPTION, PD, P)
%SWAPRATE Compute par swap rate for the swap underlying a given swaption
%
% INPUTS:
% MKTSWAPTION: struct with following fields: 
%             - optionmaturity
%             - swapmaturity
%
%          PD: struct with dates and OIS-adjusted discounts
%           P: struct with dates and EUR6M pseudodiscounts 
%
% OUTPUTS: 
%        RATE: scalar rate
%
% FUNCTIONS:
%  paymentDates, findDiscount

%% Daycount conventions for fixed leg

fixedConv = 6; % 30/360

%% Payment dates

% generate an array containing the dates of the floating payments and the
% corresponding discounts
floatingFreq = 2;
floatingDates = paymentDates(MKTSWAPTION.optionmaturity, MKTSWAPTION.swapmaturity, floatingFreq, 'follow');
floatingDiscounts = findDiscount(floatingDates,PD);

% generate an array containing the dates of the fixed payments and the
% corresponding discounts
fixedFreq = 1;
fixedDates = paymentDates(MKTSWAPTION.optionmaturity, MKTSWAPTION.swapmaturity, fixedFreq, 'follow');
fixedDiscounts = findDiscount(fixedDates,PD);


%% Fixed and floating forward discounts

% array of delta between all fixed payment dates. The first element is wrt
% the option maturity
delta = yearfrac(fixedDates(1:end-1),fixedDates(2:end),fixedConv);

% forward fixed discount wrt option maturity
fwdFixedDiscounts = fixedDiscounts(2:end)/fixedDiscounts(1);

% floating forward discounts wrt option maturity
fwdFloatingDiscounts = floatingDiscounts(1:end-1)/floatingDiscounts(1); 

%% Spread
% floating forward discounts
fwdDiscounts = floatingDiscounts(2:end)./floatingDiscounts(1:end-1);

% pseudodiscounts and forward pseudodiscounts at floating dates
floatingPseudoDiscounts = findDiscount(floatingDates,P);
fwdPseudodiscounts = floatingPseudoDiscounts(2:end)./floatingPseudoDiscounts(1:end-1);

spread = fwdDiscounts./fwdPseudodiscounts;

%% Swap rate

% bpv relative to fixed dates
bpv = sum(delta.*fwdFixedDiscounts);

% swap rate
RATE = (1 - fwdFixedDiscounts(end) + sum(fwdFloatingDiscounts.*(spread - 1)))/bpv;

end % swapRate
