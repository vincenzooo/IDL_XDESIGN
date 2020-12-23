function materialsgain,mat,ref,alpha_deg,energy,filename=filename

  ;+
  ;Calculate and compare reflectivities of two monolayer coatings made of different materials in a range of angles and energies.
  ; Uses REFLEX_IRT (IRT fresnel formula applied to list of photons)., plotting the comparison with PLOT_GAIN.
  ;Results of reflectivity calculation are returned as a matrix nener x nangles x 2.
  ;If filename is provided files are saved according to PLOT_GAIN outputs,
  ;   if set to empty string, show plots without saving results.
  ;
  ; compare reflectivity of different monolayer coatings
  ;     Index folder in IMD format must be a path relative to current path.
  ;
  ; OUTPUT: THREE FILE FOR EACH MATERIAL ARE CREATED IN THE CURRENT FOLDER.
  ;
  ; funzione abbastanza inutile, nel senso che e' un semplice wrapper, ma non sarebbe molto piu' dura calcolare le matrici di riflettivita' con qualsiasi metodo (qui REFLEX2D_IRT) e poi plottarle con PLOT_GAIN. 
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
