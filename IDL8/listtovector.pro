function listToVector,lista
  ;Convert a list of vectors to a single vector, merging all the 
  ; elements.
  result=[]
  for i=0,n_elements(lista)-1 do begin
    if size(lista[i],/n_dim) gt 1 then message,'List elements must be scalars or vectors'
    ;TODO: add code to accept also multidimensional arrays with size 1 along all dimensions
    ; but one (i.e. columns, rows or whatever).
    result=[result,lista[i]]
  endfor
  return,result
end 

a=list([1,2,3],[4,5],6)
help,a
print,a
b=listTovector(a)
print,'-----'
help,b
print,b


end