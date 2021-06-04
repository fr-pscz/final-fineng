function PXFUN = priceFunctionCSSMHW(MKTSWAPTION, PD, P)
%
%
%
%

tenor = round(yearfrac(MKTSWAPTION.optionmaturity,MKTSWAPTION.swapmaturity));
c = @(m,s) (1 - 1/(1+s./m).^(tenor))./s;

S = computeS(MKTSWAPTION, PD, P);

K = MKTSWAPTION.strike;

discountOptionMaturity = findDiscount(MKTSWAPTION.optionmaturity,PD);
m = 1;
integrand = @(x,p,s) exp(-x.^2/2)/sqrt(2*pi)*c(m,s)*max((K - s),0);

PXFUN = @(p) discountOptionMaturity * integral(@(x) integrand(x,p, S(x,p)),-10,fzero(@(x) S(x,p) - K,0),'arrayvalued',true);
end
