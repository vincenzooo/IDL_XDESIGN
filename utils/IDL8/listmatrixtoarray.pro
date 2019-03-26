function listmatrixtoarray,list,missing=missval
;given a list of vectors transform it in a 2-dim array with number of column
;equal to the length of the longer vector.
;The missing values are filled with NaN, or with missing if the argument is passed.

l=0
nvectors=n_elements(list)
for i= 0,nvectors-1 do begin
  l=l>n_elements(list[i])
endfor

if n_elements(missval) eq 0 then missval=!Values.F_NAN

result=replicate(missval,l,nvectors)
for i= 0,nvectors-1 do begin
  n=n_elements(list[i])
  result[0:n-1,i]=list[i]
endfor

return,result

end