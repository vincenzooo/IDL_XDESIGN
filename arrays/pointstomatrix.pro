
;
;+
; NAME:
; POINTSTOMATRIX
;
; PURPOSE:
; This function transform a vector of points in a 2D matrix. The number of points is obtained
; by the x and y values. These can be incorporated in the first row/column of the matrix with 
; the flag WithAxis. In alternative, NPX and NPY can be used to specify the number of points for 
; each dimension (if X and Y are not provided the integer index is used). 
; If the starting set of data are the coordinates of each point, x and y vectors can be
; passed, if 
;
; CATEGORY:
; Arrays
;
; CALLING SEQUENCE:
; Result = PointsToMatrix( Points, X, Y)
;
; INPUTS:
; X, Y: can be passed as 
;
; OPTIONAL INPUTS:
; Npx, Npy:  Number of points in x and Y directions
; 
; KEYWORD PARAMETERS:
; /WITHAXIS: if set, axis are added as first and last column.
; /GUESS: if set POINTS,X,Y are provided as three (equal length)
; vectors, but no parameters are passed for the axis grid, try to guess
; it from X and Y vectors.
; 
; PADDING: (number) if this argument is provided (and /WITHAXIS is set), 
;   PADDING is used to fill the top left cell in the file.
;   The default is 0.
; 
; OUTPUTS:
;  N x M matrix.
;
; OPTIONAL OUTPUTS:
; Describe optional outputs here.  If the routine doesn't have any, 
; just delete this section.
; xgrid, ygrid
;
; SIDE EFFECTS:
; If npx and npy are provided and the product of the respective numbers of elements
; is equal to the number of elements in POINTS (e.g. if they are switched), 
; the matrix is created and the program has no way to detect the error.  
; 
; EXAMPLE:
; a=findgen(6)
; x=[12,14]
; y=[25,27,32]
; 
; print,pointsToMatrix(a,x,y)
;      0.00000      1.00000
;      2.00000      3.00000
;      4.00000      5.00000
; print,pointsToMatrix(a,x,y,/withAxis)
;      0.00000      12.0000      14.0000
;      25.0000      0.00000      1.00000
;      27.0000      2.00000      3.00000
;      32.0000      4.00000      5.00000
; print,pointsToMatrix(a,x,y,/withAxis,padding=-1)
;     -1.00000      12.0000      14.0000
;      25.0000      0.00000      1.00000
;      27.0000      2.00000      3.00000
;      32.0000      4.00000      5.00000
; print,pointsToMatrix(a,x,y,/withAxis,padding=-1,npx=2,npy=3)
;     -1.00000      12.0000      14.0000
;      25.0000      0.00000      1.00000
;      28.0000      2.00000      3.00000
;      32.0000      4.00000      5.00000 
; But beware:
; print,pointsToMatrix(a,x,y,/withAxis,padding=-1,npx=3,npy=2)
;      -1.00000      12.0000      13.0000      14.0000
;      25.0000      0.00000      1.00000      2.00000
;      32.0000      3.00000      4.00000      5.00000
; Still valid, but wrong... 
;--------------     
; print,pointsToMatrix(a,/withAxis,padding=-1,npx=2,npy=3)
;% POINTSTOMATRIX: X is not provided, index will be used for X coordinate
;% POINTSTOMATRIX: Y is not provided, index will be used for Y coordinate
;     -1.00000      0.00000      1.00000
;      0.00000      0.00000      1.00000
;      1.00000      2.00000      3.00000
;      2.00000      4.00000      5.00000
;      
; MODIFICATION HISTORY:
;   Written by: Vincenzo Cotroneo, Date.
;   Harvard-Smithsonian Center for Astrophysics
;   60, Garden street, Cambridge, MA, USA, 02138
;   vcotroneo@cfa.harvard.edu
;   
;   Written by: Vincenzo Cotroneo, Date.
;   INAF/Brera Astronomical Observatory
;   via Bianchi 46, Merate (LC), 23807 Italy 
;   vincenzo.cotroneo@brera.inaf.it
;   
;-

function PointsToMatrix,points,x,y, withAxis=withAxis,npx=npx,npy=npy,$
    xgrid=xout,ygrid=yout,padding=padding,guess=guess,$
    xout=xxo,yout=yyo
    
  if n_elements(xxo) ne 0 or n_elements(yyo) ne 0 then message,'obsolete, rename to xgrid|ygrid'

  if keyword_set(guess) then begin
    if n_elements(x) ne n_elements(y) then message,'X and Y have different lengths with /GUESS set.'
    if n_elements(x) ne n_elements(points) then message,'POINTS has different length than X and Y with /GUESS set.'
    ;determine if the scan is along x or y
    xfaster=abs((x[1]-x[0])) gt abs((y[1]-y[0]))
    if xfaster then begin ;pointers are mindbending
      faster=x
      slower=y
    endif else begin
      faster=y
      slower=x
    endelse
    i=0L
    while abs((faster[i+1]-faster[0])) gt abs((slower[i+1]-slower[0])) do begin 
      i=i+1
    endwhile
    npfaster=i+1
    npslower=n_elements(x)/npfaster
    
    if float(n_elements(x))/npslower ne float(npfaster) then message,'error in determining number of points'
    if xfaster then begin ;pointers are mindbending
      npx=npfaster
      npy=npslower
    endif else begin
      npy=npfaster
      npx=npslower
    endelse
    xrange=range(x)
    xout=creategrid(x0=xrange[0],x1=xrange[1],np=npx) ;+ec[0]+ec[1])
    ;xgrid=xgrid[ec[0]:npx+ec[0]-1]
    yrange=range(y)
    yout=creategrid(x0=yrange[0],x1=yrange[1],np=npy) ;+ec[0]+ec[1])
    
  endif else begin
    if n_elements(x) eq n_elements(points) then $ 
      if n_elements(y) ne 1 then message,'No info provided for X and Y sizes'+$
      'set the /GUESS flag OR pass NPX and NPY.'
    ;set x and y grids
    if n_elements(x) ne 0 then begin
      if n_elements(npx) ne 0 then  $
        xout=fix(createGrid(x0=(range(x))[0],x1=(range(x))[1],npoints=npx),type=size(points,/type)) $
      else begin
        xout=fix(x,type=size(points,/type))
        npx=n_elements(x)
      endelse
    endif else begin
      if n_elements(npx) eq 0 then message,"No values provided for X and NPX (at least one of them is needed)"
      message,"X is not provided, index will be used for X coordinate",/informational
      xout=indgen(npx,type=size(points,/type))
    endelse
    
    if n_elements(y) ne 0 then begin
      if n_elements(npy) ne 0 then  $
        yout=fix(createGrid(x0=(range(y))[0],x1=(range(y))[1],npoints=npy),type=size(points,/type)) $
      else begin
         yout=fix(y,type=size(points,/type))
         npy=n_elements(y)
      endelse
    endif else begin
      if n_elements(npy) eq 0 then message,"No values provided for Y and NPY (at least one of them is needed)"
      message,"Y is not provided, index will be used for Y coordinate",/informational
      yout=indgen(npy,type=size(points,/type))
    endelse
  endelse
  
  if n_elements(padding) eq 0 then padding=0
  if n_elements(padding) gt 1 then message, 'PADDING must be a single value.'
  
  m=reform(points,npx,npy)
  if keyword_set(withAxis) then begin
    m=[transpose(yout),m]
    m=[[padding,xout],[m]]
  endif
  
  return,m

end

pro test

  ; EXAMPLE:
   a=findgen(6)
   x=[12.3,14.6]
   y=[25.0,27.5,32.0]
  ; 
  help,a
  print,a
  help,x
  print,x
  help,y
  print,y
  print,'pointsToMatrix(a,x,y)'
  print,pointsToMatrix(a,x,y)
;     0.000000      1.00000
;      2.00000      3.00000
;      4.00000      5.00000
  
  print,'pointsToMatrix(a,x,y,/withAxis)'
  print,pointsToMatrix(a,x,y,/withAxis)
;     0.000000      12.3000      14.6000
;      25.0000     0.000000      1.00000
;      27.5000      2.00000      3.00000
;      32.0000      4.00000      5.00000
  print,'pointsToMatrix(a,x,y,/withAxis,padding=-1)'
  print,pointsToMatrix(a,x,y,/withAxis,padding=-1)
;     -1.00000      12.3000      14.6000
;      25.0000     0.000000      1.00000
;      27.5000      2.00000      3.00000
;      32.0000      4.00000      5.00000
   print,'pointsToMatrix(a,x,y,/withAxis,padding=-1,npx=2,npy=3)'
   print,pointsToMatrix(a,x,y,/withAxis,padding=-1,npx=2,npy=3)
;     -1.00000      12.3000      14.6000
;      25.0000     0.000000      1.00000
;      27.5000      2.00000      3.00000
;      32.0000      4.00000      5.00000
  ; But beware:
   print,'pointsToMatrix(a,x,y,/withAxis,padding=-1,npx=3,npy=2)'
   print,pointsToMatrix(a,x,y,/withAxis,padding=-1,npx=3,npy=2)
;     -1.00000      12.3000      13.4500      14.6000
;      25.0000     0.000000      1.00000      2.00000
;      32.0000      3.00000      4.00000      5.00000
  ; Still valid, but the program is unable to detect the mistake by counting elements... 
  ;--------------     
   print,'pointsToMatrix(a,/withAxis,padding=-1,npx=2,npy=3)'
   print,pointsToMatrix(a,/withAxis,padding=-1,npx=2,npy=3)
;% POINTSTOMATRIX: X is not provided, index will be used for X coordinate
;% POINTSTOMATRIX: Y is not provided, index will be used for Y coordinate
;     -1.00000     0.000000      1.00000
;     0.000000     0.000000      1.00000
;      1.00000      2.00000      3.00000
;      2.00000      4.00000      5.00000
  ;      
  
  a=findgen(6)
  x=[12,14]
  y=[25,27,32]
  xy=grid(x,y)
  xx=xy[*,0]
  yy=xy[*,1]
  
  help,xx
  print,xx
  help,yy
  print,yy
  
  print,'pointsToMatrix(a,xx,yy,/guess,/withAxis)'
  print,pointsToMatrix(a,xx,yy,/guess,/withAxis)
  ;     0.000000      12.0000      14.0000
  ;      25.0000     0.000000      1.00000
  ;      28.0000      2.00000      3.00000
  ;      32.0000      4.00000      5.00000
  print,'pointsToMatrix(a,yy,xx,/guess,/withAxis)'
  print,pointsToMatrix(a,yy,xx,/guess,/withAxis)
  ;     0.000000      25.0000      28.0000      32.0000
  ;      12.0000     0.000000      1.00000      2.00000
  ;      14.0000      3.00000      4.00000      5.00000

end

test

end
