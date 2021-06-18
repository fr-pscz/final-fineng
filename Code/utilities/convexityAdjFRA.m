function MKTFRACONVEX = convexityAdjFRA(MKTFRA, PARAMS)
%CONVEXITYADJFRA Convexity adjustment for forward rate agreements
%
% INPUTS:
%       MKTFRA: struct array with following fields:
%             - settledate
%             - startdate
%             - enddate
%             - rate
%
%       PARAMS: array [a; σ; γ] for MHW parameters
%
% OUTPUTS:
% MKTFRACONVEX: struct array of FRAs with adjusted rate

convVol = 3; % Act/365
convFRA = 2; % Act/360
% initialize output struct
MKTFRACONVEX = MKTFRA;

for ii = 1:numel(MKTFRA)
    sigma = @(t) PARAMS(2).*exp(PARAMS(1).*t).*...
        (exp(-PARAMS(1).*yearfrac(MKTFRA(ii).settledate, MKTFRA(ii).startdate, convVol))...
       - exp(-PARAMS(1).*yearfrac(MKTFRA(ii).settledate, MKTFRA(ii).enddate, convVol)))./PARAMS(1);
    eta   = @(t) (1-PARAMS(3)).*PARAMS(2).*exp(PARAMS(1).*t).*...
        (exp(-PARAMS(1).*yearfrac(MKTFRA(ii).settledate, MKTFRA(ii).startdate, convVol))...
       - exp(-PARAMS(1).*yearfrac(MKTFRA(ii).settledate, MKTFRA(ii).enddate, convVol)))./PARAMS(1);
   
   gammaFRA = exp(-integral(@(t) sigma(t) .* eta(t), 0, yearfrac(MKTFRA(ii).settledate, MKTFRA(ii).startdate, convVol)));
   
   MKTFRACONVEX(ii).rate = MKTFRA(ii).rate.*gammaFRA + (gammaFRA - 1)./yearfrac(MKTFRA(ii).startdate, MKTFRA(ii).enddate, convFRA);
end % cycle through FRAs

end 
