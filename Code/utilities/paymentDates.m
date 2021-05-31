function D = paymentDates(START, END, FREQ, CONV)
%PAYMENTDATES Compute payment dates at regular intervals.
%   INPUTS:
%       START: first payment date
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
% generate payment dates by adding calmonths
D = datenum(datetime(START, "ConvertFrom", "datenum") + calmonths(0:12/FREQ:12*nYears)');

%% Trimming
% depending on rounding, D may contain payment dates after END
D = D(D <= END);

%% Holidays
% payments can only take place on business days
END = dateRolling(END, CONV);
D   = dateRolling(D,   CONV);

%% Error handling
if D(end) ~= END
    error('ERROR: START and END dates do not match specified FREQ.')
end

end
