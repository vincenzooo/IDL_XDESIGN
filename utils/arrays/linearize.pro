function linearize,X,y0=y0,yN=yN,m=m,q=q,ymin=minvalue,ymax=maxvalue,pars=pars

  ;+
  ; NAME:
  ; LINEARIZE
  ;
  ; PURPOSE:
  ;  !Return an array of values obeying to a linear relation. The relation can
  ;  ! be set by a couple of parameters among y0,yN,m,q.
  ;
  ; CATEGORY:
  ; Arrays
  ;
  ; CALLING SEQUENCE:
  ; Write the calling sequence here. Include only positional parameters
  ; (i.e., NO KEYWORDS). For procedures, use the form:
  ;
  ; Result = LINEARIZE, X, Y1, Yn
  ;
  ; INPUTS:
  ; X:  a list of values for the x of returned values
  ;
  ; INPUT KEYWORDS:
  ; ; Two of the following must be set:
  ; y0   first value, corresponding to X[0]
  ; yN   last value, corresponding to last element of X
  ; m    (keyword) linear coefficient, slope y = mx + q
  ; q    (keyword) linear coefficient, intercept
  ;
  ; KEYWORD PARAMETERS:
  ;  !ymin  if provided all values lower than this are set to ymin
  ;  !ymax  if provided all values higher than this are set to ymax  
  ; 
  ; OUTPUTS:
  ; The linearized values corresponding to X
  ;
  ; OPTIONAL OUTPUTS:
  ; pars: returns an array with complete set of possible input values
  ;    that replicate the linearization [y0,yn,m,q]
  ;
  ; RESTRICTIONS:
  ; If called with y0 (or yN) and q, the X corresponding to Y0/YN must
  ;   not be zero, or the line equation will be underconstrained (if Y0=Q)
  ;   or inconsistent (if y0 != q).
  ; 
  ; PROCEDURE:
  ; Translated from fortran, very naively (without using any IDL
  ;   interpolation procedures), calculate m and q from provided inputs,
  ;   then uses them to calculate output.
  ; 
  ; direct translation from fortran
  ;    real(8) X(:)  !assumed-shape array
  ;    real(8) linearize(size(X)),ymin,ymax
  ;    real(8),optional::y0,yN,m,q,minvalue,maxvalue  ;
  ;
  ; EXAMPLE:
  ; 
  ;  x=findgen(10)
  ;  l=linearize(x,y0=1,yN=12,pars=pars)  ;l is linear set of values, m=1.11.. , q=2.0
  ;  print,l
  ;  print, pars
  ;
  ;  l=linearize(x,y0=pars[0],m=pars[2]) ;same thing, setting first point and slope
  ;  print,l
  ;  
  ;  ;  1.00000      2.22222      3.44444      4.66667      5.88889      7.11111      8.33333      9.55556      10.7778      12.0000
  ;  ;  1.00000      12.0000      1.22222      1.00000
  ;  ;  1.00000      2.22222      3.44444      4.66667      5.88889      7.11111      8.33333      9.55556      10.7778      12.0000
  ;
  ; MODIFICATION HISTORY:
  ;   Written by: Vincenzo Cotroneo
  ; 2019/04/30 Extracted from fortran, some version of creaGeo
  ;-
  ;  
  
  ;!check number of arguments
  argcount=(n_elements(y0) ne 0) + (n_elements(yN) ne 0) + $
      (n_elements(m) ne 0) + (n_elements(q) ne 0) 

  if (argcount ne 2) then begin
    print, "Wrong number of argument provided to function LINEARIZE (nargs=",argcount,","
    print, "must be two!)"
    print,"y0=",y0
    print,"yN=",yN
    print,"m=",m
    print,"q=",q
    stop
  endif
  
  npoints=n_elements(x)
  ;!calculate m and q (if m and q are provided proceeds).
  if (n_elements(y0)  ne 0) then begin  
    if (n_elements(yn) ne 0) then begin
      m=(yn-y0)/(X[npoints-1]-X[0])
    endif else if (n_elements(q) ne 0) then begin
      if X[0] eq 0 then message,"overlapping parameters, y at x=0 and q."
      m=(y0-q)/X[0] 
    endif else begin
      if ~(n_elements(m) ne 0) then begin
        print,"Y0 only argument: this should never happen, check LINEARIZE ROUTINE!!"
        stop
      endif
    endelse 
    q=y0-x[0]*m
  endif else if (n_elements(yN) ne 0) then begin  
    if (n_elements(q) ne 0) then begin
      if X[npoints-1] eq 0 then message,"overlapping parameters, y at x=0 and q."
      m=(yN-q)/X[Npoints-1]
    endif else if (n_elements(m) ne 0) then $
      q=yN-x[npoints]-1*m $
    else print,"YN only argument: this should never happen, check LINEARIZE ROUTINE!!"
    
  endif
  
  ll=X*m+q
  ymin=(n_elements(minvalue) eq 0)? min(ll) : minvalue
  ymax=(n_elements(maxvalue) eq 0)? max(ll) : maxvalue
  
  if (ymin gt ymax) then message, "ERROR: MINVALUE>MAXVALUE in function LINEARIZE"
  
  for i=0,npoints-1 do begin
    if (ll[i] gt  ymax) then ll[i]=ymax
    if (ll[i] lt  ymin) then ll[i]=ymin
  endfor
  
  if arg_present(pars) then pars=[y0,yn,m,q]
  
  return, ll

end 

x=findgen(10)
l=linearize(x,y0=1,yN=12,pars=pars)  ;l is linear set of values, m=1.11.. , q=2.0
print,l
print, pars

l=linearize(x,y0=pars[0],m=pars[2]) ;same, setting slope
print,l

;l=linearize(x,y0=pars[0],q=pars[3]) ;same, setting intercept, gives error, undetermined because of x=0
;print,l
l=(linearize([x[0]-1,x],y0=pars[0]-pars[2],q=pars[3]))[1:*] ;same, adding a fictious point and calculating y from m,q, this works. 
print,l


l=linearize(x,m=pars[2],q=pars[3]) ;same, setting m and q
print,l

end