;this is copied from end of reflex2d2 and 3.

outfolder='E:\work\documenti in progress\Cotroneo2010_FovOptSPIE\poster'
alphaRad=3.7e-3
fovarcmin=8.
enmin=1.
enmax=80.
nener=1000
thResArcsec=5.
ener=vector(enmin,enmax,nener)
folder=file_dirname(file_which('reflexdll.pro'))
mat1=folder+path_sep()+'af_files\a-Si.dat'
mat2=folder+path_sep()+'af_files\a-C.dat'
mat3=folder+path_sep()+'af_files\Pt.dat'

;  nbil=200
;  a=105.
;  b=0.9
;  c=0.27
;  gamma=0.35
;  rough=4.
;  dspacing=thicknessPL(a,b,c,nbil,gamma)

;
;  reflex2D,ener,fovArcmin,alphaRad,thResArcsec,dSpacing,$
;    mat1,mat2,mat3,rough,dmatrix=dmatrix,tmatrix=tmatrix,mlname="ML 1",$
;    outfolder=outfolder,/nocontour
;
;  nbil=200
;  a=77.4
;  b=-0.9432
;  c=0.223
;  gamma=0.42
;  rough=4.
;  dspacing=thicknessPL(a,b,c,nbil,gamma)
;  reflex2D,ener,fovArcmin,alphaRad,thResArcsec,dSpacing,$
;    mat1,mat2,mat3,rough,dmatrix=dmatrix,tmatrix=tmatrix,mlname="ML 2",$
;    outfolder=outfolder,/nocontour
;
; ;risultato della prima ottimizzazione con una sola iterazione,
; ;esteso a 200 bilayer.
;
;  nbil=200 ;148
;  a= 82.3442
;  b=-0.767218
;  c=0.258612
;  gamma=0.524157
;  rough=4.
;  dspacing=thicknessPL(a,b,c,nbil,gamma)
;  reflex2D,ener,fovArcmin,alphaRad,thResArcsec,dSpacing,$
;    mat1,mat2,mat3,rough,dmatrix=dmatrix,tmatrix=tmatrix,mlname="ML 3",$
;    outfolder=outfolder,/nocontour
;
;
;  nbil=187
;  d1=194.497
;  dN=23.9321
;  c=0.222582
;  gamma=0.411721
;  rough=4.
;  dum=d1dntoalphabeta(d1,dn,c,alpha=alpha,beta=beta)
;  dum=alphabetatoab(alpha,beta,c,nbil,a=a,b=b)
;  dspacing=thicknessPL(a,b,c,nbil,gamma)
;  reflex2D,ener,fovArcmin,alphaRad,thResArcsec,dSpacing,$
;    mat1,mat2,mat3,rough,dmatrix=dmatrix,tmatrix=tmatrix,mlname="ML 4",$
;    outfolder=outfolder,/nocontour
;
;  nbil=137
;  d1=118.6492767
;  dN=29.5356941
;  c=0.2118295
;  gamma=0.3691501
;  rough=4.
;  dum=d1dntoalphabeta(d1,dn,c,alpha=alpha,beta=beta)
;  dum=alphabetatoab(alpha,beta,c,nbil,a=a,b=b)
;  dspacing=thicknessPL(a,b,c,nbil,gamma)
;  reflex2D,ener,fovArcmin,alphaRad,thResArcsec,dSpacing,$
;    mat1,mat2,mat3,rough,dmatrix=dmatrix,tmatrix=tmatrix,mlname="ML 5",$
;    outfolder=outfolder,/nocontour
;
;  nbil=38
;  d1=61.2241211
;  dN=61.2229691
;  c=4.2973185
;  gamma=0.2674135
;  rough=4.
;  dum=d1dntoalphabeta(d1,dn,c,alpha=alpha,beta=beta)
;  dum=alphabetatoab(alpha,beta,c,nbil,a=a,b=b)
;  dspacing=thicknessPL(a,b,c,nbil,gamma)
;  reflex2D,ener,fovArcmin,alphaRad,thResArcsec,dSpacing,$
;    mat1,mat2,mat3,rough,dmatrix=dmatrix,tmatrix=tmatrix,mlname="ML 6",$
;    outfolder=outfolder,/nocontour


;  nbil=37
;  d1=74.6417618
;  dN=39.2416458
;  c=0.3761268
;  gamma=0.4384359
;  rough=4.
;  dum=d1dntoalphabeta(d1,dn,c,alpha=alpha,beta=beta)
;  dum=alphabetatoab(alpha,beta,c,nbil,a=a,b=b)
;  dspacing=thicknessPL(a,b,c,nbil,gamma)
;  reflex2D,ener,fovArcmin,alphaRad,thResArcsec,dSpacing,$
;    mat1,mat2,mat3,rough,dmatrix=dmatrix,tmatrix=tmatrix,mlname="ML 7b",$
;    outfolder=outfolder,/nocontour


nbil=200
a=115.5
b=0.9
c=0.27
gamma=0.35
rough=4.
dspacing=thicknessPL(a,b,c,nbil,gamma)
dspacing[0]=dspacing[0]+50.
dspacing=[0,100.,dspacing]

reflex2D,ener,fovArcmin,alphaRad,thResArcsec,dSpacing,$
  mat1,mat2,mat3,rough,tmatrix=tmatrix,mlname="ML 1",$
  outfolder=outfolder,/nocontour   ;Si chiamava ml 9

nbil=33
d1=75.2154770
dN=43.1798134
c=0.2656355
gamma=0.4343832
rough=4.
dum=d1dntoalphabeta(d1,dn,c,alpha=alpha,beta=beta)
dum=alphabetatoab(alpha,beta,c,nbil,a=a,b=b)
dspacing=thicknessPL(a,b,c,nbil,gamma)
reflex2D,ener,fovArcmin,alphaRad,thResArcsec,dSpacing,$
  mat1,mat2,mat3,rough,tmatrix=tmatrix,mlname="ML 2",$
  outfolder=outfolder,/nocontour  ;si chiamava ml 7

nbil=117
d1=100.1601715
dN=30.2138138
c=0.2062590
gamma=0.4271505
rough=4.
dum=d1dntoalphabeta(d1,dn,c,alpha=alpha,beta=beta)
dum=alphabetatoab(alpha,beta,c,nbil,a=a,b=b)
dspacing=thicknessPL(a,b,c,nbil,gamma)
reflex2D,ener,fovArcmin,alphaRad,thResArcsec,dSpacing,$
  mat1,mat2,mat3,rough,tmatrix=tmatrix,mlname="ML 3",$
  outfolder=outfolder,/nocontour  ;ML 8

nbil=207
d1=123.8735046
dN=23.7926178
c=0.2363445
gamma=0.4300654
rough=4.
dum=d1dntoalphabeta(d1,dn,c,alpha=alpha,beta=beta)
dum=alphabetatoab(alpha,beta,c,nbil,a=a,b=b)
dspacing=thicknessPL(a,b,c,nbil,gamma)
reflex2D,ener,fovArcmin,alphaRad,thResArcsec,dSpacing,$
  mat1,mat2,mat3,rough,tmatrix=tmatrix,mlname="ML 4",$
  outfolder=outfolder,/nocontour
end