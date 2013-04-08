function hewOnFPshift, zVector, x,y,cosx1,cosy1,cosz1,$
  xbarvec=xbarvec,ybarvec=ybarvec,plot=plot,throughput=throughput,percentile=perc
	;Shift the focal plane of the amounts in zVector, compute hew,
	;return a vector with the values of hew
	;the optional output vectors xbarvec and ybarvec contains the coordinates of baycentre
	;if plot is set, plot the focal planes
	;per ora usa window 4, si puo' poi aggiungere opzione per il plot
	;Dependences:
	;uses shiftFocalPlane,calculateHEW,vector(Windt)(usato solo per il plot)

	windownumber=5
	zsteps=n_elements(zVector)
	hewvector=fltarr(zsteps)
	xbarvec=fltarr(zsteps)
	ybarvec=fltarr(zsteps)
	if n_elements(plot) ne 0 then begin
		colors=fix(vector(0,250,zsteps))
		window,windownumber
	endif
	for i=0,zsteps-1 do begin
		shiftFocalPlane,zVector[i],x,y,cosx1,cosy1,cosz1,xstart=xstart,ystart=ystart
		hewVector[i]=calculateHEW(x,y,xbar=xbar,ybar=ybar,throughput=throughput,percentile=perc)
		xbarvec[i]=xbar
		ybarvec[i]=ybar
		if n_elements(plot) ne 0 then begin
			if i eq 0 then begin plot,x,y,psym=3,/isotropic
			endif else oplot,x,y,psym=3,color=colors[i]
			wait,0.5
		endif
		x=xstart
		y=ystart
	endfor
	return,hewVector

end

;test 
device, decomposed =0
tek_color
loadct, 39
zvec=vector(-5,5,22)
folder='E:\work\workOA\traie8\NHXMphB_HEW\coating2'
fpfile=folder+path_sep()+'psf_Data_03.txt'
readFP,fpfile,xfp=x,yfp=y,cosx1=cz1,cosy1=cx1,cosz1=cy1,qtarget=15
focal=double(readNamelistVar(folder+path_sep()+'imp_offAxis.txt','F_LENGTHdaImp_m')*1000)

hew=hewonfpshift(zvec,x,y,cx1,cy1,cz1,/plot)
window,3
plot,zvec,hew/focal*206265.,psym=4,xtitle='focal shift (mm)',ytitle='hew (arcsec)'
end
