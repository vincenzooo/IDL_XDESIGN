function coating_reflex,coat,lam,angles,roughness=roughness
  ;convert a coating to reflectivity for a set of lambda and angles.
  ;It is basically another version of reflex_2d accepting different formats
  ;  of coating descriptors. coating format is recognized by the extension:
  ;  .nk it is a single material, the file is refraction index. 
  ;     roughness is used as passed
  ;  .imd imd format with a set 
  ;  return a 2d matrix (nangles,lam)
  
  if n_elements(roughness) eq 0 then roughness =0
  if file_extension(coat) eq '.nk' || file_extension(coat) eq '' then  begin
    ;assemble monolayer coatings
    z=[300.] ;arbitrary thick coating for monolayer
    materials=[coat,'Ni'] ;set as substrate
    sigma=roughness
  endif else if file_extension(coat) eq '.imd' then begin
    ;multilayer structure description in imd format, load from file
    readcol,coat,materials,z,sigma,format='X,A,F,F,X,X,X,X',comment=';',/quick
    materials=[materials,'Ni'] ;set as substrate
    sigma=[sigma,roughness]
  endif else begin
    ;multilayer structure description on three columns, load from file
    readcol,coat,z,materials,sigma,format='F,A,F'
  endelse
  materials = file_basename(materials)

  nc=load_nc(lam,materials)
  fresnel,90.-angles, lam, nc,z,sigma,ra=r_sel

  return,r_sel

end

cd,programrootdir()
;IMD> size(nc_bare)
;2           3         201           6         603
;IMD> size(nc_coated)
;2           4         201           6         804
;IMD> materials
;Pt
;Ni
;IMD> c_mat
;a-C

; EXECUTION
;roughness=4.
;off_axis=!NULL
alpha=1.3425 ;[1.8517,1.3425,0.5440]
energy=5d*(findgen(100))/100.+0.5
lam=12.398/energy

coat='Ir'
ref=coating_reflex(coat,lam,alpha)
plot,energy,ref[0,*]


z=[80.,300.]
angles=1.1d
nc=load_nc(lam,'test/input/coatings/IrC.imd')
fresnel,90.-angles, lam, nc,z,ra=r_sel
plot,energy,r_sel



end