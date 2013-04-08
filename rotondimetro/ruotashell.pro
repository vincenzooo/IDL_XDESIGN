pro shellRotate,ang,rad,rotangle
;ruota le misure di rotondita' passate in <angle>,<radius>
;di un angolo rotangle


;plot,ang,rad
;oplot,[ang,ang],[!y.crange[0],!y.crange[1]],color=200
nang=n_elements(ang)
if rotangle lt 0 || rotangle gt 360 then begin
  print, "Only rotation angles in the range 0-360 are accepted" 
  stop
endif
ang=(ang-rotangle) 

negative=where(ang lt 0,complement=positive)
ang2=[ang[positive],360.+ang[negative]]
rad2=[rad[positive],rad[negative]]
;oplot,ang2,rad2,color=150
end

pro shellFlip,angle,radius,fixed=fixedpoint
;capovolge le misure du rotondita' (come se la shell fosse capovolta)
;puo' accettare in <fixed> l'angolo da tenere fisso (ce ne sara' uno solo,
;anzi due, considerando quello a 180°)

end
;lo zero del primo set di misure era a 310.8 gradi
file='D:\work\work_wfxt\rotondimetro\misure\9_wfflat_derotaz\WFFLAT03_06_joined.dat'
angolo=310.8-0.728*360 ;262.08 gradi
readcol,file,ang,rad,format='F,F',skipline=8
plot,ang,rad
shellRotate,ang,rad,60.
oplot,ang,rad,color=160  
end

;171.2-->71.6 centro rottura posizione E 