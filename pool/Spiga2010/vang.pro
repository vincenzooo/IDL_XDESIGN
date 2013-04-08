function vignettingVectors,a1,a0,a0s,l,phi=phi,psi=psi,sigma=sigma

  ;tolgo i termini in L1 assumendo L1=L2, L1=1 con tutte le lunghezze espresse in unita' di L1
;  a0=atan(r0/F)
;  a0s=atan(r0s/F)
  na1=n_elements(a1)
  goodindex=where(a1 gt 0,c)
  v_m=fltarr(na1,4)
  if c gt 0 then begin  ;no good elements, return 0
    
    aa=a0/a1[goodindex]
    aas=a0s/a1[goodindex]
    da0=a0-a0s
    phi=da0*(4./l+1)
    psi=da0*(4./l)
    sigma=da0*(4./l-3)
    
    V=(2*aa-1)            ;(2*a0-a1)/a1
    V1=(aa-aas)*(4./l+1)
    ;V1=phi/a1
    V2=(aa-aas)*(4./l)
    ;v2=psi/a1
    V3=(aa-aas)*(4./l-3)+2*(1-aas)
    v3=2.+(sigma-2*a0)/a1
    V_m[goodindex,*]=[[V],[V1],[V2],[V3]]
  endif 
  
  v_m=v_m>0.0
  v_m=v_m<1.0
  return,v_m
end

setstandarddisplay
;filediam='E:\work\work_wfxt\design\WFXT2009_rescaled.txt'
;readcol,filediam,R,L,t,a0,format='(X,F,X,F,F,F,X,X,X,X,X,X,X,X,X,X)'
if n_elements(ish) eq 0 then ish=0
L=300.
F=10000.
;R=[210.0,207.5]
a0=[0.3,0.297]*!pi/180.  ;atan(R/F)/4
thVec=0.25*!pi/180. ;0.02 ;[1.5]*!pi/180;vector(0,1d.5,10)

nsh=n_elements(R)
a0=abs(a0)
azang=vector(0d,!pi,100)

colors=plotcolors(4)
for i=0,n_elements(thVec)-1 do begin
  window,i+1
  ;a1=0>(a0[ish]-abs(-thVec[i]*cos(azang)))
  ;a1=0>(asin(sin(thVec[i])*cos(a0[ish])*cos(azang)+cos(thVec[i])*sin(a0[ish])))
  a1=a0[ish]-thVec[i]*cos(azang)
  vig=vignettingVectors(a1,a0[ish],a0[ish+1],L/F,psi=psi,phi=phi,sigma=sig)
  print,['phi=','psi=','sigma=']+string([phi,psi,sig]*180/!pi),' degrees'
  multiplot,azang*180/!PI,vig,colors=[fsc_color('black'),colors],background=fsc_color('white'),$
  legend=['V','V1','V2','V3'],title='a0,a0*,l='+strjoin(string([a0[ish],a0[ish+1],l/F],format='(g0.3)'),', '),$
  xtitle='azimuthal angle (deg)',ytitle='Vignetting'
;  plot,phang*180./!PI,1+vig[*,0]
;  plot,phang*180./!PI,1+vig[*,0]
;  plot,phang*180./!PI,1+vig[*,0]
;  plot,phang*180./!PI,1+vig[*,0]
endfor



end