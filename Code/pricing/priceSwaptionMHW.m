function PRICE = priceSwaptionMHW(MKTSWAPTION, DISCOUNT, PSEUDODISCOUNT)
%
%
%
%

act365 = 3;

f = fun(MKTSWAPTION, DISCOUNT, PSEUDODISCOUNT);

xstar = @(p) fzero(@(x) f(x,p),0)

tenor = yearfrac(MKTSWAPTION.optionmaturity,MKTSWAPTION.swapmaturity,act365);
c = @(m,s) 1./s*(1 - 1/(1+s./m)^(tenor));

s = computeS(MKTSWAPTION, DISCOUNT, PSEUDODISCOUNT);

strikeATM = swapRate(MKTSWAPTION, DISCOUNT, PSEUDODISCOUNT);

discountOptionMaturity = findDiscount(MKTSWAPTION.optionmaturity,DISCOUNT);
m = 1;
integrand = @(x,p) exp(-x.^2/2)/sqrt(2*pi)*c(m,s(x,p))*max((strikeATM - s(x,p)),0).*(x < xstar(p));

% PRICE = @(p) discountOptionMaturity * quadgk(@(x) integrand(x,p),-inf,+inf);
PRICE = @(p) discountOptionMaturity * integral(@(x) integrand(x,p),-inf,+inf,'arrayvalued',true);
end



