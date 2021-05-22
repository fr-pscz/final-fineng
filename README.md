# final-fineng
Final project Financial Engineering

## Style guidelines

Variables and functions inside a filespace with **camelCase** variables passed as input or output with all caps.

Example:

```
function D = businessConvert(D, CONV)
%BUSINESSCONVERT Automatic date rolling
%
%   INPUTS:
%   D:    array of dates to convert
%   CONV: business day convention. Possible values: follow, modifiedfollow,
%         previous, modifiedprevious
%
%   OUTPUTS:
%   D: first available business day

internalVariable = f(D);
D(~isbusday(D)) = busdate(D(~isbusday(D)),{CONV});

end % businessConvert
```

## Data format

### OIS Rates

Struct with fields:

* maturity
* valuedate
* settledate
* rate


### Curves

Struct with two fields:

* t
* y

Applies to Zeta curve, Discount curve, Pseudodiscount curve, Beta spreads.

### Bonds

Struct with fields:

* maturity
* valuedate
* settledate
* px
* coupon
* yield
* paymentdates

### Swaptions

Struct with fields:

* maturity
* tenor
* valuedate
* settledate
* px
* impliedvola
* strike
* position (receiver/payer)
