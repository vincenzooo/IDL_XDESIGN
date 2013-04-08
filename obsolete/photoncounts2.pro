

function geoVignetting,psfdir,angles,shtarget,qatarget
;return the geometrical vignetting function from the results of traie(7).
;the vector of angles
;must be passed, but it is used only to count the number of elements.
;target values for shell number and qa can be passed as scalar or vector values.
;if not given use 15 (double reflection for qa) and all the shells.


	nangles=n_elements(angles)
	afrac=fltarr(nangles)  ;number of double (or qatarget) reflected photons
;	readcol,resdir+'\ShellStruct.txt',Nshell,Dmax,Dmid,Dmin,thickness,Angle,Area
;	Acoll=total(area)
;	print, 'Acoll=', Acoll

	for i =1,nangles do begin
		psffile=psfdir+'\psf_data_'+string(i,'(i2.2)')+'.txt'
		readFP,psffile,shtarget=shtarget,qtarget=qatarget,frac=f,nph=np
		afrac[i-1]=float(f)/np
	endfor

	return,AFrac

end


pro extractDith, folder ,angles,psfdir=psfdir


	spdir=strsplit(folder,'\',/extract)
	basedir=strjoin(spdir[0:n_elements(spdir)-2],'\')
	curdir=spdir[n_elements(spdir)-1]

	if n_elements(psfdir) eq 0 then psfdir=folder
	geo= geoVignetting(psfdir,angles,0,15)  ;,nshell,qa

	readcol,folder+'\aree.txt', ener,aeff
	nenergies=countblocks(ener,nblocks=nblocks)
	ener=ener[0:nenergies-1]
	;nblocks=n_elements(aeff)/nenergies
	aeff=reform(aeff,nenergies,nblocks)

	openw,1,basedir+'\'+curdir+'_dit.dat'
	printf,1,'angle  energy  aeff aeff_toOnAxis aefftoGeo'
	;write the geometrical vignetting
	for j=0,nblocks-1 do begin
		printf,1,angles[j],0.0,geo[j],geo[j]/geo[0],0.0
	endfor
	printf,1
	printf,1
	for ii=0,nenergies-1 do begin
		for j=0,nblocks-1 do begin
			printf,1,angles[j],ener[ii],aeff[ii,j],aeff[ii,j]/aeff[ii,0],aeff[ii,j]/aeff[0,0]
		endfor
		printf,1
		printf,1
	endfor
	close,1
end

;esempio:
;folder='D:\work\traie7\dithering_remake\m2_ff015_200_max65_ml1115_plus'
;extractDith, folder, [0,12,24,36,48,60]

;folder='D:\work\traie7\dithering_remake\m2_ff015_200_max65_ml1115oc'
;extractDith, folder, [0,12,24,36,48,60]  ;secondo  argomento gli angoli

ang=[0,12,24,36,48,60]
;folder='D:\work\traie7\dithering_remake\m2_ff015_200_max65_standard'
;folder='D:\work\traie7\dithering_remake\m2_ff015_200_max65_standard_H'
;folder='D:\work\traie7\dithering_remake\m2_ff015_200_max65_standard_plus'
;folder='D:\work\traie7\dithering_remake\m2_ff015_200_max65_standard_plusH'
folder='D:\work\traie7\dithering_remake\m2_ff015_200_max65_ml1115_plus'
;folder='D:\work\traie7\dithering_remake\m2_ff015_200_max65_ml1115_plusH'
extractDith, folder,ang,psfdir='D:\work\traie7\dithering_remake\m2_ff015_200_max65_ml1115oc'
end
