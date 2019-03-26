function read_measure,filename,xl=xl,yl=yl,xstep=xstep,ystep=ystep,$
  xgrid=xgrid,ygrid=ygrid,isotropic=isotropic,npx=npx,npy=npy,$
  recenter=recenter,rawdata=rawdata,invertz=invertz
;read a data plane, resample it and return in 'standard format' (n and m-vector
;for x and y and n x m array for z).
;rawdata is a 3xNpoinst matrix with points coordinates as read from file.

  if keyword_set(invertz) then zfac=-1 else zfac=1
  readcol,filename,z,x,y,format='X,F,F,F'
  z=z*zfac
  rawdata=[[x],[y],[z]]
  
  if n_elements(xl) eq 0 then xl=range(x,/size)
  if n_elements(yl) eq 0 then yl=range(y,/size)
  
  if (n_elements(npx) ne 0) and (n_elements(xstep) ne 0) then $
    message,'npx and xstep cannot be both set.'
  if (n_elements(xgrid) ne 0) and (n_elements(xstep) ne 0) then $
    message,'xgrid and xstep cannot be both set.'
  if (n_elements(npx) ne 0) and (n_elements(xgrid) ne 0) then $
    message,'npx and xgrid cannot be both set.'
  if (n_elements(npy) ne 0) and (n_elements(ystep) ne 0) then $
    message,'npy and ystep cannot be both set.'
  if (n_elements(ygrid) ne 0) and (n_elements(ystep) ne 0) then $
    message,'ygrid and ystep cannot be both set.'
  if (n_elements(npy) ne 0) and (n_elements(ygrid) ne 0) then $
    message,'npy and ygrid cannot be both set.'   
    
  if (n_elements(xstep) ne 0) then npx=1+fix(xl/xstep)
  if n_elements(xgrid) eq 0 then begin
      xgrid=vector(min(x),min(x)+xl,npx+2)
      xgrid=xgrid[1:n_elements(xgrid)-2]
  endif
  if (n_elements(ystep) ne 0) then npy=1+fix(yl/ystep)
  if n_elements(ygrid) eq 0 then begin
      ygrid=vector(min(y),min(y)+yl,npy+2)      
      ygrid=ygrid[1:n_elements(ygrid)-2]
  endif
      
  npx=n_elements(xgrid)
  npy=n_elements(ygrid)

;  if n_elements(xstep) eq 0 then xstep=total(x[1:np-1]-x[0:np-2])/(np-1)
;  if n_elements(ystep) eq 0 then ystep=total(y[1:np-1]-y[0:np-2])/(np-1)
;  if keyword_set(isotropic) then begin
;    step=(xstep+ystep)/2)
;    xstep=step
;    ystep=step
;  endif
   
  return, resample_surface(x,y,z,xgrid=xgrid,ygrid=ygrid)
  
end