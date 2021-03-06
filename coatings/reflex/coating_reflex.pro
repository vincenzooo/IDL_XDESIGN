function coating_reflex,coat,lam,angles,roughness=roughness,lib=lib
  ;convert a coating to reflectivity for a set of lambda and angles (grazing angles in degrees).
  ;It is basically another version of reflex_2d accepting multiple formats
  ;  of coating descriptors. coating format is recognized by the extension:
  ;  .nk or no extension, it is a single material, the file is refraction index. 
  ;     optical constant is in IMD or IRT format, meaning a 3 column with wavelength, real, imag
  ;     and any number of ignored lines starting by ;
  ;     roughness is used from parameters
  ;  .imd imd format as exported layers. Note that substrate is not included in this format
  ;     and periodic multilayers probably don't export correctly.
  ;  .dat, .txt or any other format, 
  ;  return a 2d matrix (nangles,lam) with reflectivity
  ;-
  
  if n_elements(lib) eq 0 then lib = 'IRT'
  
  if n_elements(roughness) eq 0 then roughness =0
  


  if lib eq 'IMD' then begin
    
    ;Prepare correct coating description.
    if file_extension(coat) eq '.nk' || file_extension(coat) eq '' then  begin
      ;assemble monolayer coatings
      z=[300.] ;arbitrary thick coating for monolayer
      materials=[coat,'Ni'] ;set as substrate
      sigma=roughness
    endif else if file_extension(coat) eq '.imd' then begin
      ;multilayer structure description in imd format, load from file
      readcol,coat,materials,z,sigma,format='X,A,F,F,X,X,X,X',comment=';' ;/quick
      materials=[materials,'Ni'] ;set as substrate
      sigma=[sigma,roughness]
    endif else begin
      ;multilayer structure description on three columns, load from file
      readcol,coat,z,materials,sigma,format='F,A,F'
    endelse
    materials = file_basename(materials)
    
    nc=load_nc(lam,materials)
    fresnel,90.-angles, lam, nc,z,sigma,ra=r_sel, mfc_model=1 ; mfc_model=1 for nevot-croce roughness
  endif else if lib eq 'IRT' then begin
    ;nc=load_nc(lam,materials)
    r_sel=tref2d(lam,angles,coat)  ;replace with reflex2D_IRT
    ;message,"library IRT not implemented yet"
  endif else if lib eq 'dll' then begin
    message,"library dll not implemented yet"
  endif

  return,r_sel

end

cd,programrootdir()

; EXECUTION
;roughness=4.
;off_axis=!NULL

nkpath='C:\Users\kovor\Documents\IDL\user_contrib\imd\nk'

alpha=1.3425 ;[1.8517,1.3425,0.5440]
energy=5d*(findgen(100))/100.+0.5
lam=12.398/energy


coat=nkpath+path_sep()+'Ir.nk'
ref=coating_reflex(coat,lam,alpha)
plot,energy,ref[*,0],yrange=[0,1]


;z=[80.,300.]
;angles=1.1d
;r_sel=coating_reflex('test/input/coatings/IrC_100.imd',$
;  lam,alpha,lib='IMD')
;
;oplot,energy,r_sel,color=2
;legend,['Ir','IrC'],color=[1,2]



end