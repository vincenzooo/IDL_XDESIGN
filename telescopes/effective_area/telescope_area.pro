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


function reflexshells,coatings,alpha,lam,roughness=roughness
  ;loop through each coating and calculate effective area for all shells with the specific coating,
  ;  populating reflectivity matrix with reflectivity for each Energy
  ;  in columns and for offaxis angles + coating in rows
  ;

  ;cc list of coating for each shell
  cc = n_elements(coatings) eq 1? replicate(coatings,n_elements(alpha)):coatings

  coatingslist=coatings[uniq(cc)]
  reflex_m=dblarr(n_elements(alpha),n_elements(lam))

  foreach coat, coatingslist do begin
    ish_sel=where(cc eq coat,c)
    if c ne 0 then $
      reflex_m[ish_sel,*]= coating_reflex(coat,lam,alpha[ish_sel],roughness=roughness)
  endforeach
  return, reflex_m
end

function telescope_area,energy,alpha,acoll,coatings,roughness
  
  lam=12.398425d/energy
  if n_elements(roughness) eq 0 then roughness=0
  ;if n_elements(coating_folder) eq 0 then c_folder=''
  
  reflex_m=reflexshells(coatings,alpha,lam,roughness=roughness)
  ac = (size (acoll))[0] eq 0 ? [acoll] : acoll
  
  EA_m=reflex_m^2*Rebin(ac, n_elements(alpha), n_elements(energy))

  return, EA_m

end


;infolder contains telescope_geometry.dat and telescope_geometry_info, from which relevant geometrical
;  information acoll, angle and coating, are extracted.

cd, programrootdir()

outfolder='test/results/test_telescope_area/cubex_24shells_01/Config001'

file_mkdir,file_dirname(outfolder)
;--------------
; EXECUTION
roughness=4.
off_axis=!NULL
alpha=[1.8517,1.3425,0.5440]
acoll=[7.3614,3.4260,0.4514]
coat='Ir'
coat=['Ir','test/input/coatings/IrC.imd','Ir']

energy=10d*(findgen(100))/100.+0.5
EA_m=TELESCOPE_AREA(energy,alpha,acoll,coat,4.) ;small telescope
EA_tot=total(EA_m,1)

;; PLOT
WHILE !D.Window GT -1 DO WDelete, !D.Window
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

window,/free
plot,energy,TELESCOPE_AREA(energy,alpha[1],acoll[1],'test/input/coatings/IrC.imd',4.),/nodata
oplot,energy,TELESCOPE_AREA(energy,alpha[1],acoll[1],'test/input/coatings/IrC.imd',4.),color=2
oplot,energy,TELESCOPE_AREA(energy,[alpha[1]],[acoll[1]],'Ir',4.) ,color=3
legend,['IrC','Ir'],color=[2,3]

end
