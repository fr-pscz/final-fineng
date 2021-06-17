function ILLIQUIDCURVE = illiquidityCorrection(TTL, BBAR, ZSPREAD, PARAMS, BOUND)
%ILLIQUIDITYCORRECTION Generates issuer discount curve accounting for both liquidity and credit risk
%
% INPUTS:
%           TTL: calendar duration for time-to-liquidate
%          BBAR: curve struct for the issuer discount curve
%       ZSPREAD: curve struct for the issuer Z-Spreads
%        PARAMS: array [a; σ; γ] for MHW parameters
%         BOUND: string specifying 'upper' (default) or 'lower' bound
%
% OUTPUTS:
% ILLIQUIDCURVE: curve struct for the illiquid issuer discount curve ("B-double-bar" in the literature)

convSpreads = 3; % Act/365
tau = datenum(datetime(BBAR.t(1), 'ConvertFrom', 'datenum') + TTL);

zeta = PARAMS(2).*(1-exp(-PARAMS(1).*yearfrac(tau, BBAR.t(BBAR.t > tau), convSpreads)))./PARAMS(1);
capSigmaSq = zeta.^2 .* (1-exp(-2*PARAMS(1)*yearfrac(BBAR.t(1),tau,convSpreads)))./(2.*PARAMS(1));
capSigma = sqrt(capSigmaSq);
illiquidPi = NaN.*capSigma;

%% Illiquidity π
if nargin < 5 || strcmp(BOUND, 'upper')
    illiquidPi = (2 + capSigmaSq./2).*normcdf(capSigma./2) + ...
        capSigma./sqrt(2.*pi).*exp(-capSigmaSq./8);
elseif strcmp(BOUND, 'lower')
    for ii = 1:numel(capSigma)
        f = @(n) exp(-capSigmaSq(end)./8).*exp(-0.5.*n.*capSigma(ii).*(capSigma(ii) - capSigma(end))).*...
            (1+sqrt(pi.*(1-n)./2).*capSigma(end).*exp((1-n).*capSigmaSq(end)./8).*normcdf(sqrt(1-n).*capSigma(end)./2)).*...
            (1+sqrt(pi.*n./2).*(2.*capSigma(ii) - capSigma(end)).*exp(n.*(2.*capSigma(ii) - capSigma(end)).^2./8).*normcdf(sqrt(n).*(2.*capSigma(ii) - capSigma(end))./2))./...
            (pi.*sqrt(n-n.^2));
        illiquidPi(ii) = integral(f, 0, 1);
    end
end

%% Survival probability
deltattau = yearfrac(BBAR.t(1), tau, convSpreads);
integralSigma = (PARAMS(2)/PARAMS(1))^2 * (...
    deltattau -...
    2*(1-exp(-PARAMS(1)*deltattau))/PARAMS(1) + ...
    (1-exp(-2*PARAMS(1)*deltattau))/(PARAMS(1)*2));
    
probSurv = exp(...
    - interp1(ZSPREAD.t, ZSPREAD.y, tau) .* yearfrac(BBAR.t(1), tau, convSpreads)...
    + PARAMS(3)^2 * integralSigma/2);

%% Output
ILLIQUIDCURVE.t = BBAR.t;
ILLIQUIDCURVE.y = BBAR.y;
ILLIQUIDCURVE.y(BBAR.t > tau) = BBAR.y(BBAR.t > tau).* (1 + probSurv - illiquidPi);
end
