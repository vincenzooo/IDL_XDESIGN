rtFolder='E:\work\workOA\traie8\studioDistrib1\sh24D295'
index=2

readcol, rtFolder+path_sep()+'aree.txt',ener,area
nener=len_blocks(ener,nblocks=n)
ener=ener[0:nener-1]

rough=4.
nbil=200
;crea dspacing
dSpac=thicknessPL(115.5 ,-0.9,0.27,nbil,0.35)

;calcola l'area usando il file focal plane
;legge i dati del coating e l'area
mat1=readnamelistVar(rtFolder+path_sep()+'imp_OffAxis.txt','matsub')
mat1=file_dirname(rtFolder)+path_sep()+'af_files'+path_sep()+mat1
mat2=readnamelistVar(rtFolder+path_sep()+'imp_OffAxis.txt','mat2even')
mat2=file_dirname(rtFolder)+path_sep()+'af_files'+path_sep()+mat2
mat3=readnamelistVar(rtFolder+path_sep()+'imp_OffAxis.txt','mat1odd')
mat3=file_dirname(rtFolder)+path_sep()+'af_files'+path_sep()+mat3
loadRI,ener,mat1,mat2,mat3

;load data from raytracing
psffile=rtfolder+path_sep()+'psf_Data_'+string(index,format='(i2.2)')+'.txt'
readFP,psffile,qtarget=15,nph=nph,nSelected=nSel,$
  k=k,alpha1=alpha1,alpha2=alpha2,frac=frac

apar=fltarr(nener)*0
for i=0,100 do begin ;nsel-1 do begin
  ang1=alpha1[i]
  ang2=alpha2[i]
  r1=reflexDLL (ener, ang1, dSpac, rough)
  r2=reflexDLL (ener, ang2, dSpac, rough)
  t=r1*r2
  apar=apar+t
endfor
r2=reflexDLL (ener, ang2, dSpac, rough,/unload)
plot,ener,apar

end