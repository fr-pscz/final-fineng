# final-fineng
Final project Financial Engineering

## Data format

### Curves

Struct with two fields:

* t
* y

Applies to Zeta curve, Discount curve, Pseudodiscount curve, Beta spreads.

### Bonds

Struct with fields:

* maturity
* valuedate
* marketpx
* coupon
* paymentdates
