
pro extractVignettingArea, folderlist,energybands,suffix=suffix

;usage:
;extractVignettingArea, folder
;extract the vignetting from the aree.txt file in OA raytracing results
;(differently from extractVignetting that uses the focal plane data in psf_filexxx.txt).

;analyze the area ray-tracing results in <folder> and create
;there a file with subfix "_vigA" with columns:
;angle(rad) energy(keV) EffectiveArea(cm^2) vignetting 
; vignetting is the ratio between effective area and E.A. on axis,
; mirror fraction is the effective fraction (weighted by effective area)
;of primary mirror for double reflection.
;(the routine in extractVignetting has an additional column "mirrorFraction" that
; cannot be calculated here, also it includes the possibility of chosing other kinds
;of reflection history than double-reflected photons).
;the optional input parameter psfdir in extractVignetting is not useful here

;24/07/2010
;prima versione del programma per spie 2010.

  fl=folderlist
  if n_elements(fl) eq 1 then fl=[fl]
  
  for i=0,n_elements(fl)-1 do begin
    folder=fl[i]
 
    spdir=strsplit(folder,path_sep(),/extract)
    basedir=strjoin(spdir[0:n_elements(spdir)-2],path_sep()) ;path della directory folder
    curdir=spdir[n_elements(spdir)-1] ;directory
  
;    ;focusedFraction=fraction of photons focused,
;    ;ageo is the telescope area on entrance pupil without walls.
;    ;also read the values of angles
;    focusedFraction= geoVignetting(psfdir,shtarget=shtarget,qatarget=qatarget,$
;        angles=angles,nph=nph,nSelected=nFocused)
;    ageo=getAgeo(psfdir)
    angles=getOAangle(folder,/arcmin)
  
;    ;mirrorfraction=fraction of photons on the first surface
;    mirrorFraction=geoVignetting(psfdir,shtarget=shtarget,qatarget=[1,3,5,7,9,11,13,15],nSelected=nOnPrimary)
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
    nbands=n_elements(energybands)/2
    
    if nbands ne 0 then begin
      baeff=fltarr(nbands,nblocks)
      for ii=0,nblocks-1 do begin
        baeff[*,ii]=bandaverage(aeff[*,ii],energybands,x=ener)
      endfor
      nenergies=nbands
      aeff=baeff
    endif else begin
      energybands=fltarr(2,nenergies)
      energybands[0,*]=ener
      energybands[1,*]=ener
    endelse
    
    get_lun,nf
    if n_elements (suffix) eq 0 then suffix=""
    openw,nf,folder+path_sep()+curdir+'_vigArea'+suffix+'.dat'
    printf,nf,'angle  EnergyLow EnergyHigh  aeff(cm^2) vignetting '
    for ii=0,nenergies-1 do begin
      for j=0,nblocks-1 do begin
        printf,nf,format='(5f,i,f)',angles[j],energybands[0,ii],energybands[1,ii],aeff[ii,j],$
          aeff[ii,j]/aeff[ii,0]
      endfor
      printf,nf
      printf,nf
    endfor
    free_lun,nf
    beep
  endfor
end

;;esempio:
;;single folder
;folder='D:\work\traie7\hxmt_13\FF1_ph_sx2vig'
;extractVignetting, folder
;
;list of folders
;folders=["F:\next_HXT\run_3_12_28short",$
;   "F:\next_HXT\run_2_ff0_short"]
;extractVignetting, folders


;----------------------------
;USED FOR:
;folder='E:\work\workOA\traie8\SPIE2010\sh24D295ML1_01'
folders=['E:\work\workOA\traie8\SPIE2010\sh24D295ML1_01',$
  'E:\work\workOA\traie8\SPIE2010\sh24D295ML2_01',$
  'E:\work\workOA\traie8\SPIE2010\sh24D295ML3_01']
eb=fltarr(2,1)
eb[*,0]=[25.,35.]
extractVignettingArea, folders,eb,suffix='25_35'

end