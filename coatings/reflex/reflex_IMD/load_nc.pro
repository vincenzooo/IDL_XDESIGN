;load refraction indices using IMD function (moved here from refle_funk_beta. 
; call .run imdstart (or .run IMD and close all windows) before running this code, prompt should change to IMD>

function load_nc,lam, matlist,c_mat
  ;+
  ;load refraction indices from IMD optical constant for all 
  ;  mterials in stack. 
  ;  
  ;  to load the IMD code needed, call .run imd and close all windows
  ;  (or .run IMDstart if present) .
  ;  If everything works, prompt should change to IMD>.
  ;  
  ;  arguments:
  ;  lam is vector wavelengths in angstrom
  ;  matlist is the list of materials (name of IMD optical constant file stripped
  ;    of extension, typically material name like 'Ir', 'Pt' etc.),
  ;    from surface to substrate. Matching optical constants files must be present
  ;    in imd_nk folder of IMD.
  ;  c_mat (string with overcoating material) is unnecessary, 
  ;     but it is kept for backwards compatibility.
  ;-
  materials=matlist
  nc=replicate(dcomplex(1,0),n_elements(lam))
  if n_elements(c_mat) ne 0 then materials=[c_mat,materials]
  foreach mat, materials do nc=[[nc],[IMD_NK(mat,lam)]]

  return,transpose(nc)
end


en_vec =vector(0.2,10.,20)
lam=12.39845/en_vec

nc1=load_nc(lam,['a-C','Ir','Ni'])
;nc2=load_nc(lam,['a-C','Ir','Ni'])
;nc3=load_nc(lam,['Ir','Ni'],'a-C')

print,nc1
end