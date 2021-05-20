function [OIS, LIBOR, FRA, Settlement_Date] = readExcelData( filename )
% Reads data from excel
%  It reads mid rates and dates
%
% INPUTS:
%  filename: excel file name where data are stored
% 
% OUTPUTS:
% OIS:   struct with dates and rates relative to OIS
% LIBOR: struct with dates and rates relative to LIBOR, the first one is
%        EURIBOR6m
% FRA:   struct with matrix of start and expiry dates, rates, matrix of tenors 

%% Settings
formatData='dd/mm/yyyy'; %Pay attention to your computer settings 

%% Dates from Excel

%Settlement date
[~, settlement] = xlsread(filename, 1, 'H5');
%Date conversion
Settlement_Date = datenum(settlement, formatData);

%% OIS
%Dates and rates relative to OIS
[~, date_OIS] = xlsread(filename, 1, 'B2:B19');
OIS.dates = datenum(date_OIS, formatData);

OIS.rates = xlsread(filename, 1, 'E2:E19');

%% LIBORvs6m
%Dates and rates relative to LIBORrvs6m
[~, date_libor] = xlsread(filename, 2, 'B2:B14');
LIBOR.dates = datenum(date_libor, formatData);

LIBOR.rates =  xlsread(filename, 2, 'C2:C14'); % The first rate is the 6m Euribor rate.

%% FRA
%Dates, rates and tenors relative to FRA

% matrix of start and expiry dates
[~, date_FRA] = xlsread(filename, 3, 'C2:D10');
numberFRA= size(date_FRA,1);
FRA.dates=ones(numberFRA,2);
FRA.dates(:,1) = datenum(date_FRA(:,1), formatData);
FRA.dates(:,2) = datenum(date_FRA(:,2), formatData);

% rates
FRA.rates = xlsread(filename, 3, 'G2:G10');

% matrix of tenors
tenors_FRA = xlsread(filename, 3, 'A2:B10');
FRA.tenors=ones(numberFRA,2);
FRA.tenors(:,1)= tenors_FRA(:,1);
FRA.tenors(:,2)= tenors_FRA(:,2);

end % readExcelData