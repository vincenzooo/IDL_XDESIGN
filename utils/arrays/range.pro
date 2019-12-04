function range, x,irange,size=size,noNan=noNaN,median=median,expand=eexpand
;return the range (a vector [min,max]) of the array X, or !Null if empty x
;  (so it can be tested for n_elements).
;SIZE: if set return the width of the range (max-min)
;MEDIAN: output, return the median (MAX+MIN)/2
;NONAN: as default, min and max are called with the NaN keyword set. This
;   ignores the invalid values NaN. Set NONAN to disable this option (invalid results
;   will be returned for NaN values).
;EXPAND: the range is expanded by this fraction of the range size (default=0). Useful to 
;IRANGE: can be used to return a two vector with the index of the elements in X for min and max.

if n_elements(x) eq 0 then begin
  message,'You must provide an argument',/INFO
  return,!NULL
endif
if n_elements(eexpand) eq 0 then expand=0 else begin
  if eexpand le -0.5 then message,'Invalid value for EXPAND'
  expand=eexpand
endelse
  NaN=~keyword_set(noNaN)
  min=min(x,imin,max=max,subscript_max=imax,NaN=NaN)
  span=max-min
  irange=[imin,imax]
  median=(min+max)/2.
if keyword_set(size) ne 0 then return,span*(1+expand)
  return,[min,max]+[-span*(expand)/2,span*(expand)/2]
end