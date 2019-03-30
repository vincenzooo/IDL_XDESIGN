function coating_reflex,coat,lam,angles,roughness=roughness
  ;convert a coating to reflectivity for a set of lambda and angles.
  ;It is basically another version of reflex_2d accepting different formats
  ;  of coating descriptors. coating format is recognized by the extension:
  ;  .nk it is a single material, the file is refraction index. 
  ;     roughness is used as passed
  ;  .imd imd format with a set 
  ;  return a 2d matrix (nangles,lam)
  
  if file_extension(coat) eq '.nk' || file_extension(coat) eq '' then  begin
    ;assemble monolayer coatings
    z=[300.] ;arbitrary thick coating for monolayer
    materials=[coat,'Ni'] ;set as substrate
    sigma=roughness
  endif else if file_extension(coat) eq '.imd' then begin
    ;multilayer structure description in imd format, load from file
    readcol,c_folder+path_sep()+coat,th,materials,sigma,format='F,A,F,X,X,X'
  endif else begin
    ;multilayer structure description on three columns, load from file
    readcol,coat,th,materials,sigma,format='F,A,F'
  endelse
  materials = file_basename(materials)

  nc=load_nc(lam,materials)
  fresnel,90.-angles, lam, nc,z,sigma,ra=r_sel

  return,r_sel

end