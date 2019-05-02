;run ea_onaxis from IRT telescope geometry and generate outputs.

pro get_geo,configfolder,alpha=alpha,acoll=acoll,coatings=coatings
  
  ; get relevant parameters alpha, acoll and coatings from SEEJ configuration folder 
  ;infolder contains telescope_geometry.dat and telescope_geometry_info, from which relevant geometrical
  ;  information acoll, angle and coating, are extracted.

  a=read_datamatrix(configfolder+path_sep()+'telescope_geometry.dat',skip=1)
  coatings=a[(size(a))[1]-1:*,*]
  ;alpha in deg, acoll in cm^2
  readcol,configfolder+path_sep()+'telescope_geometry_info.dat',alpha,acoll,format='X,X,X,X,X,X,X,F,F,X'

end

pro save_results,EA_m,energy,alpha,outfolder=outfolder
  ;save plots and data from outputs of ea_onaxis

  ;save effective area matrix
  if n_elements(outfolder) ne 0 then begin
    eafile=outfolder+path_sep()+'Effective_Area_onaxis.dat'  ;fnaddsubfix(outname,'_EA','.dat')
    write_datamatrix,eafile,Ea_m,y=energy,$
      header=';Energy(keV)    Aeff(cm^2)_for_sh_nr@angle_deg:'+$
    strjoin(strjoin(string(indgen(n_elements(alpha)))+'@'+strtrim(string(alpha,format='(f5.3)'),2))),separator=string(9b)
  endif

  ;; PLOT
  cleanup
  setstandarddisplay

  ;plot BY SHELL
  window,/free
  plot,energy,energy*0,yrange=[0,max(EA_m)*1.1],xtitle='Energy (keV)',ytitle='Aeff (cm^2)',$
    title='Single shells effective area'
  foreach oa, alpha, ioa do begin
    oplot,energy,EA_m[ioa,*],color=ioa+1
  endforeach
  legend,string(indgen(n_elements(alpha)))+string(alpha),col=indgen(n_elements(alpha))+1,pos=12,$
    title=string(9b)+'shell#'+string(9b)+'angle(deg)'
  if n_elements(outfolder) ne 0 then maketif,outfolder+path_sep()+'EA_shells'

p=make_ea_plots(ea_m,energy,alpha)
if n_elements(outfolder) ne 0 then p.save,outfolder+path_sep()+'EA_shells.png'

  ;Plot Total
  EA_tot=total(EA_m,1)
  window,/free
  plot,energy,EA_tot,yrange=[0,max(EA_tot)*1.1],xtitle='Energy (keV)',ytitle='Aeff (cm^2)',$
    title='Total telescope On-axis effective area'
  if n_elements(outfolder) ne 0 then maketif,outfolder+path_sep()+'EA_tot'

end


function calc_telescope_area,infolder, outfolder,energy, roughness, anglerad=anglerad

  get_geo,infolder,alpha=alpha,acoll=acoll,coatings=coatings
  if keyword_set(anglerad) then alpha=alpha*180d/!PI
  if n_elements(outfolder) ne 0 then file_mkdir,outfolder
  
  EA_m=telescope_area(energy,alpha,acoll,coatings,roughness)

  save_results,EA_m,energy,alpha,outfolder=outfolder

  return, EA_m

end

;infolder='../SEEJ_updated/current_version/data/tests/control/cubex/cubex_24shells_01/Config001' 
infolder='data/tests/control/cubex/cubex_24shells_01/Config001'
outfolder='data/test/results/tests_calc_telescope_area/cubex_24shells_01/Config001'

roughness=4.
energy=vector(0.1d,5d,50)
off_axis=!NULL

EA_m=calc_telescope_area(infolder,outfolder,energy,roughness)

end
