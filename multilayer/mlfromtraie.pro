function mlFromTraie,rtFolder,funk=funk,$
  mlpars=mlpars,nbil=nbil,rough=rough,extraT=extraT,$
  ocThickness=ocThickness,materials=materials
  ;return an array with the multilayer parameters extracted
  ;from the setting file of the fortran raytracing file.
  ;function is a function that transform the parameters in dspacing.
  ; if not provided, 4-dim power-law is assumed
    ;legge i dati del coating e l'area
  ;example:
;  dSpac=mlFromTraie(rtFolder,rough=rough,materials=mat)
;  mat1=mat[0]
;  mat2=mat[1]
;  mat3=mat[2]
;  loadRI,ener,mat1,mat2,mat3
;  r1=reflexDLL (ener, ang, dSpac, rough)
    
  mat1=readnamelistVar(rtFolder+path_sep()+'imp_OffAxis.txt','matsub')
  ;mat1='af_files'+path_sep()+mat1
  mat1=file_dirname(rtFolder)+path_sep()+'af_files'+path_sep()+mat1
  mat2=readnamelistVar(rtFolder+path_sep()+'imp_OffAxis.txt','mat2even')
  ;mat2='af_files'+path_sep()+mat2
  mat2=file_dirname(rtFolder)+path_sep()+'af_files'+path_sep()+mat2
  mat3=readnamelistVar(rtFolder+path_sep()+'imp_OffAxis.txt','mat1odd')
  ;mat3='af_files'+path_sep()+mat3
  mat3=file_dirname(rtFolder)+path_sep()+'af_files'+path_sep()+mat3
  materials=[mat1,mat2,mat3]
  
  ocThickness=float(readnamelistVar(rtFolder+path_sep()+'imp_OffAxis.txt','esterno1st'))
  extraT=float(readnamelistVar(rtFolder+path_sep()+'imp_OffAxis.txt','esterno2nd'))
  rough=float(readnamelistVar(rtFolder+path_sep()+'imp_OffAxis.txt','oddrough'))
  nbil=fix(readnamelistVar(rtFolder+path_sep()+'imp_OffAxis.txt','n_bilayers'))
  ndim=fix(readnamelistVar(rtFolder+path_sep()+'imp_OffAxis.txt','ndim'))
  
  mlpars=fltarr(ndim)
  for i=0,ndim-1 do begin
    mlpars[i]=float(readnamelistVar(rtFolder+path_sep()+'imp_OffAxis.txt','par('+string(i+1,format='(i1)')+')'))
  endfor
  if n_elements(funk) eq 0 then begin
    dSpac=thicknessPL(mlpars[0],-mlpars[1],mlpars[2],nbil,mlpars[3])
  endif else begin
    dSpac=call_function(funk,mlpars,nbil)
  endelse

  dSpac[0]=dSpac[0]+extraT
  if ocThickness ne 0 then begin
    dSpac=[[0,ocThickness],dSpac]
    nbil=nbil+1
  endif
  
  return,dspac
end