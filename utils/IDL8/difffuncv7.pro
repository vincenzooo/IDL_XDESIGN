function diffFunc,x_m,y_m,baseIndex=baseIndex,xIndex=xIndex,_extra=e,$
                  xbase=xbase,x_mbase=x_mbase,removeBase=removeBase,$
                  in_mask=in_mask,xmin=xstart,xmax=xend
;given two functions in the form of vector return the difference using 
;the common range and the less dense x sampling.
;I call it 'base' and it will give the reference value,
;I call the other (to be rescaled) 'data'.
;the functions must be provided in 2 x npoints arrays of x and y values.
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
s=size(x_m,/dimensions)
nvectors=s[1]

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
  y_tmp=extractXrange(x_m[*,i],y_m[*,i],x_tmp,xstart=xstart,xend=xend)
  result_m[*,i]=interpol(y_tmp,x_tmp,xbase,_strict_extra=e)-y_m[ibase,baseIndex]
endfor

if keyword_set(removeBase) ne 0 then begin
  mask=intarr(npt,nvectors)
  mask[*,baseIndex]=1
  result_m=reform(result_m[where(mask eq 0)],npt,nvectors-1)
  x_mbase=reform(x_mbase[where(mask eq 0)],npt,nvectors-1)
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
  y_diff=diffFunc(a,b,x_mbase=x_mbase,xbase=xbase,in_mask=in_mask,/quadratic) ;this is for the test, I know it is quadratic
  multiplot,x_mbase,y_diff,title='differences',psym=4
  print,' -- Starting values --'
  print,strjoin(['point#','x_1','x_2','x_3','y_1','y_2','y_3'],STRING(9b))
  print,transpose([[indgen(npoints)+1],[a],[b]])
;  print,' -- Starting values in selected range --'
;  print,strjoin(['point x_1','point x_2','point x_3','x_1','x_2','x_3','y_1','y_2','y_3'],STRING(9b))
;  tmp=reform(transpose(indgen(npoints)+1),nlines,npoints)
;  print,[tmp[where(in_mask ne 0)],a[where(in_mask ne 0)],b[where(in_mask ne 0)]]
   print,' -- Results --'
   print,strjoin(['x_base','diff_1','diff_2','diff_3','expected_values 1 2 3'],STRING(9b))
   print,transpose([[xbase],[y_diff],[fltarr(n_elements(xbase))],[2*xbase^2],[xbase]])
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