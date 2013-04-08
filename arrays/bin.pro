function bin,data,binsize,binpoints=bp,binindex=bi,cutlast=cutlast,nocheck=nocheck
  ;bin the data on intervals defined by binspoints.
  ; binpoints is a vector with ninterval+1 elements, defining the values for
  ;  start and end point (data must be monothonic). If used binindex returns the
  ;  index of the binpoints. Monotonicity is checked unless NOCHECK is set (it can
  ;  be useful to save time in case of large arrays).
  ; The indices for the intervals can also be directly set by using BININDEX,
  ;   in that case binpoints must not be used. 
  ; 
  ; The endpoint is included in the interval.
  ;If the last point in binpoints is not the last data point, the remaining data
  ; points are included only if CUTLAST is not set.
  
  if n_elements(binsize) eq 0 then begin
    if n_elements(bp) eq 0 then message,'either BINSIZE or BINPOINTS must be set!'
    if n_elements(bp) lt 2 then message,'set at least two BINPOINTS' 
  endif else if n_elements(bp) ne 0 then message, 'BINSIZE and BINPOINTS cannot be both set'
  
  if n_elements(bp)*n_elements(bi) ne 0 then message,"BINPOINTS and BININDEX cannot be both set"
  
  if n_elements(binsize) ne 0 then begin
    if n_elements(binsize) gt 1 then message,'BINSIZE must be a scalar (use BINPOINTS otherwise)!'  
    if binsize le 0 then message,'BINSIZE must be positive'
    n=n_elements(data)
    if n eq 0 then message,'Empty vector'
    if binsize gt n then message,'BINSIZE is larger than the number of points'
    ninter=long(n/binsize)
    bi=[0,(lindgen(ninter)+1)*binsize-1]
  endif else begin
    if n_elements(bp) ne 0 then begin
      if not keyword_set(nocheck) then begin
        ;check array for monotonicity
        sorted=data[sort(data)]
        if data[0] gt data[n_elements(data)-1] then sorted=reverse(sorted)
        if not array_equal(data,sorted) then message,'Data are not monotonic'
      endif
      bi=value_locate(data,bp)
      good=where(bi ne -1,ncomplement=c)
      bi=bi[good]
      if c eq 1 then begin
        message,'First '+string(c)+' elements are out of range, ignore the first intervals',/info
        if bi[0] ne 0 then bi=[0,bi] 
      endif 
    endif ;otherwise uses bi, do nothing
  endelse
  out=[total(data[bi[0]:bi[1]])/(bi[1]-bi[0]+1)]
  for i=1,n_elements(bi)-2 do begin
    ;the denominator does not include +1 to account for the missing starting point
    out=[out,total(data[bi[i]+1:bi[i+1]])/(bi[i+1]-bi[i])]
  endfor
  if not keyword_set(cutlast) then begin
    n=n_elements(data)
    out=[out,total(data[bi[i]+1:n-1])/(n-bi[i]-1)]
  endif
  return,out
end