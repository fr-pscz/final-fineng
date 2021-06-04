function PARAM = calibrateMHW(MKTSWAPTION, PD, P)
%
%
%        
%
%

priceMKT = [MKTSWAPTION.px]';
priceMHW = priceFunctionCSSMHW(MKTSWAPTION(1),PD, P);
lsError = @(p) (priceMHW(p) - priceMKT(1)).^2;

for ii = 2:9
    %priceMHW = computationalIntegrand(MKTSWAPTION(ii),PD, P);
    priceMHW = priceFunctionCSSMHW(MKTSWAPTION(ii),PD, P);
    lsError = @(p) lsError(p) + (priceMHW(p) - priceMKT(ii)).^2;
end

G = linspace(0,1,10);
startPARAM = [0.13;0.001;0];
minFVal = 100;

for ii = 1:numel(G)
    w = waitbar(ii/numel(G));
    [param, fVal] = fmincon(@(p) lsError([p;G(ii)]), startPARAM(1:2), -eye(2), zeros(2,1));
    if fVal < minFVal
        minFVal = fVal;
        PARAM = [param;G(ii)];
    end
end
close(w)
end
