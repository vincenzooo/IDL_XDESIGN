function fractionArea,psffile,shtarget,qatarget,$
	X=x,Y=y,cos_x1=cosX1,cos_y1=cosY1,cos_z1=cos_z1,yor=yor,$
	zor=zor,qa=qa,shell=shell,k=k,alpha1=alpha1,alpha2=alpha2
;from a focal plane file <psffile> in the format of traie(7) results,
;return the fraction of photons meeting both the condition of qa and shell
;being respectively in <qatarget>, <shtarget> (arrays or single values).


	if n_elements(shtarget) eq 0 then shtarget =0
	if n_elements(qa) eq 0 then qatarget =0

	;nangles=n_elements(angles)
	;counts=lonarr(nangles)  ;number of double (or qatarget) reflected photons

	readcol,resdir+'\ShellStruct.txt',Nshell,Dmax,Dmid,Dmin,thickness,Angle,Area
	Acoll=total(area)

	print, 'Acoll=', Acoll

	for i =1,nangles do begin

		readcol,resdir+'\psf_data_'+string(i,'(i2.2)')+'.txt',$
		 X,Y,cos_x1,cos_y1,cos_z1,yor,zor,qa,shell,k,alfa1,alfa2
		count=n_elements(x)
		a=lindgen(count)
		if qatarget ne 0 then a=wherein(qa,qatarget,count)
		if shtarget ne 0 then a=wherein(shell[a],shtarget,count)
		counts[i-1]=count

	endfor
	nph=n_elements(x)

	AgeoFrac=float(counts)/nph
	return,AgeoFrac

end

function geoVignetting,resdir,angles,shtarget,qatarget
;return the geometrical vignetting function from the results of traie(7).
;the collecting area is read from shellstruct.txt, the vector of angles
;must be passed, but it is used only to count the number of elements.
;target values for shell number and qa can be passed as SCALAR values.
;if not given use 15 (double reflection for qa) and all the shells.


	if n_elements(shtarget) eq 0 then shtarget =0
	if n_elements(qa) eq 0 then qatarget =15

	nangles=n_elements(angles)
	counts=lonarr(nangles)  ;number of double (or qatarget) reflected photons

	readcol,resdir+'\ShellStruct.txt',Nshell,Dmax,Dmid,Dmin,thickness,Angle,Area
	Acoll=total(area)

	print, 'Acoll=', Acoll

	for i =1,nangles do begin

		psffile=resdir+'\psf_data_'+string(i,'(i2.2)')+'.txt'
		counts[i-1]=fractionArea(psffile,shtarget,qatarget)
	endfor

	return,AgeoFrac

end


pro extractDith, folder, blocklen, enIndexes,angles

	spdir=strsplit(folder,'\',/extract)
	basedir=strjoin(spdir[0:n_elements(spdir)-2],'\')
	curdir=spdir[n_elements(spdir)-1]

	geo= geoVignetting(folder,angles)  ;,nshell,qa

	readcol,folder+'\aree.txt', ener,aeff
	ener=ener[0:blocklen-1]
	nblocks=n_elements(aeff)/blocklen
	aeff=reform(aeff,blocklen,nblocks)

	openw,1,basedir+'\'+curdir+'_dit.dat'
	printf,1,'angle  energy  aeff aeff_toOnAxis aefftoGeo'
	;write the geometrical vignetting
	for j=0,nblocks-1 do begin
		printf,1,angles[j],0.0,geo[j],geo[j]/geo[0],0.0
	endfor
	printf,1
	printf,1
	for i=0,n_elements(enIndexes)-1 do begin
		ii=enIndexes[i]
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
;extractDith, folder, 2, [0,1],[0,12,24,36,48,60]
folder='D:\work\traie7\dithering_remake\m2_ff015_200_max65_ml1115_plusH'
extractDith, folder, 4, indgen(4),[0,12,24,36,48,60]
close,1


end