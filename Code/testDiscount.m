clear
clc
load('market.mat')
addpath('utilities')

%% EONIA
PD = bootstrapEONIA(mktOIS);
zD = disc2zero(PD.y(2:end), PD.t(2:end), PD.t(1), ...
                        -1, 3);

% Plot
figure
title('EONIA')
yyaxis left
plot(PD.t(2:end),zD.*100, 'LineWidth', 2)
ylabel('Zero rates')
ytickformat('percentage')
hold on
yyaxis right
plot(PD.t,PD.y, 'LineWidth', 2)
ylabel('Discount factors')
datetick
grid on


%% EURIBOR6M
P = bootstrapEUR6M(mktFRA, mktSwap, PD);
z = disc2zero(P.y(2:end), P.t(2:end), P.t(1), ...
                        -1, 3);

% Plot
figure
title('EURIBOR6M')
yyaxis left
plot(P.t(2:end),z.*100, 'LineWidth', 2)
ylabel('Zero rates')
ytickformat('percentage')
hold on
yyaxis right
plot(P.t,P.y, 'LineWidth', 2)
ylabel('Discount factors')
datetick
grid on