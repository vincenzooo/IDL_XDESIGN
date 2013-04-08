function bandAverage, vector, bands, x=x, total = total
;restituisce il valore medio di un vettore. Le bande sono in forma
; [[b1start,b1end],[b1start,b1end],...]
; in array 2 x nbands
; se x e' fornito, si considerano i valori di bands riferiti a x,
; senno' vengono assunti come indici del vettore. 
; Total computes the total, not the average.

;esempio:
;IDL> print,bandaverage(findgen(20),[[2,3],[6,11]])
;      2.50000      8.50000
;IDL> print,bandaverage(findgen(20),[[2,3],[6,11]],/total)
;      5.00000      51.0000
;IDL> print,bandaverage(findgen(20),[[2,3],[6,11]],x=findgen(20)-5)
;      7.50000      13.5000

if n_elements(x) ne 0 then bandIndex=fix(findex(x,bands)+0.5) $
  else bandindex=bands

if n_elements(bandindex) eq 2 then bandindex=reform(bandindex,[2,1])
if size(bandindex,/n_dimensions) ne 2 then message, "array <bands> passed to bandAverage"+$
"must have 2 dimensions (2 x nbands), it has " +  string(size(bandindex,/n_dimensions))
s=size(bandindex,/dimensions)
if s[0] ne 2 then message, "array <bands> passed to bandAverage must be (2 x nbands)"+$
  "it is ",s
nbands=s[1]

for i=0,nbands-1 do begin
  newTotal=total(vector[bandindex[0,i]:bandindex[1,i]])
  if not (keyword_Set(total)) then newTotal=newTotal/(-bandindex[0,i]+bandindex[1,i]+1)
  if i eq 0 then ba=newTotal else ba=[ba,newTotal]
endfor

return,ba

end