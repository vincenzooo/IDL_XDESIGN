function nvectors,array
;given an array that is supposed to be a matrix of row vectors or a single
;column vector, return the number of vectors in the matrix  
  tmp=size(array,/n_dimension)
  if tmp eq 1 then return,1 else begin
    s=size(array)
    return,s[tmp]
  endelse

end

