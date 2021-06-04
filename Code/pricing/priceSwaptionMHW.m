function PX = priceSwaptionMHW(MKTSWAPTION, PD, P, PARAM)

PX = zeros(numel(MKTSWAPTION),1);

for ii = 1:numel(MKTSWAPTION)
    f = priceFunctionCSSMHW(MKTSWAPTION(ii), PD, P);
    PX(ii) = f(PARAM);
end
end % priceSwaptionMHW
