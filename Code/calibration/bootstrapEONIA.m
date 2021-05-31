function P = bootstrapEONIA(OIS)
%BOOTSTRAPEONIA Bootstrap discounts from quoted OIS rates
%
% INPUTS:
% OIS: struct with market information contained in 4 fields: 
%             - valuedate
%             - settledate
%             - maturity
%             - rate
% (all dates in datenum format)
%
% OUTPUTS: 
% P: struct with dates and EONIA discounts


%% Extracting arrays from inputs

settleDate = OIS.settledate;
maturity = [OIS.maturity]';
rate = [OIS.rate]';


%% Computing discounts with maturity up to 1 year

% selecting dates and rates with maturity up to 1 year
oneYear = dateRolling(datenum(datetime(settleDate, "ConvertFrom", "datenum") + calyears(1)), 'follow');
maturityBefore1Y = maturity(maturity <= oneYear);
ratesBefore1Y = rate(maturity <= oneYear);

% computing yearfraction for bootstrap
convOIS = 2; % Act/360
deltaT0Te = yearfrac(settleDate, maturityBefore1Y, convOIS); 

% computing discounts
discountsBefore1Y = 1 ./ (1 + deltaT0Te .* ratesBefore1Y);


%% Boostrap discounts with maturity longer than 1 year 

% selecting dates and rates with maturity longer than 1 year
maturityAfter1Y = maturity(maturity > oneYear);
rateAfter1Y = rate(maturity > oneYear);

% computing array of yearfractions: delta(t_i, t_i+1) for i=1,2,...,11
deltaI = yearfrac([maturityBefore1Y(end); maturityAfter1Y(1:end-1)], maturityAfter1Y, convOIS);

% inizializing auxiliary variables
bpv = yearfrac(settleDate, maturityBefore1Y(end), convOIS) * discountsBefore1Y(end); % 1Y BPV
discountAfter1Y = zeros(length(deltaI),1);

% bootstrap
for i = 1:length(deltaI)
    % compute discount
    discountAfter1Y(i) = ( 1 - rateAfter1Y(i) * bpv ) / ( 1 + deltaI(i) * rateAfter1Y(i) );
    % update BPV for next iteration
    bpv = bpv + deltaI(i) * discountAfter1Y(i);
end

% Assigning output values
P.y = [1; discountsBefore1Y; discountAfter1Y];
P.t = [settleDate; maturity];

end
