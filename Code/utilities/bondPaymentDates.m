function D = bondPaymentDates(SETTLE, END, FREQ, CONV)
%BONDPAYMENTDATES Compute payment dates at regular intervals.
%   INPUTS:
%       SETTLE: settle date
%       END:    last payment date
%       FREQ:   number of payments per year
%       CONV:   business day convention (follow, modifiedfollow,
%               previous, modifiedprevious)
%
%   OUTPUTS:
%       D:    payment dates
%
%   FUNCTIONS:
%   paymentDates

nMonths = (ceil(yearfrac(SETTLE,END)) + 1)*12;
%% Find START date for paymentDates
START = datenum(datetime(END, "ConvertFrom", "datenum") - calmonths(nMonths));

D = paymentDates(START, END, FREQ, CONV);

%% Trimming
idxFirstPayment = find(D <= SETTLE, 1, 'last');
% depending on rounding, D may contain payment dates after END
D = D(idxFirstPayment:end);

%% Holidays
% payments can only take place on business days
END = dateRolling(END, CONV);
D   = dateRolling(D,   CONV);

%% Error handling
if D(end) ~= END
    error('ERROR: START and END dates do not match specified FREQ.')
end % error

end % bondPaymentDates
