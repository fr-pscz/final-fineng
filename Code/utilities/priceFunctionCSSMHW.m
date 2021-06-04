function PXFUN = priceFunctionCSSMHW(MKTSWAPTION, PD, P)
%PRICEFUNCTIONCSSMHW Create function handle for CS swaption price in a MHW model
%
% INPUTS:
% MKTSWAPTION: struct with following fields:
%             - settledate
%             - optionmaturity
%             - swapmaturity
%             - strike
%
%          PD: struct with dates and OIS-adjusted discounts
%           P: struct with dates and EUR6M pseudodiscounts 
%
% OUTPUTS: 
%        PXFUN: CS receiver swaption price function handle
%
% FUNCTIONS:
%  computeS

tenor = round(yearfrac(MKTSWAPTION.optionmaturity,MKTSWAPTION.swapmaturity));
m = 1;
c = @(s) (1 - 1/(1+s./m).^(tenor))./s;

S = computeS(MKTSWAPTION, PD, P);

K = MKTSWAPTION.strike;

payoffDiscount = findDiscount(MKTSWAPTION.optionmaturity,PD);
integrand = @(x,p,s) exp(-x.^2/2)/sqrt(2*pi)*c(s)*max((K - s),0);

PXFUN = @(p) payoffDiscount * integral(@(x) integrand(x,p, S(x,p)),-10,fzero(@(x) S(x,p) - K,0),'arrayvalued',true);
end % priceFunctionCSSMHW
