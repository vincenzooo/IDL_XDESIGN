function read_geo,geofile,acoll=acoll,ang=ang,header=h,_extra=e
  ;+
  ; read acoll and ang from file in format 1, 3, 6 or 8 col.
  ; `a` is raw data matrix.
  ; Useso READ_DATAMATRIX
  ;-

  a = read_datamatrix (geofile,comment=[';','#','!'],$
    header=h,_extra=e)
  if size(a,/N_dim) ne 2 then message, 'wrong format for geometry file'
  s = size(a,/dim)
  if s[0] eq 1 then begin ;
    acoll=transpose(a)
  endif else if s[0] eq 3 then begin
    acoll = transpose(a[2,*])
    ang = transpose(a[1,*])
  endif else if s[0] eq 8 then begin  ; here in rad
    acoll = transpose(a[6,*])
    ang = transpose(a[5,*])*180/!PI
  endif  else if s[0] eq 10 then begin
    acoll = transpose(a[8,*])
    ang = transpose(a[7,*])
  endif
  acoll=double(acoll)
  ang=double(ang)
  return,a
end