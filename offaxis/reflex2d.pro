pro reflex2D,ener,fovArcmin,alphaRad,th,dSpacing,$
    matsub,matbot,mattop,roughness,tmatrix=tmatrix,$
    mlname=mlname,nocontour=nocontour,outfolder=outfolder,$
    aeffOAangles=aeffoaangles,postscript=postscript,zoomrange=zoomrange,trimfactor=trimfactor
;plotta la riflettività di un multilayer in funzione di angoli ed
;energie usando la routine contourgain
  
  setstandarddisplay
  rough=roughness
  mat1=matsub
  mat2=matbot
  mat3=mattop
  alpha=float(alphaRad)
  nener=n_elements(ener)
  ;fov=float(fovarcmin*60./206265) ; da primi in radianti 
  ;thRes=float(thResArcsec/206265) ; da secondi in radianti 
  ;ntheta=1.+fov/thres ;questo e' il numero di intervalli per gli angoli di impatto
  ;corrispondera' anche al doppio del numero di intervalli sul campo di vista
  ;angmin=-fov
  ;angmax=+fov
  ntheta=n_elements(th)
  if n_elements(mlname) eq 0 then titlestring="" else titlestring=" for "+mlname
  if n_elements(outfolder) eq 0 then outfolder=""
  ;th=vector(3.7e-3*180/!PI-8./60,3.7e-3*180/!PI+8./60,ntheta)
  ;th=vector(angmin,angmax,ntheta)
  OnAxisIndex=fix(findex(th,0.0))
  rmatrix=fltarr(nener,ntheta)
  ;dMatrix=fltarr(ntheta,ntheta)
  ;dMatrixPlot=fltarr(ntheta,ntheta)

  loadRI,ener,mat1,mat2,mat3
  rmatrix=reflexMatrix(ener,alpha+th,dspacing, rough)
;  for i =0,ntheta-1 do begin
;    ref= reflexDLL (ener, alpha+th[i], dSpacing, rough,/unload)
;    rMatrix[*,i]=ref
;  endfor
  window,2,xsize=600,ysize=400
  cont_image,rMatrix,ener,(alpha+th)*180/!PI,/colorbar,$
    bar_title='Reflectivity',$
    ytitle='Incidence angle (deg)', xtitle='Energy (keV)',$
    title='Reflectivity'+titlestring,nocontour=nocontour,$
    min_value=0,max_value=1
  writetif,outfolder+path_sep()+'reflex_'+mlname+'.tif'
  set_plot, 'ps'
  device, filename = outfolder+path_sep()+'reflex_'+mlname+'.ps', /encapsulated, /color
  cont_image,rMatrix,ener,(alpha+th)*180/!PI,/colorbar,$
    bar_title='Reflectivity',$
    ytitle='Incidence angle (deg)', xtitle='Energy (keV)',$
    title='Reflectivity'+titlestring,nocontour=nocontour,$
    min_value=0,max_value=1
  device, /close
  set_plot, 'win'
  
  tmatrix=rmatrix*reverse(rmatrix,2)
;  window,4,xsize=600,ysize=400
;  cont_image,tMatrix,ener,(alpha+th)*180/!PI,/colorbar,$
;    bar_title='Throughput',$
;    ytitle='Incidence angle (deg)', xtitle='Energy (keV)',$
;    title='Throughput'+titlestring,nocontour=nocontour,$
;    min_value=0,max_value=1
;  writetif,outfolder+path_sep()+'Throughput'+mlname+'.tif'
;  set_plot, 'ps'
;  device, filename = outfolder+path_sep()+'Throughput'+mlname+'.ps', /encapsulated, /color
;  cont_image,tMatrix,ener,(alpha+th)*180/!PI,/colorbar,$
;    bar_title='Throughput',$
;    ytitle='Incidence angle (deg)', xtitle='Energy (keV)',$
;    title='Throughput'+titlestring,nocontour=nocontour,$
;    min_value=0,max_value=1
;  device, /close
;  set_plot, 'win'
;  
;  window,5
;  plot,ener,total(tmatrix,2)/ntheta, title='Effective area integrated over FOV for '+mlname,$
;    xtitle='Energy (keV)', ytitle='Integrated area (cm^2)'
;  writecol,outfolder+path_sep()+'meanFOV'+mlname+'.dat',ener,total(tmatrix,2)/ntheta
;  writetif,outfolder+path_sep()+'meanFOV'+mlname+'.tif'
;  set_plot, 'ps'
;  device, filename = outfolder+path_sep()+'meanFOV'+mlname+'.ps', /encapsulated, /color
;  plot,ener,total(tmatrix,2)/ntheta, title='Effective area integrated over FOV for '+mlname,$
;    xtitle='Energy (keV)', ytitle='Integrated area (cm^2)'
;  device, /close
;  set_plot, 'win'
;   
;  window,6
;  plot,ener,tmatrix[*,OnAxisIndex], title='On axis effective area for '+mlname,$
;    xtitle='Energy (keV)', ytitle='Effective area (cm^2)'
;  writecol,outfolder+path_sep()+'Aeff'+mlname+'.dat',ener,tmatrix[*,OnAxisIndex]
;  writetif,outfolder+path_sep()+'Aeff'+mlname+'.tif'
;  set_plot, 'ps'
;  device, filename = outfolder+path_sep()+'Aeff'+mlname+'.ps', /encapsulated, /color
;  plot,ener,tmatrix[*,OnAxisIndex], title='On axis effective area for '+mlname,$
;    xtitle='Energy (keV)', ytitle='Effective area (cm^2)'
;  device, /close
;  set_plot, 'win'
;  
;  window,7
;  plot,ener,tmatrix[*,OnAxisIndex], title='On axis effective area for '+mlname,$
;    xtitle='Energy (keV)', ytitle='Effective area (cm^2)',xrange=zoomrange
;  writecol,outfolder+path_sep()+'zoomAeff'+mlname+'.dat',ener,tmatrix[*,OnAxisIndex]
;  writetif,outfolder+path_sep()+'zoomAeff'+mlname+'.tif'
;  set_plot, 'ps'
;  device, filename = outfolder+path_sep()+'zoomAeff'+mlname+'.ps', /encapsulated, /color
;  plot,ener,tmatrix[*,OnAxisIndex], title='On axis effective area for '+mlname,$
;    xtitle='Energy (keV)', ytitle='Effective area (cm^2)',xrange=zoomrange
;  device, /close
;  set_plot, 'win'
;  
;  OffAxisIndex=fix(findex(th,[0.0,2.0,4.0,6.0,8.0]/60.*!PI/180))
;  window,8
;  plot,ener,tmatrix[*,OffAxisIndex[0]], title='Off-axis effective area for '+mlname,$
;    xtitle='Energy (keV)', ytitle='Effective area (cm^2)'
;  for i=1, n_elements(offAxisIndex)-1 do begin
;    oplot,ener,tmatrix[*,offAxisIndex[i]],color=i*50
;  endfor

;  writecol,outfolder+path_sep()+'Aeff'+mlname+'.dat',ener,tmatrix[*,OnAxisIndex]
;  writetif,outfolder+path_sep()+'Aeff'+mlname+'.tif'
;  set_plot, 'ps'
;  device, filename = outfolder+path_sep()+'Aeff'+mlname+'.ps', /encapsulated, /color
;  plot,ener,tmatrix[*,OnAxisIndex], title='On axis effective area for '+mlname,$
;    xtitle='Energy (keV)', ytitle='Effective area (cm^2)'
;  device, /close
;  set_plot, 'win'

  
;  if n_elements(aeffoaangles) ne 0 then begin
;    ;plotta le aree efficaci per quegli angoli
;    naa=n_elements(aeffoaangles)
;    aeffMatrix=fltarr(ener,naa)
;    aaindex=findex(th,aeffoaangles) ;trova l'indice corrispondente all'angolo offaxis
;    for i =0,naa-1 do begin
;      aeffMatrix[*,i]=interpolate(dmatrix,aaindex[i])*
;    endfor
;  endif
  
;  dMatrix=distributionMatrix(alpha,th,locations=thetaY,trimfactor=trimfactor)
;  for i =0,ntheta-1 do begin
;    dMatrixPlot[i,*]=dMatrix[i,*]/max(dMatrix[i,*])
;  endfor
  
;  window,6
;  plot,th,total(dmatrix,1)
 
end

  outfolder='E:\work\documenti in progress\Cotroneo2010_FovOptSPIE\poster'
  alphaRad=3.7e-3
  fovarcmin=8.
  enmin=1.
  enmax=80.
  nener=1000
  thResArcsec=5.
  ener=vector(enmin,enmax,nener)
  folder=file_dirname(file_which('reflexdll.pro'))
  mat1=folder+path_sep()+'af_files\a-Si.dat'
  mat2=folder+path_sep()+'af_files\a-C.dat'
  mat3=folder+path_sep()+'af_files\Pt.dat'

;  nbil=200
;  a=105.
;  b=0.9
;  c=0.27
;  gamma=0.35
;  rough=4.
;  dspacing=thicknessPL(a,b,c,nbil,gamma)

;  
;  reflex2D,ener,fovArcmin,alphaRad,thResArcsec,dSpacing,$
;    mat1,mat2,mat3,rough,dmatrix=dmatrix,tmatrix=tmatrix,mlname="ML 1",$
;    outfolder=outfolder,/nocontour
;
;  nbil=200
;  a=77.4
;  b=-0.9432
;  c=0.223
;  gamma=0.42
;  rough=4.
;  dspacing=thicknessPL(a,b,c,nbil,gamma)
;  reflex2D,ener,fovArcmin,alphaRad,thResArcsec,dSpacing,$
;    mat1,mat2,mat3,rough,dmatrix=dmatrix,tmatrix=tmatrix,mlname="ML 2",$
;    outfolder=outfolder,/nocontour
; 
; ;risultato della prima ottimizzazione con una sola iterazione, 
; ;esteso a 200 bilayer.
;  
;  nbil=200 ;148
;  a= 82.3442    
;  b=-0.767218
;  c=0.258612
;  gamma=0.524157
;  rough=4.
;  dspacing=thicknessPL(a,b,c,nbil,gamma)
;  reflex2D,ener,fovArcmin,alphaRad,thResArcsec,dSpacing,$
;    mat1,mat2,mat3,rough,dmatrix=dmatrix,tmatrix=tmatrix,mlname="ML 3",$
;    outfolder=outfolder,/nocontour
; 
; 
;  nbil=187
;  d1=194.497
;  dN=23.9321
;  c=0.222582 
;  gamma=0.411721 
;  rough=4.
;  dum=d1dntoalphabeta(d1,dn,c,alpha=alpha,beta=beta)
;  dum=alphabetatoab(alpha,beta,c,nbil,a=a,b=b)
;  dspacing=thicknessPL(a,b,c,nbil,gamma)
;  reflex2D,ener,fovArcmin,alphaRad,thResArcsec,dSpacing,$
;    mat1,mat2,mat3,rough,dmatrix=dmatrix,tmatrix=tmatrix,mlname="ML 4",$
;    outfolder=outfolder,/nocontour   
;  
;  nbil=137
;  d1=118.6492767
;  dN=29.5356941
;  c=0.2118295
;  gamma=0.3691501  
;  rough=4.
;  dum=d1dntoalphabeta(d1,dn,c,alpha=alpha,beta=beta)
;  dum=alphabetatoab(alpha,beta,c,nbil,a=a,b=b)
;  dspacing=thicknessPL(a,b,c,nbil,gamma)
;  reflex2D,ener,fovArcmin,alphaRad,thResArcsec,dSpacing,$
;    mat1,mat2,mat3,rough,dmatrix=dmatrix,tmatrix=tmatrix,mlname="ML 5",$
;    outfolder=outfolder,/nocontour      
;      
;  nbil=38
;  d1=61.2241211 
;  dN=61.2229691
;  c=4.2973185
;  gamma=0.2674135
;  rough=4.
;  dum=d1dntoalphabeta(d1,dn,c,alpha=alpha,beta=beta)
;  dum=alphabetatoab(alpha,beta,c,nbil,a=a,b=b)
;  dspacing=thicknessPL(a,b,c,nbil,gamma)
;  reflex2D,ener,fovArcmin,alphaRad,thResArcsec,dSpacing,$
;    mat1,mat2,mat3,rough,dmatrix=dmatrix,tmatrix=tmatrix,mlname="ML 6",$
;    outfolder=outfolder,/nocontour


;  nbil=37
;  d1=74.6417618  
;  dN=39.2416458
;  c=0.3761268
;  gamma=0.4384359
;  rough=4.
;  dum=d1dntoalphabeta(d1,dn,c,alpha=alpha,beta=beta)
;  dum=alphabetatoab(alpha,beta,c,nbil,a=a,b=b)
;  dspacing=thicknessPL(a,b,c,nbil,gamma)
;  reflex2D,ener,fovArcmin,alphaRad,thResArcsec,dSpacing,$
;    mat1,mat2,mat3,rough,dmatrix=dmatrix,tmatrix=tmatrix,mlname="ML 7b",$
;    outfolder=outfolder,/nocontour
 
        
  nbil=200
  a=115.5  
  b=0.9
  c=0.27
  gamma=0.35
  rough=4.
  dspacing=thicknessPL(a,b,c,nbil,gamma)
  dspacing[0]=dspacing[0]+50.
  dspacing=[0,100.,dspacing]
  
  reflex2D,ener,fovArcmin,alphaRad,thResArcsec,dSpacing,$
    mat1,mat2,mat3,rough,tmatrix=tmatrix,mlname="ML 1",$
    outfolder=outfolder,/nocontour   ;Si chiamava ml 9
    
  nbil=33
  d1=75.2154770 
  dN=43.1798134
  c=0.2656355
  gamma=0.4343832
  rough=4.
  dum=d1dntoalphabeta(d1,dn,c,alpha=alpha,beta=beta)
  dum=alphabetatoab(alpha,beta,c,nbil,a=a,b=b)
  dspacing=thicknessPL(a,b,c,nbil,gamma)
  reflex2D,ener,fovArcmin,alphaRad,thResArcsec,dSpacing,$
    mat1,mat2,mat3,rough,tmatrix=tmatrix,mlname="ML 2",$
    outfolder=outfolder,/nocontour  ;si chiamava ml 7
 
  nbil=117
  d1=100.1601715  
  dN=30.2138138
  c=0.2062590
  gamma=0.4271505
  rough=4.
  dum=d1dntoalphabeta(d1,dn,c,alpha=alpha,beta=beta)
  dum=alphabetatoab(alpha,beta,c,nbil,a=a,b=b)
  dspacing=thicknessPL(a,b,c,nbil,gamma)
  reflex2D,ener,fovArcmin,alphaRad,thResArcsec,dSpacing,$
    mat1,mat2,mat3,rough,tmatrix=tmatrix,mlname="ML 3",$
    outfolder=outfolder,/nocontour  ;ML 8
  
  nbil=207
  d1=123.8735046   
  dN=23.7926178
  c=0.2363445
  gamma=0.4300654
  rough=4.
  dum=d1dntoalphabeta(d1,dn,c,alpha=alpha,beta=beta)
  dum=alphabetatoab(alpha,beta,c,nbil,a=a,b=b)
  dspacing=thicknessPL(a,b,c,nbil,gamma)
  reflex2D,ener,fovArcmin,alphaRad,thResArcsec,dSpacing,$
    mat1,mat2,mat3,rough,tmatrix=tmatrix,mlname="ML 4",$
    outfolder=outfolder,/nocontour 
  end