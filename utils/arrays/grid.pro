function grid, x, y,xout=xgrid, yout=ygrid
; return two vectors containing the x and y coordinates
; of the points on the grid defined by the x and y vectors.
; x is cycled faster.
 
ny=n_elements(y)
nx=n_elements(x)
Xgrid = reform(rebin(x,[nx,ny]),nx*ny) 
Ygrid = reform(transpose(rebin(y,[ny,nx])),nx*ny)

return,[[xgrid],[ygrid]]

end