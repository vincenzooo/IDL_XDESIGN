function geoVignetting,psfdir,shtarget=shtarget,qatarget=qatarget,ageo=ageo,angles=angles,$
     nSelected=nselVec,nph=nph

;return as a vector, the geometrical vignetting function from the results of traie(7)
;or the fraction of photons with a value of qa, if qatarget is set.
;
;input parameters:
;-psfdir: folder with results psffiles
;optional input parameters:
;- target values for shell number <shtarget> and qa <qatargert>
;can be passed as scalar or vector values.
;if not given use 15 (double reflection for qa) and 0 (all the shells).
;output parameters:
;-ageo: obsolete, the geometrical area must be extracted externally to the
;function with getAgeo
;-angles: vector with the offaxis angles in arcmin
;-nSelected: vector with the number of photons for each angle
;-nph:total number of photons contained in the psf files
;uses: getOAangle, readFP
;--------------------------
;1/4/2009 changed interface
;old interface: geoVignetting,psfdir,nfiles,shtarget,qatarget,acoll=acoll
;removed the number of angles <nfiles>, now is read from folder and
;passed back as optional output parameter <angles>

;-----------
;16/04/2009 removed ageo from optional parameters, ageo is not used
;in the present routine. Use instead the function getAgeo in the caller program.
;added <nph> as optional ouput parameter giving the number of photons
if n_elements(ageo) ne 0 then message,$
  "the output parameter ageo is obsolete, "+$
  "use instead the function getAgeo."
;-----------

  angles=getOAangle(psfdir,/arcmin)
  nfiles=n_elements(angles)
  afrac=fltarr(nfiles)  ;number of double (or qatarget) reflected photons
  nSelVec=lonarr(nfiles)
;ageo=getAgeo(psfdir)

  for i =0,nfiles-1 do begin
    psffile=psfdir+'\psf_data_'+string(i+1,'(i2.2)')+'.txt'
    readFP,psffile,shtarget=shtarget,qtarget=qatarget,nSelected=f,nph=nph
    nSelVec[i]=f
    afrac[i]=float(f)/nph

  endfor
  return,AFrac
end