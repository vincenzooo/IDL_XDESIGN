function readFEA,nodefilelist,datafilelist,positions=positions,displacements=displacements

;read node positions
  for i =0,n_elements(nodefilelist)-1 do begin
    readcol,nodefilelist[i],n,x,y,z,format='(I,F,F,F)'
    if i eq 0 then begin
      n_m=n
      x_m=x
      y_m=y
      z_m=z
    endif else begin
      n_m=[n_m,n]
      x_m=[x_m,x]
      y_m=[y_m,y]
      z_m=[z_m,z]
    endelse
  endfor
  s=sort(n_m)
  n_m=n_m[s]
  x_m=x_m[s]
  y_m=y_m[s]
  z_m=z_m[s]
  ;read displacements
  for i =0,n_elements(datafilelist)-1 do begin
    readcol,datafilelist[i],nd,dx,dy,dz,format='(I,F,F,F,X,X,X)',skip=18
    if i eq 0 then begin
      nd_m=nd
      dx_m=dx
      dy_m=dy
      dz_m=dz
    endif else begin
      nd_m=[nd_m,nd]
      dx_m=[dx_m,dx]
      dy_m=[dy_m,dy]
      dz_m=[dz_m,dz]
    endelse
  endfor
  s=sort(nd_m)
  nd_m=nd_m[s]
  dx_m=dx_m[s]
  dy_m=dy_m[s]
  dz_m=dz_m[s]
  if not array_equal(nd_m,n_m) then print,'WARNING!! n not equal!!'
  positions=[[x_m],[y_m],[z_m]]
  displacements=[[dx_m],[dy_m],[dz_m]]
  
  return,positions+displacements
end