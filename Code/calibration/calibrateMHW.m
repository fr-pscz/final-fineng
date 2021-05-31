function PARAM = calibrationMHW(MKTSWAPTION, PD, P)
%
%
%        
%
%


priceMKT = zeros(9,1);
priceMKT(1) = priceSwaption(mktSwaption(1), PD,P);

price = priceSwaptionMHW(mktSwaption(1),PD, P);
priceMHW = @(p) price(p); 

for i = 2:9
% MKTSWAPTION(i).px = priceSwaption(MKTSWAPTION, DISCOUNT); 
% i = 1;
    priceMKT(i) = priceSwaption(mktSwaption(i), PD,P);
    price = priceSwaptionMHW(mktSwaption(i),PD, P);
    priceMHW = @(p) [priceMHW(p); price(p)]; 
end


% figure
% plot([1:9],priceMKT,'ro-')
% hold on
% plot([1:9],priceMHW,'bo-')
% legend('price_{MKT}','price_{MHW}')

% param = [12.94/100; 1.26/100; 0.07/100];
param0 = [12/100; 1/100; 0/100]; % messo solo per vedere se dandogli questi com inizio trova quelli giusti: no


error = @(p) sum((priceMHW(p) - priceMKT).^2);

PARAM = fmincon(error,param0,[],[],[],[],[0; 0; 0],[+inf,+inf,1]) 

