function arraytolistmatrix,array,missing=missval
;transform a 2-dim array in a list of vectors.
;The second index becames the position in the list (create a list of the row vectors).
;Elements whose value is equal to missval (or who are not finite, i.e. NaN or Inf, if the
;keyword is not provided) are excluded.


s=size(array,/n_dimensions)
if s gt 2 then message, 'Only 1 or 2d array accepted'
if s eq 1 then return, list(array)
s=size(array,/dimensions)
nvectors=s[1]

result=list()

if n_elements(missval) eq 0 then begin
  for i= 0,nvectors-1 do begin
    result=result+list(array[(where(finite(array[*,i]))),i])
  endfor
endif else begin
  for i= 0,nvectors-1 do begin
    result=result+list(array[where(array[*,i] ne missval),i])
  endfor
endelse
  
return,result

end

  n=!Values.F_NAN
  a=[[1,2,3,4],[1,2,n,n],[1,n,n,n],[2,3,5,6]]
  print,arraytolistmatrix(a)

end