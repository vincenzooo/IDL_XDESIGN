pro MAKE_IRT_TEST_VAL,$
  energy=energy,alpha=alpha_deg,$
  wavelength=lam,materia=mat

  ;create all test variable needed 
  ;  for IRT routines for Ir monolayer.
  ;nkpath='irt_converted'
  ;nkpath='nk.dir'
  nkpath='C:\Users\kovor\Documents\IDL\user_contrib\imd\nk'
  mat = nkpath+path_sep()+'Ir.nk

  npa=10   ;number of angles
  npe=100  ;number of energies
  en_range=[0.1 ,10.]
  deg_range=[0.7d, 0.85d]

  ;create input axis vectors
  energy = dindgen(npe)/(npe-1)*(en_range[1]-en_range[0])+en_range[0]
  alpha_deg =dindgen(npa)/(npa-1)*(deg_range[1]-deg_range[0])+deg_range[0]
  lam=12.398425d/energy
  
end