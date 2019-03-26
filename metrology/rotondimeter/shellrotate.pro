pro shellRotate,ang,rad,rotangle
;ruota le misure di rotondita' passate in <angle>,<radius>
;di un angolo rotangle. Dopo la rotazione l'angolo rotangle
;sara' sullo zero.

nang=n_elements(ang)
if rotangle lt 0 || rotangle gt 360 then begin
  print, "Only rotation angles in the range 0-360 are accepted" 
  stop
endif
ang=(ang-rotangle) 

negative=where(ang lt 0,nneg,complement=positive,ncomplement=npos)
if nneg eq 0 then return
if npos eq 0 then begin
  ang=360.+ang
  rad=rad
endif else begin
  ang=[ang[positive],360.+ang[negative]]
  rad=[rad[positive],rad[negative]]
endelse
end

pro shellFlip,angle,radius,fixed=fixedpoint
;capovolge le misure du rotondita' (come se la shell fosse capovolta)
;puo' accettare in <fixed> l'angolo da tenere fisso (ce ne sara' uno solo,
;anzi due, considerando quello a 180°)
if n_elements (fixedpoint) eq 0 then fixedpoint=0

shellRotate,angle,radius,fixedpoint
circleangle=360.
;flip intorno all'origine.
angle=circleangle-reverse(angle)
radius=reverse(radius)
shellRotate,angle,radius,-fixedpoint

end

device, decomposed =0
tek_color
loadct, 39

;lo zero del primo set di misure era a 310.8 gradi
file='D:\work\work_wfxt\rotondimetro\misure\9_wfflat_derotaz\WFFLAT03_06_joined.dat'
print,filepath('shellRotate.pro')
angolo=310.8-0.728*360 ;262.08 gradi
readcol,file,ang,rad,format='F,F',skipline=8
path=file_dirname(file,/mark_directory)
name=file_basename(file)
outfile=path+name+"_rot.dat"
plot,ang,rad
shellRotate,ang,rad,angolo
oplot,ang,rad,color=160 
shellFlip,ang,rad
oplot,ang,rad,color=200
writecol,outfile,ang,rad
end

;171.2-->71.6 centro rottura posizione E 