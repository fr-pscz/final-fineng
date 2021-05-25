function P = bootstrapEUR6M(FRA, SWAP, DISCOUNTS)

% Does bootstrap of Euribor6M 
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
startDateFra = [FRA.startdate]';
endDateFra = [FRA.enddate]';
rateFra = [FRA.rate]' /100;

% SWAP data
settleDateSwap = SWAP.settledate;
maturitySwap = [SWAP.maturity]'; % the first one is the 6M fixing of EUR
rateSwap = [SWAP.rate]' /100;
eur6M = rateSwap(1);
rateSwap = rateSwap(2:end);


%% Bootstrap

act360=2;
act365= 3;

%%% STEP 1: compute P(t_0, 6m) with EUR6m 

deltaT0T6 = yearfrac(settleDateSwap, maturitySwap(1), act360);
p6M = 1 / ( 1 + deltaT0T6 * eur6M );


%%% STEP 2: compute P(t_0, 12m) with FRA 6x12 

deltaT6T12 = yearfrac(settleDateFra, endDateFra(6), act360);
p12M = 1 / ( 1 + deltaT6T12 * rateFra(6) )  *  p6M;


%%% STEP 3: compute P(t_0, 1m), ...., P(t_0, 5m) with FRA 1x7, .., 5x11 

% interpolation of P(t_0, 7m), ...., P(t_0, 11m)
p.y = [1; p6M; p12M];
p.t = [settleDateFra; maturitySwap(1); endDateFra(6)];
interpDates = endDateFra(1:5);
interpP = findDiscount(interpDates, p);

% Going backward
deltaFra = yearfrac(startDateFra(1:5), endDateFra(1:5), act360);
pBack = interpP  ./  ( 1 ./ (1 + deltaFra .* rateFra(1:5)) );


%%% STEP 4: compute P(t_0, 2y), ...., P(t_0, 12y) with swaps

% Computing fixed-legs of swaps (from 1y to 12y)
deltaSwap = yearfrac([settleDateSwap; maturitySwap(2:end-1)], maturitySwap(2:end), act360); deltaSwap(length(rateSwap)+1) = 0;
fixedLeg=zeros(12,1);
bpv = deltaSwap(1) * DISCOUNTS.y(8); % 8 is the index of OIS discount curve correspoding to 1y

for i = 1:length(rateSwap)
    
    fixedLeg(i) = rateSwap(i) * bpv;
    if i<12
        bpv = bpv + deltaSwap(i+1) * DISCOUNTS.y(i+8);
    end
end

% Computing the discounts inverting the formula via interpolation
p1 = p12M;
pSwap =  ones(length(rateSwap)-1, 1);
diff = fixedLeg(2:end) - fixedLeg(1:end-1);
deltaP = yearfrac(settleDateSwap, maturitySwap(2:end),act365);
deltaMid = yearfrac(maturitySwap(2:end-1), maturitySwap(3:end), act365); 

% Yearfractions and Discounts on floating payment dates
floatingDates = paymentDates(maturitySwap(2), maturitySwap(end), 2, 'follow');
floatingDates = flipud(floatingDates);
floatingDelta = yearfrac(floatingDates(1:end-1), floatingDates(2:end), act365);
deltaDiscount = yearfrac(settleDateFra, floatingDates(2:end),act365);
pFloating = findDiscount(floatingDates, DISCOUNTS);

% Inverting the NPV formula of the swap
for i = 1:length(rateSwap)-1
   
    alpha2 = (deltaDiscount(2*i-1)*floatingDelta(2*i-1)) / (deltaMid(i)*deltaP(i+1));
    alpha1 = (-deltaDiscount(2*i-1)*floatingDelta(2*i-1)) / (deltaMid(i)*deltaP(i));
    k1 = deltaDiscount(2*i-1)/deltaP(i);
    k = p1 ^ (k1 + alpha1); 
    w3 = pFloating(2*i); 
    w4 = pFloating(2*i+1);
    f = @(x) k * w3 * x^(alpha2-1) - w3 +  ( (w4 * p1) / k ) * x^(-alpha2) - w4 - diff(i); 
    b = fzero(f, [0.1 1]);
    pSwap(i) = b;
    p1 = pSwap(i);

end


%% Assigning outputs

P.y = [1; pBack; p6M; p12M; pSwap];

P.t = [settleDateFra; startDateFra(1:5); maturitySwap];
