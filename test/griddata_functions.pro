;+
;comparison of several functions for Radial Basis Function
; in GRIDDATA function.

;d (h in IDL documentation) is the distance to the interpolate
;R is the SMOOTHING parameter
;defining k=sqrt(d^2+R^2):
;
;0  Inverse Multiquadric 1/k
;1  Multilog  log(k^2)
;2  Multiquadric  k
;3  Natural Cubic Spline k^3
;4  Thin Plate Spline k^2*log(k^2)
 
 
 