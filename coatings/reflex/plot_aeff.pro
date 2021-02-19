pro plot_aeff,ener,aeff, title = t,outname=outname

  plot,ener,aeff, title = t, $
    ytitle='Area (cm^2)',xtitle='Energy (keV)'

  if n_elements(outname) gt 0 then begin
    WRITE_PNG, fnaddsubfix(outname,'_atot','.png'), TVRD(/TRUE)
    writecol,fnaddsubfix(outname,'_atot','.txt'),ener,aeff_tot,$
      header='#Ener(keV)    Aeff(cm^2)'

    writecol,fnaddsubfix(outname,'_struct','.txt'),ang,acoll,ffiles[cind],$
      header="#"+outname+': Coating  Angle(deg)  Acoll(cm^2)'
  endif
end