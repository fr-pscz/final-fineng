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
* px
* coupon
* yield
* paymentdates

### Swaptions

Struct with fields:

* maturity
* tenor
* valuedate
* px
* impliedvola
* strike
* position (receiver/payer)
