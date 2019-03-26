pro reflex2D2,ener,fovArcmin,alphaRad,thResArcsec,dSpacing,$
    matsub,matbot,mattop,roughness,dmatrix=dmatrix,tmatrix=tmatrix
; note 2019/03/25 first version, use directly reflexDLL (as opposite to using 
;  reflexMatrix). So I rename it today from reflex2d2 to reflex2d_1.
;plotta la riflettività di un multilayer in funzione di angoli ed
;energie usando la routine contourgain

  setstandarddisplay
  rough=roughness
  mat1=matsub
  mat2=matbot
  mat3=mattop
  alpha=float(alphaRad)
  nener=n_elements(ener)
  fov=float(fovarcmin*60./206265) ; da primi in radianti 
  thRes=float(thResArcsec/206265) ; da secondi in radianti 
  ntheta=1.+fov/thres ;questo e' il numero di intervalli per gli angoli di impatto
  ;corrispondera' anche al doppio del numero di intervalli sul campo di vista
  angmin=-fov
  angmax=+fov
  


  ;th=vector(3.7e-3*180/!PI-8./60,3.7e-3*180/!PI+8./60,ntheta)
  th=vector(angmin,angmax,ntheta)

  rmatrix=fltarr(nener,ntheta)
  ;dMatrix=fltarr(ntheta,ntheta)
  dMatrixPlot=fltarr(ntheta,ntheta)

  loadRI,ener,mat1,mat2,mat3
  for i =0,ntheta-1 do begin
    ref= reflexDLL (ener, alpha+th[i], dSpacing, rough,/unload)
    rMatrix[*,i]=ref
  endfor
  window,2,xsize=600,ysize=400
  cont_image,rMatrix,ener,(alpha+th)*180/!PI,/colorbar,title='',$
    bar_title='Reflectivity',$
    ytitle='Incidence angle (deg)', xtitle='Energy (keV)'
  
  tmatrix=rmatrix*reverse(rmatrix,2)
  window,4,xsize=600,ysize=400
  cont_image,tMatrix,ener,(alpha+th)*180/!PI,/colorbar,title='',$
    bar_title='Reflectivity',$
    ytitle='Incidence angle (deg)', xtitle='Energy (keV)'
  window,5
  plot,ener,total(tmatrix,2)/ntheta
  
  dMatrix=distributionMatrix2(alpha,fov,ntheta,thetaX=thetaX,thetaY=thetaY)
;  for i =0,ntheta-1 do begin
;    dMatrixPlot[i,*]=dMatrix[i,*]/max(dMatrix[i,*])
;  endfor
  
  window,3,xsize=600,ysize=400
  cont_image,transpose(dMatrix),thetaX*60*180/!PI,thetaY*180/!PI,/colorbar,title='',$
    bar_title='Normalized number of photons',$
    ytitle='Impact angle on parabola (deg)', xtitle='Off axis angle (arcmin)'
    ;min_value=min(dMatrix),max_value=0.05 ;max(dMatrix)
  ;;colorbar,/vertical,minrange=min(rMatrix),maxrange=max(rMatrix)
  ;plot_gain,90-th,ener,rMatrix,rMatrix*0+0.5,filename='prova.tif'

end


  alphaRad=3.7e-3
  fovarcmin=8.
  nener=100
  thResArcsec=60.
  ener=vector(1.,80.,nener)
  nbil=200
  a=105.
  b=0.9
  c=0.27
  gamma=0.35
  rough=4.
  dspacing=thicknessPL(a,b,c,nbil,gamma)
  folder=file_dirname(file_which('reflexdll.pro'))
  mat1=folder+path_sep()+'af_files\a-Si.dat'
  mat2=folder+path_sep()+'af_files\a-C.dat'
  mat3=folder+path_sep()+'af_files\Pt.dat'
  
  reflex2D,ener,fovArcmin,alphaRad,thResArcsec,dSpacing,$
    mat1,mat2,mat3,rough,dmatrix=dmatrix,tmatrix=tmatrix
  
  
  end
