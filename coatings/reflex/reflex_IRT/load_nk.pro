;+
;LOAD_NK, LAM, MATERIAL
;
;;Complex optical constants for lam from file
; Return complex refraction indices as read from file `Material` interpolated
;   at wavelength lam.
; lam doesn't need to be sorted. If Lam is not provided, return as from file.
;-

function load_nk,lam,material
  
  ;remove /silent for debug, make sure it is not called too many times:
  ;readcol,material,l,r,i,comment=';',/quick,/silent   
  ;lam=12.398425d/energy
  g=read_datamatrix(material,skip=1,type=5)
  l=g[0,*]
  r=g[1,*]
  i=g[2,*]
  

  isel=where(l gt 0,c)
  if c eq 0 then message, "file read, but no value found on optical constants file ",fil
  
  if n_elements(lam) ne 0 then begin
    r_nk=interpol( r[isel], l[isel], lam)
    i_nk=interpol( i[isel], l[isel], lam)
  endif else begin
    r_nk=r[isel]
    i_nk=i[isel]    
    lam=l[isel]
    if n_elements(r_nk) ne n_elements(i_nk) or n_elements(r_nk) ne n_elements(i_nk) then $
      message,"Something wrong in reading optical constants of "+mats
  endelse
    
  return, dcomplex(r_nk,i_nk)
  ;return, n
end

pro compare_nk,energy,mats,ind  ;mats list of two

  lam=12.398425d/energy
  readcol,mats[0]+'.nk',l,r,i,comment=';'
  readcol,mats[1]+'.nk',l1,r1,i1,comment=';'
  window,/free
  plot,l,r
  oplot,l1,r1,color=2,psym=4

  window,/free
  plot,l,i
  oplot,l1,i1,color=2,psym=4

  nk_ind0=nk(lam,mats[0])

  window,/free
  plot,energy,real_part(nk_ind0),title=file_basename(mats[0])+' refraction index ',$
    xtitle='Energy(keV)',ytitle= 'Real part'
  nk_ind1=load_nk(lam,mats[1])

  oplot,energy,real_part(nk_ind1),psym=4,color=2
  ind=list(real_part(nk_ind0),real_part(nk_ind1))

end

pro test_nk,energy,matlist
  ;COMMON RAYS,X,Y,Z,QX,QY,QZ,LAM,NUM,NIND
  ;COMMON PHYS,DIFF,ORDS,REFMAT,LENSMAT,SUNITS,WUNITS

  ;wunits=''  ;will use default (Angstrom)
  lam=12.398425d/energy
  foreach mat, matlist do begin
    ;nk_ind=load_nk(lam,mat)
    nk_ind=load_nk(lam,mat+'.nk')
    window,/free
    plot,energy,real_part(nk_ind),title=file_basename(mat)+' refraction index ',$
      xtitle='Energy(keV)',ytitle= 'Real part'

    im=imaginary(nk_ind)
    AXIS, YAXIS=1, YSTYLE = 1,ytitle= 'Im. part', yrange=[min(im),max(im)], /save,/ylog
    oplot,energy,im
  endforeach

end

WHILE !D.Window GT -1 DO WDelete, !D.Window ;close all currently open windows
setstandarddisplay,/tek
cd,programrootdir()

print,"test NK"
nkpath='/home/cotroneo/usr_contrib/kov/coatings/reflex/test/input/nk'
;nkpath='irt_converted'
npoints=100
en_range=[0.1 ,5.]
matlist = nkpath+path_sep()+ ['Ir','Pt','Ni','Au']
energy = findgen(npoints)/(npoints-1)*(en_range[1]-en_range[0])+en_range[0]

;compare_nk,energy,['irt_converted/Ir','nk.dir/Ir'],ind

test_nk,energy,matlist

end