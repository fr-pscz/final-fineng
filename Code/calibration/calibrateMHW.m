function PARAM = calibrateMHW(MKTSWAPTION, PD, P)
%CALIBRATEMHW Computes best parameters for MHW model given a set of swaptions
%
% INPUTS:
% MKTSWAPTION: struct with following fields:
%             - settledate
%             - optionmaturity
%             - swapmaturity
%             - strike
%             - px
%
%          PD: struct with dates and OIS-adjusted discounts
%           P: struct with dates and EUR6M pseudodiscounts 
%
% OUTPUTS: 
%        PARAM: [a; σ; γ] 
%
% FUNCTIONS:
%  priceFunctionCSSMHW

% Extract prices
priceMKT = [MKTSWAPTION.px]';

% Initialize function handle
priceMHW = priceFunctionCSSMHW(MKTSWAPTION(1),PD, P);
lsError = @(p) (priceMHW(p) - priceMKT(1)).^2;

% Add all remaining swaptions
for ii = 2:9
    priceMHW = priceFunctionCSSMHW(MKTSWAPTION(ii),PD, P);
    lsError = @(p) lsError(p) + (priceMHW(p) - priceMKT(ii)).^2;
end

%% Error minimization
% γ is estimated with a coarse grid due to its low impact on overall error
n = 15; % grid size
%G = linspace(0,1,n); % linear grid
G = [0;(cos((2.*(n:-1:1)' - 1).*0.5.*pi./n) + 1)./2;1]; % chebyshev grid 
% initialize values for minimization
startPARAM = [0.13;0.001;0];
minFVal = 100;


for ii = 1:numel(G) % cycle over γs
    w = waitbar(ii/numel(G)); % give progress updates
    [param, fVal] = fmincon(@(p) lsError([p;G(ii)]), startPARAM(1:2), -eye(2), zeros(2,1));
    if fVal < minFVal
        minFVal = fVal;
        PARAM = [param;G(ii)]; % params that minimize error given γ
    end % minimum condition
end % cycle over γs
close(w)
end % calibrateMHW
