function P = bootstrapEONIA(OIS)

% Does bootstrap of EONIA curve
%
% INPUTS:
% OIS: struct with market information contained in 4 fields: 
%             - valuedate
%             - settledate
%             - maturity
%             - rate
% (all dates in datenum format, rate in %)
%
% OUTPUTS: 
% P: struct with dates and discounts of OIS rates 


%% Extracting arrays from inputs

settleDate = OIS.settledate;
maturity = [OIS.maturity]';
rate = [OIS.rate]' /100;


%% Bootstrap of OIS with maturity less than 1 year

% selecting dates and rates with maturity less than 1 year
maturityBefore1Y = maturity(1:8);
ratesBefore1Y = rate(1:8);

% computing yearfraction for bootstrap
act360 = 2;
deltaT0Te = yearfrac(settleDate, maturityBefore1Y, act360); 

% computing discounts
discountsBefore1Y = 1 ./ (1 + deltaT0Te .* ratesBefore1Y);


%% Boostrap of OIS with maturity longer than 1 year 

% selecting dates and rates with maturity longer than 1 year
maturityAfter1Y = maturity(9:end);
rateAfter1Y = rate(9:end);

% computing array of yearfractions: delta(t_i, t_i+1) for i=1,2,...,11
deltaI = yearfrac([maturityBefore1Y(end); maturityAfter1Y(1:end-1)], maturityAfter1Y, act360);

% inizializing axuliary variables
bpv = yearfrac (settleDate, maturityBefore1Y(end), act360) * discountsBefore1Y(end);
discountAfter1Y = zeros(length(deltaI),1);

% computing discounts
for i = 1:length(deltaI)
    
    discountAfter1Y(i) = ( 1 - rateAfter1Y(i) * bpv ) / ( 1 + deltaI(i) * rateAfter1Y(i) );
    
    bpv = bpv + deltaI(i) * discountAfter1Y(i);
end

% Assigning output values
P.y = [discountsBefore1Y; discountAfter1Y];

P.t = maturity;

end
