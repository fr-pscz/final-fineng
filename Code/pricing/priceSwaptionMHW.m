function PX = priceSwaptionMHW(MKTSWAPTION, PD, P, PARAM)
% PRICESWAPTIONMHW function that computes the price of swaptions according to a multi-curve Hull and White
% INPUTS:
% MKTSWAPTION: struct with following fields:
%             - settledate
%             - optionmaturity
%             - swapmaturity
%             - strike
%             - px
%
% PD: struct with dates and OIS-adjusted discounts
% P: struct with dates and EUR6M pseudodiscounts 
%
% PARAM: array containing the parameters of the model
%
% OUTPUTS:
% PX: price of the swaptions
%
% FUNCTIONS:
% priceFunctionCSSMHW

PX = zeros(numel(MKTSWAPTION),1);

for ii = 1:numel(MKTSWAPTION)
    f = priceFunctionCSSMHW(MKTSWAPTION(ii), PD, P);
    PX(ii) = f(PARAM);
end
end % priceSwaptionMHW
