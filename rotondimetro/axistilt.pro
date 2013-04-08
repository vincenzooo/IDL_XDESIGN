function dirCos,mx,my
;restituisce i coseni direttori a partire dai coefficienti angolari.
  modulo=sqrt(1+mx^2+my^2)
  Cx=mx/modulo
  Cy=my/modulo
  Cz=1./modulo
  return,[Cx,Cy,Cz]
end

function dcxdmx,mx,my
;restituisce la derivata parziale di Cx(Cy) rispetto a mx(my), che si assume passato per primo
v=sqrt(1+mx^2+my^2)
return,1/v-mx^2/v^3
end

function dcxdmy,mx,my
;restituisce la derivata parziale di Cx(Cy) rispetto a my(mx),
; che si assume passato per secondo (ma tanto è simmetrica).
v=sqrt(1+mx^2+my^2)
return,-mx*my/v^3
end

function dczdmx,mx,my
;restituisce la derivata parziale di Cz rispetto a mx(my),
; che si assume passato per primo.
v=sqrt(1+mx^2+my^2)
return,-mx/v^3
end

function AxisTilt, rettaPar, rettaHyp, errorPar, errorHyp, zIP,$
    silent=silent,tilt=tilt,errtilt=errtilt,shift=shift,$
    errShift=errShift,parVec=vpar,parHyp=vHyp,parIP=parIP,hypIP=hypIP,$
    log=logU
    
;questi sono i dati (risultanti dal fit con gnuplot) per la shell dritta
;  mx  qx  my  qy
;Par Dri -0.000627306  -6.04868  -2.12E-05 34.515
;Hyp Dri -0.000558414  -22.7985  -0.000116485  24.3556
; errore
;-2.38753E-05  -1.44563452 -5.8688E-07 0.03555045
;-2.26269E-05  -3.42661455 -1.14027E-05  1.727055596

;questi sono i dati per la shell capovolta
;Par Cap 0.00154677  -297.201  0.000805006 -97.6356
;Hyp Cap 0.00132666  -266.832  0.000506747 -86.391

;  mx  qx  my  qy
;Parabola
mXPar= rettaPar[0] ;la proiezione dell'asse sul piano xz ha eq.: x=mxPar*z+qxPar  
qXPar= rettaPar[1]  
mYPar= rettaPar[2] ;la proiezione dell'asse sul piano yz ha eq.: y=myPar*z+qyPar
qYPar= rettaPar[3]
;Iperbole
mxHyp= rettaHyp[0]
qxHyp= rettaHyp[1]
myHyp= rettaHyp[2]
qyHyp= rettaHyp[3]
;zIP=100000. ;z dell'intersection plane in micron

mXerrHyp=errorHyp[0] ;errori sul fit dei diversi parametri
qXerrHyp= errorHyp[1]
mYerrHyp= errorHyp[2]
qYerrHyp= errorHyp[3]
mXerrPar= errorPar[0]
qXerrPar= errorPar[1] 
mYerrPar= errorPar[2] 
qYerrPar= errorPar[3]

logFlag=n_elements(logU)
if logFlag ne 0 then begin
   tU=size(logU,/type)
   if tU eq 7 then begin   ;e' stringa
      get_lun, logFileN
      openw,logFileN,logU
   endif 
endif else begin
    logFileN=-1 ;standard output
endelse
  
VPar=dircos(mxPar,myPar) ;versore dell'asse della parabola
VHyp=dircos(mxHyp,myHyp)
tilt=acos(total(vPar*vHyp))

printf,logFileN,"Parabola Axis: ",vPar
printf,logFileN,"Parabola phase on XY plane: ",atan(vPar[0],vPar[1]),"= ",$
    atan(vPar[0],vPar[1])*180/!PI," deg"
printf,logFileN,"Parabola Axis, angle formed with Z:",acos(vPar[2]),"rad = ",$
    acos(vPar[2])*206265  ," arcsec"  
printf,logFileN,"Hyperbola Axis: ",vHyp
printf,logFileN,"Hyperbola phase on XY plane: ",atan(vHyp[0],vHyp[1]),$
    atan(vHyp[0],vHyp[1])*180/!PI," deg"
printf,logFileN,"Hyperbola Axis, angle formed with Z:",acos(vHyp[2]),"rad = ",$
    acos(vHyp[2])*206265  ," arcsec"  
printf,logFileN,"Tilt Parabola/Hyperbole"
printf,logFileN, tilt," rad = ",tilt*206265," arcsec"

dfac=-1/sqrt(1-tilt^2) ;d acos(x)/dx
;calcolo la derivata parziale del tilt rispetto alle coordinate dello spazio (Mi,Qi)
;come derivate di funzione composta: Tilt=Tilt(Ci(Mi,Qi)),
;secondo regole spiegate in funzcomposte2.pdf
ParDer=dfac*[vHyp,vPar] ;vettore delle componenti Ci(Mi,Qi)
;matrice delle derivate dCi/dMQi
dCdm=[[dcxdmx(mxPar,myPar),dcxdmy(mxPar,myPar),0,0],$
      [dcxdmy(myPar,mxPar),dcxdmx(myPar,mxPar),0,0],$
      [dczdmx(mxPar,myPar),dczdmx(myPar,mxPar),0,0],$
      [0,0,dcxdmx(mxHyp,myHyp),dcxdmy(mxHyp,myHyp)],$
      [0,0,dcxdmy(myHyp,mxHyp),dcxdmx(myHyp,mxHyp)],$
      [0,0,dczdmx(mxHyp,myHyp),dczdmx(myHyp,mxHyp)]]

derVector= dCdM ;parder
;derVector=dfac*[dTiltdmxpar,dTiltdmypar,dTiltdmxhyp,dTILTdMxHyp]
errVector=[mxErrPar,mYerrPar,mXerrHyp,mYerrHyp]
errTilt=sqrt(total((derVector*errVector)^2))
printf,logFileN,"Errore sul tilt"
printf,logFileN,errTilt," rad=",errTilt*206265," arcsec (",errTilt/tilt*100,"%)"

;intersezione parabola / piano IP
xParIP=mxPar*zIP+qxPar
yParIP=myPar*zIP+qYPar
xHypIP=mxHyp*zIP+qxHyp
yHypIP=myHyp*zIP+qYHyp
parIP=[xParIP,yParIP] ;coordinate dell'asse all'IP
hypIP=[xHypIP,yHypIP]
distIP=sqrt(total((parIP-hypIP)^2))
printf,logFileN,"Origin p:",parIp
printf,logFileN,"Origin h:",hypIP
printf,logFileN,"Distance of axis points at z=IP:",distIP, "um"
printf,logFileN,"Error on Xp,Yp,Xh,Yh"

;errore sulle singole coordinate
errShiftVec=[mxErrPar,mYerrPar,qxErrPar,qYerrPar,$
             mXerrHyp,mYerrHyp,qXerrHyp,qYerrHyp]
;derivata della distanza rispetto alla corrispondente coordinata
derXfac=1/distIP*(xParIP-xHypIP) ;fattore comune alle derivate relative alla x
derYfac=1/distIP*(yParIP-yHypIP) ;fattore comune alle derivate relative alla y
parDerShiftVec=[-derXfac*zIP,derYfac*zIP,-derXfac,derYfac,$
                derXfac*zIP,-derYfac*zIP,derXfac,-derYfac]
errShift=sqrt(total((errShiftVec*parDerShiftVec)^2))
printf,logFileN,"um:",errShift
printf,logFileN,"%",errShift/distIP*100
;errDist=sqrt()
;printf,logFileN,"Error in distance: ",,"um (",,"%)"

;distanza minima tra le due rette
;esprimendo due rette sghembe come R1=A+Bt e R2=C+Dt (A,B,C,D vettori, t parametro),
;la distanza minima è q=(A-C)-(A-C)B/|B|.B/|B|-(A-C)D/|D| D/|D|.
;Nel nostro caso |B|=|D|=1 per costruzione, quindi:
;q=(A-C)-(A-C)B B-(A-C)D D
B=vPar
D=vHyp
A=[xParIP,yParIP,zIP]
C=[xHypIP,yHypIP,zIP]
;Q=(A-C)-total((A-C)*B) * B-total((A-C)*D)*D
;mindist=sqrt(total((Q)^2))
mindist=linesmindist(A,B,C,D,points=p)
Q=p[*,0]-p[*,1]
printf,logFileN, "minima distanza tra gli assi:",mindist
printf,logFileN, "vettore minima distanza:",Q
;qua il risultato non mi convince

if logFlag ne 0 then free_lun,logFileN

end

pro testAxisTilt
;  mx  qx  my  qy
;Parabola
mXPar=-0.000627306d ;la proiezione dell'asse sul piano xz ha eq.: x=mxPar*z+qxPar  
qXPar=-6.04868d  
mYPar=-2.12d-05 ;la proiezione dell'asse sul piano yz ha eq.: y=myPar*z+qyPar
qYPar=34.515d
;Iperbole
mxHyp=  -0.000558414d
qxHyp= -22.7985d
myHyp=-0.000116485d
qyHyp=24.3556d
zIP=100000. ;z dell'intersection plane in micron

mXerrHyp=2.263d-005 ;errori sul fit dei diversi parametri
qXerrHyp= 3.427d
mYerrHyp= 1.14d-005
qYerrHyp=1.727d
mXerrPar=2.38753d-05
qXerrPar=1.44563452d 
mYerrPar=5.8688d-07 
qYerrPar=0.03555045d

result=AxisTilt([mxPar,qxPar,myPar,qyPar], [mxHyp,qxHyp,myHyp,qyHyp],$ 
                [mxErrPar,qxErrPar,myErrPar,qyErrPar],$
                [mxErrHyp,qxErrHyp,myErrHyp,qyErrHyp],$
                 zIP,tilt=tilt,errtilt=errtilt,shift=shift,$
    errShift=errShift,parVec=vpar,parHyp=vHyp,parIP=parIP,hypIP=hypIP)
    
end

folder='E:\work\work_wfxt\rotondimetro\shell7\asse\'
file=folder+path_sep()+'fitResultsForIDL.dat'
logfile=folder+path_sep()+'fitIDL_log.txt'
parmatrix=double(read_datamatrix(file,skip=5))
zIP=100000.
result=AxisTilt(parmatrix[*,0], parmatrix[*,1],$ 
                parmatrix[*,2], parmatrix[*,3],$ 
                 zIP,tilt=tilt,errtilt=errtilt,shift=shift,$
    errShift=errShift,parVec=vpar,parHyp=vHyp,parIP=parIP,hypIP=hypIP,$
    log=logFile)
;result=AxisTilt(parmatrix[0,*], parmatrix[1,*],$ 
;                parmatrix[2,*], parmatrix[3,*],$ 
;                 zIP,tilt=tilt,errtilt=errtilt,shift=shift,$
;    errShift=errShift,parVec=vpar,parHyp=vHyp,parIP=parIP,hypIP=hypIP,$
;    log=logFile)

;voglio calcolare l'errore introdotto nell'out of roundness
angzpar=acos(vPar[2])
angzhyp=acos(vHyp[2])
D=490.
print,"contribute from parabola tilt to OOR:",D/2*(1/vPar[2]-1)*1000.,"um"
print,"contribute from hyperbola tilt to OOR:",D/2*(1/vHyp[2]-1)*1000.,"um"
zpoints=[0,100.,200.]*1000.
writecol,folder+path_sep()+'asseParFit.dat',$
      zPoints/1000.,parIP[0]+vpar[2]*vpar[0]*(zPoints-zIP),$
      parIP[1]+vpar[2]*vpar[1]*(zPoints-zIP)
writecol,folder+path_sep()+'asseHypFit.dat',$
      zPoints/1000.,hypIP[0]+vhyp[2]*vhyp[0]*(zPoints-zIP),$
      hypIP[1]+vhyp[2]*vhyp[1]*(zPoints-zIP)

end