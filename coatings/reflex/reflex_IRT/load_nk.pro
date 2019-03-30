function load_nk,lam,material
  readcol,material,l,r,i,comment=';',/quick
  ;lam=12.398425d/energy
  r_nk=interpol( r, l, lam)
  i_nk=interpol( i, l, lam)
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

  wunits=''  ;will use default (Angstrom)
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

print,"test NK"
nkpath='nk.dir'
;nkpath='irt_converted'
npoints=100
en_range=[0.1 ,5.]
matlist = nkpath+path_sep()+ ['Ir','Pt','Ni','Au']
energy = findgen(npoints)/(npoints-1)*(en_range[1]-en_range[0])+en_range[0]

;compare_nk,energy,['irt_converted/Ir','nk.dir/Ir'],ind

test_nk,energy,matlist

end