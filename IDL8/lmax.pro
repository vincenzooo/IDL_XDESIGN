function lmax,x , Max_Subscript ;,_extra=e
;wrapper for the MAX function to include also lists
;see lmin

if size(x,/type) eq 11 then begin ;object
  maxlist=list()
  if obj_class(x) eq 'LIST' then begin
    ;assumes it a list of arrays
    foreach element,x,i do begin
      maxlist=maxlist+list(lmax(element))
    endforeach
    result=lmax(maxlist.toarray(),max_subscript) 
  endif
endif else result=max(x,max_subscript)

return,result
end

pro test_lmin
  a=list([1,2,3],[4,5],6,[2,-1],[5,6])
  print,a
  print,lmax(a,i);,max=m)
  print,i
  ;m is undefined
  b=[1,4,6,-1,5]
  print
  print,b
  print,lmax(b,i);,max=m)
  print,i
  ;print,m

end

test_lmin

end