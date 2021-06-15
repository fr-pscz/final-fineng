function [] = calibrateMHWtest(MKTSWAPTION, PD, P)
%CALIBRATEMHWTEST Plot error surface
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
n = 4; % grid size
%G = linspace(0,1,n); % linear grid
G = [0;(cos((2.*(n:-1:1)' - 1).*0.5.*pi./n) + 1)./2;1]; % chebyshev grid 
% initialize values for minimization
startPARAM = [1;0.1;0];

%% Param grids
N = 20;
gridA = linspace(11/100, 20/100, N);
gridS = linspace(1/100, 1.7/100, N);

[A,S] = meshgrid(gridA,gridS);

E = 0.*A;

%% Compute Error (can't be vectorialized)
for gg = 1:numel(G) % cycle over γs
    for aa = 1:numel(gridA) % cycle over as
        for ss = 1:numel(gridS) % cycle over σs
            E(aa,ss) = lsError([A(aa,ss); S(aa,ss); G(gg)]);
        end
    end
    save(['test/err' num2str(gg) '.mat'], 'E')
    figure
    surfc(A,S,E)
    title(['γ = ' num2str(G(gg))])
    xlabel('a')
    ylabel('σ')
    zlabel('Error')
end
end % calibrateMHW
