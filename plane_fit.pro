function plane_fit, x, y, z,fitpars=fitpars
;modified by kov

;compute the average surface, calculate statistical indicator

  ; M. Katz 1/26/04
; IDL function to perform a least-squares fit a plane, based on
; Ax + By + C = z
;
; ABC = plane_fit(x, y, z, error=error)
;


tx2 = total(x^2)
ty2 = total(y^2)
txy = total(x*y)
tx = total(x)
ty = total(y)
N = n_elements(x)

A = [[tx2, txy, tx], $
[txy, ty2, ty], $
[tx, ty, N ]]

b = [total(z*x), total(z*y), total(z)]

out = invert(a) # b

;fitpars=[a,b,c]

return, out ;--- [A,B,C]
end
