pro suppressedRadiusPlot,xx,yy,rsuppressed,polar=polar,center=center,$
    expansion=expansion,_extra=e,rout=r,psiout=psi,nosquare,oplot=oplot
    
    if n_elements(center) eq 0 then center= [0.,0.]
    if keyword_set(polar) then begin
      ;convert from polar (r,psi) to cartesian
      x=xx*cos(yy)
      y=xx*sin(yy)
    endif else begin
      x=xx
      y=yy
    endelse
    
    ;convert to polar coordinates
    psi=atan((y-center[0]),(x-center[1])) ;atan((y),(x-realxc))
    r=sqrt((x-center[0])^2+(y-center[1])^2)-rsuppressed ;sqrt((x-realxc)^2+(y)^2)
    
    rnegative=where(r lt 0,c,complement=rpos,ncomplement=cpos) 
    if c ne 0 then begin
       print,'suppressedRadiusPlot.pro WARNING:'+newline()+$
        'There are ',c,' values with radius smaller then the suppressed radius,'+$
        newline()+' they will not be plotted'
        if cpos eq 0 then goto, out else r=r[rpos]
    endif 
    
    if keyword_set(nosquare) eq 0 then begin
      range=squarerange(r,psi,/polar,expansion=expansion)
      xrange=range[0:1]
      yrange=range[2:3]
      isotropic=1
    endif 
    if keyword_set(oplot) then oplot,r,psi,/polar,_strict_extra=e $
    else plot,r,psi,xrange=xrange,yrange=yrange,isotropic=isotropic,/polar,_strict_extra=e
    out:
end