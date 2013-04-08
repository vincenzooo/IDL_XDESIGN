;!!!obsolete, use extract vignetting instead!!!

pro extractDith, folder, psfdir=psfdir

MESSAGE, 'The routine extractDith is obsolete, please replace it with extractVignetting'
;
;;6/03/2009 photoncounts3, merge di photoncounts e photoncounts2
;;con uso di routine in usercontrib
;;todo: add errorbars
;
;function geoVignetting,psfdir,shtarget,qatarget,ageo=ageo,angles=angles
;
;;return the geometrical vignetting function from the results of traie(7).
;;
;;target values for shell number <shtarget> and qa <qatargert>
;;can be passed as scalar or vector values.
;;if not given use 15 (double reflection for qa) and 0 (all the shells).
;;--------------------------
;;1/4/2009 changed interface
;;old interface: geoVignetting,psfdir,nfiles,shtarget,qatarget,acoll=acoll
;;removed the number of angles <nfiles>, now is read from folder and
;;passed back as optional output parameter angles
;
;	angles=getOAangle(folder,/arcmin)
;	nfiles=n_elements(angles)
;	afrac=fltarr(nfiles)  ;number of double (or qatarget) reflected photons
;
;;	readcol,psfdir+'\ShellStruct.txt',Nshell,Dmax,Dmid,Dmin,thickness,Angle,Area
;;	overlap=where(Dmax[1:*]+thickness[1:*] gt dmid[0:n_elements(dmid)-2], count)
;;	if  (count ne 0) then begin
;;		print, "WARNING: shell overlapping at shell ",overlap+1
;;		print, "Total collecting area can be incorrectly calculated!!"
;;	endif
;;	Acoll=total(area)	;on Axis geometric area as sum of the shell area
;;	print, 'Acoll=', Acoll
;	ageo=getAgeo(psfdir)
;
;	for i =1,nfiles do begin
;		psffile=psfdir+'\psf_data_'+string(i,'(i2.2)')+'.txt'
;		readFP,psffile,shtarget=shtarget,qtarget=qatarget,frac=f,nph=np
;		afrac[i-1]=float(f)/np
;	endfor
;
;	return,AFrac
;
;end
;
;;uses: function getOAangle, folder,index,file=file,arcmin=arcmin,deg=deg
;
;pro extractDith, folder, psfdir=psfdir
;	;psfdir can be provided if the focal plane data are in a different folder
;	;(e.g. for a ray tracing started from common data)
;	;changes (1/04/2009) changed values in column, see p.143 logbook
;	spdir=strsplit(folder,'\',/extract)
;	basedir=strjoin(spdir[0:n_elements(spdir)-2],'\')
;	curdir=spdir[n_elements(spdir)-1]
;
;	if n_elements(psfdir) eq 0 then psfdir=folder
;	;focusedFraction=fraction of photons focused, ageo is the area on which photons fall
;	focusedFraction= geoVignetting(psfdir,0,15,angles=angles,ageo=ageo)
;	;mirrorfraction=fraction of photons on the first surface
;	mirrorFraction=geoVignetting(psfdir,0,[1,3,5,7,9,11,13,15])
;	nangles=n_elements(angles)
;	anglesRad=angles*!PI/(60*180.)
;
;	readcol,folder+'\aree.txt', ener,aeff
;	nenergies=countblocks(ener,nblocks=nblocks)
;	ener=ener[0:nenergies-1]
;	aeff=reform(aeff,nenergies,nblocks)
;
;	get_lun,nf
;	openw,nf,basedir+'\'+curdir+'_dit.dat'
;	printf,nf,'angle  energy  aeff(cm^2) vignetting mirrorAreaFraction'
;	;write the geometrical vignetting
;	for j=0,nblocks-1 do begin
;		printf,nf,angles[j],0.0,aGeo*focusedFraction[j]*cos(anglesRad[j]),$
;				focusedFraction[j]/focusedFraction[0]*cos(anglesRad[j]),$
;				focusedFraction[j]/mirrorFraction[j]
;	endfor
;	printf,nf
;	printf,nf
;	for ii=0,nenergies-1 do begin
;		for j=0,nblocks-1 do begin
;			printf,nf,angles[j],ener[ii],aeff[ii,j],aeff[ii,j]/aeff[ii,0],$
;					aeff[ii,j]/(aGeo*mirrorFraction[j]*cos(anglesRad[j]))
;		endfor
;		printf,nf
;		printf,nf
;	endfor
;	free_lun,nf
;end
;
;;;esempio:
;;folder='D:\work\traie7\hxmt_13\FF1_ph_sx2vig'
;;extractDith, folder
;
;
;folders=["F:\next_HXT\run_3_12_28short",$
;		"F:\next_HXT\run_2_ff0_short"]
;
;for i=0,n_elements(folders)-1 do begin
;	extractDith, folders[i]
;endfor
MESSAGE, 'photoncounts is obsolete, please replace it with extractVignetting'

end
