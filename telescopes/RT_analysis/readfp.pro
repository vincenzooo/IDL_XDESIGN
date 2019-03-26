pro readFP,psffile,shtarget=sht,qtarget=qat,nph=nph,nSelected=nSelected,$
	Xfp=x,Yfp=y,cosx1=cos_X1,cosy1=cos_Y1,cosz1=cos_z1,y0=y0,$
	z0=z0,qa=qa,shell=shell,k=k,alpha1=alpha1,alpha2=alpha2,$
	outfile=outfile,noselect=noselect,help=help,frac=frac
;frac lasciato per generare messaggio quando chiamato da vecchia interfaccia

;ATTENZIONE: se nessun fotone soddisfa i criteri vengono restituiti tutti i 
;valori a zero e nselected=0. Questo perche' IDL non permette di cancellare
;vettori esistenti, per cui si potrebbe fare in modo che restituisca
;vettori non inizializzati, ma questo non funzionerebbe se le variabili
;passate alla routine non erano variabili non inizializzate nella routine
;chiamante (per es, se readFP viene chiamata due volte).

;read a focal plane file <psffile> in the format of traie(7) results.
;can return:
;the usual focal plane data
;<nph> total number of photons
;<nSelected> (name changed from "frac") the number of photons meeting both 
;	the condition of qa and shell being respectively in <qtarget>, <shtarget>
; (arrays or single values). qtarget is not called qatarget to avoid the 
; stupid IDL error with ambiguous abbreviation.
;if <outfile> is provided, save the selected data in a file.
;if noselect is set, return all data (but write on file only the ones
;meeting the condition)

;uses: wherein, readcol

;(2/12/2009) cambiati i nomi di sht e qat per evitare che vengano modificati
;in output se passati come variabili non definite.
;cambiata gestione di qtarget e shtarget se non vengono forniti i valori.
;prima assegnava valore [0], ora li lascia non definiti, affidandosi all'esecuzione
;di wherein con flag /silent

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
	;if n_elements(sht) eq 0 then shtarget =[0] else shtarget=sht
	;if n_elements(qat) eq 0 then qtarget =[0] else qtarget=qat

	;read and filter the variables
	readcol,psffile, X,Y,cos_x1,cos_y1,cos_z1,y0,z0,qa,shell,k,alpha1,alpha2,skipline=1
	count=n_elements(x)
	nph=count
	;;selindex=lindgen(count)
	
	;crea un vettore <selindex> degli indici degli elementi selezionati,
	;<count> contiene la lunghezza di <selindex>
	;se la variabile non e' definita l'indice contiete tutto il 
	;vettore.
	;tmp=wherein(qa,qtarget,count)
	;if ((qtarget ne [0]) and (count ne 0)) then selindex=selindex[tmp]
	;if (qtarget ne [0]) then begin
	tmp=wherein(qa,qat,count,/silent)
  if (count ne 0) then begin
  	;;selindex=selindex[tmp]
  	selindex=tmp ;;
  	;endif
  	;if (shtarget ne [0]) then begin
  	tmp=wherein(shell[selindex],sht,count,/silent)
  	if (count ne 0) then selindex=selindex[tmp] ;;selindex=selindex[tmp]
  	;endif
  endif
  nSelected=count
  if count eq 0 then begin
      x=[0.0]
      y=[0.0]
      cos_x1=[0.0]
      cos_y1=[0.0]
      cos_z1=[0.0]
      y0=[0.0]
      z0=[0.0]
      qa=[0L]
      shell=[0L]
      k=[0L]
      alpha1=[0.0]
      alpha2=[0.0]
      selindex=0
  endif
  
  
	if n_elements(outfile) ne 0 then begin
	  if count eq 0 then begin
	      print, "ReadFP: No photons matching the filters"
        if n_elements(qat) ne 0 then print, "qa==",qat
        if n_elements(sht) ne 0 then print, "sh==",sht
        print,"Will not create the output file ",outfile
    endif else begin 
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
    endelse
	endif

	if keyword_Set(noselect) eq 0 then begin
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