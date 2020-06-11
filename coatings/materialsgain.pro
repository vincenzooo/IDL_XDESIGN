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

  ;+
  ; TREF2D
  ;
  ; VC 2019/03/29
  ; compare reflectivity of different monolayer coatings in a range of angles and energies.
  ; wrapper around REFLEX_IRT (IRT fresnel formula applied to list of photons).
  ;
  ; REFLEX_IRT (formerly IRT_REFLEX) calculates reflectivity for a list of photons, each one with angle and energy
  ; REFLEX2D_IRT uses REFLEX_IRT to BUILD a 2D reflectivity matrix. Tests in plot_gain have a more evolved version.
  ; MATERIALSGAIN: from two materials and a range of angles and energy, use plot_gain to show gain in 2d and 1d
  ;
  ; RUNNING THIS FILE runs MATERIALGAINS comparing a list of materials to a reference material (Ir).
  ;     Index folder in IRT format must be a path relative to current path.
  ;
  ; OUTPUT: THREE FILE FOR EACH MATERIAL ARE CREATED IN THE CURRENT FOLDER.
  ;
  ;-
  
  WHILE !D.Window GT -1 DO WDelete, !D.Window ;close all currently open windows  
  
  ;get reflectivity matrix for test and reference material.
  r2D_mat=reflex2D_IRT(energy, !PI/2- alpha_deg*!PI/180d,mat)
  r2D_ref=reflex2D_IRT(energy, !PI/2- alpha_deg*!PI/180d,ref)

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
  r=materialsgain(m,ref,alpha_deg,energy) ;,filename='')  
endforeach

end
