function squareRange, xx, yy, polar=polar,expansion=expansion
; return the range needed for an isotropic square in the form [xmin,xmax,ymin,ymax].
; migliorare facendo possa prendere anche un rettangolo. 
; If POLAR is set, assumes xx and yy as r and psi

if keyword_set(polar) then begin
  ;convert from polar (r,psi) to cartesian
  x=xx*cos(yy)
  y=xx*sin(yy)
endif else begin
  x=xx
  y=yy
endelse

if n_elements(expansion) eq 0 then expansion=1.02
xmax=max(x)
xmin=min(x)
ymax=max(y)
ymin=min(y)
xrange=abs(xmax-xmin)
yrange=abs(ymax-ymin)
squareRange=max([xrange,yrange])*expansion
xgap=(squareRange-xrange)/2
ygap=(squareRange-yrange)/2

return,[xmin-xgap,xmax+xgap,ymin-ygap,ymax+ygap]

end