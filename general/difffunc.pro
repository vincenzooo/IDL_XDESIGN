function diffFunc,xx_m,yy_m,baseIndex=baseIndex,xIndex=xIndex,_extra=e,$
                  xbase=xbase,x_mbase=x_mbase,removeBase=removeBase,$
                  in_mask=in_mask,xmin=xstart,xmax=xend,couples=couples,allcouples=allcouples,force=force
;given a set of n functions in the form of matrices of row vectors return the difference using 
;the common range and the less dense x sampling.
;I call 'base' the vector that give the reference value (diff_i=row_i-base),
;I call the other (to be rescaled) 'data'.
;the functions must be provided in n x npoints arrays of x and y values.
;
; (if baseIndex is indicated, the corresponding column is used as 'base',
; no matter which has fewer elements).
; xIndex determines instead from which vector the x axis must be token.
; if it is not set uses the x vector with the fewer elements (can be different from
; the base used for the differences).
; The vector function of index xIndex are not interpolated.
; 
; /LSQUADRATIC] [, /QUADRATIC] [, /SPLINE] keywords can be used for interpolation
;(with interpol). If none is set use linear interpolation.
;baseindex return the index (either 0 or 1) of the vector used as base 
;
;if /removebase is set the base vector (all made of zeros will be removed). 
;/force can be used to make the routine work with both removebase and allcouples.
;  this can be useful to call it from another routine that decides wether to set 
;  allcouples according ot the number of vectors.  

;if launched with lists,transform list in array and operate on array, they will be 
;transformed back to lists at the end

if n_elements(baseindex) ne 0 and keyword_set(allcouples) then message, 'BASEINDEX and ALLCOUPLES cannot be set both.'
if keyword_set(removebase) and keyword_set(allcouples) then BEGIN
  if keyword_set(force) then print, 'DIFFFUNC WARNING: REMOVEBASE and ALLCOUPLES are both set, removebase will be ignored (but the'+$
      ' bases will be removed in any case, this is how ALLCOUPLES works).' else $
  message, 'REMOVEBASE and ALLCOUPLES cannot be set both.'
endif

x_m=xx_m
y_m=yy_m
listmode=0
if size(x_m,/type) eq 11 then begin
  if obj_class(x_m) eq 'LIST' then begin
      if (size(y_m,/type) ne 11) ||  obj_class(x_m) ne 'LIST' then $
        message,'Both matrix must be of the same kind (arrays or lists).'
      x_m=listmatrixtoarray(x_m)
      y_m=listmatrixtoarray(y_m)
      listmode=1
    endif 
endif

s=size(x_m,/dimensions)
nvectors=s[1]

if keyword_set(allcouples) then begin ;test all couples
for i=0,nvectors-2 do begin
  resulttmp=diffFunc(xx_m[*,i:nvectors-1],yy_m[*,i:nvectors-1],_extra=e,$
                    x_mbase=x_mbasetmp,/removeBase,couples=couplestmp)
  result_m=(i eq 0)?resulttmp:concatenate(result_m,resulttmp,2)
  x_mbase=(i eq 0)?x_mbasetmp:concatenate(x_mbase,x_mbasetmp,2)
  couples=(i eq 0)?couplestmp:[[couples],[couplestmp+i]]
  endfor
return,result_m
endif

;determine the commmon range
xstart=max(min(x_m,dimension=1))
xend=min(max(x_m,dimension=1))
;if n_elements(xmin) ne 0 then begin
;  if xmin lt xstart then message, 'xmin is lower that the minimum acceptable range (some vectors have no data).'
;  xstart=xmin
;endif
;if n_elements(xmax) ne 0 then begin
;  if xmax gt xend then message, 'xmax is higher that the maximum acceptable range (some vectors have no data).'
;  xend=xmax
;endif


;chose the subvector with the fewer elements. 
;baseIndex is the index
in_mask=lonarr(s)
in_mask[where((x_m le xend) and (x_m ge xstart))]=1
c_m=total(in_mask,1,/preserve_type)

if n_elements(xIndex) eq 0 then begin
  npt=min(c_m,xIndex)
endif else npt=c_m[xIndex]

if n_elements(baseIndex) eq 0 then begin
  dummy=min(c_m,baseIndex)
endif

;determine the base x 
ibase=where(in_mask[*,xIndex] ne 0) ;index of the base in the range
xbase=x_m[ibase,xIndex]
if size(xbase,/dimensions) ne npt then message,'error in array size'
if arg_present(x_mbase) then x_mbase=rebin(xbase,npt,nvectors) ;just for convenience as a return value
;xbase=transpose(xbase)

;create the differences matrix
result_m=fltarr(npt,nvectors)
for i =0,nvectors-1 do begin
  couples=(i eq 0 )?[baseIndex,0]:[[couples],[baseIndex,i]]
  y_tmp=extractXrange(x_m[*,i],y_m[*,i],x_tmp,xstart=xstart,xend=xend)
  result_m[*,i]=interpol(y_tmp,x_tmp,xbase,_strict_extra=e)-y_m[ibase,baseIndex]
endfor

if keyword_set(removeBase) ne 0 then begin
  mask=intarr(npt,nvectors)
  mask[*,baseIndex]=1
  result_m=reform(result_m[where(mask eq 0)],npt,nvectors-1)
  x_mbase=reform(x_mbase[where(mask eq 0)],npt,nvectors-1)
  couples=couples[*,where(indgen(nvectors)ne baseIndex)]
endif

if listmode eq 1 then begin
  x_mbase=arraytolistmatrix(x_mbase)
  result_m=arraytolistmatrix(result_m)
endif

return,result_m

end

pro testDiffFunc
  
  nlines=3
  npoints=20
  a=findgen(npoints)
  a=rebin(a,npoints,nlines)
  a[*,1]=a[*,1]*0.9+10.5
  a[*,2]=a[*,2]*0.8+13.5
  b=a^2                  ;  b[*,0]=x^2
  b[*,1]=b[*,1]*3        ;  b[*,1]=3*x^2
  b[*,2]=b[*,2]+a[*,2]   ;  b[*,2]=x^2+x
  
  ;expected differences: 0.0  |  2*x^2  | x 
  
  window,0
  multiplot,a,b,title='raw data',psym=4
  
  window,1
  y_diff=diffFunc(a,b,x_mbase=x_mbase,xbase=xbase,in_mask=in_mask,/quadratic,couples=couples) ;this is for the test, I know it is quadratic
  multiplot,x_mbase,y_diff,title='differences',psym=4
  print,' -- Starting values --'
  print,strjoin(['point#','x_1','x_2','x_3','y_1','y_2','y_3'],STRING(9b))
  print,transpose([[indgen(npoints)+1],[a],[b]])
;  print,' -- Starting values in selected range --'
;  print,strjoin(['point x_1','point x_2','point x_3','x_1','x_2','x_3','y_1','y_2','y_3'],STRING(9b))
;  tmp=reform(transpose(indgen(npoints)+1),nlines,npoints)
;  print,[tmp[where(in_mask ne 0)],a[where(in_mask ne 0)],b[where(in_mask ne 0)]]
  s=size(b,/dimensions)
  coupstr=''
  for i=0,s[1]-1 do begin
    str=[strtrim(couples[1,i],2),strtrim(couples[0,i],2)]
    coupstr=coupstr+' '+strjoin(str,'-')
  endfor
  print,' -- Results --'
  print,strjoin(['x_base',coupstr,'expected_values 1 2 3'],STRING(9b))
  print,transpose([[xbase],[y_diff],[fltarr(n_elements(xbase))],[2*xbase^2],[xbase]])
  
  ;test recursion
  print
  print
  print,'----------------'
  
  y_diff=diffFunc(a,b,x_mbase=x_mbase,xbase=xbase,in_mask=in_mask,/quadratic,couples=couples,/allcouples) 
  window,2
  multiplot,x_mbase,y_diff,title='differences',psym=4
  
  s=size(y_diff,/dimensions)
  coupstr=''
  for i=0,s[1]-1 do begin
    str=[strtrim(couples[1,i],2),strtrim(couples[0,i],2)]
    coupstr=coupstr+' '+strjoin(str,'-')
  endfor
  print,' -- Results --'
  print,strjoin(['x_base('+coupstr+')',coupstr],STRING(9b))
  print,transpose([[x_mbase],[y_diff]])
  
  
  ver=strsplit(!version.RELEASE,'.',/extract)
  if ver[0] ge 8 then begin
   ;try again with lists
    nlines=3
    a=list(findgen(18),findgen(9)*0.9+10.5,findgen(10)*0.8+13.5)
    b=list(findgen(18)^2,3*(findgen(5)*0.9+10.5)^2,(findgen(9)*0.8+13.5)^2+(findgen(10)*0.8+13.5))
    
    print,' -- Starting values (lists) --'
    print,'a:'
    print,a
    print,'b:'
    print,b
      
  ;  window,2
  ;  multiplot,a,b,title='raw data',psym=4
    
    y_diff=diffFunc(a,b,x_mbase=x_mbase,xbase=xbase,in_mask=in_mask,/quadratic) ;this is for the test, I know it is quadratic
  ;  window,3
  ;  multiplot,x_mbase,y_diff,title='differences',psym=4
  
    print,' -- Results (lists) --'
    print,strjoin(['x_base','diff_1','diff_2','diff_3','expected_values 1 2 3'],STRING(9b))
    ;print,transpose([[xbase],[y_diff],[fltarr(n_elements(xbase))],[2*xbase^2],[xbase]])
    print,'xbase:'
    print,xbase
    print,'y_diff:'
    print,y_diff
    ;expected differences: 0.0  |  2*x^2  | x 
   endif 
end

testDiffFunc

;  nlines=3
;  npoints=20
;  a=findgen(npoints)
;  a=reform(transpose(a),npoints,nlines)
;  a[*,1]=a[*,1]*0.9+10.5
;  a[*,2]=a[*,2]*0.8+13.5
;  b=a^2                  ;  b[*,0]=x^2
;  b[*,1]=b[*,1]*3        ;  b[*,1]=3*x^2
;  b[*,2]=b[*,2]+a[*,2]   ;  b[*,2]=x^2+x
;  
;  ;expected differences: 0.0  |  2*x^2  | x 

; -- Starting values --
;point#  x_1 x_2 x_3 y_1 y_2 y_3
;      1.00000      0.00000      10.5000      13.5000      0.00000      330.750      182.250
;      2.00000      1.00000      11.4000      14.3000      1.00000      389.880      205.490
;      3.00000      2.00000      12.3000      15.1000      4.00000      453.870      230.010
;      4.00000      3.00000      13.2000      15.9000      9.00000      522.720      255.810
;      5.00000      4.00000      14.1000      16.7000      16.0000      596.430      282.890
;      6.00000      5.00000      15.0000      17.5000      25.0000      675.000      311.250
;      7.00000      6.00000      15.9000      18.3000      36.0000      758.430      340.890
;      8.00000      7.00000      16.8000      19.1000      49.0000      846.720      371.810
;      9.00000      8.00000      17.7000      19.9000      64.0000      939.870      404.010
;      10.0000      9.00000      18.6000      20.7000      81.0000      1037.88      437.490
;      11.0000      10.0000      19.5000      21.5000      100.000      1140.75      472.250
;      12.0000      11.0000      20.4000      22.3000      121.000      1248.48      508.290
;      13.0000      12.0000      21.3000      23.1000      144.000      1361.07      545.610
;      14.0000      13.0000      22.2000      23.9000      169.000      1478.52      584.210
;      15.0000      14.0000      23.1000      24.7000      196.000      1600.83      624.090
;      16.0000      15.0000      24.0000      25.5000      225.000      1728.00      665.250
;      17.0000      16.0000      24.9000      26.3000      256.000      1860.03      707.690
;      18.0000      17.0000      25.8000      27.1000      289.000      1996.92      751.410
;      19.0000      18.0000      26.7000      27.9000      324.000      2138.67      796.410
;      20.0000      19.0000      27.6000      28.7000      361.000      2285.28      842.690
; -- Results --
;x_base  diff_1  diff_2  diff_3
;      14.0000      0.00000      391.700     0.774994
;      15.0000      0.00000      450.000      1.94499
;      16.0000      0.00000      512.240      3.19501
;      17.0000      0.00000      578.420      4.52499
;      18.0000      0.00000      648.540      5.77499
;      19.0000      0.00000      720.440      5.82501
end