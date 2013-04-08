
pro extractVignetting, folderlist, psfdir=psfdir,qatarget=qat,shtarget=sht

;usage:
;extractVignetting, folder, psfdir=psfdir
;analyze the focal plane and area ray-tracing results in <folder> and create
;there a file with subfix "_vig" with columns:
;angle(rad) energy(keV) EffectiveArea(cm^2) vignetting mirrorFraction
; vignetting is the ratio between effective area and E.A. on axis,
; mirror fraction is the effective fraction (weighted by effective area)
;of primary mirror for double reflection.
;
;--Q: HOW is the geometrical area calculated?? Is it always correct?
;
;psfdir can be provided if the focal plane data are in a different folder
;(e.g. for a ray tracing started from common data)

;16/04/2009
;changed name of program from extractDith to extractVignetting
;changed filename from photoncounts3 to extractVignetting
;after (1/04/2009) changed values in columns, see p.143 logbook

	;psfdir can be provided if the focal plane data are in a different folder
	;(e.g. for a ray tracing started from common starting data)
	;changes 
	;(1/12/2009) added shtarget and qatarget to select shells and to 
	;calculate statistics on photons other that the doubly reflected ones.
	;(1/04/2009) changed values in columns, see p.143 logbook
	fl=folderlist
	if n_elements(fl) eq 1 then fl=[fl]

;  if keyword_set(autooutput) ne 0 then begin
;    if n_elements(outfiles) ne 0 then message, 'The flag outoOutput and'+$
;      ' a list of output filenames (OUTFILES), for '+$
;      newline()+'the psf data of selected photons, are both set.'+newline() $
;    else begin
;      outfiles=strarr(n_elements(fl))
;      for i =0,n_elements(fl)-1 do begin
;        outfiles[i]=fnaddsubfix(fl[i],'_selected')
;      endfor
;    endelse 
;	endif 
;	
;	if n_elements(outfiles) ne 0 then begin
;    if n_elements(fl) ne n_elements(outfiles) then begin
;	    message,'The number of filenames for the psf outputfiles does not match'+$
;	    newline()+'the number of input files:'+newline()+$
;	    'nr of input files='+strtrim(string(n_elements(fl)),2)+newline()+$
;	    'nr of output files='+strtrim(string(n_elements(outfiles)),2)+'.'+newline()+$
;	    'N.B.: for automatic output, set the flag autooutput.'
;    endif
;	endif 
	
	for i=0,n_elements(fl)-1 do begin
    folder=fl[i]
  	spdir=strsplit(folder,path_sep(),/extract)
  	basedir=strjoin(spdir[0:n_elements(spdir)-2],path_sep())
  	curdir=spdir[n_elements(spdir)-1]
    vignettingFile=folder+path_sep()+curdir+'_vig.dat'
  	if n_elements(psfdir) eq 0 then psfdir2=folder else psfdir2=psfdir
    if n_elements(qat) eq 0 then qatarget =[15] else qatarget=qat
    if n_elements(sht) ne 0 then shtarget=[sht]
  
  	;focusedFraction=fraction of photons focused,
  	;ageo is the telescope area on entrance pupil without walls.
  	;also read the values of off-axis angles
  	focusedFraction= geoVignetting(psfdir2,shtarget=shtarget,qatarget=qatarget,$
  	    angles=angles,nph=nph,nSelected=nFocused)
  	ageo=getAgeo(psfdir2)
    print,psfdir2
  	;mirrorfraction=fraction of photons on the first surface
  	mirrorFraction=geoVignetting(psfdir2,shtarget=shtarget,qatarget=[1,3,5,7,9,11,13,15],$
  	    nSelected=nOnPrimary)
  	nangles=n_elements(angles)
  	anglesRad=angles*!PI/(60*180.)
  	readcol,folder+path_sep()+'aree.txt', ener,aeff,areaErr
  	nenergies=len_blocks(ener,nblocks=nblocks)
  	if nblocks ne nangles then begin
  		a=dialog_message("nblocks in file aree.txt= "+string(nblocks)+$
  			", nangles= "+string(nangles))
  	endif
  	ener=ener[0:nenergies-1]
  	aeff=reform(aeff,nenergies,nblocks)
    areaErr=reform(areaErr,nenergies,nblocks)
    
  	get_lun,nf
  	openw,nf,vignettingFile
  	printf,nf,'angle  energy  aeff(cm^2) vignetting mirrorAreaFraction nOfFocusedPhotons Error(cm^2)'
  	;values for geometric vignetting
  
  	;mirrorAreaFraction: (area interessata da doppia riflessione)/(area proiettata degli specchi)
  	;p=focusedFraction,n=  nph
  	sigma2=nph*focusedFraction*(1-focusedFraction) ;n*p*(1-p)
  	error=1/sqrt(nph)*sqrt(1/focusedFraction-1)*aGeo
  	for j=0,nblocks-1 do begin
  		printf,nf,format='(5f,i,f)',$
  				angles[j],0.0,cos(anglesRad[j])*aGeo*focusedFraction[j],$
  				cos(anglesRad[j])*focusedFraction[j]/focusedFraction[0],$
  				focusedFraction[j]/mirrorFraction[j],nFocused[j],error[j]
  	endfor
  	printf,nf
  	printf,nf
  	for ii=0,nenergies-1 do begin
  		for j=0,nblocks-1 do begin
  			printf,nf,format='(5f,i,f)',angles[j],ener[ii],aeff[ii,j],$
  			aeff[ii,j]/aeff[ii,0],aeff[ii,j]/(aGeo*mirrorFraction[j]*cos(anglesRad[j])),$
  			nFocused[j],areaErr[ii,j]
  		endfor
  		printf,nf
  		printf,nf
  	endfor
  	free_lun,nf
  	beep
  end
end

;;esempio:
;;single folder
;folder='D:\work\traie7\hxmt_13\FF1_ph_sx2vig'
;extractVignetting, folder
;
;list of folders
;folders=["F:\next_HXT\run_3_12_28short",$
;		"F:\next_HXT\run_2_ff0_short"]
;extractVignetting, folders


;----------------------------
;USED FOR:

;folders=["F:\next_HXT\run_3_12_28short",$
;   "F:\next_HXT\run_2_ff0_short"]

;folders = ['G:\2sx_sh295_delta05',$
;		   'G:\2sx_sh295_delta10']

;folders=["F:\finiteDsourceOld\\2sx_sh295_delta01",$
;"F:\finiteDsourceOld\2sx_sh295_delta03",$
;"F:\finiteDsourceOld\2sx_sh295_delta05",$
;"F:\finiteDsourceOld\2sx_sh295_delta10"]

;folders = ['D:\work\traie7\angle_distr\3sx_sh560_delta022']
;
;folders=['E:\work\workOA\traie8\studioVignetting\F20D295ff000cc_thsx',$
;         'E:\work\workOA\traie8\studioVignetting\F20D295ff002cc_thsx',$
;         'E:\work\workOA\traie8\studioVignetting\F20D295ff004cc_thsx',$
;         'E:\work\workOA\traie8\studioVignetting\F20D295ff006cc_thsx',$
;         'E:\work\workOA\traie8\studioVignetting\F20D295ff008cc_thsx',$
;         'E:\work\workOA\traie8\studioVignetting\F20D295ff010cc_thsx']

folders='E:\work\workOA\traie7\hexitSat_2009\F10D394ff010_around30'
folders='E:\work\workOA\traie8\NHXMphB_mlvignetting\phBg2_ff010_10m_max394'
folders=['E:\work\workOA\traie8\SPIE2010\sh24D295ML1_01',$
         'E:\work\workOA\traie8\SPIE2010\sh24D295ML2_01',$
         'E:\work\workOA\traie8\SPIE2010\sh24D295ML3_01']
folders=['E:\work\workOA\traie8\studioVignetting5\run1fig9_case12sh',$
         'E:\work\workOA\traie8\studioVignetting5\run1fig9_case22sh',$
         'E:\work\workOA\traie8\studioVignetting5\run1fig9_case32sh']

extractVignetting, folders,shtarget=1


end
