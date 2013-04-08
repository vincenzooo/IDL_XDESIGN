function bestFocal,folder,index,zVector,wplot=wplot,nops=nops,$
    figureErrorArcsec=FEarcsec,bestHEW=bestHEWindex,log=logU
;-----------------------------------
;Return the geometric hew as a function of the z shift for a given angle,
;  reading focal plane data.
;PARAMETERS
;- folder: the folder containing simulation data
;- index : the index of the off-axis angle
;- zVector: the vector of focal plane shifts, positive from optics to FP 
;OPTIONAL ARGUMENTS
;- wplot: vector determining the plots to be shown, 1-focal spot
;  2-hew as a function of z, 3-x and y positions of barycenter for z
;- nops: suppress the creation of a ps plot of hew as a function of z shift
;- figureErrorArcsec: error in arcsec to be summed in quadrature with hew
;- logU: if string use it as a filename for log file, if present and not
;        string, create log on standard ouput
;RETURN VALUES
;- bestHEW: optional output with the index of the best hew
;USED:
;getOAangle,readFP,hewOnFPshift,readNamelistVar, in
;legend (by Windt)

device, decomposed =0
tek_color
loadct, 39

if n_elements(index) eq 0 then index=1
if n_elements(FEarcsec) eq 0 then FEarcsec=0
if n_elements(nops) eq 0 then nops=0
readcol,folder+path_sep()+'shellStruct.txt',F='I,X,F,X,X,F', N,Dmid,shang
if n_elements(wplot) eq 0 then wplot=[-1]
if n_elements(wplot) eq 1 then wplot=[wplot]

logFlag=n_elements(logU)
if logFlag ne 0 then begin
   tU=size(logU,/type)
   if tU eq 7 then begin   ;e' stringa
      get_lun, logFileN
      openw,logFileN,logU
   endif else begin
      logFileN=-1 ;standard output
   endelse
endif

th=getOAangle(folder)
focal=readNamelistVar(folder+path_sep()+'imp_offAxis.txt','F_LENGTHdaImp_m')
focal=float(focal)*1000.

nangles= n_elements(th)-1
hewBar=fltarr(nangles)
hewReal=fltarr(nangles)

;read photon list and set variables
readFP, folder+path_sep()+'psf_Data_'+string(index,format='(i2.2)')+'.txt',qtarget=15, $
	nph=ntot, Xfp=x,Yfp=y,cosx1=cosX1,cosy1=cosY1,cosz1=cosz1,$
	k=k,alpha1=a1,alpha2=a2,nSelected=nSel

zsteps=n_elements(zVector)
if in(1,wplot) then plot=1
hewVector=hewOnFPshift(zVector, x,y,cosx1,cosy1,cosz1,xbarvec=xbarvec,ybarvec=ybarvec,plot=plot)

hewVarcsec=sqrt((atan(hewVector/(focal+zVector))*206265.)^2+FEarcsec^2)

if logFlag ne 0 then begin
    printf,logFileN,'-----------------------'
    printf,logFileN,'Off-Axis angle: ',th[index-1]*206265./60,' arcmin'
    for i =0,zsteps-1 do begin
    	printf,logFileN,'zfocalplane: '+string(focal+zVector[i])+$
    		'  barycenter HEW: '+string(hewVector[i])+' mm --> '+$
    		string(hewVarcsec[i])+' arcsec'
    		;atan(hewVector[i]/(focal+zVector[i]))*206265.,' arcsec'
    endfor
    printf,logFileN,'BEST:'
endif

besthew=min(hewVarcsec,imin)
if logFlag ne 0 then printf,logFileN,'zfocalplane: '+string(focal+zVector[imin])+$
		'  barycenter HEW: '+string(hewVector[imin])+ ' mm --> '+$
		string(hewVarcsec[imin])+' arcsec'
if logFlag ne 0 then free_lun,logFileN
bestHEWindex=imin ;valore di ritorno

if in(2,wplot) then begin
    window,2
    plot,zVector,hewVarcsec,/ynozero,$
    	xtitle='focal plane position (mm) wrt nominal length',ytitle='HEW (arcsec)'
endif
if in(3,wplot) then begin
    window,3
    ;plot,xbarvec,ybarvec,xtitle='x barycentre (mm)',ytitle='y baricentre (mm)',psym=4
    plot,focal+zVector,xbarvec,$
    	yrange=[min([xbarvec,ybarvec]),max([xbarvec,ybarvec])],$
    	psym=6
    oplot,focal+zVector,ybarvec,psym=7,color=100
    legend,['x barycenter', 'y barycenter'],color=[255,100],psym=[6,7]
endif

if nops ne 0 then begin
	set_plot, 'ps'
	device, filename = folder+'\hewOnFPShift'+index+'.ps', /encapsulated, /color
	plot,zVector,hewVarcsec,/ynozero,$
	xtitle='focal plane position (mm) wrt nominal length',ytitle='HEW (arcsec)'
	device, /close
	set_plot, 'win'
endif

return,hewVarcsec

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

	folder='E:\Dati_applicazioni\idl\usr_contrib\kov\test_data\F10D394ff010_thsx'
	zvector=vector(-30.,30.,100)
	;for index=4,4 do begin
	index=4
	hew=bestFocal(folder,index,zVector,figureErrorArcsec=0.,log='bestFocalLog.txt')
	;endfor

end