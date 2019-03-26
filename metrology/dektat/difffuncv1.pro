function diffFunc,x12,y12,baseIndex=baseIndex,_strict_extra=e,indexes=i_m,baseindex=base
;given two functions in the form of vectors return the difference using 
;the common range and the less dense x sampling.
;I call it 'base' and it will give the reference value,
;I call the other (to be rescaled) 'data'.
;the functions must be provided in 2 x npoints arrays of x and y values.
;
; (if baseIndex is indicated, the corresponding column is used as 'base',
; no matter which has fewer elements).
; /LSQUADRATIC] [, /QUADRATIC] [, /SPLINE] keywords can be used for interpolation
;(with interpol). If none is set use linear interpolation.

;indexes return a matrix with the selected indexes
;baseindex return the index (either 0 or 1) of the vector used as base 

;determine the commmon range
xstart=max(min(x12,dimension=2))
xend=min(max(x12,dimension=2))

;extract the subvectors and chose the one with the fewer elements
if n_elements(baseIndex) eq 0 then begin
  if (n_elements(xx1) lt n_elements(xx2)) then begin
    base=0
    data=1
  endif else begin
    base=1
    data=0
  endelse
endif else begin
  base=baseIndex
  data=~baseindex
endelse

yy_b=extractxrange(x12[base],y12[base],xx_b,xstart=xstart,xend=xend,xindex=index_b)
yy_d=extractxrange(x12[data],y12[data],xx_d,xstart=xstart,xend=xend,xindex=index_d)

;interpolation of 'data' and difference with 'base'
yy_d=interpol(yy_d,xx_d,xx_b,e)-yy_b

return,yy_d

end