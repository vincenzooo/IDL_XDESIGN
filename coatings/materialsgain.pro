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

energy = dindgen(npe)/(npe-1)*(en_range[1]-en_range[0])+en_range[0]
alpha_deg =dindgen(npa)/(npa-1)*(deg_range[1]-deg_range[0])+deg_range[0]

ref='irt_converted/'+'Ir'
testmat='irt_converted/'+'Ni'

foreach m, testmat do begin
  r=materialsgain(m,ref,alpha_deg,energy,filename='')  
endforeach

end
