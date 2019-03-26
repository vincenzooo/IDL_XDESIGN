function concatenate,array1,array2,axis,padding=padding
;concatenate two arrays along the dimension specified by axis (starting from 1).
;axis represent the only dimension for which is allowed to have a different number of elements. 
; it works like usual array concatenation, but can pad missing values
; with the value specified in padding (default: empty string if string type or Nan in other cases).

;;works with two axis
  a1=array1
  a2=array2
  
  if n_elements(axis) eq 0 then axis =1
  
  ;array are transposed if it is not the first axis, then the array are concatenated along the first dimension
  if axis eq 2 then a1=transpose(a1)
  if axis eq 2 then a2=transpose(a2)
  
  if n_elements(padding) eq 0 then $
    if size(a1,/type) eq 7 then padding="" else padding=!values.F_NAN
  
  ndim1=size(a1,/n_dimensions)
  ;if (ndim1 le 1) and (axis gt ndim1) then message, 'arrays cannot be concatenated on axis '+string(axis)
  ndim2=size(a2,/n_dimensions)
  if ndim2 gt 2 then message, 'maximum number of dimensions for concatenation is 2!'
  ;it should be possible to extend it to 3 dimensions, in that case, you need to 
  ;build two rectangular matrix with same number of elements
  ;
  ;add shallow dimensions to give same dim to arrays
  s1=size(a1,/dimensions)
  s2=size(a2,/dimensions)
  ;ndim1=size(a1,/n_dimensions)
  ;ndim2=size(a2,/n_dimensions)
  
  shallows=replicate(1,(ndim1>ndim2))
  ndim=n_elements(shallows)
  if ndim1 lt ndim2 then begin
    shallows[0:ndim1-1]=s1
    a1=reform(a1,shallows) 
  endif
  if ndim1 gt ndim2 then begin
    shallows[0:ndim2-1]=s2
    a2=reform(a2,shallows) 
  endif
  
  ;arrays must have same size on all axis but first
  
  s1=long(size(a1,/dimensions)) ;can be changed, recalculate
  s2=long(size(a2,/dimensions))
  
  resultsize=max([[s1],[s2]],dimension=ndim)
  resultsize[0]=s1[0]+s2[0]
  result=replicate(padding,resultsize)
  
  if ndim eq 1 then result=[a1,a2] $
  else if ndim eq 2 then begin
      for i =0l,(s1[1]<s2[1])-1 do begin
        result[*,i]=[a1[*,i],a2[*,i]]
      endfor
      longer=(s1[1] gt s2[1])?a1:a2
      p=(s1[1] gt s2[1])?[0,s1[0]-1]:[s1[0],s1[0]+s2[0]-1]
      for i =long((s1[1]<s2[1])-1),long((s1[1]>s2[1])-1) do begin
        result[p[0]:p[1],i]=longer[*,i]
      endfor
    endif else begin
      message,'unexpected number of dimensions:'+string(ndim) 
    endelse
  
  if axis eq 2 then result=transpose(result)
  return,result

end

  pro test_concatenate
  
  a=indgen(3,3)
  d=indgen(5)
  c=indgen(2,3)
  print,'a:',a
  print,'d:',d
  print,'print,concatenate(a,d)'
  print,concatenate(a,d)
  print,'print,concatenate(a,d,2)'
  print,concatenate(a,d,2)
  print,'print,concatenate(d,a,2)'
  print,concatenate(d,a,2)
  print,'print,concatenate(d,a,1)'
  print,concatenate(d,a,1)
  ;IDL> print,concatenate(a,d)
  ;      0.00000      1.00000      2.00000      0.00000      1.00000      2.00000      3.00000      4.00000
  ;      3.00000      4.00000      5.00000          NaN          NaN          NaN          NaN          NaN
  ;      6.00000      7.00000      8.00000          NaN          NaN          NaN          NaN          NaN
  ;IDL> print,concatenate(a,d,2)
  ;      0.00000      1.00000      2.00000          NaN          NaN
  ;      3.00000      4.00000      5.00000          NaN          NaN
  ;      6.00000      7.00000      8.00000          NaN          NaN
  ;      0.00000      1.00000      2.00000      3.00000      4.00000
  ;IDL> print,concatenate(d,a,2)
  ;      0.00000      1.00000      2.00000      3.00000      4.00000
  ;      0.00000      1.00000      2.00000          NaN          NaN
  ;      3.00000      4.00000      5.00000          NaN          NaN
  ;      6.00000      7.00000      8.00000          NaN          NaN
  ;IDL> print,concatenate(d,a,1)
  ;      0.00000      1.00000      2.00000      3.00000      4.00000      0.00000      1.00000      2.00000
  ;          NaN          NaN          NaN          NaN          NaN      3.00000      4.00000      5.00000
  ;          NaN          NaN          NaN          NaN          NaN      6.00000      7.00000      8.00000
  end
  
  test_concatenate
  
  end