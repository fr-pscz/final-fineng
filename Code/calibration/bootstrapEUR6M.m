function P = bootstrapEUR6M(FRA, SWAP, DISCOUNTS)
%BOOTSTRAPEUR6M Bootstrap pseudo-discounts from swaps and FRAs
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
%
% OUTPUTS: 
% P: struct with pseudo-discounts and corresponding dates

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
convInterp   = 3; % Act/365

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
interpP     = findDiscount(interpDates, p);

% Going backward
deltaFra = yearfrac(startDateFra(1:idxFRA1Y-1), endDateFra(1:idxFRA1Y-1), convEUR6M);
pBack    = interpP  ./  ( 1 ./ (1 + deltaFra .* rateFra(1:idxFRA1Y-1)) );


%% STEP 4: compute P(t_0, 2y), ..., P(t_0, 12y) with swaps

% Computing fixed-legs of swaps (from 1y to 12y)
deltaSwap  = yearfrac([settleDateSwap; maturitySwap(2:end-1)], maturitySwap(2:end), convFixedLeg);
partialBPV = deltaSwap .* findDiscount(maturitySwap(2:end),DISCOUNTS);
fixedLeg   = rateSwap .* cumsum(partialBPV);

% Computing the discounts inverting the formula via interpolation
pSwap    = ones(length(rateSwap)-1, 1);
diffNPV  = diff(fixedLeg);

% Yearfractions and Discounts on floating payment dates
floatingDates = paymentDates(settleDateSwap, maturitySwap(end), 2, 'follow');
floatingDates = floatingDates(3:end); % don't need settle and 6M
floatingDelta = yearfrac(floatingDates(1:end-1), floatingDates(2:end), convInterp);
floatingDates = floatingDates(2:end); % only need payments from 1.5Y onwards
% Discounts for floating payments
pFloating = findDiscount(floatingDates, DISCOUNTS);

% initialize last known pseudodiscount
lastD = p12M;

% Inverting the NPV formula of the swap
deltaDiscount = yearfrac(settleDateSwap,floatingDates,convInterp);
deltaMid      = yearfrac(maturitySwap(2:end-1), maturitySwap(3:end), convInterp);
deltaP        = yearfrac(settleDateSwap, maturitySwap(2:end), convInterp);

for ii = 1:length(rateSwap)-1
   
    alpha2 = (deltaDiscount(2*ii-1)*floatingDelta(2*ii-1)) / (deltaMid(ii)*deltaP(ii+1));
    alpha1 = (-deltaDiscount(2*ii-1)*floatingDelta(2*ii-1)) / (deltaMid(ii)*deltaP(ii));
    k1 = deltaDiscount(2*ii-1)/deltaP(ii);
    k = lastD ^ (k1 + alpha1); 
    w3 = pFloating(2*ii-1); 
    w4 = pFloating(2*ii);
    f = @(x) k * w3 * x^(alpha2-1) - w3 +  ( (w4 * lastD) / k ) * x^(-alpha2) - w4 - diffNPV(ii); 
    b = fzero(f, [0.1 1]);
    pSwap(ii) = b;
    lastD = pSwap(ii);

end

%% Assigning outputs

P.y = [1; pBack; p6M; p12M; pSwap];

P.t = [settleDateFra; startDateFra(1:5); maturitySwap];
end
