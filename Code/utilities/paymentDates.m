function D = paymentDates(START, END, FREQ, CONV)
%PAYMENTDATES Compute payment dates at regular intervals.
%   INPUTS:
%       START: first payment date (or lower limit for payment dates)
%       END:   last payment date
%       FREQ:  number of payments per year
%       CONV:  business day convention (follow, modifiedfollow,
%              previous, modifiedprevious)
%
%   OUTPUTS:
%       D:    payment dates

%% Generate payment dates
% compute upper bound for the number of payment years
nYears = ceil(yearfrac(START,END,1));
% generate payment dates backwards from END (included)
D = datenum(datetime(END, "ConvertFrom", "datenum") - calmonths(flip(0:12/FREQ:12*nYears))');

%% Trimming
% depending on rounding, D may contain payment dates before START
% we are only interested in dates after START
D = D(D >= START);

%% Holidays
% payments can only take place on business days
D = dateRolling(D, CONV);
end
