;+
;modified by kov
;x,y,z 3 vectors with coordinates of points (same number of elements).
;return value [A,B,C] of plane Ax + By + C = z
;planesurf is a vector with z of plane points

;compute the average surface, calculate statistical indicator

; From original routine by M. Katz 1/26/04
; IDL function to perform a least-squares fit a plane, based on
; Ax + By + C = z
;
; ABC = plane_fit(x, y, z, error=error)
;-

function plane_fit, x, y, z,planesurf=plane

if size(z,/n_dimensions) eq 2 then begin
  ;points are provided as a matrix
  ;convert matrix to points and calls itself with points.
  tmp=matrixtopoints(z,x,y)
  xx=tmp[*,0]
  yy=tmp[*,1]
  zz=tmp[*,2]
  out=plane_fit(xx,yy,zz,plane=plane)
  return,out
endif else begin
  xxx=x
  yyy=y
  zz=z
endelse

if n_elements(yyy) ne n_elements(xxx) then message, "wrong number of elements for x and y."
if n_elements(zz) ne n_elements(xxx) then message, "wrong number of elements for z."

tx2 = total(xxx^2)
ty2 = total(yyy^2)
txy = total(xxx*yyy)
tx = total(xxx)
ty = total(yyy)
N = n_elements(xxx)

A = [[tx2, txy, tx], $
[txy, ty2, ty], $
[tx, ty, N ]]

b = [total(zz*xxx), total(zz*yyy), total(zz)]

out = invert(a) # b
plane=(out[0]*xxx+out[1]*yyy+out[2])

return, out
end

pro test_plane_fit,plane
  ;plane parameters
  if n_elements(plane) eq 0 then begin
    as=0.5
    bs=0.1
    cs=-0.3
  endif else begin
    as=plane[0]
    bs=plane[1]
    cs=plane[2]
  endelse
  
  ;grid
  npx=10
  npy=10

  xp=findgen(npx)
  yp=findgen(npy)
  xy=grid(xp,yp)
  x=xy[*,0]
  y=xy[*,1]
  surfPoints=fltarr(npx*npy)+x*as+y*bs+cs
  surfMatrix=pointsToMatrix(surfPoints,x,y,/guess)
  
  print, "X, Y and Z can be passed as vectors (with same number of elements)."
  print, "The result is a 3-elements vector with the plane coefficients."
  print, "An optional argument PLANESURF, with the surface plane, can be returned."
  a=plane_fit(x,y,surfPoints,plane=plane)
  help,a
  print,a
  print,"help,planesurf"
  help,plane
  
  print, "X, Y can be passed as coordinates of a grid, with Z passed as 2-D surface."
  a=plane_fit(xp,yp,surfMatrix,plane=plane)
  help,a
  print,a
  print,"help,planesurf"
  help,plane
  
end

test_plane_fit

end
