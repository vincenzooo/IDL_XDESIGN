pro readImpact,impactfile,shtarget=shtarget,qtarget=qatarget,nph=nph,nSelected=nSelected,$
	x1=ximp1,y1=yimp1,z1=zimp1,x2=ximp2,y2=yimp2,z2=zimp2,qa=qa,shell=shell,$
	k=k2,alpha1=al1,alpha2=al2,outfile=outfile,noselect=noselect,help=help,frac=frac
;frac lasciato per generare messaggio quando chiamato da vecchia interfaccia

;read a impact points file <impactfile> in the format of traie(7) results.
;can return:
;the usual imapct points dataa
;<nph> total number of photons
;<nSelected> (name changed from "frac") the number of photons meeting both the condition of qa and shell
;being respectively in <qtarget>, <shtarget> (arrays or single values).
;if <outfile> is provided, save the selected data in a file.
;if noselect is set, return all the data (but write on file only the ones
;meeting the condition)

	if n_elements(help) ne 0 then begin
		print,'pro readImpact,impactfile,shtarget=shtarget,qtarget=qatarget,nph=nph,nSelected=nSelected,$'
		print,'x1=ximp1,y1=yimp1,z1=zimp1,x2=ximp2,y2=yimp2,z2=zimp2,qa=qa,shell=shell,$'
		print,'k=k2,alpha1=al1,alpha2=al2,outfile=outfile,noselect=noselect,help=help'
		print,'----------------------------------------------------------------------'
		print,'Read a impact points file <impactfile> in the format of traie(7) results.'
		print,'Can return:'
		print,'the usual impact points data'
		print,'<nph> total number of photons'
		print,'<frac> the number of photons meeting both the condition of qa and shell'
		print,'being respectively in <qtarget>, <shtarget> (arrays or single values).'
		print,'if <outfile> is provided, save the selected data in a file.'
		print,'if noselect is set, return all the data (but write on file only the ones'
		print,'meeting the conditions)'
		print,'----------------------------------------------------------------------'
		return
	endif
	
	;force to update the caller program if using the old names for parameters
  if n_elements(frac) ne 0 then message,$
    "the output parameter <frac> (number of photons meeting the conditions)"+$
    "was renamed to <nSelected>, update the caller command"
	
	;if n_elements(shtarget) eq 0 then shtarget=0
	;if n_elements(qatarget) eq 0 then qatarget=0

	readcol,impactfile,ximp1,yimp1,zimp1,ximp2,yimp2,zimp2,qa,shell,k2,al1,al2
  nph=n_elements(ximp1)
  tmp=wherein(qa,qatarget,count,/silent)
  if (count ne 0) then begin
    selindex=tmp 
    tmp=wherein(shell[selindex],shtarget,count,/silent)
    if (count ne 0) then selindex=selindex[tmp] 
  endif
  nSelected=count
  if count eq 0 then begin
    ximp1=[0.0]
    yimp1=[0.0]
    zimp1=[0.0]
    ximp2=[0.0]
    yimp2=[0.0]
    zimp2=[0.0]
    qa=[0]
    shell=[0]
    k2=[0]
    al1=[0]
    al2=[0]
    selindex=0
  endif

	if n_elements(outfile) ne 0 then begin
		if count eq 0 then begin
      print, "ReadFP: No photons matching the filters"
      if n_elements(qatarget) ne 0 then print, "qa==",qatarget
      if n_elements(shtarget) ne 0 then print, "sh==",shtarget
      print,"Will not create the output file ",outfile
    endif else begin 
      get_lun,unit
      frmt='(7f12.5,2i4,i9,2f23.14)'
      openw,unit,outfile
      printf,unit," X1  Y1  Z1 X2 Y2  Z2  qa	shell	k	alpha1	alpha2"
      for j=0L,count-1 do begin
			  i=a[j]
        printf,unit,format=frmt,ximp1[i],yimp1[i],zimp1[i],ximp2[i],yimp2[i],zimp2[i],$
				    qa[i],shell[i],k2[i],al1[i],al2[i]
      endfor
      close,unit
    endelse
	endif

	if n_elements(noselect) eq 0 then noselect=0
	if noselect eq 0 then begin
		ximp1=ximp1[selindex]
		yimp1=yimp1[selindex]
		zimp1=zimp1[selindex]
		ximp2=ximp2[selindex]
		yimp2=yimp2[selindex]
		zimp2=zimp2[selindex]
		qa=qa[selindex]
		shell=shell[selindex]
		k2=k2[selindex]
		al1=al1[selindex]
		al2=al2[selindex]
	endif

end