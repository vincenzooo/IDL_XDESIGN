pro reflex2d_plot,ref,x=ang,y=ener,outname=outname,header=header,aeff=aeff,win=win,_extra=e

  ; plot and/or save data in reflectivity (or effective area) matrix
  ;   with default labels
  ; if OUTNAME is provided, output plots and text files are saved.
  ; It is convenience routine for `reflex2d` (this is why `reflex2d_plot`
  ;     and not viceversa).
  ; /AEFF assumes effective area data are passed and use appropriate
  ;     labels for plotting Aeff.


  if keyword_set(aeff) then begin
    header = '#Aeff@energy(keV)\angle(deg)'  ;header of txt file
    bar_title = 'Aeff(cm^2)'                 ;colorbar text in 2d plor
    prefix = 'Aeff_'                         ;subfix for output file
  endif else begin
    header = '#Reflex@energy(keV)\angle(deg)'
    bar_title = 'R'
    prefix = 'Ref_'
  endelse

  window,/free
  win=!D.window
  cont_image,ref,ang,ener,/colorbar,$ ;max_value=1,$
    xtitle='Angle (deg)',ytitle='Energy (keV)',bar_title=bar_title,$
    _extra=e
  ;legend,l,pos=4
  if n_elements(outname) ne 0 then begin
    WRITE_PNG, fnaddsubfix(outname,'','.png',pre = prefix), TVRD(/TRUE)
    write_datamatrix,fnaddsubfix(outname,'','.txt',pre = prefix),ref,$
      x=ang,y=ener,header=header
  endif
end
