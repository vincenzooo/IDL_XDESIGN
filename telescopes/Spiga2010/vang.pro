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

function vignettingVectorsFull,a1,a0,a0s,l1,l2,phi=phi,psi=psi,sigma=sigma

  ;reinclude terms in L1 assumendo L1=L2, L1=1 con tutte le lunghezze espresse in unita' di L1
  ;  a0=atan(r0/F)
  ;  a0s=atan(r0s/F)
  if n_elements(l2) eq 0 then l2 = l1
  na1=n_elements(a1)
  goodindex=where(a1 gt 0,c)
  v_m=fltarr(na1,4)  ;will contain four types of vignetting
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


function vang,a0,a0s,thVec,Lnorm,_extra=e
  ;+
  ;plot obstruction for a shell as a function of azimuthal angle for each
  ;  of the offaxis angles in thVec. a0 and a0s are respectively 
  ;  the slopes of the shell and of the next obstructing one.
  ;  Lnorm is the normalized length of the shell L/F
  ;  
  ;- 

  setstandarddisplay
  ;nsh=n_elements(R)
  ;a0=abs(a0) 
  azang=vector(0d,!pi,100)   
  
  result=list()
  colors=plotcolors(4)
  for i=0,n_elements(thVec)-1 do begin
    window,i+1
    ;a1=0>(a0[ish]-abs(-thVec[i]*cos(azang)))
    ;a1=0>(asin(sin(thVec[i])*cos(a0[ish])*cos(azang)+cos(thVec[i])*sin(a0[ish])))
    a1=a0-thVec[i]*cos(azang)
    vig=vignettingVectors(a1,a0,a0s,Lnorm,psi=psi,phi=phi,sigma=sig)
    result.add,vig
    print,['phi=','psi=','sigma=']+string([phi,psi,sig]*180/!pi),' degrees'
    multi_plot,azang*180/!PI,vig,colors=[fsc_color('black'),colors],background=fsc_color('white'),$
    legend=['V','V1','V2','V3'],title='a0,a0*,l/F='+strjoin(string([a0,a0s,lnorm],format='(g0.3)'),', '),$
    xtitle='azimuthal angle (deg)',ytitle='Vignetting',wind=i+1,_strict_extra=e
  ;  plot,phang*180./!PI,1+vig[*,0]
  ;  plot,phang*180./!PI,1+vig[*,0]
  ;  plot,phang*180./!PI,1+vig[*,0]
  ;  plot,phang*180./!PI,1+vig[*,0]
  endfor
  
  return, result

end


function SEEJtest

  sfile='data/tests/results/config_tester_test//Feb21_test/Config001/telescope_geometry_info.dat'
  readcol,sfile,i,D,t,a,format='I,X,F,X,X,X,F,F,X,X'
  
  L=45.
  
  for ish=0,8 do begin
    r=vang(a[ish],a[ish+1],0,L/700,window=ish)
    print,(r[0])[-1,0],(r[0])[-1,1],(r[0])[-1,2],(r[0])[-1,3]
  endfor
  return,r
end

;filediam='E:\work\work_wfxt\design\WFXT2009_rescaled.txt'
;readcol,filediam,R,L,t,a0,format='(X,F,X,F,F,F,X,X,X,X,X,X,X,X,X,X)'
;this case reproduces Spiga2010, with some difference consisting in having fixed shell length here.
if n_elements(ish) eq 0 then ish=0
L=300.
F=10000.
;R=[210.0,207.5]
a0=[0.3,0.297]*!pi/180.  ;atan(R/F)/4                         ;array with all shell angles
thVec=0.25*!pi/180. ;0.02 ;[1.5]*!pi/180;vector(0,1d.5,10)    ;off axis angles, make a plot for each of them

vang,a0[ish],a0[ish+1],thVec,L/F


end