pro readFP,psffile,shtarget=sht,qtarget=qat,nph=nph,nSelected=nSelected,$
	Xfp=x,Yfp=y,cosx1=cos_X1,cosy1=cos_Y1,cosz1=cos_z1,y0=y0,$
	z0=z0,qa=qa,shell=shell,k=k,alpha1=alpha1,alpha2=alpha2,$
	outfile=outfile,noselect=noselect,help=help,frac=frac
;frac lasciato per generare messaggio quando chiamato da vecchia interfaccia

;read a focal plane file <psffile> in the format of traie(7) results.
;can return:
;the usual focal plane data
;<nph> total number of photons
;<nSelected> the number of photons meeting both the condition of qa and shell
;	(name changed from "frac")
;being respectively in <qatarget>, <shtarget> (arrays or single values).
;if <outfile> is provided, save the selected data in a file.
;if noselect is set, return all the data (but write on file only the ones
;meeting the condition)

;(2/12/2009) cambiati i nomi di sht e qat per evitare che vengano modificati
;in output se passati come variabili non definite

	;print help if called without arguments
	if n_elements(help) ne 0 or n_elements(psffile) eq 0 then begin
		print,'pro readFP,psffile,shtarget=shtarget,qtarget=qatarget,nph=nph,nSelected=nSelected,$'
		print,'Xfp=x,Yfp=y,cosx1=cos_X1,cosy1=cos_Y1,cosz1=cos_z1,y0=y0,$'
		print,'z0=z0,qa=qa,shell=shell,k=k,alpha1=alpha1,alpha2=alpha2,$'
		print,'outfile=outfile,noselect=noselect,help=help'
		print,'----------------------------------------------------------------------'
		print,'Read a focal plane file <psffile> in the format of traie(7) results.'
		print,'Can return:'
		print,'the usual focal plane data'
		print,'<nph> total number of photons'
		print,'<nSelected> the number of photons meeting both the condition of qa and shell'
		print,'being respectively in <qtarget>, <shtarget> (arrays or single values).'
		print,'if <outfile> is provided, save the selected data in a file.'
		print,'if noselect is set, return all the data (but write on file only the ones'
		print,'meeting the condition)'
		print,'----------------------------------------------------------------------'
		return
	endif

	;force to update the caller program if using the old names for parameters
	if n_elements(frac) ne 0 then message,$
		"the output parameter <frac> (number of photons meeting the conditions)"+$
		"was renamed to <nSelected>, update the caller command"

	;exlude filter is not selected
	if n_elements(sht) eq 0 then shtarget =[0] else shtarget=sht
	if n_elements(qat) eq 0 then qatarget =[0] else qatarget=qat

	;read and filter the variables
	readcol,psffile, X,Y,cos_x1,cos_y1,cos_z1,y0,z0,qa,shell,k,alpha1,alpha2,skipline=1
	count=n_elements(x)
	nph=count
	selindex=lindgen(count)
	tmp=wherein(qa,qatarget,count)
	;if ((qatarget ne [0]) and (count ne 0)) then selindex=selindex[tmp]

	if (qatarget ne [0]) then begin
		tmp=wherein(qa,qatarget,count)
		if (count ne 0) then selindex=selindex[tmp]
	endif
	if (shtarget ne [0]) then begin
	 	tmp=wherein(shell[selindex],shtarget,count)
	 	if (count ne 0) then selindex=selindex[tmp]
	endif

	nSelected=count
				;counts[i-1]=count
			;endfor

	if n_elements(outfile) ne 0 then begin
		get_lun,unit
		frmt='(7f12.5,2i4,i9,2f23.14)'
		openw,unit,outfile
		printf,unit," X	Y	cos_x1	cos_y1	cos_z1	yor	zor	qa	shell	k	alpha1	alpha2"
		for j=0L,count-1 do begin
			i=selindex[j]
			printf,unit,format=frmt,X[i],Y[i],cos_x1[i],cos_y1[i],cos_z1[i],y0[i],z0[i],$
				qa[i],shell[i],k[i],alpha1[i],alpha2[i]
		endfor
		close,unit
	endif

	if n_elements(noselect) eq 0 then noselect=0
	if noselect eq 0 then begin
		x=x[selindex]
		y=y[selindex]
		cos_x1=cos_x1[selindex]
		cos_y1=cos_y1[selindex]
		cos_z1=cos_z1[selindex]
		y0=y0[selindex]
		z0=z0[selindex]
		qa=qa[selindex]
		shell=shell[selindex]
		k=k[selindex]
		alpha1=alpha1[selindex]
		alpha2=alpha2[selindex]
	endif

end