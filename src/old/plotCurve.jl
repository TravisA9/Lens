using Winston


Curve = [( 1/(X+1) ) for X in 1000:-1:-1000]
 Curve[1002] = 0 # because it was "Inf"

#  x = -2pi:0.1:2pi;
# plot(x, sin(x.^2)./x)
 plot(Curve)
