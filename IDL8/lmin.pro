function lmin,x , Min_Subscript ;,_extra=e
;wrapper for the MIN function to include also lists
;Result = MIN( Array [, Min_Subscript] [, /ABSOLUTE] [, DIMENSION=value] [, MAX=variable] [, /NAN] [, SUBSCRIPT_MAX=variable]

if size(x,/type) eq 11 then begin ;object
  minlist=list()
  ;maxlist=list()
  if obj_class(x) eq 'LIST' then begin
    ;assumes it a list of arrays
    foreach element,x,i do begin
      minlist=minlist+list(lmin(element)) ;,max=max))
      ;maxlist=maxlist+list(max)
    endforeach
    result=lmin(minlist.toarray(),min_subscript) ;,_extra=e)
    ;max=max(maxlist.toarray(),subscript_max,_extra=e)
  endif
endif else result=min(x,min_subscript) ;,_strict_extra=e)

return,result
end

pro test_lmin
  a=list([1,2,3],[4,5],6,[2,-1],[5,6])
  print,a
  print,lmin(a,i);,max=m)
  print,i
  ;m is undefined
  b=[1,4,6,-1,5]
  print,lmin(b,i);,max=m)
  print,i
  ;print,m

end

test_lmin

end