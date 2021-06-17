function P = bootstrapAlternativeEUR6M(FRA, SWAP, DISCOUNTS, FLAG)
%BOOTSTRAPALTERNATIVEEUR6M Bootstrap pseudo-discounts from swaps and FRAs
%
% INPUTS:
% FRA: struct with market information contained in 5 fields: 
%             - valuedate
%             - settledate
%             - startdate
%             - enddate
%             - rate
%
% SWAP: struct with market information contained in 4 fields: 
%             - valuedate
%             - settledate
%             - maturity
%             - rate
% ( Notice that the first rate is the fixing of Euribor 6m )
%
% DISCOUNTS: struct with dates and discounts of OIS rates 
%
% FLAG: select the interpolation rule used in the bootstrap
%              - if no flag is given, uses linear on zero rates 
%              - 1 spline on zero rates
%              - 2 spline on discounts
%              - 3 log linear on discounts  
%
% OUTPUTS: 
% P: struct with pseudo-discounts computed with selected interpolation rule and corresponding dates 


if nargin < 4
    P = bootstrapEUR6M(FRA, SWAP, DISCOUNTS);
    return
end

%% Extracting arrays from inputs

% FRA data
settleDateFra = FRA.settledate;
startDateFra  = [FRA.startdate]';
endDateFra    = [FRA.enddate]';
rateFra       = [FRA.rate]';

% SWAP data
settleDateSwap = SWAP.settledate;
maturitySwap   = [SWAP.maturity]'; % the first one is the 6M fixing of EUR
rateSwap       = [SWAP.rate]';
% split fixing from complete swaps
eur6M    = rateSwap(1);
rateSwap = rateSwap(2:end);


%% Bootstrap conventions

convEUR6M    = 2; % Act/360
convFixedLeg = 6; %  30/360

%% STEP 1: compute P(t_0, 6m) with EUR6m 

deltaT0T6 = yearfrac(settleDateSwap, maturitySwap(1), convEUR6M);
p6M       = 1 / ( 1 + deltaT0T6 * eur6M );


%% STEP 2: compute P(t_0, 12m) with FRA 6x12
idxFRA1Y = find(startDateFra == maturitySwap(1));

deltaT6T12 = yearfrac(startDateFra(idxFRA1Y), endDateFra(idxFRA1Y), convEUR6M);
p12M       = p6M / ( 1 + deltaT6T12 * rateFra(idxFRA1Y) );


%% STEP 3: compute P(t_0, 1m), ...., P(t_0, 5m) with FRA 1x7, .., 5x11 

% interpolation of P(t_0, 7m), ...., P(t_0, 11m)
p.y         = [1; p6M; p12M];
p.t         = [settleDateFra; maturitySwap(1); endDateFra(idxFRA1Y)];
interpDates = endDateFra(1:idxFRA1Y-1);
interpP     = findDiscountAlternative(interpDates, p, FLAG);

% Going backward
deltaFra = yearfrac(startDateFra(1:idxFRA1Y-1), endDateFra(1:idxFRA1Y-1), convEUR6M);
pBack    = interpP  ./  ( 1 ./ (1 + deltaFra .* rateFra(1:idxFRA1Y-1)) );


%% STEP 4: compute P(t_0, 2y), ..., P(t_0, 12y) with swaps

% Computing fixed-legs of swaps (from 1y to 12y)
deltaSwap  = yearfrac([settleDateSwap; maturitySwap(2:end-1)], maturitySwap(2:end), convFixedLeg);
partialBPV = deltaSwap .* findDiscountAlternative(maturitySwap(2:end),DISCOUNTS,FLAG);
fixedLeg   = rateSwap .* cumsum(partialBPV);

% Computing the discounts inverting the formula via interpolation
pSwap    = ones(length(rateSwap)-1, 1);
diffNPV  = diff(fixedLeg);

% Yearfractions and Discounts on floating payment dates
floatingDates = paymentDates(settleDateSwap, maturitySwap(end), 2, 'follow');
floatingDates = floatingDates(3:end); % don't need settle and 6M
floatingDates = floatingDates(2:end); % only need payments from 1.5Y onwards
% Discounts for floating payments
pFloating = findDiscountAlternative(floatingDates, DISCOUNTS, FLAG);

% initialize last known pseudodiscount
lastD = p12M;

for ii = 1:length(rateSwap)-1
    % function of discount (t_0, ii+0.5) from the discount (t_0, ii+1) 
    f = @(x) findDiscountAlternative(floatingDates(2*ii-1), struct('t', [settleDateSwap; maturitySwap(ii+1); maturitySwap(ii+2)], 'y', [1; lastD; x] ), FLAG);
    r = @(x)  f(x)./x - 1 ;   %function handle of forward (ii+0.5, ii+1)
    g = @(x) lastD./f(x) - 1; %function handle of forward (ii, ii+0.5) 
    h = @(x) g(x).*pFloating(2*ii-1) + r(x).* pFloating(2*ii) - diffNPV(ii); % function handle of NPV swap
    lastD = fzero(h, 1);
    pSwap(ii) = lastD;

end

%% Assigning outputs

P.y = [1; pBack; p6M; p12M; pSwap];

P.t = [settleDateFra; startDateFra(1:5); maturitySwap];
end
