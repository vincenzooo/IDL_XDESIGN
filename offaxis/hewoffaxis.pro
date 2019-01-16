pro hewOffAxis,folder,distance=distance,plot=plot,window=windownumber,log=logU,$
    outfile=outfileName
  ;Calculate the HEW in dependence on the off-axis angle for a given distance
  ;of the focal plane. Generate a file in outfile (default 'hewOffAxis.txt')
  ;with off-axis angle, hew and barycenter positions. If a log file is provided
  ;
  ;-----------------------------------
  ;input variables
  ;folder: folder with data
  ;options:
  ;distance: distance between focal plane and intersection plane in mm,
  ;positive from optics to focal plane.
  ;plot: if set, plot in sequence the focal spot for each off-axis angle.
  ;window: if provided, use it for the window number for the focal plane,
  ;  override plot if plot is not provided.
  ;USES:
  ;getOAangle,readFP,readNamelistVar,calculateHEW
  ;readcol, vector (Windt),aspect (Coyote)

  if n_elements (outfileName) eq 0 then outfileName='hewOffAxis.txt' 
  device, decomposed =0
  tek_color
  loadct, 39
  readcol,folder+path_sep()+'shellStruct.txt',F='I,X,F,X,X,F', N,Dmid,shang
  
  logFlag=n_elements(logU)
  if logFlag ne 0 then begin
     tU=size(logU,/type)
     if tU eq 7 then begin   ;e' stringa
        get_lun, logFileN
        openw,logFileN,folder+path_sep()+logU
     endif else begin
        logFileN=-1 ;standard output
     endelse
  endif
  
  th=getOAangle(folder)
  focal=readNamelistVar(folder+path_sep()+'imp_offAxis.txt','F_LENGTHdaImp_m')
  focal=float(focal)*1000.
  if n_elements(distance) eq 0 then distance=focal
  
  nangles= n_elements(th)
  hewBar=fltarr(nangles)
  hewReal=fltarr(nangles)
  xVec=fltarr(nangles)
  yVec=fltarr(nangles)
  
  if n_elements(plot) ne 0 || n_elements(windownumber) ne 0 then begin
    colors=fix(vector(0,250,nangles))
    if n_elements(windownumber) ne 0 then begin
      window,windownumber
    endif else begin
      window
      windownumber=!D.WINDOW
    endelse
  endif
  
  for index=0, nangles-1 do begin
    ;read photon list and set variables
    readFP, folder+path_sep()+'psf_Data_'+string(index+1,format='(i2.2)')+'.txt',qtarget=15, $
      nph=ntot, Xfp=x,Yfp=y,cosx1=cosX1,cosy1=cosY1,cosz1=cosz1,k=k,alpha1=a1,alpha2=a2,nSelected=nSel
      
    shiftFocalPlane,distance-focal,x,y,cosx1,cosy1,cosz1
    
    realxc=-th[index]*distance
    hewreal[index]=calculateHEW(x,y, xcenter=realxc,ycenter=0) ;calculate hew wrt the nominal center
    psi=atan((y),(x-realxc))
    r=sqrt((x-realxc)^2+(y)^2)
    
    hewBar[index]=calculateHEW(x,y, xbar=barx,ybar=bary) ;calculate hew and barycentre
    xVec[index]=barx
    yVec[index]=bary
    printf,logFileN,'-----------------------'
    printf,logFileN,'Off-Axis angle: ',th[index]*206265./60,' arcmin'
    printf,logFileN,'centerOA HEW: ',hewreal[index], ' mm --> ',atan(hewreal[index]/distance)*206265.,' arcsec'
    printf,logFileN,'barycenter HEW: ',hewBar[index], ' mm --> ',atan(hewBar[index]/distance)*206265.,' arcsec'
    
    if n_elements(plot) ne 0 || n_elements(windownumber) ne 0 then begin
      plot,x,y,psym=3,title='Off-axis angle: '+string(th[index]*206265./60)+$
        ' arcmin',position=aspect(1.0) ;,/isotropic,xstyle=1,ystyle=1
      wait,0.5
    endif
    
  endfor
  if logFlag ne 0 then free_lun,logFileN
  
  get_lun,nf
  openw,nf,folder+path_sep()+outfileName
  printf,nf,'Off-axis angle (arcmin) | hew wrt barycenter (arcsec) | barycenter coordinates (x,y) arcsec'
  for index=0, nangles-1 do begin
    printf,nf,th[index]*206265./60,atan(hewreal[index]/distance)*206265.,$
      atan(xVec[index]/distance)*206265.,atan(yVec[index]/distance)*206265.
  endfor
  free_lun,nf
  
  window,5
  plot,th*206265./60,atan(hewreal/distance)*206265.,xtitle='Off-axis angle (arcmin)',$
    ytitle='HEW (arcsec)'
    
    
;alfa: shell slope
;r0,Dmid: radius and diameter at intersection plane as read from shellstruct.txt
;th: off-axis angle
;focal: focal length in mm
;ntot: number of photons used for raytracing
;nsel: number of photons meeting the conditions
;barx, bary: coords of the baricentre of photons (geometric, reflectivity not considered)
;realxc: center of image as F*tan(theta)
;x,y,psi,r: cartesian and polar choords of photons positions on focal plane
;k=index of the selected photons in raytracing
;a1,a2: impact angles in rad
;ximp1,yimp1,zimp1,ximp2,yimp2,zimp2: cartesian coordinates of the two impact points
;psiimp1,rimp1,psiimp2,rimp2: polar coordinates of the two impact points
;k2: index of the selected photons in raytracing
    
end

folder="E:\work\workOA\traie8\NHXMphB_HEW\coating2"
;"E:\Dati_applicazioni\idl\usr_contrib\kov\test_data\poly_sh490" ;cosi' finche'
;non capisco come recuperare la directory dell'eseguibile
print, "Program launched, perform test execution on folder"
print, folder
hewOffAxis,folder,distance=10000,/plot,log='hewoffaxisLog10000.txt',outfile='hewoffaxis10000.dat'
end