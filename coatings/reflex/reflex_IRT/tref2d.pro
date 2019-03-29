;+
;
; VC 2019/03/29
; compare reflectivity of different monolayer coatings in a range of angles and energies.
; modification of IRT fresnel formula applied to list of photons.
; 
; IRT_REFLEX Calculate reflectivity for a list of photons, each one with angle and energy
; TREF2D uses IRT_REFLEX to BUILD a 2D reflectivity matrix. Tests in plot_gain have a more evolved version.
; 
; MATERIALSGAIN: from two materials and a range of angles and energy, use plot_gain to show gain in 2d and 1d
; 
; RUNNING THIS FILE runs MATERIALGAINS comparing a list of materials to a reference material (Ir). 
;     Index folder in IRT format must be a path relative to current path.
; 
; OUTPUT: THREE FILE FOR EACH MATERIAL ARE CREATED IN THE CURRENT FOLDER.
;
;-

;function load_nk,lam,material
;  readcol,material+'.nk',l,r,i,comment=';',/quick
;  ;lam=12.398425d/energy
;  r_nk=interpol( r, l, lam)
;  i_nk=interpol( i, l, lam)
;  return, dcomplex(r_nk,i_nk)
;  ;return, n
;end
;
;function TREF,ANG,NC
;  ;simple fresnel formula for monolayer, from IRT.
;
;  CT1=COS(ANG)
;  ST1=SQRT(1.-CT1*CT1)
;  ST2=ST1/NC
;  CT2=SQRT(1.-ST2*ST2)
;  TE=(CT1-NC*CT2)/(CT1+NC*CT2)
;  TM=(CT1-CT2/NC)/(CT1+CT2/NC)
;  RTE=double(TE*CONJ(TE))
;  RTM=double(TM*CONJ(TM)) 
;  R=(RTE+RTM)/2.
;  
;  RETURN, R
;END
;
;pro test_nk,energy,matlist
;  ;COMMON RAYS,X,Y,Z,QX,QY,QZ,LAM,NUM,NIND
;  ;COMMON PHYS,DIFF,ORDS,REFMAT,LENSMAT,SUNITS,WUNITS
;
;  wunits=''  ;will use default (Angstrom)
;  lam=12.398425d/energy
;  foreach mat, matlist do begin
;    ;nk_ind=load_nk(lam,mat)
;    nk_ind=load_nk(lam,mat)
;    window,/free
;    plot,energy,real_part(nk_ind),title=file_basename(mat)+' refraction index ',$
;      xtitle='Energy(keV)',ytitle= 'Real part'
;
;    im=imaginary(nk_ind)
;    AXIS, YAXIS=1, YSTYLE = 1,ytitle= 'Im. part', yrange=[min(im),max(im)], /save,/ylog
;    oplot,energy,im
;  endforeach
;
;end
;
;pro compare_nk,energy,mats,ind  ;mats list of two
;
;  lam=12.398425d/energy
;  readcol,mats[0]+'.nk',l,r,i,comment=';'
;  readcol,mats[1]+'.nk',l1,r1,i1,comment=';'
;  window,/free
;  plot,l,r
;  oplot,l1,r1,color=2,psym=4 
;
;  window,/free
;  plot,l,i
;  oplot,l1,i1,color=2,psym=4  
;  
;  nk_ind0=nk(lam,mats[0])
;  
;  window,/free
;  plot,energy,real_part(nk_ind0),title=file_basename(mats[0])+' refraction index ',$
;    xtitle='Energy(keV)',ytitle= 'Real part'
;  nk_ind1=load_nk(lam,mats[1])
; 
;  oplot,energy,real_part(nk_ind1),psym=4,color=2
;  ind=list(real_part(nk_ind0),real_part(nk_ind1))    
;  
;end


function tref2d,en,an,material
  ;reflex 2D
  ;+
  ;return a 2D array with reflectivity as a function of energy (in keV) and angle (in radians).
  ;  energy and angle need to be provided to TREF as vectors of same length (as a list of photons),
  ;  for compatibility with IRT.
  ;-

  if (size(energy))[0] eq 0 then energy=[en] else energy = en
  if (size(angle))[0] eq 0 then angle=[an] else angle = an
  
  ;trick the code to set the angle, artificially manipulating photon director vectors.
  ;in original code lambda and Qs have same size (one element per photon), here I use them
  ; to create a 2d matrix.
  nph=n_elements(energy)*n_elements(angle)
  
  a=reform(transpose(Rebin(angle, n_elements(angle), n_elements(energy))),nph)
  lam=12.398425d/reform(Rebin(energy, n_elements(energy), n_elements(angle)),nph)
  ;rind=load_nk(lam,material)  ;lam and material must be loaded before calling nk
  rind=load_nk(lam,material)  ;lam and material must be loaded before calling nk
  
  R=IRT_REFLEX(a,Rind)
  
  return, reform(r,n_elements(energy), n_elements(angle))

end

WHILE !D.Window GT -1 DO WDelete, !D.Window ;close all currently open windows
setstandarddisplay,/tek

print,"test NK"
nkpath='nk.dir'
;nkpath='irt_converted'

print,"test TREF"

npa=10   ;number of anglees
npe=100  ;number of energies
en_range=[0.1 ,10.]
deg_range=[0.7d, 0.85d]
mat = nkpath+path_sep()+'Ir'
i=5   ;test index for angle
j=80  ;test index for energy

;create input axis vectors
energy = dindgen(npe)/(npe-1)*(en_range[1]-en_range[0])+en_range[0]
alpha_deg =dindgen(npa)/(npa-1)*(deg_range[1]-deg_range[0])+deg_range[0]

;test calling with two vectors
r2D=tref2d(energy, !PI/2- alpha_deg*!PI/180d,mat)


window,/free
cont_image,R2d,energy,alpha_deg,xtitle='Energy(keV)',ytitle='Grazing Angle (deg)',$
  /colorbar,title='Reflectivity of '+file_basename(mat)

;extract a row from reflex2d
window,/free
plot,energy,r2d[*,i],xtitle='Energy(keV)',ytitle='Reflectivity',$
  title='Reflectivity of '+file_basename(mat)+' at '+ $
  string(alpha_deg[i],format='(f6.3)')+' deg'

;calculate for a row only
r_en=tref2d(energy, !PI/2- alpha_deg[i]*!PI/180d,mat)
oplot,energy,r_en,psym=1,color=2

;calculate for a point only
r_p=tref2d(energy[j], !PI/2- alpha_deg[i]*!PI/180d,mat)
oplot,energy[j:j+1],r_p,psym=4,color=3

;extract a column from reflex2d
window,/free
plot,alpha_deg,r2d[j,*],xtitle='Grazing Angle (deg)',ytitle='Reflectivity',$
  title='Reflectivity of '+file_basename(mat)+' at '+ $
  string(energy[j],format='(f6.3)')+' keV'

;calculate for a column only
r_an=tref2d(energy [j], !PI/2- alpha_deg*!PI/180d,mat)
oplot,alpha_deg,r_an,psym=1,color=2

;calculate for a point only
oplot,alpha_deg[i:i+1],r_p,psym=4,color=3


end



