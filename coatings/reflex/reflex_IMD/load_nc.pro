;load refraction indices using IMD function (moved here from refle_funk_beta. 
; call .run imdstart (or .run IMD and close all windows) before running this code, prompt should change to IMD>

function load_nc,lam, matlist,c_mat,medium=medium,mat_hash=mat_hash
  ;+
  ;load refraction indices from IMD optical constant for all 
  ;  materials in stack for a list of wavelengths.
  ;  return a complex matrix Nmat+1 x Nlam in format compatile with IMD
  ;  FRESNEL routine.
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
  ;  medium is usually vacuum, user can optionally provide a list of complex
  ;     refraction indices (same length as lam).
  ;  mat_hash: used to output the refraction indices hash, useful to recalculate
  ;     reflectivity without reading optical constant file (e.g. if number or order of
  ;     layers changes).
  ;
  ;2020/12/23 modified for faster reading in case of repeated material multilayer, 
  ;   each material is read only once.
  ;-
  materials=matlist
  if n_elements(c_mat) ne 0 then materials = [c_mat,materials]
  
  ; medium to put as first layer
  if n_elements(medium) eq 0 then $
    nc = replicate(dcomplex(1,0),n_elements(lam)) $
  else begin
    if n_elements(medium) ne n_elements(lam) then message, 'if MEDIUM is provided, must be same length as LAM'
    nc=medium
  endelse  
  ; read all materials indices in a case-insensitive hash
  keys = unique (materials)
  mat_hash = hash(/fold_case)
  foreach mat, keys do begin
    mat_hash[mat] = IMD_NK(mat,lam)
  endforeach

  foreach mat, materials do begin
    nc=[[nc],[mat_hash(mat)]]
  endforeach

  return, transpose(nc)
end


en_vec =vector(0.2,10.,20)
lam=12.39845/en_vec

nc1=load_nc(lam,['a-C','Ir','Ni'])
;nc2=load_nc(lam,['a-C','Ir','Ni'])
;nc3=load_nc(lam,['Ir','Ni'],'a-C')

print,nc1
end