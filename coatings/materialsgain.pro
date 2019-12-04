function test_reflex,energy,angle,material
  ;+
  ;This is copied here 2019/12/03
  ;from plot_gain.pro. It was probably removed, but
  ;  that one is version for IRT list of photons,\
  ;  which "
  ;return a 2D array with reflectivity as a function of energy (in keV) and angle (in radians).
  ;this is an incomplete attempt to build a list of photons, removing common blocks from original IRT.
  ;a working version with original common blocks and workaround is in material analysis.
  ; "
  ;
  ; we try to ripristinate a version that works
  ;   with array of data:
  ;   
  ;   N.B.: energy e ener sono nomi terribili, rimpiazza
  ;   a cose fatte con ener_vec and ener_mat
  ;-
  nph=n_elements(energy)*n_elements(angle)

  a=reform(transpose(Rebin(angle, n_elements(angle), n_elements(energy))),nph)
  ener=reform(Rebin(energy, n_elements(energy), n_elements(angle)),nph)

  index=load_index(material,ener)  ;read and interpolate refraction index at the energy of each photon
  ;  rind=reform(Rebin(index, n_elements(energy), n_elements(angle)),nph)
  ;index=load_nk(ener,material)  ;read and interpolate refraction index at the energy of each photon
  rind_r=reform(Rebin(real_part(index), n_elements(energy), n_elements(angle)),nph)
  rind_i=reform(Rebin(imaginary(index), n_elements(energy), n_elements(angle)),nph)

  ;R=Reflex_monolayer(angle,ener,rind)
  R=Reflex_monolayer(a,complex(rind_r,rind_i))
  return, reform(r,n_elements(energy), n_elements(angle))

end


function materialsgain,mat,ref,alpha_deg,energy,filename=filename

  ;+
  ;compare two monolayer coatings creating two reflectivity matrices.
  ;Returns are returned as a matrix nener x nangles x 2.
  ;  and plotted with plot_gain.
  ;If filename is provided files are saved according to PLOT_GAIN outputs,
  ;   if set to empty string, show plots without saving results.
  ;
  ;Note it is independent on the library used for reflectivity calculation, 
  ;  provided reflex2D can do the calculation and is able to find indices
  ;  (here IRT indices are provided, in general same indices can work for all libraries).
  ;
  ;-
  
  WHILE !D.Window GT -1 DO WDelete, !D.Window ;close all currently open windows  
  
  ;get reflectivity matrix for test and reference material.
  r2D_mat=test_reflex(energy, !PI/2- alpha_deg*!PI/180d,mat)
  r2D_ref=test_reflex(energy, !PI/2- alpha_deg*!PI/180d,ref)

  plot_gain,90.-alpha_deg,energy,transpose(R2d_mat),transpose(R2d_ref),filename=filename,ntracks=3

  return,[[[r2d_mat]],[[r2d_ref]]]
end 



npe=100
npa=50
en_range=[0.1 ,5.]
deg_range=[0.7d, 0.85d]
nk_dir='C:\Users\kovor\Documents\IDL\user_contrib\imd\nk'

energy = dindgen(npe)/(npe-1)*(en_range[1]-en_range[0])+en_range[0]
alpha_deg =dindgen(npa)/(npa-1)*(deg_range[1]-deg_range[0])+deg_range[0]


;ref='irt_converted/'+'Ir'
ref=nk_dir+path_sep()+'Ir.nk'
;testmat='irt_converted/'+'Ni'
testmat=nk_dir+path_sep()+$
  ['Ni.nk','Au.nk','Pt.nk']
foreach m, testmat do begin
  r=materialsgain(m,ref,alpha_deg,energy,filename='')  
endforeach

end
