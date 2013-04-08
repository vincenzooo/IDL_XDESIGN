function VSCcurvature,dirfom,offAxisAngleArcmin,alpha=alpha
;calcola la curvatura del piano focale secondo Van Speybroeck and Chase 1972
; la formula e' 0.055*(1+zeta)(r^2*Lp/Z0^2)(1/tan(alpha)^2)
; per ora assumo il caso zeta=0,Lp specificato come

zeta=1
if n_elements(offAxisAngleArcmin) eq 0 then offAxisAngleArcmin=getOAAngle(folder,/arcmin)
Lp=double(readNamelistVar(dirfom+path_sep()+'imp_offAxis.txt','F_HEIGHTdaImp_cm')*10.)
readcol,dirfom+path_sep()+'shellStruct.txt',alpha,format='X,X,X,X,X,F,X,X'
if n_elements(alpha) gt 1 then alpha=[min(alpha),max(alpha)]

theta=offAxisAngleArcmin*!PI/180/60
delta=0.055*(1+zeta)*Lp*(tan(theta)/tan(alpha))^2

return,delta

end