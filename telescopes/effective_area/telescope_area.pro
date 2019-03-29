;+
; NAME:
; TELESCOPE_AREA
;
; PURPOSE:
; Calculate on-axis effective area of a multi-shell Wolter telescope,
;   with arbitrary coatings. Using IMD procedures (.run IMD or .run IMDstart
;   need to be run before calling this function).
;
; CATEGORY:
; Telescopes
;
; CALLING SEQUENCE:
;
; Result = TELESCOPE_AREA(Energy,Alpha,Acoll,Coatings)
;
; INPUTS:
; Energy: vector of energies on which to calculate effective area.
; Alpha: vector with shell slope in degrees for each shell
; Acoll: vector with collecting area for each shell
; Coatings: vector with strings describing coatings for each of the shells,
;   if scalar, same coating is assumed on all shells.
;   coating can be described in either of three ways:
;     1) material name: a material name matching a filename (no extension) for IMD optical constants.
;          refraction index is read from IMD internal database. A scalar Roughness can be
;          provided
;     2) IMD structure file: 
;     3) Simple structure file: three column file with thickness, material (as in 1), roughness.
;   Comment lines (e.g. headers) starting by ; are ignored in structure files.
;
; OPTIONAL INPUTS:
; Roughness: rms surface roughness for reflectivity reduction, it has
;   effect only if coating is described by material name (monolayer) and it is
;   assumed zero if not provided. It is read from file if structure files are used.
;
; OUTPUTS:
; This function returns on-axis effective area for each shell as a function of energy
;   in form (nshell,nener). Total effective area EA_tot of the telescope as a function of 
;   energy can be obtained by resulting matrix EA_m as EA_tot=total(EA_m,1).
;
; COMMON BLOCKS:
; No common blocks are defined in the function itself, but since this uses IMD procedures,
;   see imd inline help for definitions and naming, 
;
; SIDE EFFECTS:
; IMD procedures must be loaded in memory.
;
;
; PROCEDURE:
; A reflectivity matrix is built by iterating over coatings and calculating the effective
;    area for all shells with same coating. Square reflectivity is multiplied by collecting 
;    area to create effective area matrix.
;
; EXAMPLE:
; ener=(findgen(10))/10.+0.2
; EA_m=EA_onaxis(ener,[1.8517,1.7954,1.7389],[7.3614,6.8313,6.3256],'Ir',4.) ;small telescope
; EA_tot=total(EA_m,1)
; window,/free
; plot,ener,EA_tot,xtitle='Energy (keV)',ytitle='Aeff (cm^2)',$
;   title='Total telescope On-axis effective area'
;
; MODIFICATION HISTORY:
;   Written by: Vincenzo Cotroneo 2019/03/26
;-


function telescope_area,energy,alpha,acoll,coatings,roughness
  
  if n_elements(outfolder) ne 0 then file_mkdir,outfolder
  
  nshell=n_elements(alpha)
  nener=n_elements(energy)
  lam=12.398425d/energy
  if n_elements(roughness) eq 0 then roughness=0
  if n_elements(coating_folder) eq 0 then c_folder=''
    
  EA_m=dblarr(nshell,nener) ;vector with effective areas for each Energy in columns for offaxis angles in rows
  coatingslist=coatings[uniq(coatings)]
  
  ;loop through each coating and calculate effective area for all shells with the specific coating,
  ;  populating effective area matrix
  foreach coat, coatingslist do begin
    
    ish_sel=where(coatings eq coat,c)
    if c ne 0 then begin
      ;convert coating to materials
      if file_extension(coat) eq 'nk' || file_extension(coat) eq '' then  begin
        ;assemble monolayer coatings
        z=[300.] ;arbitrary thick coating for monolayer
        materials=[coat,'Ni'] ;set as substrate
        sigma=roughness
      endif else if file_extension(coat) eq 'imd' then begin
        ;multilayer structure description in imd format, load from file
        readcol,c_folder+path_sep()+coat,th,materials,sigma,format='F,A,F'
        endif else begin
        ;multilayer structure description on three columns, load from file
        readcol,c_folder+path_sep()+coat,th,materials,sigma,format='F,F,F'
      endelse
      materials = file_basename(materials)
      
      nc=load_nc(lam,materials)
      fresnel,90.-alpha[ish_sel], lam, nc,z,sigma,ra=r_sel
      EA_m[ish_sel,*]=r_sel^2*Rebin(acoll[ish_sel], n_elements(ish_sel), nener)
      
    endif

  endforeach

  return, EA_m

end


;infolder contains telescope_geometry.dat and telescope_geometry_info, from which relevant geometrical
;  information acoll, angle and coating, are extracted.

;infolder='../SEEJ_updated/current_version/data/tests/control/cubex/cubex_24shells_01/Config001' 
infolder='test/input/cubex_24shells_01/Config001'
outfolder='test/results/test_telescope_area/cubex_24shells_01/Config001'

a=read_datamatrix(infolder+path_sep()+'telescope_geometry.dat',skip=1)
coatings=a[(size(a))[1]-1:*,*]
;alpha in deg, acoll in cm^2
readcol,infolder+path_sep()+'telescope_geometry_info.dat',alpha,acoll,format='X,X,X,X,X,X,X,F,F,X'

file_mkdir,file_dirname(outfolder)
;--------------
; EXECUTION
roughness=4.
energy=vector(0.1d,5d,50)  
off_axis=!NULL

EA_m=telescope_area(energy,alpha,acoll,coatings,roughness)

;; PLOT
cleanup
setstandarddisplay

;plot BY SHELL
window,/free
plot,energy,energy*0,yrange=[0,max(EA_m)*1.1],xtitle='Energy (keV)',ytitle='Aeff (cm^2)',$
  title='Single shells effective area'
foreach oa, alpha, ioa do begin
  oplot,energy,EA_m[ioa,0:*],color=ioa+1
endforeach
legend,string(indgen(n_elements(alpha)))+string(alpha),col=indgen(n_elements(alpha))+1,pos=12,$
  title=string(9b)+'shell#'+string(9b)+'angle(deg)'
maketif,outfolder+path_sep()+'EA_shells'

;Plot Total
EA_tot=total(EA_m,1)
window,/free
plot,energy,EA_tot,xtitle='Energy (keV)',ytitle='Aeff (cm^2)',$
  title='Total telescope On-axis effective area'
maketif,outfolder+path_sep()+'EA_tot'


end
