

function reflex2D_IRT,energy,angle,material
  ;+
  ;Return a 2D array with reflectivity as a function of energy (in keV) and grazing angle (in radians).
  ; Energy and angle can also be scalar.
  ;Wrapper around REFLEX_IRT (IRT fresnel formula applied to list of photons).
  ; REFLEX_IRT calculates reflectivity for a list of photons, each one with angle and energy
  ; REFLEX2D_IRTuses REFLEX_IRT to BUILD a 2D reflectivity matrix. 
  ;   
  ; This funciton results from merged TEST_IRT_REFLEX, TREF2D e REFLEX_MONOLAYER
  ;-
  
  if (size(energy))[0] eq 0 then energy=[energy]
  if (size(angle))[0] eq 0 then ang=[angle] else ang = angle
  
  nph=n_elements(energy)*n_elements(ang)

  ang=reform(transpose(Rebin(ang, n_elements(ang), n_elements(energy))),nph)
  ener=reform(Rebin(energy, n_elements(energy), n_elements(angle)),nph)

  ;removed 2020/06/11
  ;index=load_index(material,ener)  ;read and interpolate refraction index at the energy of each photon
  index = load_nk(12.398425d/energy,material)
  
  ;complex interpolation doesn't work (?) so I need to manually perform it
  ; rind=reform(Rebin(index, n_elements(energy), n_elements(angle)),nph) ;not working
  ;index=load_nk(ener,material)  ;read and interpolate refraction index at the energy of each photon
  rind_r=reform(Rebin(real_part(index), n_elements(energy), n_elements(angle)),nph)
  rind_i=reform(Rebin(imaginary(index), n_elements(energy), n_elements(angle)),nph)

  ;R=Reflex_monolayer(angle,ener,rind)
  ;ANG=!PI/2.-Angle  ;convert to angle to normal in rad
  R=REFLEX_IRT(!PI/2.-Ang,dcomplex(rind_r,rind_i))
  return, reform(r,n_elements(energy), n_elements(angle))

end


WHILE !D.Window GT -1 DO WDelete, !D.Window ;close all currently open windows
setstandarddisplay

print,"test TREF"

MAKE_IRT_TEST_VAL,$
  energy=energy,alpha=alpha_deg,$
  wavelength=lam,mat=mat

i=5   ;test index for angle
j=80  ;test index for energy

;test calling with two vectors
;r2D=tref2d(lam, !PI/2- alpha_deg*!PI/180d,mat)
r2D=reflex2D_IRT(energy, alpha_deg*!PI/180d,mat)

window,/free
cont_image,R2d,energy,alpha_deg,xtitle='Energy(keV)',ytitle='Grazing Angle (deg)',$
  /colorbar,title='Reflectivity of '+file_basename(mat)

;add section lines on 2D plot, giusto per fare scena

;extract a row from reflex2d
window,/free
plot,energy,r2d[*,i],xtitle='Energy(keV)',ytitle='Reflectivity',$
  title='Reflectivity of '+file_basename(mat)+' at '+ $
  string(alpha_deg[i],format='(f6.3)')+' deg'

;calculate for a row only
r_en=reflex2D_IRT(energy, alpha_deg[i]*!PI/180d,mat)
;r_en=tref2d(lam, !PI/2- alpha_deg[i]*!PI/180d,mat)
oplot,energy,r_en,psym=1,color=2

;calculate for a point only
r_p=reflex2D_IRT(energy[j], alpha_deg[i]*!PI/180d,mat)
;r_p=tref2d(lam[j], !PI/2- alpha_deg[i]*!PI/180d,mat)
oplot,energy[j:j+1],r_p,psym=4,color=3
legend,['calculated from row',$
  'calculated for point',$
  'extracted column'],color=[1,2,3],psym=[1,1,4],$
  position=12

;extract a column from reflex2d
window,/free
plot,alpha_deg,r2d[j,*],xtitle='Grazing Angle (deg)',ytitle='Reflectivity',$
  title='Reflectivity of '+file_basename(mat)+' at '+ $
  string(energy[j],format='(f6.3)')+' keV'

;calculate for a column only
r_an=reflex2D_IRT(energy[j], alpha_deg*!PI/180d,mat)
;r_an=tref2d(lam [j], !PI/2- alpha_deg*!PI/180d,mat)
oplot,alpha_deg,r_an,psym=1,color=2

;calculate for a point only
oplot,alpha_deg[i:i+1],r_p,psym=4,color=3

legend,['calculated from column',$
  'calculated for column',$
  'calculated for point'],color=[1,2,3],$
  psym=[1,1,4],position=12

end
