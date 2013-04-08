; TODO replace this function with the intrinsic griddata
function resample_surface,x,y,z,xgrid=xgrid,ygrid=ygrid
  ;given three vectors of points coordinates x,y,z,
  ;return a 2-D matrix of points corresponding to interpolated z points
  ;on the x and y coordinates defined by xgrid and ygrid
  
  triangulate,x,y,triangles,boundaryPoints
  s=size(triangles,/dimensions)
  ntriangles=s[1]
  ;plot,[0],[0],xrange=range(x),yrange=range(y)
;  for i=0l,ntriangles-1 do begin
;    thisTriangle=[triangles[*,i],triangles[0,i]]
;    ;oplot,x[thisTriangle],y[thisTriangle]
;  endfor
  griddeddata=trigrid(x,y,z,triangles,xout=xgrid,yout=ygrid,Extrapolate=boundaryPoints)
  return,griddeddata
end