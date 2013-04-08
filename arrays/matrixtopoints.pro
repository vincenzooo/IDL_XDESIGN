function matrixToPoints,matrix,x,y,withAxis=withAxis
;+
; NAME:
; matrixToPoints
;
; PURPOSE:
; Convert a 2D matrix (N x M) to a list of points coordinates (Npoints x 3, with Npoints=NxM).
;
; CATEGORY:
; Arrays
;
; CALLING SEQUENCE:
; Result = matrixToPoints(Matrix,x,y)
;
; INPUTS:
; Matrix: N x M points containing values on a rectangular grid.
;
; OPTIONAL INPUTS:
; X,Y: Coordinates for X and Y. If not provided and WITHAXIS is not set, uses the column/row indices.
;
; KEYWORDS:
; WITHAXIS: If this keyword is set, X and Y values are extracted from the matrix
; 1st column () and line ().
;
; OUTPUTS:
; This function returns a Npoints x 3 matrix (with Npoints=NxM).
; 
;
; MODIFICATION HISTORY:
;   Written by: Vincenzo Cotroneo, Date.
;   Harvard-Smithsonian Center for Astrophysics
;   60, Garden street, Cambridge, MA, USA, 02138
;   vcotroneo@cfa.harvard.edu
;   
;-
    if size(matrix,/n_dimension) ne 2 then message,"Matrix must be a 2D array."
    s=size(matrix,/dimension)
    sx=s[0]
    sy=s[1]
    if keyword_set(withAxis) then begin
      if n_elements(x) ne 0 or n_elements(y) ne 0 then message,"with axis is set, but X and Y values have been provided,"+$ 
      "they will be ignored and used for return values.",/warning
      x=matrix[1:-1,0]
      y=transpose(matrix[0,1:-1])
      data=matrix[1:-1,1:-1]
    endif else begin
      if n_elements(x) eq 0 then x=indgen(sx,type=size(matrix,/type)) else $
          if n_elements(x) ne sx then message,"Wrong number of elements for x ("+string(sx)+"), matrix size is "+string(s)
      if n_elements(y) eq 0 then y=indgen(sy,type=size(matrix,/type)) else $
          if n_elements(y) ne sy then message,"Wrong number of elements for y ("+string(sy)+"), matrix size is "+string(s)
      data=matrix
    endelse
        
    xygrid=grid(x,y)
    return, [[xygrid[*,0]],[xygrid[*,1]],[reform(data,n_elements(Data))]]

end 

pro matrixtolist_test
  a=findgen(4,5)
    print,a
  ;      0.00000      1.00000      2.00000      3.00000
  ;      4.00000      5.00000      6.00000      7.00000
  ;      8.00000      9.00000      10.0000      11.0000
  ;      12.0000      13.0000      14.0000      15.0000
  ;      16.0000      17.0000      18.0000      19.0000
    print,matrixToPoints(a)
  ;      0.00000      1.00000      2.00000      3.00000      0.00000      1.00000      2.00000      3.00000      0.00000      1.00000      2.00000      3.00000      0.00000      1.00000      2.00000
  ;      3.00000      0.00000      1.00000      2.00000      3.00000
  ;      0.00000      0.00000      0.00000      0.00000      1.00000      1.00000      1.00000      1.00000      2.00000      2.00000      2.00000      2.00000      3.00000      3.00000      3.00000
  ;      3.00000      4.00000      4.00000      4.00000      4.00000
  ;      0.00000      1.00000      2.00000      3.00000      4.00000      5.00000      6.00000      7.00000      8.00000      9.00000      10.0000      11.0000      12.0000      13.0000      14.0000
  ;      15.0000      16.0000      17.0000      18.0000      19.0000
  
    print,matrixToPoints(a,/withaxis)
  ;      1.00000      2.00000      3.00000      1.00000      2.00000      3.00000      1.00000      2.00000      3.00000      1.00000      2.00000      3.00000
  ;      4.00000      4.00000      4.00000      8.00000      8.00000      8.00000      12.0000      12.0000      12.0000      16.0000      16.0000      16.0000
  ;      5.00000      6.00000      7.00000      9.00000      10.0000      11.0000      13.0000      14.0000      15.0000      17.0000      18.0000      19.0000
end


matrixtolist_test

end