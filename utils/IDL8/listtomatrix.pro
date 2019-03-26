function listToMatrix,lista,missing=m, tanspose=transp,type=usertype
  ;Convert a list of vectors to a matrix, something like list.toarray() method,
  ; but really working, i.e.: 
  ; 1) it doesn't fail if vetors have not the same lenghts.
  ; 2) missing value is used to fill missing values in each vector, not entire vectors.
  
  ;If list elements have different types the resulting array is the highest type between
  ; list elements (I tried to include also MISSING in this broadcasting process, but 
  ; this would end to make everything float, since there is not int Nan). 
  ; Note however that if list is INT and missing is not passed, 0 is used for the same
  ;   reason (this happens also with .toarray()).
  
  ; see tests at the end for an example.
  
  ;2013/08/14 changed the orientation of result to keep it coherent with toarray():
  ;   the number of elements of the list is the size of the first dimension.
  ;   Added TRANSPOSE flag to flip the result.
  ;   Added TYPE argument, differently from toarray only a numerical value can be used
  ;     (it doesn't work with strings returned by typename).
  ;2013/07/31 created

  if n_elements(m) eq 0 then missing=!VALUES.D_NAN else missing=m
  s=[]
  t=[]
  for i=0,n_elements(lista)-1 do begin
    if size(lista[i],/n_dim) gt 1 then message,'List elements must be scalars or vectors'
    ;TODO: add code to accept also multidimensional arrays with size 1 along all dimensions
    ; but one (i.e. columns, rows or whatever).
    s=[s,n_elements(lista[i])]
    t=[t,size(lista[i],/type)]
  endfor
  maxsize=max(s)
  if n_elements(usertype) eq 0 then tt=max(t) else tt=usertype
  result=make_array(maxsize,n_elements(lista),value=missing,type=tt)
    ;type=max([t,size(missing,/type)]))
  for i=0,n_elements(lista)-1 do begin  ;matrix is created as transposed for higher speed.
    result[0:s[i]-1,i]=lista[i]
  endfor
  if not keyword_set(transp) then result=transpose(result)  
  return,result
end  

a=list([1,2,3],[4,5],6,[7,8,9,10])
help,a
print,a
;; print,a.toarray()  ;gives error
print,'--- toArray (-999 used for missing values):'
print,a.toarray(missing=-999) ;this gives nonsense: columns are sized as the first 
;  and entirely replaced by the MISSING value
;       1     -11     -11
;       2     -11     -11
;       3     -11     -11
print,'----- listToMatrix:'
b=listToMatrix(a)
help,b
print,b
print,'-----'
c=listToMatrix(a,missing=-999)
help,c
print,c

end