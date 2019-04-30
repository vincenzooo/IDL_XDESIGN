;+
; NAME:
; REPLICATE_VECTOR
;
; PURPOSE:
; Replicated the vector to fill exactly nelements (vector is truncated).
; 
; CATEGORY:
; Arrays
;
; CALLING SEQUENCE:
; Result = REPLICATE_VECTOR,Vector,N
;
; INPUTS:
; Vector: A vector to replicate
; N: The final number of elements after replication
;
; EXAMPLE:
;  linecolors = ['blue','green','red']
;  print,replicate_vector(linecolors,7)
;
; MODIFICATION HISTORY:
;   Written by: Vincenzo Cotroneo, sometime faraway in the past
;   Doc added 2019/04/30, added management of non numeric types
;-


function replicate_vector,vector,nelements


  if nelements lt 1 then message,'Invalid value for NELEMENTS argument'
  n=n_elements(vector)
  nrep=fix(nelements/n)

  t=size(vector,/type) 

  if t gt 0 && t lt 7 then begin  ;numeric, can use rebin
    tmp=rebin([vector],n,nrep+1) ;square bracket is needed if it is a one element
  endif else begin
    tmp=[]
    for i =0,nrep do begin
      tmp=[tmp,vector]
    endfor
  endelse
    tmp=reform(tmp,n*(nrep+1))
  return,tmp[0:nelements-1]

end

x=indgen(3)^2

print,replicate_vector(x,7)


linecolors = ['blue','green','red']
print,replicate_vector(linecolors,7)


end